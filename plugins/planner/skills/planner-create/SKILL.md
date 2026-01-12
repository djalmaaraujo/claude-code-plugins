---
name: planner-create
description: Create implementation plan files with dependency analysis and parallel execution support. Breaks down complex features into multiple self-contained plans with proper dependency tracking. Use when user wants to create plans, break down features, or plan implementation.
allowed-tools: Task, TaskOutput, Read, Write, Edit, Glob, Grep
user-invocable: true
---

# Create Plans

You are now executing the planner-create skill. Follow these steps immediately:

## Step 1: Read Smart Parallelism Configuration

Read the user's project configuration to understand the plan creation strategy:

1. **Read configuration file**: Read `plans/planner.config.json`

   - If successful and valid JSON:
     - Parse: `smart_parallelism`
     - Store the value and proceed to Step 2

2. **Use default**: If file not found or invalid:
   - `smart_parallelism = false`

**This affects dependency creation:**

- `true`: Aggressive parallelization (fewer dependencies, more parallel plans)
- `false`: Conservative dependencies (safer sequential execution)

## Step 2: Analyze Existing Plans

Understand the current project structure:

1. Use Glob: `plans/*.md` (exclude PROGRESS.md, example.md)
2. Store as `existing_plans` for context
3. Detect naming conventions:
   - Prefix patterns (e.g., "auth-", "api-")
   - Numbering schemes (e.g., "01-", "02-")
   - Naming styles (e.g., kebab-case, descriptive names)

## Step 3: Spawn Plan-Creator Agent

Use the Task tool to spawn the plan-creator agent:

```
Task tool:
  description: "Create plans for: [short summary]"
  subagent_type: "planner:plan-creator"
  prompt: |
    description: "[user's full feature description]"
    prefix: "[provided prefix or inferred from description]"

    smart_parallelism: [true/false from Step 1]

    existing_plans:
    [LIST OF EXISTING PLAN FILES]

    naming_conventions:
    [DETECTED PATTERNS FROM EXISTING PLANS]

    BEGIN CREATION.
```

## Step 4: Report Results

After the agent completes, show the creation result:

```
════════════════════════════════════════
Plans Created Successfully

Feature: [feature description]
Prefix: [prefix used]
Plans created: [N]

Plan Execution Order:
Round 1 (parallel): [list of independent plans]
Round 2: [plans depending on Round 1]
Round 3: [plans depending on Round 2]
...

Files created:
- plans/[plan-01].md
- plans/[plan-02].md
- plans/[plan-03].md
- Updated plans/PROGRESS.md

To execute:
  /planner:batch --prefix=[prefix]
  OR
  /planner:batch [plan-01].md [plan-02].md ...

Smart Parallelism: [enabled/disabled]
════════════════════════════════════════
```

---

## Reference Information

### What This Skill Does

When creating plans for a feature, this skill:

1. **Reads Configuration**: Gets smart parallelism setting from `plans/planner.config.json`
2. **Analyzes Requirements**: Breaks down the feature into manageable plans
3. **Creates Plan Files**: Each plan is self-contained (~40% context usage)
4. **Determines Dependencies**: Identifies sequential vs. parallel execution needs
5. **Updates Tracking**: Adds new plans to `plans/PROGRESS.md`

### Key Features

- **Smart Breakdown**: Splits complex features into small, focused plans
- **Dependency Analysis**: Identifies which plans must run sequentially vs. in parallel
- **Context Optimization**: Each plan uses ~40% context to leave room for implementation
- **Naming Conventions**: Follows existing project patterns or creates sensible defaults
- **Automatic Tracking**: Updates PROGRESS.md with all new plans
- **Configurable Strategy**: Uses smart parallelism setting for dependency decisions

### Smart Parallelism

The `smart_parallelism` setting in `plans/planner.config.json` affects how aggressively plans are parallelized:

**When `true` (Aggressive):**

- Minimizes dependencies
- Maximizes parallel execution
- Faster overall execution
- Requires careful conflict management

**When `false` (Conservative):**

- More sequential dependencies
- Safer execution order
- Slower but more predictable
- Better for complex interdependencies

### Plan Structure

Each created plan includes:

```markdown
# Configuration

depends_on: "prefix-00-setup.md"

# Plan: prefix-01-database.md

## Objective

[What this plan accomplishes]

## Steps

1. [Detailed implementation steps]
2. ...

## Files to Modify

- path/to/file.ts: [what changes]

## Testing

[How to verify the changes work]

## Completion

Update plans/PROGRESS.md to mark this plan as COMPLETED.
```

### Example

```
User: Create plans for user authentication with JWT

Step 1: Read smart_parallelism
→ Found: smart_parallelism: true

Step 2: Analyze existing plans
→ Found naming pattern: "feature-NN-name.md"
→ Detected numbering scheme: 00, 01, 02, etc.

Step 3: Spawn plan-creator agent
→ Passes config, description, and conventions

Agent creates:
→ auth-00-setup.md (no deps)
→ auth-01-database.md (depends on: 00)
→ auth-02-jwt-service.md (depends on: 01)
→ auth-03-api.md (depends on: 02)
→ auth-04-tests.md (no deps - can run in parallel)

Updates PROGRESS.md:
→ Added 5 new plans

Report:
→ Round 1: auth-00-setup.md, auth-04-tests.md
→ Round 2: auth-01-database.md
→ Round 3: auth-02-jwt-service.md
→ Round 4: auth-03-api.md

Suggested command: /planner:batch --prefix=auth
```
