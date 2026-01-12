#!/bin/bash
#
# Slack User Cache Utilities
# Helper script for cache inspection and management
#
# Usage:
#   ./cache-utils.sh count              - Count total cached users
#   ./cache-utils.sh list               - List all cached users
#   ./cache-utils.sh search <pattern>   - Search users by partial name
#   ./cache-utils.sh clear              - Clear the cache

PLUGIN_ROOT="$HOME/.claude/plugins/marketplaces/djalmaaraujo-claude-code-plugins/plugins/slack"
source "$PLUGIN_ROOT/lib/config.sh"

CONFIG_PATH="$(get_config_path)"

# Validate config exists
if [ ! -f "$CONFIG_PATH" ]; then
  echo "Error: Config file not found at $CONFIG_PATH" >&2
  exit 1
fi

case "$1" in
  count)
    COUNT=$(jq '.users | length' "$CONFIG_PATH")
    echo "Total cached users: $COUNT"
    ;;

  list)
    echo "Cached users:"
    echo "============="
    jq -r '.users[] | "\(.name) - \(.real_name) (\(.display_name))"' "$CONFIG_PATH"
    ;;

  search)
    if [ -z "$2" ]; then
      echo "Usage: $0 search <pattern>" >&2
      exit 1
    fi

    PATTERN="$2"
    echo "Users matching '$PATTERN':"
    echo "========================="
    jq -r --arg query "$PATTERN" '.users[] | select(
      (.name | ascii_downcase | contains($query | ascii_downcase)) or
      (.real_name | ascii_downcase | contains($query | ascii_downcase)) or
      (.display_name | ascii_downcase | contains($query | ascii_downcase))
    ) | "\(.name) - \(.real_name) (\(.id))"' "$CONFIG_PATH"
    ;;

  clear)
    echo "Clearing user cache..."
    jq '.users = []' "$CONFIG_PATH" > /tmp/slack-cache.tmp && mv /tmp/slack-cache.tmp "$CONFIG_PATH"
    echo "✓ Cache cleared"
    ;;

  *)
    echo "Slack User Cache Utilities"
    echo ""
    echo "Usage:"
    echo "  $0 count              - Count total cached users"
    echo "  $0 list               - List all cached users"
    echo "  $0 search <pattern>   - Search users by partial name"
    echo "  $0 clear              - Clear the cache"
    echo ""
    exit 1
    ;;
esac
