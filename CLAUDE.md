# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Claude Code plugin marketplace containing two plugins:
- **planner**: Sub-agent-based plan execution system with dependency resolution and parallel execution
- **slack**: Slack integration for sending messages and searching users via browser session credentials

## Architecture

### Marketplace Structure
```
.claude-plugin/marketplace.json    # Marketplace metadata, lists all plugins
plugins/
├── planner/                       # Plan execution plugin
│   ├── .claude-plugin/plugin.json # Plugin metadata
│   ├── commands/                  # Slash commands (thin wrappers)
│   ├── agents/                    # Subagent definitions (.md files)
│   ├── skills/                    # Skill definitions (each has SKILL.md)
│   └── hooks/hooks.json           # Hook configurations
└── slack/                         # Slack integration plugin
    ├── .claude-plugin/plugin.json # Plugin metadata
    ├── commands/                  # Slash commands (thin wrappers)
    ├── lib/                       # Shared bash libraries (config.sh, slack-api.sh)
    ├── skills/                    # Skill definitions (each has SKILL.md + shell scripts)
    └── tests/                     # Test scripts
```

### Plugin Component Types

**Commands** (`commands/*.md`): Thin wrappers that invoke corresponding skills
- Simple markdown files that delegate to skills via the Skill tool
- Provide `/plugin:command` interface for users

**Skills** (`skills/*/SKILL.md`): Core logic with frontmatter:
- `name`, `description`, `allowed-tools`, `user-invocable: true`
- Markdown body contains execution instructions
- Invoked by commands or automatically by Claude

**Subagents** (`agents/*.md`): Spawned by skills via Task tool with `subagent_type: "planner:agent-name"`

**Shared Libraries** (Slack plugin): Bash scripts in `lib/` sourced by skill scripts

### Key Patterns

**Command → Skill Delegation**:
Commands are thin wrappers that invoke skills. Example command file:
```markdown
---
allowed-tools: Skill
---
Run the `planner:planner-setup` skill with any arguments the user provided: $ARGUMENTS
```

**Planner Plugin Flow**:
1. User runs `/planner:planner-setup` command
2. Command invokes `planner:planner-setup` skill
3. Skill spawns subagents via Task tool with structured prompts
4. Subagents execute and return results
5. Skill formats and reports results to user

**Slack Plugin Flow**:
1. User runs `/slack:slack-send-message` command
2. Command invokes `slack:slack-send-message` skill
3. Skill validates config via `slack-status/check.sh`
4. Shared functions in `lib/slack-api.sh` handle API calls
5. Config stored in `config.json` (workspace, token, cookie)

## Testing

### Slack Plugin
```bash
# Run all tests
plugins/slack/tests/run-all-tests.sh

# Individual tests
plugins/slack/tests/test-send-dm.sh
plugins/slack/tests/test-send-channel.sh

# Verify configuration
plugins/slack/scripts/verify.sh
plugins/slack/skills/slack-status/check.sh
```

## Configuration Files

- `plugins/slack/config.json`: Slack credentials (gitignored)
- `plugins/slack/example.config.json`: Template for config.json
- `plugins/planner/hooks/hooks.json`: Planner hook definitions
