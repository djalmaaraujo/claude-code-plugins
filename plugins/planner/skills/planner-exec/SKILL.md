---
name: planner-exec
description: Execute a single plan file with full dependency validation, configuration options (auto-commit, README update, CLAUDE.md update), conflict detection, and PROGRESS.md tracking. Blocks execution if dependencies are not met. Use when user wants to run a specific plan, execute a plan file, or implement a single plan.
allowed-tools: Task, TaskOutput, Read, Glob, AskUserQuestion
user-invocable: true
context: fork
---

# Execute Single Plan

You will now execute the single plan workflow. Do NOT just report what you'll do - actually execute each step using the tools available.

## EXECUTE NOW: Step 1 - Find Plan File

Use the Glob tool NOW to find the plan file. Parse user's arguments to identify the plan name.

- If partial name (e.g., "01"): `Glob("plans/*01*.plan.md")`
- If full name: `Glob("plans/[name]")`
- If multiple matches: Use AskUserQuestion to clarify

## EXECUTE NOW: Step 2 - Read Plan

Use the Read tool NOW to read the plan file found in Step 1.

Extract:
- The full plan content
- The `depends_on` field from `# Configuration` section (if present)

## EXECUTE NOW: Step 3 - Check Dependencies

If `depends_on` exists in the plan:

1. Use Read tool to read `plans/PROGRESS.md`
2. Check if each dependency has status `COMPLETED`
3. If any dependency is NOT completed:
   - Report: "⛔ BLOCKED: Dependency [name] is not COMPLETED"
   - STOP execution immediately

## EXECUTE NOW: Step 4 - Read Config

Use Read tool NOW to read `plans/planner.config.json`.

Extract these values (use defaults if not found):
- `auto_commit` (default: false)
- `auto_commit_standard` (default: "no_standard")
- `auto_update_claude_md` (default: false)
- `replan_on_exec` (default: false)

## EXECUTE NOW: Step 5 - Spawn Agent

**You MUST immediately call the Task tool with these exact parameters:**

```
description: "Execute plan: [plan_name]"
subagent_type: "planner:plan-executor"
prompt: |
  plan_name: "[actual plan filename]"

  plan_content: |
    [FULL PLAN FILE CONTENT from Step 2]

  skip_dependency_check: true

  config:
    auto_commit: [value from Step 4]
    auto_commit_standard: [value from Step 4]
    auto_update_claude_md: [value from Step 4]
    replan_on_exec: [value from Step 4]

  additional_instructions: [user's extra instructions or "None"]

  BEGIN EXECUTION.
```

**Call the Task tool NOW. Do not delay. Do not just describe what you would do.**

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
