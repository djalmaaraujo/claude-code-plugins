# Planner Plugin for Claude Code

Sub-agent-based plan execution system with automatic dependency resolution, parallelism, and safety checks.

## Features

- ✅ **Plan creation** - Break down complex features into manageable plans
- ✅ **Dependency resolution** - Automatic ordering based on plan dependencies
- ✅ **Parallel execution** - Run independent plans simultaneously
- ✅ **Progress tracking** - PROGRESS.md tracks all plan statuses
- ✅ **Safety checks** - Validates dependencies before execution
- ✅ **Configuration options** - Auto-commit, CLAUDE.md updates, and more

## Quick Start

### 1. Initialize Planner

```
/planner:planner-setup
```

This creates the `plans/` directory and `PROGRESS.md` tracking file.

### 2. Create Plans

```
/planner:planner-create Add user authentication feature
```

This breaks down the feature into multiple plan files with proper dependencies.

### 3. Check Status

```
/planner:planner-status
```

Shows progress bar, completed plans, in-progress plans, and suggested next actions.

### 4. Execute Plans

**Single plan:**
```
/planner:planner-exec plans/001-setup-database.md
```

**All plans (with dependency resolution):**
```
/planner:planner-batch
```

## Available Slash Commands

| Command | Description |
|---------|-------------|
| `/planner:planner-setup` | Initialize planner in a project |
| `/planner:planner-create` | Create plan files for a feature |
| `/planner:planner-status` | Show overview of all plans |
| `/planner:planner-exec` | Execute a single plan file |
| `/planner:planner-batch` | Execute multiple plans with dependency resolution |

## Directory Structure

After setup, your project will have:

```
project/
├── plans/
│   ├── PROGRESS.md           # Status tracking
│   ├── planner.config.json   # Configuration
│   ├── 001-first-plan.md     # Plan files
│   ├── 002-second-plan.md
│   └── ...
```

## Plan File Format

Each plan file includes:

```markdown
# Plan Title

## Dependencies
- 001-previous-plan.md

## Description
What this plan accomplishes.

## Tasks
- [ ] Task 1
- [ ] Task 2

## Acceptance Criteria
- Criterion 1
- Criterion 2
```

## Configuration

`plans/planner.config.json`:

```json
{
  "auto_commit": false,
  "auto_update_claude_md": false,
  "smart_parallelism": true
}
```

- **auto_commit**: Automatically commit after each plan
- **auto_update_claude_md**: Update project CLAUDE.md with changes
- **smart_parallelism**: Run independent plans in parallel

## License

MIT

## Author

Djalma Araujo
