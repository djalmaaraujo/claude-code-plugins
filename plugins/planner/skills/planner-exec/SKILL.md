---
name: planner-exec
description: Execute a single plan file with full dependency validation, configuration options (auto-commit, README update, CLAUDE.md update), conflict detection, and PROGRESS.md tracking. Blocks execution if dependencies are not met. Use when user wants to run a specific plan, execute a plan file, or implement a single plan.
allowed-tools: Task, TaskOutput, Read, Glob, AskUserQuestion
user-invocable: true
---

# Execute Single Plan

You are now executing the planner-exec skill. Follow these steps immediately:

**Agent Reference**: This skill uses the plan-executor agent (@agents/plan-executor.md) to perform the actual plan execution work.

## Step 1: Find the Plan File

Use Glob to locate the plan in `plans/` directory:

**If user provides partial name (e.g., "01"):**

- Search: `plans/*01*.md`

**If user provides full name (e.g., "auth-01-database.md"):**

- Search: `plans/auth-01-database.md`

**If multiple matches:**

- Ask user which one they meant using AskUserQuestion

## Step 2: Read Plan Content

Read the plan file and extract:

1. The full plan content
2. The `# Configuration` section
3. The `depends_on` field (if present)

Example:

```markdown
# Configuration

depends_on: "auth-00-setup.md"
```

## Step 3: Check Dependencies

If `depends_on` exists, verify dependencies in `plans/PROGRESS.md`:

1. Read `plans/PROGRESS.md`
2. For each dependency listed:

   - Find its status in the table
   - If status is NOT `COMPLETED`:

     ```
     ⛔ BLOCKED: Cannot execute [plan_name]

     Dependency [dep_name] is not COMPLETED
     Current status: [status]

     Please complete dependencies first, or use planner-batch for automatic ordering.
     ```

   - Exit immediately with BLOCKED status

**IMPORTANT:** Do NOT proceed if dependencies are not met!

## Step 4: Read Configuration

Read the user's project configuration from `plans/planner.config.json`:

1. **Read configuration file**: Read `plans/planner.config.json`

   - If successful and valid JSON:
     - Parse: `auto_commit`, `auto_commit_standard`, `auto_update_claude_md`, `replan_on_exec`
     - Build config object and proceed to Step 5

2. **Use defaults**: If file not found or invalid:
   ```
   config.auto_commit = false
   config.auto_commit_standard = "no_standard"
   config.auto_update_claude_md = false
   config.replan_on_exec = false
   ```

## Step 5: Spawn Plan-Executor Agent

Use the Task tool to spawn the plan-executor agent:

```
Task tool:
  description: "Execute plan: [plan_name]"
  subagent_type: "planner:plan-executor"
  prompt: |
    plan_name: "[actual plan filename]"

    plan_content: |
      [FULL PLAN FILE CONTENT - properly indented]

    skip_dependency_check: false

    config:
      auto_commit: [true/false from Step 4]
      auto_commit_standard: [value from Step 4 or "no_standard"]
      auto_update_claude_md: [true/false from Step 4]
      replan_on_exec: [true/false from Step 4]

    additional_instructions: [user's extra instructions or "None"]

    BEGIN EXECUTION.
```

## Step 6: Report Results

After the agent completes, report to the user:

```
════════════════════════════════════════
## Execution Result

**Plan**: [plan_name]
**Status**: SUCCESS | FAILURE | BLOCKED
**Summary**: [Brief description of what was done]
**Files Modified**: [List of changed files]
**Config Actions**: [Actions taken: committed, updated CLAUDE.md, etc.]
**Issues**: [Any problems encountered, or "None"]
**Next**: [Suggested next plan from PROGRESS.md, or "All plans complete"]
════════════════════════════════════════
```

---

## Reference Information

### What This Skill Does

When executing a single plan, this skill:

1. **Verifies Dependencies**: Checks that all required plans are COMPLETED
2. **Reads Configuration**: Gets settings from `plans/planner.config.json`
3. **Checks for Conflicts**: Warns if other plans are IN PROGRESS
4. **Executes the Plan**: Follows plan steps with fresh context
5. **Updates Tracking**: Marks plan as IN PROGRESS → COMPLETED/FAILED
6. **Applies Configuration**: Handles post-execution tasks based on config

### Safety Features

- **Dependency Blocking**: Refuses to execute if dependencies aren't met
- **Conflict Detection**: Warns about other plans currently running
- **Resume Awareness**: Detects if a plan was already completed
- **Structured Results**: Consistent SUCCESS/FAILURE/BLOCKED reporting

### Configuration Options

Configuration is read from `plans/planner.config.json` (set during planner-setup):

| Option                     | Description                                                                     |
| -------------------------- | ------------------------------------------------------------------------------- |
| **Auto-commit**            | Create a git commit after successful execution                                  |
| **Auto-commit standard**   | Commit message format: "conventional_commits" or "no_standard"                  |
| **Auto-update CLAUDE.md**  | Analyze and update project CLAUDE.md if changes made it inaccurate              |
| **Re-plan on Executing**   | Re-analyze and draft fresh implementation before executing (slower)             |

These options are only applied if execution succeeds. Failed plans skip configuration actions.

### Configuration Actions (Applied After Success Only)

Actions are applied in this order:

1. **Auto-update CLAUDE.md** (if enabled):

   - Read current CLAUDE.md
   - Analyze if changes made content inaccurate
   - Update if needed

2. **Auto-commit** (if enabled):
   - Uses the planner-commit skill (@skills/planner-commit/SKILL.md)
   - If `auto_commit_standard` is `"conventional_commits"`: Uses Conventional Commits format
   - If `auto_commit_standard` is `"no_standard"`: Uses simple format `feat(planner): Complete [plan_name] - [summary]`
   - DO NOT push (user does that)

### PROGRESS.md Updates

The plan-executor agent manages PROGRESS.md automatically:

**Before execution:**

```markdown
| auth-02-api.md | NOT STARTED | |
```

**During execution:**

```markdown
| auth-02-api.md | IN PROGRESS | |
```

**After success:**

```markdown
| auth-02-api.md | COMPLETED | 2026-01-09 |
```

**After failure:**

```markdown
| auth-02-api.md | FAILED | |
```

### Status Values

- `NOT STARTED`: Plan hasn't been executed yet
- `IN PROGRESS`: Plan is currently executing (shows in progress, warns of conflicts)
- `COMPLETED`: Plan finished successfully (dependencies satisfied for dependent plans)
- `FAILED`: Plan encountered an error (blocks dependent plans)
