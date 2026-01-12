#!/bin/bash
#
# Run all Slack plugin tests
#

set -e

PLUGIN_ROOT="$HOME/.claude/plugins/slack"
TESTS_DIR="$PLUGIN_ROOT/tests"

echo "======================================"
echo "  Slack Plugin - Test Suite"
echo "======================================"
echo ""

# Track results
PASSED=0
FAILED=0

run_test() {
  local test_name="$1"
  local test_script="$2"
  shift 2
  local args="$@"

  echo "→ Running: $test_name"
  echo "  Script: $test_script"
  if [ -n "$args" ]; then
    echo "  Args: $args"
  fi
  echo ""

  if "$test_script" $args >/dev/null 2>&1; then
    echo "  ✅ PASSED"
    PASSED=$((PASSED + 1))
  else
    echo "  ❌ FAILED"
    FAILED=$((FAILED + 1))
  fi
  echo ""
}

# Test 1: Status check
echo "Test 1: Slack Status Check"
echo "----------------------------"
STATUS=$("$PLUGIN_ROOT/skills/slack-status/check.sh")
STATUS_CODE=$(echo "$STATUS" | cut -d'|' -f1)

if [ "$STATUS_CODE" = "OK" ]; then
  echo "✅ PASSED"
  echo "Details: $STATUS"
  PASSED=$((PASSED + 1))
else
  echo "❌ FAILED"
  echo "Status: $STATUS"
  FAILED=$((FAILED + 1))
fi
echo ""

# Test 2: User search
echo "Test 2: Search User (djalma)"
echo "----------------------------"
USER_RESULT=$("$PLUGIN_ROOT/skills/slack-search-user/search-user.sh" djalma 2>&1)
USER_ID=$(echo "$USER_RESULT" | tail -1)

if [ "$USER_ID" = "U01ULLNEM3Q" ]; then
  echo "✅ PASSED"
  echo "Found user ID: $USER_ID"
  PASSED=$((PASSED + 1))
else
  echo "❌ FAILED"
  echo "Result: $USER_RESULT"
  FAILED=$((FAILED + 1))
fi
echo ""

# Test 3: Cache utils
echo "Test 3: Cache Utilities"
echo "------------------------"
CACHE_COUNT=$("$PLUGIN_ROOT/skills/slack-search-user/cache-utils.sh" count 2>&1)

if echo "$CACHE_COUNT" | grep -q "Total cached users"; then
  echo "✅ PASSED"
  echo "$CACHE_COUNT"
  PASSED=$((PASSED + 1))
else
  echo "❌ FAILED"
  echo "Result: $CACHE_COUNT"
  FAILED=$((FAILED + 1))
fi
echo ""

# Test 4: Send message to channel
echo "Test 4: Send Message to Channel (#slack-ai-testing)"
echo "----------------------------------------------------"
if "$TESTS_DIR/test-send-channel.sh" "slack-ai-testing" "🧪 Automated test suite message at $(date)" >/dev/null 2>&1; then
  echo "✅ PASSED"
  PASSED=$((PASSED + 1))
else
  echo "❌ FAILED"
  FAILED=$((FAILED + 1))
fi
echo ""

# Test 5: Send DM
echo "Test 5: Send DM to User (@djalma)"
echo "----------------------------------"
if "$TESTS_DIR/test-send-dm.sh" "djalma" "🧪 Automated test suite DM at $(date)" >/dev/null 2>&1; then
  echo "✅ PASSED"
  PASSED=$((PASSED + 1))
else
  echo "❌ FAILED"
  FAILED=$((FAILED + 1))
fi
echo ""

# Summary
echo "======================================"
echo "  Test Results"
echo "======================================"
echo ""
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo "Total:  $((PASSED + FAILED))"
echo ""

if [ $FAILED -eq 0 ]; then
  echo "🎉 All tests passed!"
  exit 0
else
  echo "⚠️  Some tests failed"
  exit 1
fi
