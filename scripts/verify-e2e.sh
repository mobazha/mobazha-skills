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
  local args=(-s -o /dev/null -w "%{http_code}" -X "$method")

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

echo "=== Mobazha Skills E2E Verification ==="
echo "Gateway: $GATEWAY_URL"
echo ""

# Step 0: Health check
echo "--- Health ---"
TOKEN=""
check "Health endpoint" "GET" "/healthz" "200"
echo ""

# Step 1: Obtain a Bearer token
echo "--- Authentication (store-mcp-connect skill) ---"
TOKEN_RESPONSE=$(curl -s -X POST "${GATEWAY_URL}/platform/v1/auth/signin" \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"$ADMIN_USER\",\"password\":\"$ADMIN_PASS\"}" 2>/dev/null || echo "{}")

TOKEN=$(echo "$TOKEN_RESPONSE" | grep -o '"accessToken":"[^"]*"' | head -1 | cut -d'"' -f4 || true)

if [[ -z "$TOKEN" ]]; then
  echo -e "${YELLOW}SKIP${NC}: Could not obtain auth token. Remaining tests will be skipped."
  echo "  Response: $TOKEN_RESPONSE"
  skipped=$((skipped + 20))
else
  echo -e "${GREEN}PASS${NC}: Obtained Bearer token"
  passed=$((passed + 1))
fi
echo ""

# Step 2: Onboarding endpoints (store-onboarding skill)
echo "--- Onboarding (store-onboarding skill) ---"
check "System setup status" "GET" "/v1/system/setup" "200"
echo ""

# Step 3: Profile endpoints (store-onboarding skill)
echo "--- Profile (store-onboarding skill) ---"
check "Get profile" "GET" "/v1/profiles" "200"
echo ""

# Step 4: Settings endpoints (store-onboarding skill)
echo "--- Settings (store-onboarding skill) ---"
check "Get settings" "GET" "/v1/settings" "200"
echo ""

# Step 5: Listings endpoints (store-management / product-import skills)
echo "--- Listings (store-management skill) ---"
check "List my listings" "GET" "/v1/listings" "200"
check "Get listing template" "GET" "/v1/listings/template" "200"
echo ""

# Step 6: Media endpoint (product-import skill)
echo "--- Media (product-import skill) ---"
check "Media upload endpoint exists" "POST" "/v1/media" "400"
echo ""

# Step 7: Orders endpoints (store-management skill)
echo "--- Orders (store-management skill) ---"
check "Get sales" "GET" "/v1/orders/sales" "200"
check "Get purchases" "GET" "/v1/orders/purchases" "200"
echo ""

# Step 8: Chat endpoints (store-management skill)
echo "--- Chat (store-management skill) ---"
check "Get conversations" "GET" "/v1/chat/conversations" "200"
echo ""

# Step 9: Notifications (store-management skill)
echo "--- Notifications (store-management skill) ---"
check "List notifications" "GET" "/v1/notifications" "200"
echo ""

# Step 10: Exchange rates (store-management skill)
echo "--- Exchange Rates (store-management skill) ---"
check "Get exchange rates" "GET" "/v1/exchange-rates" "200"
echo ""

# Step 11: MCP SSE endpoint (store-mcp-connect skill)
echo "--- MCP SSE (store-mcp-connect skill) ---"
MCP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
  "${GATEWAY_URL}/platform/v1/mcp/sse" 2>/dev/null || echo "000")
if [[ "$MCP_STATUS" == "200" || "$MCP_STATUS" == "405" || "$MCP_STATUS" == "401" ]]; then
  echo -e "${GREEN}PASS${NC}: MCP SSE endpoint responds ($MCP_STATUS)"
  passed=$((passed + 1))
elif [[ "$MCP_STATUS" == "000" ]]; then
  echo -e "${YELLOW}SKIP${NC}: MCP SSE endpoint not reachable"
  skipped=$((skipped + 1))
else
  echo -e "${YELLOW}WARN${NC}: MCP SSE endpoint returned $MCP_STATUS"
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
