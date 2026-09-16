#!/usr/bin/env bash
# Verify every URL the live site publishes still resolves in a local build,
# and that redirect stubs actually redirect somewhere real.
#
# For each URL in the expected-urls file:
#   1. Confirm the rendered file exists (public/<url>/index.html).
#   2. If redirect-map.tsv lists that URL as an old_path, confirm the file
#      is a Hugo alias stub (meta-refresh) whose target matches the map's
#      canonical_destination, and that the destination itself resolves.
#   3. Confirm no canonical destination is itself a redirect stub (no
#      redirect chains) and that the map has no conflicting entries.
#
# Usage: ./scripts/check-urls.sh [public_dir] [expected_urls_file] [redirect_map_file]
set -uo pipefail

PUBLIC="${1:-public}"
EXPECTED="${2:-$(dirname "$0")/expected-urls.txt}"
MAP="${3:-$(dirname "$0")/redirect-map.tsv}"
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

if [ ! -f "$MAP" ]; then
  echo "ERROR: redirect map file not found: $MAP" >&2
  exit 1
fi

# --- Load the redirect map, guarding against data-hygiene bugs that would
# silently defeat the checks below (a stale duplicate entry, or a map that
# redirects through itself). Comment (#) and blank lines are skipped.
declare -A dest_of      # old_path -> canonical_destination
declare -A is_dest      # canonical_destination -> 1 (set membership)
map_rows=0

while IFS=$'\t' read -r old dest || [ -n "${old:-}" ]; do
  [ -z "${old:-}" ] && continue
  case "$old" in \#*) continue ;; esac
  if [ -z "${dest:-}" ]; then
    echo "ERROR: malformed redirect-map row (missing destination): $old" >&2
    exit 1
  fi
  map_rows=$((map_rows + 1))
  if [ -n "${dest_of[$old]+x}" ] && [ "${dest_of[$old]}" != "$dest" ]; then
    echo "ERROR: redirect-map conflict: $old maps to both '${dest_of[$old]}' and '$dest'" >&2
    exit 1
  fi
  dest_of["$old"]="$dest"
  is_dest["$dest"]=1
done < "$MAP"

if [ "$map_rows" -eq 0 ]; then
  echo "ERROR: $MAP has no redirect rows to check" >&2
  exit 1
fi

# No old_path may itself be used as a canonical destination elsewhere in the
# map (that would be a redirect chain: old -> old2 -> dest).
for old in "${!dest_of[@]}"; do
  if [ -n "${is_dest[$old]+x}" ]; then
    echo "ERROR: redirect-map chain: '$old' is both an old_path and a canonical destination" >&2
    exit 1
  fi
done

# A file is a Hugo alias stub if it carries a meta-refresh — Hugo's default
# alias template's one distinguishing, minify-safe marker.
is_stub() {
  grep -Eqi 'http-equiv=.{0,3}refresh' "$1" 2>/dev/null
}

# Pull the redirect target out of content="0; url=...". Strips scheme+host
# so absolute and relative meta-refresh targets both compare as paths.
stub_target() {
  grep -oE 'url=[^">]*' "$1" 2>/dev/null | head -1 | cut -d= -f2- | sed -E 's#^https?://[^/]+##'
}

while IFS= read -r url || [ -n "$url" ]; do
  [ -z "$url" ] && continue
  candidate="${PUBLIC}${url}index.html"

  if [ ! -f "$candidate" ]; then
    echo "MISSING: $url"
    fail=$((fail + 1))
    continue
  fi

  if [ -n "${dest_of[$url]+x}" ]; then
    # This URL is an old_path in the map: it must be a working redirect.
    dest="${dest_of[$url]}"
    if ! is_stub "$candidate"; then
      echo "NOT A REDIRECT: $url exists but has no meta-refresh (map expects -> $dest)"
      fail=$((fail + 1))
      continue
    fi
    target="$(stub_target "$candidate")"
    if [ "$target" != "$dest" ]; then
      echo "REDIRECT MISMATCH: $url points to '$target', map expects '$dest'"
      fail=$((fail + 1))
      continue
    fi
    dest_candidate="${PUBLIC}${dest}index.html"
    if [ ! -f "$dest_candidate" ]; then
      echo "REDIRECT DESTINATION MISSING: $url -> $dest (not found in build output)"
      fail=$((fail + 1))
      continue
    fi
    if is_stub "$dest_candidate"; then
      echo "REDIRECT CHAIN: $url -> $dest, but $dest is itself a redirect stub"
      fail=$((fail + 1))
      continue
    fi
    continue
  fi

  if [ -n "${is_dest[$url]+x}" ] && is_stub "$candidate"; then
    echo "CANONICAL IS A STUB: $url is a redirect destination in the map but redirects itself"
    fail=$((fail + 1))
    continue
  fi
done < "$EXPECTED"

echo "----"
echo "$((total - fail))/$total expected URLs resolve"
[ "$fail" -eq 0 ] || echo "FAIL: $fail missing"
exit $((fail > 0))
