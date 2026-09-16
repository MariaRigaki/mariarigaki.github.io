#!/usr/bin/env bash
# Verify every URL the live site publishes still resolves in a local build.
# Usage: ./scripts/check-urls.sh [public_dir]
set -uo pipefail

PUBLIC="${1:-public}"
EXPECTED="$(dirname "$0")/expected-urls.txt"
fail=0

if [ ! -f "$EXPECTED" ]; then
  echo "ERROR: expected URLs file not found: $EXPECTED" >&2
  exit 1
fi

total=$(grep -cve '^\s*$' "$EXPECTED")
if [ "$total" -eq 0 ]; then
  echo "ERROR: $EXPECTED has no URLs to check" >&2
  exit 1
fi

while IFS= read -r url || [ -n "$url" ]; do
  [ -z "$url" ] && continue
  # A URL resolves if the path exists as a rendered page, or if some page
  # declares it as an alias (Hugo renders aliases as redirect stubs).
  candidate="${PUBLIC}${url}index.html"
  if [ -f "$candidate" ]; then
    continue
  fi
  echo "MISSING: $url"
  fail=$((fail + 1))
done < "$EXPECTED"

echo "----"
echo "$((total - fail))/$total expected URLs resolve"
[ "$fail" -eq 0 ] || echo "FAIL: $fail missing"
exit $((fail > 0))
