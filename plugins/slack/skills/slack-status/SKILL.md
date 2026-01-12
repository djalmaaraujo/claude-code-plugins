---
name: slack-status
description: Validates Slack configuration and credentials. Checks if config exists, credentials are present, and authentication is working. Used internally by other Slack skills.
user-invocable: true
---

# Slack Status Skill

Validates Slack plugin configuration and credentials. This skill is used internally by other Slack skills to ensure everything is properly configured before attempting operations.

## Usage

This skill is called automatically by other Slack skills. You can also use it directly to check the status of your Slack configuration.

**When the user asks:**

- "Is Slack configured?"
- "Check Slack status"
- "Are my Slack credentials valid?"

Run the status check script:

```bash
~/.claude/plugins/marketplaces/djalmaaraujo-claude-code-plugins/plugins/slack/skills/slack-status/check.sh
```

## Output Format

The script returns a status string in the format: `STATUS|MESSAGE|DETAILS`

### Status Codes

**OK** - Everything is working

```
OK|Ready to use|Workspace: a8c.slack.com, Team: Automattic, User: djalma.araujo (U01ULLNEM3Q), Cached users: 12000
```

**MISSING_CONFIG** - Config file doesn't exist

```
MISSING_CONFIG|Config file not found|Create config at: ~/.claude/plugins/marketplaces/djalmaaraujo-claude-code-plugins/plugins/slack/config.json
```

**MISSING_CREDENTIALS** - Config exists but missing required fields

```
MISSING_CREDENTIALS|Missing required fields|Check workspace, token, and cookie in config
```

**INVALID_AUTH** - Credentials are invalid

```
INVALID_AUTH|Authentication failed|Error: invalid_auth - Please refresh your credentials
```

**EXPIRED_TOKEN** - Token has expired

```
EXPIRED_TOKEN|Token expired|Please refresh your credentials
```

**API_ERROR** - Other Slack API errors

```
API_ERROR|Slack API error|Error: rate_limited
```

## Integration with Other Skills

Other skills should call this check before performing operations:

```bash
# Check status
STATUS_OUTPUT=$(~/.claude/plugins/marketplaces/djalmaaraujo-claude-code-plugins/plugins/slack/skills/slack-status/check.sh)
STATUS_CODE=$(echo "$STATUS_OUTPUT" | cut -d'|' -f1)

if [ "$STATUS_CODE" != "OK" ]; then
  STATUS_MESSAGE=$(echo "$STATUS_OUTPUT" | cut -d'|' -f2)
  echo "⚠️  $STATUS_MESSAGE" >&2

  # Optionally call slack-setup
  # ~/.claude/plugins/marketplaces/djalmaaraujo-claude-code-plugins/plugins/slack/skills/slack-setup/setup.sh

  exit 1
fi

# Proceed with operation...
```

## What It Checks

1. **Config file exists** - Looks for `~/.claude/plugins/marketplaces/djalmaaraujo-claude-code-plugins/plugins/slack/config.json`
2. **Required fields present** - Validates `workspace`, `token`, `cookie`
3. **Authentication works** - Calls `auth.test` API to verify credentials
4. **Token not expired** - Checks for expiration errors

## Notes

- This skill is designed to be called programmatically by other skills
- Exit code 0 = success, Exit code 1 = failure
- All diagnostic information is in the output string
- Uses shared libraries from `~/.claude/plugins/marketplaces/djalmaaraujo-claude-code-plugins/plugins/slack/lib/config.sh` and `~/.claude/plugins/marketplaces/djalmaaraujo-claude-code-plugins/plugins/slack/lib/slack-api.sh`
