---
name: planner-batch
description: Execute multiple plans with automatic dependency resolution and parallel execution. Builds dependency graph, runs independent plans simultaneously, handles sequential dependencies, and applies configuration options. Use when user wants to run multiple plans, batch execute plans, or execute all plans for a feature.
allowed-tools: Task, TaskOutput, Read, Glob, Grep, AskUserQuestion
user-invocable: true
---

# Execute Batch Plans

You are now executing the planner-batch skill. Follow these steps immediately:

## Step 1: Read Configuration

Read the user's project configuration from `plans/planner.config.json`:

1. **Read configuration file**: Read `plans/planner.config.json`

   - If successful and valid JSON:
     - Parse: `auto_commit`, `auto_commit_standard`, `auto_update_claude_md`, `replan_on_exec`
     - Build config object and proceed to Step 2

2. **Use defaults**: If file not found or invalid:
   ```
   config.auto_commit = false
   config.auto_commit_standard = "no_standard"
   config.auto_update_claude_md = false
   config.replan_on_exec = false
   ```

## Step 2: Resolve Plan List

Determine which plans to execute based on user's request:

**If user said "test" or "auth" or similar prefix:**

- Use Glob: `plans/{prefix}-*.md`
- Sort by filename

**If user provided specific plan names:**

- For each name: if ends with `.md`, use as-is
- Otherwise, use Glob to find matching plan in `plans/`

**If no specific plans mentioned:**

- Use Glob: `plans/*.md`
- Exclude: `PROGRESS.md`, `example.md`

## Step 3: Spawn Batch Orchestrator Agent

Use the Task tool to spawn the plan-batch-orchestrator agent:

```
Task tool:
  description: "Batch execute plans"
  subagent_type: "planner:plan-batch-orchestrator"
  prompt: |
    arguments: "[comma-separated plan list or prefix]"

    config:
      auto_commit: [true/false from Step 1]
      auto_commit_standard: [value from Step 1 or "no_standard"]
      auto_update_claude_md: [true/false from Step 1]
      replan_on_exec: [true/false from Step 1]

    BEGIN ORCHESTRATION.
```

## Step 4: Report Results

After the agent completes, report to the user:

```
════════════════════════════════════════
Batch Execution Complete

Total plans: [X]
Completed: [Y]
Skipped (already done): [Z]
Failed: [W]
Parallel rounds executed: [N]

Execution rounds:
Round 1 (parallel): [plan1], [plan3]
Round 2: [plan2] (waited for plan1)
Round 3: [plan4] (waited for plan2, plan3)

Config actions applied: [list of actions]
════════════════════════════════════════
```

---

## Reference Information

### What This Skill Does

When batch executing plans, this skill:

1. **Reads Configuration**: From `plans/planner.config.json` to apply to ALL plans
2. **Resolves Plan List**: From explicit names or `--prefix` pattern
3. **Spawns Orchestrator**: Delegates to plan-batch-orchestrator agent
4. **Reports Results**: Shows summary of execution rounds and results

### Key Features

- **Automatic Parallelism**: Independent plans run simultaneously for speed
- **Sequential Coordination**: Waits for dependencies before proceeding
- **Smart Ordering**: Builds optimal execution rounds from dependency graph
- **Resume Capability**: Skips already-completed plans
- **Failure Handling**: Prompts user when dependencies fail

### Configuration Options

Configuration is read from `plans/planner.config.json` (set during planner-setup) and applied to ALL plans:

| Option                     | Description                                                                     |
| -------------------------- | ------------------------------------------------------------------------------- |
| **Auto-commit**            | Create a git commit after each successful plan                                  |
| **Auto-commit standard**   | Commit message format: "conventional_commits" or "no_standard"                  |
| **Auto-update CLAUDE.md**  | Update project CLAUDE.md after each plan if needed                              |
| **Re-plan on Executing**   | Re-analyze and draft fresh implementation before executing (slower)             |

**Note:** Configuration is set once during setup and stored in planner.config.json. Users can edit planner.config.json to change settings.

### Dependency Graph Building

The plan-batch-orchestrator agent will:

- Read all plan files
- Parse `depends_on` fields from `# Configuration` sections
- Build execution rounds
- Check PROGRESS.md for completed plans
- Execute in optimal order with parallelism
- Apply configuration options per plan

### Example Execution Flow

```
User: Execute all auth plans

Step 1: Read configuration
→ From plans/planner.config.json
→ Found: auto_commit: true, auto_update_claude_md: false

Step 2: Resolve plans
→ Found: auth-00-setup.md, auth-01-database.md, auth-02-api.md

Step 3: Spawn batch orchestrator
→ Passes config and plan list

Orchestrator reads plans:
→ Dependencies:
  auth-00-setup.md: (none)
  auth-01-database.md: depends on auth-00-setup.md
  auth-02-api.md: depends on auth-01-database.md

Build rounds:
→ Round 1: auth-00-setup.md
→ Round 2: auth-01-database.md
→ Round 3: auth-02-api.md

Execute:
→ Round 1: auth-00-setup.md completes, auto-commit applied
→ Round 2: auth-01-database.md completes, auto-commit applied
→ Round 3: auth-02-api.md completes, auto-commit applied

Report summary:
→ 3 plans completed, 3 rounds, auto-commit enabled
```

### Benefits

| Scenario                | Single Exec            | Batch Exec                           |
| ----------------------- | ---------------------- | ------------------------------------ |
| **Dependency checking** | Blocks if deps not met | Automatically orders                 |
| **Multiple plans**      | Manual, one at a time  | Automatic orchestration              |
| **Parallelism**         | No parallel execution  | Independent plans run simultaneously |
| **Resume**              | Must track manually    | Skips completed plans                |
| **Config options**      | Per-plan               | Apply to all                         |
