# Configuration

<!--
IMPORTANT: This section controls plan execution behavior.
All {{PLACEHOLDER}} values will be replaced by the plan-creator agent.
-->

depends_on: {{DEPENDENCIES}}
<!--
  Dependencies that must be completed before this plan can execute.
  Format: Comma-separated list of plan filenames (without .plan.md extension)
  Examples:
    depends_on: none
    depends_on: prefix-00-setup
    depends_on: prefix-00-setup, prefix-01-models

  Note: Plan files are named prefix-NN-name.plan.md
  The planner-exec skill will block execution if dependencies are not completed.
-->

linear_project: {{LINEAR_PROJECT_IF_PROVIDED}}
<!-- Optional: Linear project ID or name to associate with this plan -->

linear_issue: {{LINEAR_ISSUE_IF_PROVIDED}}
<!-- Optional: Linear issue ID to link to this plan -->

# Plan: {{PLAN_FILENAME}}

## Objective

{{OBJECTIVE_DESCRIPTION}}

Provide a clear, concise description of what this plan accomplishes. Include the business value and expected outcome.

## Context

{{RELEVANT_CONTEXT_FROM_CODEBASE}}

Document relevant context from the codebase:

- Existing patterns or conventions to follow
- Related files or modules
- Dependencies or prerequisites

## Implementation Steps

### Step 1: {{STEP_TITLE}}

{{STEP_DETAILS}}

Provide detailed, actionable instructions for this step.

### Step 2: {{STEP_TITLE}}

{{STEP_DETAILS}}

Continue with additional steps as needed. Each step should be clear enough to execute independently.

## Files to Modify

| File          | Action                   | Description      |
| ------------- | ------------------------ | ---------------- |
| {{FILE_PATH}} | {{CREATE/MODIFY/DELETE}} | {{WHAT_CHANGES}} |

List all files that will be created, modified, or deleted. Be specific about what changes will be made to each file.

## Standards & Conventions

Follow these conventions during implementation:

@templates/standards/general-development.md
@templates/standards/coding-style.md
@templates/standards/error-handling.md
@templates/standards/validation.md
@templates/standards/test-coverage.md
@templates/standards/code-commenting.md

Select only the relevant conventions for this specific plan.

## Testing Instructions

### Verification Steps

1. {{TEST_STEP_1}}
2. {{TEST_STEP_2}}
3. {{TEST_STEP_3}}

Provide specific commands or actions to verify the implementation works correctly.

### Expected Outcomes

- {{EXPECTED_OUTCOME_1}}
- {{EXPECTED_OUTCOME_2}}

Describe what success looks like. Include specific observable behaviors or outputs.

## Completion Checklist

- [ ] All implementation steps completed
- [ ] Files modified as specified
- [ ] Tests pass (if applicable)
- [ ] No linting/type errors introduced
- [ ] Code follows project conventions

## Completion

Update `plans/PROGRESS.md` to mark this plan as **COMPLETED**.

```markdown
| {{PLAN_FILENAME}} | COMPLETED | {{DATE}} |
```

Next suggested plan: {{NEXT_PLAN_FILENAME}}

---

## Template Usage Notes

<!--
This section is for template customization guidance.
Remove this entire section when creating actual plans.
-->

This template provides a structure for creating consistent, well-documented plans.

### How Placeholders Work

All `{{PLACEHOLDER}}` values in this template will be **automatically replaced** by the `plan-creator` agent when generating plans. The agent:

1. Analyzes your request and codebase context
2. Fills in all placeholders with appropriate content
3. Removes any unused optional sections
4. Adds additional sections if needed

### Placeholder Reference

| Placeholder | Description |
|-------------|-------------|
| `{{DEPENDENCIES}}` | Plan dependencies (e.g., `none` or `001-setup, 002-models`) |
| `{{LINEAR_PROJECT_IF_PROVIDED}}` | Linear project ID (or blank if none) |
| `{{LINEAR_ISSUE_IF_PROVIDED}}` | Linear issue ID (or blank if none) |
| `{{PLAN_FILENAME}}` | The plan's filename (e.g., `001-create-auth-module`) |
| `{{OBJECTIVE_DESCRIPTION}}` | Clear description of what the plan accomplishes |
| `{{STEP_TITLE}}` | Title for each implementation step |
| `{{STEP_DETAILS}}` | Detailed instructions for each step |
| `{{FILE_PATH}}` | Path to file being modified |
| `{{CREATE/MODIFY/DELETE}}` | Action type for the file |
| `{{WHAT_CHANGES}}` | Description of changes to the file |

### Customizing This Template

When you eject this template to your project's `plans/` folder, you can:

1. **Modify sections** - Change headings, add fields, restructure as needed
2. **Add new placeholders** - Use `{{YOUR_PLACEHOLDER}}` syntax
3. **Remove sections** - Delete sections you don't need
4. **Add project-specific guidance** - Include your team's conventions

The plan-creator agent will use your customized template when generating new plans.
