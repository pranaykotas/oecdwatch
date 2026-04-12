#!/usr/bin/env bash
# check_oecd.sh — look for new OECD semiconductor publications.
#
# Strategy: query the OECD iLibrary search API for "semiconductor", pull
# recent results, and diff against data/known_publications.txt. Any new
# titles are printed to stdout (and, in CI, fed to gh CLI to open an issue).
#
# Run locally:
#   bash scripts/check_oecd.sh
#
# The script is intentionally dependency-light: curl + grep/sed + sort.
# It does not try to parse the HTML rigorously — the OECD iLibrary search
# page exposes result titles in a predictable structure, and a fuzzy match
# is enough for an alert. False positives are cheap (one extra issue);
# false negatives are the real risk, so we err toward over-matching.

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
KNOWN_FILE="$REPO_ROOT/data/known_publications.txt"

# Ensure the known file exists
mkdir -p "$(dirname "$KNOWN_FILE")"
touch "$KNOWN_FILE"

# OECD iLibrary search URL for semiconductor content, sorted newest first
SEARCH_URL="https://www.oecd-ilibrary.org/search?value1=semiconductor&option1=fulltext&sortDescending=true&sortField=prism_publicationDate"

echo "Checking OECD iLibrary for new semiconductor publications..." >&2

# Fetch the search results page. Use a friendly User-Agent.
HTML=$(curl -sSL \
  -A "OECDWatch-Checker/1.0 (https://github.com/pranaykotas/oecdwatch)" \
  "$SEARCH_URL" || true)

if [[ -z "$HTML" ]]; then
  echo "ERROR: empty response from OECD iLibrary" >&2
  exit 1
fi

# Extract candidate result titles. The iLibrary markup uses class names
# like "result-item-title" or similar — we grep broadly and clean up.
# Output one normalised title per line.
TITLES=$(echo "$HTML" \
  | grep -oE '<h[0-9][^>]*class="[^"]*result[^"]*title[^"]*"[^>]*>[^<]*' \
  | sed -E 's/<[^>]+>//g' \
  | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//' \
  | awk 'NF > 0' \
  | sort -u)

if [[ -z "$TITLES" ]]; then
  # Fallback: look for any link text around "/docserver/" or "/reader/" URLs
  TITLES=$(echo "$HTML" \
    | grep -oE '<a[^>]*href="[^"]*oecd-ilibrary[^"]*"[^>]*>[^<]+' \
    | sed -E 's/<[^>]+>//g' \
    | grep -iE 'semiconductor|chip' \
    | sort -u || true)
fi

if [[ -z "$TITLES" ]]; then
  echo "WARN: could not extract any titles from the search page." >&2
  echo "This may mean the iLibrary markup has changed. Inspect manually: $SEARCH_URL" >&2
  exit 0
fi

# Diff against known file
NEW_TITLES=$(comm -23 <(echo "$TITLES" | sort -u) <(sort -u "$KNOWN_FILE") || true)

if [[ -z "$NEW_TITLES" ]]; then
  echo "No new OECD semiconductor publications detected." >&2
  exit 0
fi

echo "New OECD semiconductor publications detected:" >&2
echo "$NEW_TITLES" | while IFS= read -r title; do
  echo "  - $title" >&2
  echo "$title" >> "$KNOWN_FILE"
done

# Print new titles to stdout so the CI wrapper can use them
echo "$NEW_TITLES"
