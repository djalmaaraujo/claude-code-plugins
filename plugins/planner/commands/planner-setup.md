---
allowed-tools: AskUserQuestion, Bash, Write
---

# Planner Setup

## Step 1: Ask first 4 questions

```json
{
  "questions": [
    {
      "header": "Auto-commit",
      "question": "Automatically commit after successful plan execution?",
      "multiSelect": false,
      "options": [
        {"label": "Yes (Recommended)", "description": "Auto-commit changes after each plan"},
        {"label": "No", "description": "Manual commits only"}
      ]
    },
    {
      "header": "CLAUDE.md",
      "question": "Auto-update .claude/CLAUDE.md when code changes make docs inaccurate?",
      "multiSelect": false,
      "options": [
        {"label": "Yes", "description": "Keep CLAUDE.md updated automatically"},
        {"label": "No (Recommended)", "description": "Manual updates only"}
      ]
    },
    {
      "header": "Parallelism",
      "question": "How should plan dependencies be handled?",
      "multiSelect": false,
      "options": [
        {"label": "Aggressive (Recommended)", "description": "Maximize parallel execution"},
        {"label": "Conservative", "description": "More sequential, safer"}
      ]
    },
    {
      "header": "Re-plan",
      "question": "Re-analyze plans before execution?",
      "multiSelect": false,
      "options": [
        {"label": "No (Recommended)", "description": "Execute as written"},
        {"label": "Yes", "description": "Re-analyze first (slower)"}
      ]
    }
  ]
}
```

## Step 2: Ask remaining 2 questions

```json
{
  "questions": [
    {
      "header": "Specs",
      "question": "Use specification files before creating plans?",
      "multiSelect": false,
      "options": [
        {"label": "Yes (Recommended)", "description": "Create specs first, then generate plans"},
        {"label": "No", "description": "Create plans directly"}
      ]
    },
    {
      "header": "Verbosity",
      "question": "How interactive should spec creation be?",
      "multiSelect": false,
      "options": [
        {"label": "Maximum inference (Recommended)", "description": "Infer from codebase, minimal questions"},
        {"label": "Interactive", "description": "Ask more clarifying questions"}
      ]
    }
  ]
}
```

## Step 3: Create plans directory

```bash
mkdir -p plans
```

## Step 4: Write config file

Write `plans/planner.config.json`:

```json
{
  "version": "2.0.0",
  "auto_commit": [true if "Yes", false if "No"],
  "auto_update_claude_md": [true if "Yes", false if "No"],
  "smart_parallelism": [true if "Aggressive", false if "Conservative"],
  "replan_on_exec": [true if "Yes", false if "No"],
  "uses_spec": [true if "Yes", false if "No"],
  "spec_verbose": [true if "Interactive", false if "Maximum inference"]
}
```

## Step 5: Create PROGRESS.md if missing

Only if `plans/PROGRESS.md` doesn't exist, write it:

```markdown
# Project Progress

<!--
PLANNER PROGRESS TRACKER
This file tracks plan execution status.
-->

---

<!-- Plans will be added below -->
```

## Step 6: Report results

Show what was created/updated and the 6 configuration values.
