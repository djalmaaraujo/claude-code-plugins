# Plan Execution Conventions

These conventions ensure effective plan creation and execution.

## Self-Contained Plans

- Each plan should be self-contained and executable independently
- Plans run after `/clear` with NO memory of previous plans
- Include all necessary context within the plan itself
- Don't assume knowledge from other plans

## Dependency Tracking

- Declare dependencies explicitly using `depends_on`
- Only add dependencies when there's a direct execution requirement
- Independent plans can run in parallel
- Final integration plans depend on all component plans

## Progress Updates

- Always update `plans/PROGRESS.md` when completing a plan
- Mark plans as COMPLETED only when fully done
- Include completion date in the status update
- Suggest the next plan to execute

## Context Optimization

- Each plan should use approximately 40% of Claude context
- Leave room for implementation code and tool outputs
- Break large tasks into multiple smaller plans
- Keep plans focused on a single objective

## Clear Completion Criteria

- Define what "done" means for each plan
- Include verification steps
- List expected outcomes
- Provide a completion checklist

## Testing Instructions

- Include specific testing instructions in each plan
- Describe how to verify the implementation works
- List commands to run for validation
- Define expected test outcomes

## File Modification Tracking

- List all files that will be modified
- Specify the action (CREATE, MODIFY, DELETE)
- Describe what changes will be made
- Help reviewers understand the scope

## Convention References

- Reference relevant convention files using @mentions
- Apply appropriate conventions during implementation
- Follow project-specific patterns
- Maintain consistency across plans
