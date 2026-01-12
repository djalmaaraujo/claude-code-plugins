# Validation Best Practices

These conventions ensure data integrity and security through proper validation.

## Validate on Server Side

- Always validate on the server
- Never trust client-side validation alone for security or data integrity
- Server-side validation is the authoritative source of truth
- Assume all client input is potentially malicious

## Client-Side for UX

- Use client-side validation to provide immediate user feedback
- Duplicate all client-side checks on the server
- Client validation improves user experience, not security
- Show validation errors inline near the relevant fields

## Fail Early

- Validate input as early as possible
- Reject invalid data before processing begins
- Return all validation errors at once, not one at a time
- Validate at system boundaries

## Specific Error Messages

- Provide clear, field-specific error messages
- Help users understand exactly what's wrong
- Suggest how to correct the input
- Use consistent error message patterns

## Allowlists Over Blocklists

- Define what is allowed rather than trying to block everything that's not
- Allowlists are more secure and maintainable
- Blocklists inevitably miss edge cases
- Be explicit about accepted values and formats

## Type and Format Validation

- Check data types match expectations
- Validate formats (email, phone, URL, etc.)
- Enforce ranges and bounds for numeric values
- Verify required fields are present and non-empty

## Sanitize Input

- Sanitize user input to prevent injection attacks
- Protect against SQL injection, XSS, command injection
- Use parameterized queries and prepared statements
- Escape output appropriately for the context

## Business Rule Validation

- Validate business rules at the appropriate application layer
- Check constraints like sufficient balance, valid dates
- Enforce referential integrity
- Validate state transitions

## Consistent Validation

- Apply validation consistently across all entry points
- Web forms, API endpoints, background jobs all need validation
- Share validation logic where possible
- Document validation rules clearly
