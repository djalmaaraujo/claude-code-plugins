#!/bin/bash
#
# Slack Plugin - Shared API Functions
# Common functions for making Slack API calls
#

# Source config loader - use PLUGIN_ROOT if set, otherwise determine from this script's location
if [ -z "$PLUGIN_ROOT" ]; then
  PLUGIN_ROOT="$HOME/.claude/plugins/marketplaces/djalmaaraujo-claude-code-plugins/plugins/slack"
fi
source "$PLUGIN_ROOT/lib/config.sh"

slack_api_call() {
  local endpoint="$1"
  shift

  # Ensure config is loaded
  if [ -z "$SLACK_WORKSPACE" ] || [ -z "$SLACK_TOKEN" ] || [ -z "$SLACK_COOKIE" ]; then
    load_config || return 1
  fi

  curl -s -X POST "https://${SLACK_WORKSPACE}/api/${endpoint}" \
    -H "Authorization: Bearer ${SLACK_TOKEN}" \
    -H "Content-type: application/x-www-form-urlencoded" \
    -b "d=${SLACK_COOKIE}" \
    "$@"
}

slack_auth_test() {
  slack_api_call "auth.test"
}

slack_users_list() {
  local cursor="$1"
  local limit="${2:-1000}"

  if [ -n "$cursor" ]; then
    slack_api_call "users.list" \
      --data-urlencode "limit=${limit}" \
      --data-urlencode "cursor=${cursor}"
  else
    slack_api_call "users.list" \
      --data-urlencode "limit=${limit}"
  fi
}

slack_conversations_open() {
  local user_id="$1"

  slack_api_call "conversations.open" \
    --data-urlencode "users=${user_id}"
}

slack_chat_post_message() {
  local channel="$1"
  local text="$2"

  slack_api_call "chat.postMessage" \
    --data-urlencode "channel=${channel}" \
    --data-urlencode "text=${text}"
}

# Check if API response is successful
slack_check_response() {
  local response="$1"
  # Check if response contains "ok":true using grep instead of jq
  # This handles escaped characters better
  echo "$response" | grep -q '"ok"[[:space:]]*:[[:space:]]*true'
}

# Get error from API response
slack_get_error() {
  local response="$1"
  # Extract error field more safely
  echo "$response" | grep -o '"error"[[:space:]]*:[[:space:]]*"[^"]*"' | cut -d'"' -f4
  # Fallback to unknown_error if grep finds nothing
  if [ $? -ne 0 ]; then
    echo "unknown_error"
  fi
}
