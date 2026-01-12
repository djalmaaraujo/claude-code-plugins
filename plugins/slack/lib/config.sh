#!/bin/bash
#
# Slack Plugin - Shared Config Loader
# Used by all Slack skills to load centralized configuration
#

get_plugin_root() {
  echo "$HOME/.claude/plugins/marketplaces/djalmaaraujo-claude-code-plugins/plugins/slack"
}

get_config_path() {
  echo "$(get_plugin_root)/config.json"
}

config_exists() {
  local config_path="$(get_config_path)"
  [ -f "$config_path" ]
}

load_config() {
  local config_path="$(get_config_path)"

  if [ ! -f "$config_path" ]; then
    echo "Error: Config file not found at $config_path" >&2
    return 1
  fi

  # Export config values as environment variables
  export SLACK_WORKSPACE=$(jq -r '.workspace' "$config_path")
  export SLACK_TOKEN=$(jq -r '.token' "$config_path")
  export SLACK_COOKIE=$(jq -r '.cookie' "$config_path")

  # Validate required fields
  if [ "$SLACK_WORKSPACE" = "null" ] || [ -z "$SLACK_WORKSPACE" ]; then
    echo "Error: Missing workspace in config" >&2
    return 1
  fi

  if [ "$SLACK_TOKEN" = "null" ] || [ -z "$SLACK_TOKEN" ]; then
    echo "Error: Missing token in config" >&2
    return 1
  fi

  if [ "$SLACK_COOKIE" = "null" ] || [ -z "$SLACK_COOKIE" ]; then
    echo "Error: Missing cookie in config" >&2
    return 1
  fi

  return 0
}

get_cache_size() {
  local config_path="$(get_config_path)"
  jq '.users | length' "$config_path"
}

save_config() {
  local config_path="$(get_config_path)"
  local workspace="$1"
  local token="$2"
  local cookie="$3"

  cat > "$config_path" << EOF
{
  "workspace": "$workspace",
  "token": "$token",
  "cookie": "$cookie",
  "users": [],
  "setup_date": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "last_validated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF

  chmod 600 "$config_path"
}
