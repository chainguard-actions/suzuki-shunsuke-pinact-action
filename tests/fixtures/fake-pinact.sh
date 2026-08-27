#!/bin/sh
# Fake pinact binary for testing.
# Simulates pinact v4.1.1 behavior without network access.
#
# Exit codes (matching real pinact v4):
#   0 = all actions are pinned / fixed successfully
#   1 = actions aren't pinned (check mode, auto-fixable)
#   2 = problems that can't be fixed automatically
#   3 = GitHub API error or internal error

# Handle version flag
case "$1" in
  -v|--version|version)
    echo "pinact version v4.1.1 (fake)"
    exit 0
    ;;
esac

# Handle "run" subcommand
if [ "$1" = "run" ]; then
  shift
  # Parse flags
  fix=true
  includes=""
  while [ $# -gt 0 ]; do
    case "$1" in
      --fix)
        fix=true
        shift
        ;;
      --fix=false)
        fix=false
        shift
        ;;
      --no-api|--update|--verify|--verify-min-age)
        shift
        ;;
      --include)
        includes="$includes $2"
        shift 2
        ;;
      --min-age|--separator|--exclude|--branch-to-tag|--config|--diff-file|--format)
        shift 2
        ;;
      *)
        shift
        ;;
    esac
  done

  # Check each included file for pinned actions.
  # A pinned action has a 40-char hex SHA after @.
  all_pinned=true
  for f in $includes; do
    if [ -f "$f" ]; then
      # Read file line by line looking for uses: lines with non-SHA refs
      while IFS= read -r line; do
        case "$line" in
          *uses:*@*)
            # Extract the part after the last @
            after_at="${line##*@}"
            # Remove everything after first space or # (comment)
            ref="${after_at%% *}"
            ref="${ref%%#*}"
            # Strip whitespace
            ref="$(printf '%s' "$ref" | tr -d ' \t\r')"
            # Check if it's a 40-char hex SHA
            len="$(printf '%s' "$ref" | wc -c | tr -d ' ')"
            if [ "$len" -eq 40 ]; then
              # Verify it's hex
              nonhex="$(printf '%s' "$ref" | tr -d '0-9a-fA-F')"
              if [ -z "$nonhex" ]; then
                : # pinned with SHA, OK
              else
                all_pinned=false
              fi
            else
              all_pinned=false
            fi
            ;;
        esac
      done < "$f"
    fi
  done

  if $all_pinned; then
    echo "pinact: all actions are pinned"
    exit 0
  else
    if $fix; then
      # In fix mode, pretend to fix the files
      echo "pinact: fixed unpinned actions (fake - no actual changes made)"
      exit 0
    else
      echo "pinact: GitHub Actions aren't pinned."
      exit 1
    fi
  fi
fi

# Unknown command
echo "pinact: unknown command: $*" >&2
exit 1
