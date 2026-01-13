---
allowed-tools: Bash
---

# Slack Status Command

Check the current status of Slack plugin configuration.

## Instructions

Run the status check script to verify Slack configuration:

```bash
$HOME/.claude/plugins/marketplaces/djalmaaraujo-claude-code-plugins/plugins/slack/skills/slack-status/check.sh
```

## Output Interpretation

The script returns status in format: `STATUS|MESSAGE|DETAILS`

**Status codes:**
- **OK** - Everything is working properly
- **MISSING_CONFIG** - Config file doesn't exist (run /slack:slack-setup)
- **MISSING_CREDENTIALS** - Config exists but missing fields
- **INVALID_AUTH** - Credentials are invalid (refresh credentials)
- **EXPIRED_TOKEN** - Token has expired (run /slack:slack-setup)
- **API_ERROR** - Other Slack API errors

Present the results to the user in a friendly format.
