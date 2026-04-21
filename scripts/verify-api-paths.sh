#!/usr/bin/env bash
set -euo pipefail

# Verify that API paths referenced in skills match the OpenAPI spec.
#
# Usage:
#   ./scripts/verify-api-paths.sh [openapi-url-or-path]
#
# Default: fetches the spec from the mobazha_hosting repo on GitHub.

OPENAPI_SOURCE="${1:-https://raw.githubusercontent.com/mobazha/mobazha_hosting/master/api/docs/openapi.yaml}"
SKILLS_DIR="$(cd "$(dirname "$0")/../skills" && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo "=== Mobazha Skills API Path Verifier ==="
echo ""

# Download or read the OpenAPI spec
TMPSPEC=$(mktemp)
trap 'rm -f "$TMPSPEC" "$TMPSPEC.paths"' EXIT

if [[ "$OPENAPI_SOURCE" == http* ]]; then
  echo "Fetching OpenAPI spec from: $OPENAPI_SOURCE"
  if ! curl -fsSL "$OPENAPI_SOURCE" -o "$TMPSPEC" 2>/dev/null; then
    echo -e "${YELLOW}WARNING: Could not fetch OpenAPI spec. Skipping path verification.${NC}"
    exit 0
  fi
else
  if [[ ! -f "$OPENAPI_SOURCE" ]]; then
    echo -e "${YELLOW}WARNING: OpenAPI spec not found at $OPENAPI_SOURCE. Skipping.${NC}"
    exit 0
  fi
  cp "$OPENAPI_SOURCE" "$TMPSPEC"
fi

# Extract all paths from the OpenAPI spec (lines matching "^  /...")
grep -oE '^\s{2}/[a-zA-Z0-9_./{}-]+' "$TMPSPEC" | sed 's/^ *//' | sort -u > "$TMPSPEC.paths"

spec_count=$(wc -l < "$TMPSPEC.paths" | tr -d ' ')
echo "Found $spec_count paths in OpenAPI spec"
echo ""

# Extract API paths from skill markdown files
# Match patterns like: GET /v1/..., POST /v1/..., PUT /v1/..., DELETE /v1/...
# Also match bare paths in code blocks: /v1/..., /platform/v1/...
errors=0
warnings=0
checked=0

for skill_dir in "$SKILLS_DIR"/*/; do
  skill_name=$(basename "$skill_dir")
  
  # Find all .md files in the skill directory (including references/)
  while IFS= read -r -d '' mdfile; do
    # Extract API paths from the markdown file
    # Pattern 1: HTTP method + path (e.g., "GET /v1/listings")
    # Pattern 2: Bare path in context (e.g., "/v1/system/setup" or "/platform/v1/auth/tokens")
    paths=$(grep -oE '(GET|POST|PUT|DELETE|PATCH)\s+/[a-zA-Z0-9_./-]+' "$mdfile" 2>/dev/null | \
            sed 's/^[A-Z]* //' || true)
    
    # Also check for paths in curl commands or standalone references
    bare_paths=$(grep -oE '/(v1|platform/v1)/[a-zA-Z0-9_./-]+' "$mdfile" 2>/dev/null | \
                 sort -u || true)
    
    all_paths=$(echo -e "$paths\n$bare_paths" | sort -u | grep -v '^$' || true)
    
    if [[ -z "$all_paths" ]]; then
      continue
    fi
    
    while IFS= read -r api_path; do
      [[ -z "$api_path" ]] && continue
      checked=$((checked + 1))
      
      # Normalize: remove trailing slashes, query params
      normalized=$(echo "$api_path" | sed 's/\/$//' | sed 's/\?.*//')
      
      # Convert path params like {id} to regex-friendly patterns
      # Check if the path exists in the spec (exact or parameterized match)
      pattern=$(echo "$normalized" | sed 's/[^/]*$//' )
      
      if grep -qF "$normalized" "$TMPSPEC.paths" 2>/dev/null; then
        # Exact match
        :
      elif echo "$normalized" | grep -qE '\{' 2>/dev/null; then
        # Path has template params, skip (user-facing docs may use <placeholder>)
        :
      elif grep -q "$(echo "$normalized" | sed 's|/[^/]*$||')" "$TMPSPEC.paths" 2>/dev/null; then
        # Parent path exists (e.g., /v1/listings exists for /v1/listings/my-slug)
        :
      else
        # Check if it's a platform path (MCP-related, may not be in the main OpenAPI spec)
        if echo "$normalized" | grep -q "^/platform/" 2>/dev/null; then
          warnings=$((warnings + 1))
          echo -e "${YELLOW}WARN${NC}: $skill_name — $normalized (platform path, not in OpenAPI spec)"
        else
          errors=$((errors + 1))
          echo -e "${RED}FAIL${NC}: $skill_name — $normalized (not found in OpenAPI spec)"
          echo "       File: $(basename "$mdfile")"
        fi
      fi
    done <<< "$all_paths"
    
  done < <(find "$skill_dir" -name '*.md' -print0)
done

echo ""
echo "=== Results ==="
echo "Paths checked: $checked"
echo -e "Matched: $((checked - errors - warnings))"
if [[ $warnings -gt 0 ]]; then
  echo -e "${YELLOW}Warnings: $warnings${NC} (platform paths not in main spec)"
fi
if [[ $errors -gt 0 ]]; then
  echo -e "${RED}Failures: $errors${NC}"
  echo ""
  echo "These API paths in skills do not match the OpenAPI spec."
  echo "Either the skill has an incorrect path, or the spec needs updating."
  exit 1
else
  echo -e "${GREEN}All API paths verified!${NC}"
fi
