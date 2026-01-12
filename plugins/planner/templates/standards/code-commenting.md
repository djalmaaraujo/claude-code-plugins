# Code Commenting Best Practices

These conventions ensure code is understandable without excessive documentation.

## Self-Documenting Code

- Write code that explains itself through clear structure and naming
- Choose descriptive variable and function names
- Break complex logic into well-named helper functions
- Let the code be the primary documentation

## Minimal, Helpful Comments

- Add concise, minimal comments to explain large sections of code logic
- Comment the "why", not the "what" - the code shows what it does
- Explain non-obvious decisions or trade-offs
- Document complex algorithms or business rules

## Don't Comment Changes or Fixes

- Do not leave code comments that speak to recent or temporary changes
- Comments should be evergreen informational texts
- Avoid comments like "fixed bug #123" or "temporary workaround"
- Use version control for change history, not comments

## When to Comment

Good uses for comments:

- Explaining complex business logic
- Documenting non-obvious performance optimizations
- Warning about gotchas or edge cases
- Providing context that isn't clear from code alone

## When NOT to Comment

Avoid comments that:

- Repeat what the code clearly says
- Describe obvious operations
- Are outdated or incorrect
- Add noise without value

## Documentation vs Comments

- Use README files for setup and usage instructions
- Use doc comments/docstrings for public APIs
- Use inline comments sparingly for implementation details
- Keep comments close to the code they describe
