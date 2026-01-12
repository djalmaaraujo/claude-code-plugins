# Coding Style Best Practices

These conventions ensure consistent, readable, and maintainable code.

## Consistent Naming Conventions

- Establish and follow naming conventions for variables, functions, classes, and files
- Use conventions appropriate to the language (camelCase, snake_case, PascalCase)
- Be consistent across the entire codebase
- Document naming conventions in project guidelines

## Automated Formatting

- Maintain consistent code style (indenting, line breaks, etc.)
- Use automated formatters (Prettier, Black, gofmt, etc.)
- Configure editor/IDE to format on save
- Include formatter configuration in the repository

## Meaningful Names

- Choose descriptive names that reveal intent
- Avoid abbreviations and single-letter variables except in narrow contexts
- Use domain terminology consistently
- Names should be pronounceable and searchable

## Small, Focused Functions

- Keep functions small and focused on a single task
- Functions should do one thing well
- Aim for functions that fit on one screen
- Small functions are easier to test and maintain

## Consistent Indentation

- Use consistent indentation (spaces or tabs, pick one)
- Configure your editor/linter to enforce it
- Follow language conventions for indent size
- Never mix tabs and spaces

## Remove Dead Code

- Delete unused code, commented-out blocks, and imports
- Don't leave clutter "just in case"
- Version control preserves history if you need it back
- Dead code creates confusion and maintenance burden

## Backward Compatibility Only When Required

- Unless specifically instructed otherwise, assume backward compatibility is not needed
- Clean implementations are better than compatibility shims
- Remove deprecated code rather than maintaining it
- Document breaking changes clearly when they occur

## DRY Principle

- Don't Repeat Yourself - avoid duplication
- Extract common logic into reusable functions or modules
- But don't over-abstract - three similar lines can be better than a premature abstraction
- Balance DRY against readability and maintainability
