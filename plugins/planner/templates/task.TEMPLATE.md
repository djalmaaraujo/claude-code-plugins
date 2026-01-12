# Configuration

depends_on: {{DEPENDENCIES}}
linear_project: {{LINEAR_PROJECT_IF_PROVIDED}}
linear_issue: {{LINEAR_ISSUE_IF_PROVIDED}}

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

This template provides a structure for creating consistent, well-documented plans. When using this template:

1. **Replace all `{{PLACEHOLDER}}` values** with actual content
2. **Remove unused sections** if they don't apply to your plan
3. **Add sections** if the plan requires additional documentation
4. **Keep plans focused** - aim for ~40% context usage during execution
5. **Include all necessary context** - plans run with no memory of previous plans

If you need to add sections not covered by this template, inform the user at completion that additional sections were needed.
