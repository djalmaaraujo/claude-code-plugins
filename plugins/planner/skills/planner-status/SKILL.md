---
name: planner-status
description: Show overview of all plans and their current execution status from the file PROGRESS.md located in the plans/ folder. Displays progress bar, completed plans, in-progress plans, failed plans, and suggested next actions. Use when user asks about plan status, progress, what's done, what's left, or wants to see plan overview.
allowed-tools: Read, Glob, Grep
user-invocable: true
---

# Show Planner Status

You are now executing the planner-status skill. Follow these steps immediately:

## Step 1: Check Initialization

Verify planner is initialized:

1. Check if `plans/PROGRESS.md` exists
2. If not found, respond:

   ```
   Planner is not initialized in this project.

   To initialize: Tell me "Initialize planner"
   ```

3. Stop here if not initialized

## Step 2: Read PROGRESS.md

Read the full content of `plans/PROGRESS.md`:

1. Use Read tool: `plans/PROGRESS.md`
2. For large files, use Grep to extract table sections if needed

## Step 3: Parse Plan Tables

Extract all feature sections and their plan tables.

**Look for patterns:**

- `### Feature Name` headings
- Table rows: `| plan-name.md | STATUS | DATE |`

**Extract for each plan:**

- Plan filename
- Status (NOT STARTED, IN PROGRESS, COMPLETED, FAILED)
- Completion date (if applicable)
- Feature/section name

## Step 4: Calculate Statistics

Count plans by status:

- Total plans: [N]
- Completed: [X]
- In Progress: [Y]
- Failed: [Z]
- Not Started: [W]

Calculate percentage: `(Completed / Total) * 100`

## Step 5: Display Compact Format

Show the status using this format:

```
======================================
PLANNER STATUS
======================================

Overall Progress: [##########..........] 50% (5/10)

------ Feature Name 1 ------
[x] plan-01.md (Completed 2026-01-09)
[~] plan-02.md (IN PROGRESS)
[ ] plan-03.md
[!] plan-04.md (FAILED)

------ Feature Name 2 ------
[x] plan-05.md (Completed 2026-01-08)
[x] plan-06.md (Completed 2026-01-09)

======================================
IN PROGRESS
======================================
| Plan              | Feature      |
| ----------------- | ------------ |
| plan-02.md        | Feature 1    |

======================================
FAILED
======================================
| Plan              | Feature      |
| ----------------- | ------------ |
| plan-04.md        | Feature 1    |

======================================
COMPLETED PLANS
======================================
- plan-01.md (Feature 1)
- plan-05.md (Feature 2)
- plan-06.md (Feature 2)

======================================
SUGGESTED COMMANDS
======================================
[Based on current state - see logic below]
```

**Status Icons:**

- `[x]` = COMPLETED
- `[ ]` = NOT STARTED
- `[~]` = IN PROGRESS
- `[!]` = FAILED

## Step 6: Suggest Commands

Based on current state, suggest relevant commands:

**If has IN PROGRESS plans:**

```
Continue current: Tell me "Execute [plan-name]"
```

**If has NOT STARTED plans (dependencies met):**

```
Start next: Tell me "Execute [plan-name]"
```

**If has plans with same prefix:**

```
Run batch: Tell me "Execute all [prefix] plans"
```

**If has FAILED plans:**

```
Retry failed: Tell me "Execute [failed-plan]"
```

**If all complete:**

```
All done! 🎉
Create more: Tell me "Create plans for [new feature]"
```

---

## Reference Information

### What This Skill Does

When showing status, this skill:

1. Reads `plans/PROGRESS.md` to get plan statuses
2. Shows all plans with IN PROGRESS, FAILED or NOT STARTED as tables
3. Shows a list of all COMPLETED plans at the bottom
4. Provides helpful commands for continuing work

### Parsing PROGRESS.md Tables

Extract feature sections:

```markdown
### Feature Name Implementation

| Plan                         | Status      | Date       |
| ---------------------------- | ----------- | ---------- |
| prefix-00-initial-setup.md   | COMPLETED   | 2026-01-08 |
| prefix-01-database-schema.md | IN PROGRESS |            |
| prefix-02-api-endpoints.md   | NOT STARTED |            |
```

For each table row:

1. Extract plan filename (column 1)
2. Extract status (column 2): trim whitespace
3. Extract date (column 3): may be empty
4. Associate with feature from `### Feature Name` heading

### Edge Cases

**No Plans Found:**

```
======================================
PLANNER STATUS
======================================

No plans found.

Create plans: Tell me "Create plans for [feature description]"

Example: "Create plans for adding user authentication with login and signup"
```

**All Plans Completed:**

```
======================================
PLANNER STATUS
======================================

Overall Progress: [####################] 100% (10/10)

All plans completed! 🎉

Completed plans:
- auth-00-setup.md (Authentication)
- auth-01-database.md (Authentication)
- auth-02-api.md (Authentication)
...

Create more: Tell me "Create plans for [new feature]"
```

### Suggested Commands Logic

| State                            | Suggested Commands                          |
| -------------------------------- | ------------------------------------------- |
| Has IN PROGRESS plan             | Continue current: Execute [plan]            |
| Has NOT STARTED plans (deps met) | Start next: Execute [plan]                  |
| Has plans with same prefix       | Run batch: Execute all [prefix] plans       |
| All complete                     | Create more: Create plans for [description] |
| Has FAILED plans                 | Retry: Execute [failed-plan]                |

### Example

```
User: Show me the status of test plans

Step 1: Check initialization
→ Found plans/PROGRESS.md

Step 2: Read PROGRESS.md
→ Reading file...

Step 3: Parse tables
→ Found feature: "Test Suite Implementation"
→ Plans: test-00-unit.md (COMPLETED), test-01-integration.md (IN PROGRESS), test-02-e2e.md (NOT STARTED)

Step 4: Calculate statistics
→ Total: 3, Completed: 1, In Progress: 1, Not Started: 1
→ Percentage: 33%

Step 5: Display format
→ Show progress bar, feature sections, status tables

Step 6: Suggest commands
→ Continue current: Execute test-01-integration.md
→ Run batch: Execute all test plans
```
