---
name: planner-eject-template
description: Export the default plan or spec template to your project's plans/ folder for customization. Supports "plan" and "spec" template types.
allowed-tools: Read, Write, Glob, Bash, AskUserQuestion
user-invocable: true
---

# Eject Template

You are now executing the planner-eject-template skill. Follow these steps immediately:

## Step 1: Parse Arguments

Parse `$ARGUMENTS` to determine the template type:

- **Expected values**: `plan` or `spec`
- **If empty or missing**: Use AskUserQuestion tool to prompt the user (see Step 1b)
- **If invalid value**: Show error with valid options

## Step 1b: Prompt User (if no arguments)

If `$ARGUMENTS` is empty or missing, use the **AskUserQuestion** tool to ask the user which template type they want to eject:

```
Question: "Which template would you like to eject?"
Header: "Template"
Options:
  - label: "plan"
    description: "Export the plan template for customizing how plans are created"
  - label: "spec"
    description: "Export the spec template for customizing how specifications are created"
```

After the user responds, continue with Step 2 using their selection.

## Step 2: Handle Template Type

### If argument is `plan`:

Proceed to Step 3 with `template_type = "plan"`.

### If argument is `spec`:

Proceed to Step 3 with `template_type = "spec"`.

### If argument is invalid:

Output this error message and then use AskUserQuestion (Step 1b) to prompt for valid input:

```
════════════════════════════════════════
Invalid template type specified.

Valid types are: plan, spec
════════════════════════════════════════
```

## Step 3: Check Plans Directory

1. Use Glob to check if `plans/` directory exists
2. If it doesn't exist, inform the user:

```
════════════════════════════════════════
Error: plans/ directory not found

Please run /planner:setup first to initialize
the planner in your project.
════════════════════════════════════════
```

## Step 4: Check for Existing Template

**If `template_type = "plan"`:**
1. Check if `plans/task.TEMPLATE.md` already exists
2. If it exists, ask for confirmation to overwrite (or skip if user passed `--force`)

**If `template_type = "spec"`:**
1. Check if `plans/spec.TEMPLATE.md` already exists
2. If it exists, ask for confirmation to overwrite (or skip if user passed `--force`)

## Step 5: Copy Template

**If `template_type = "plan"`:**

1. Read the default template from the plugin:
   - Path: Find the plugin root and read `templates/task.TEMPLATE.md`
   - The plugin templates are located relative to this skill

2. Write the template to `plans/task.TEMPLATE.md`

3. Also copy the standards directory:
   - Create `plans/standards/` directory if it doesn't exist
   - Copy all files from plugin's `templates/standards/` to `plans/standards/`

**If `template_type = "spec"`:**

1. Read the default spec template from the plugin:
   - Path: Find the plugin root and read `templates/spec.TEMPLATE.md`

2. Write the template to `plans/spec.TEMPLATE.md`

3. Also copy the standards directory (if not already copied):
   - Create `plans/standards/` directory if it doesn't exist
   - Copy all files from plugin's `templates/standards/` to `plans/standards/`

## Step 6: Report Success

**If `template_type = "plan"`:**

```
════════════════════════════════════════
Plan Template Ejected Successfully

Files created:
  plans/task.TEMPLATE.md
  plans/standards/general-development.md
  plans/standards/error-handling.md
  plans/standards/validation.md
  plans/standards/code-commenting.md
  plans/standards/coding-style.md
  plans/standards/test-coverage.md
  plans/standards/backward-compatibility.md
  plans/standards/plan-execution.md

You can now customize these templates for your project.
The planner will use your custom template when creating
new plans.

Template placeholders use {{PLACEHOLDER}} syntax.
Edit the template to match your project's needs.
════════════════════════════════════════
```

**If `template_type = "spec"`:**

```
════════════════════════════════════════
Spec Template Ejected Successfully

Files created:
  plans/spec.TEMPLATE.md
  plans/standards/general-development.md
  plans/standards/error-handling.md
  plans/standards/validation.md
  plans/standards/code-commenting.md
  plans/standards/coding-style.md
  plans/standards/test-coverage.md
  plans/standards/backward-compatibility.md
  plans/standards/plan-execution.md

You can now customize the spec template for your project.
The spec-creator will use your custom template when creating
new specifications.

Template placeholders use {{PLACEHOLDER}} syntax.
Edit the template to match your project's needs.

The spec template includes 7 sections:
1. Front Matter
2. Introduction & Overview
3. Functional Requirements
4. Non-Functional Requirements
5. Design & Technical Details
6. Implementation & Logistics
7. Appendix

Customize these sections to fit your project's specification needs.
════════════════════════════════════════
```

---

## Implementation Notes

- The template uses `{{PLACEHOLDER}}` syntax for values to be filled in
- Convention files use `@` mentions that Claude can reference
- Users can customize the template structure while keeping core sections
- If the user's template is missing required sections, the creator agent will add them and notify the user

### Template Types

| Type | Source File | Destination | Purpose |
|------|-------------|-------------|---------|
| plan | templates/task.TEMPLATE.md | plans/task.TEMPLATE.md | Customize plan creation |
| spec | templates/spec.TEMPLATE.md | plans/spec.TEMPLATE.md | Customize spec creation |
