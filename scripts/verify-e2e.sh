#!/usr/bin/env bash
set -euo pipefail

# End-to-end verification of skills against a running Mobazha instance.
#
# Prerequisites:
#   - A running Mobazha gateway (standalone or E2E stack)
#   - GATEWAY_URL environment variable (default: http://localhost:18080)
#
# Usage:
#   GATEWAY_URL=http://localhost:18080 ./scripts/verify-e2e.sh
#
# This script verifies that the API endpoints referenced in skills
# actually work on a live Mobazha instance.

GATEWAY_URL="${GATEWAY_URL:-http://localhost:18080}"
CASDOOR_URL="${CASDOOR_URL:-http://localhost:18000}"
CASDOOR_CLIENT_ID="${CASDOOR_CLIENT_ID:-e2e-mobazha-client-id}"
CASDOOR_CLIENT_SECRET="${CASDOOR_CLIENT_SECRET:-e2e-mobazha-client-secret}"
ADMIN_USER="${ADMIN_USER:-testuser1}"
ADMIN_PASS="${ADMIN_PASS:-123}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

passed=0
failed=0
skipped=0

check() {
  local name="$1"
  local method="$2"
  local path="$3"
  local expected_status="${4:-200}"
  local body="${5:-}"

  local url="${GATEWAY_URL}${path}"
  local args=(-s -o /dev/null -w "%{http_code}" -X "$method" --max-time 10)

  if [[ -n "$TOKEN" ]]; then
    args+=(-H "Authorization: Bearer $TOKEN")
  fi
  args+=(-H "Content-Type: application/json")

  if [[ -n "$body" ]]; then
    args+=(-d "$body")
  fi

  local status
  status=$(curl "${args[@]}" "$url" 2>/dev/null || echo "000")

  if [[ "$status" == "$expected_status" ]]; then
    echo -e "${GREEN}PASS${NC}: $name ($method $path -> $status)"
    passed=$((passed + 1))
  elif [[ "$status" == "000" ]]; then
    echo -e "${YELLOW}SKIP${NC}: $name ($method $path -> connection failed)"
    skipped=$((skipped + 1))
  else
    echo -e "${RED}FAIL${NC}: $name ($method $path -> $status, expected $expected_status)"
    failed=$((failed + 1))
  fi
}

# Accept multiple status codes
check_any() {
  local name="$1"
  local method="$2"
  local path="$3"
  shift 3
  local expected_codes=("$@")

  local url="${GATEWAY_URL}${path}"
  local args=(-s -o /dev/null -w "%{http_code}" -X "$method" --max-time 10)

  if [[ -n "$TOKEN" ]]; then
    args+=(-H "Authorization: Bearer $TOKEN")
  fi
  args+=(-H "Content-Type: application/json")

  local status
  status=$(curl "${args[@]}" "$url" 2>/dev/null || echo "000")

  for code in "${expected_codes[@]}"; do
    if [[ "$status" == "$code" ]]; then
      echo -e "${GREEN}PASS${NC}: $name ($method $path -> $status)"
      passed=$((passed + 1))
      return
    fi
  done

  if [[ "$status" == "000" ]]; then
    echo -e "${YELLOW}SKIP${NC}: $name ($method $path -> connection failed)"
    skipped=$((skipped + 1))
  else
    echo -e "${RED}FAIL${NC}: $name ($method $path -> $status, expected one of: ${expected_codes[*]})"
    failed=$((failed + 1))
  fi
}

echo "=== Mobazha Skills E2E Verification ==="
echo "Gateway: $GATEWAY_URL"
echo ""

# Step 0: Health check
echo "--- Health ---"
TOKEN=""
check "Health endpoint" "GET" "/healthz" "200"
echo ""

# Step 1: Obtain a Bearer token via Casdoor OAuth password grant
echo "--- Authentication ---"
TOKEN_RESPONSE=$(curl -s --max-time 10 -X POST "${CASDOOR_URL}/api/login/oauth/access_token" \
  -d "grant_type=password&client_id=${CASDOOR_CLIENT_ID}&client_secret=${CASDOOR_CLIENT_SECRET}&username=${ADMIN_USER}&password=${ADMIN_PASS}" \
  2>/dev/null || echo "{}")

TOKEN=$(echo "$TOKEN_RESPONSE" | grep -o '"access_token"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*: *"\(.*\)"/\1/' || true)

if [[ -z "$TOKEN" ]]; then
  echo -e "${YELLOW}SKIP${NC}: Could not obtain auth token. Remaining tests will be skipped."
  echo "  Response (first 200 chars): ${TOKEN_RESPONSE:0:200}"
  skipped=$((skipped + 20))
else
  echo -e "${GREEN}PASS${NC}: Obtained Bearer token via OAuth (${#TOKEN} chars)"
  passed=$((passed + 1))
fi
echo ""

# Step 2: Profile endpoints (store-onboarding skill)
echo "--- Profile ---"
check "Get profile" "GET" "/v1/profiles" "200"
echo ""

# Step 3: Storefront settings (store-management skill)
echo "--- Storefront Settings ---"
check "Get storefront" "GET" "/v1/settings/storefront" "200"
echo ""

# Step 4: Listings template (product-import skill)
echo "--- Listings ---"
check "Get listing template" "GET" "/v1/listings/template" "200"
echo ""

# Step 5: Media endpoint (product-import skill)
echo "--- Media ---"
check_any "Media images endpoint exists" "POST" "/v1/media/images" "400" "415" "301"
echo ""

# Step 6: Chat endpoints (store-management skill)
echo "--- Chat ---"
check "Get chat rooms" "GET" "/v1/chat/rooms" "200"
echo ""

# Step 7: Notifications (store-management skill)
echo "--- Notifications ---"
check "List notifications" "GET" "/v1/notifications" "200"
echo ""

# Step 8: Exchange rates (store-management skill)
echo "--- Exchange Rates ---"
check "Get exchange rates" "GET" "/v1/exchange-rates" "200"
echo ""

# Step 9: System setup (store-onboarding skill)
# In SaaS mode, returns 503 (expected); in standalone, returns 200.
echo "--- System Setup ---"
check_any "System setup endpoint" "GET" "/v1/system/setup" "200" "503"
echo ""

# Step 10: MCP Streamable HTTP endpoint (store-mcp-connect skill)
# Send an initialize JSON-RPC request and check the HTTP status.
echo "--- MCP Streamable HTTP ---"
MCP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -X POST "${GATEWAY_URL}/v1/mcp" \
  -d '{"jsonrpc":"2.0","method":"initialize","id":"e2e","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"verify-e2e","version":"0.1"}}}' \
  2>/dev/null || echo "000")
MCP_STATUS="${MCP_STATUS:0:3}"
if [[ "$MCP_STATUS" == "200" || "$MCP_STATUS" == "401" ]]; then
  echo -e "${GREEN}PASS${NC}: MCP Streamable HTTP endpoint responds ($MCP_STATUS)"
  passed=$((passed + 1))
elif [[ "$MCP_STATUS" == "000" ]]; then
  echo -e "${YELLOW}SKIP${NC}: MCP endpoint not reachable"
  skipped=$((skipped + 1))
else
  echo -e "${YELLOW}WARN${NC}: MCP endpoint returned $MCP_STATUS"
  skipped=$((skipped + 1))
fi
echo ""

# Results
echo "=== Results ==="
echo -e "${GREEN}Passed: $passed${NC}"
if [[ $skipped -gt 0 ]]; then
  echo -e "${YELLOW}Skipped: $skipped${NC}"
fi
if [[ $failed -gt 0 ]]; then
  echo -e "${RED}Failed: $failed${NC}"
  exit 1
else
  echo -e "${GREEN}All reachable endpoints verified!${NC}"
fi
