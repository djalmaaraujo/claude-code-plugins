# Error Handling Best Practices

These conventions ensure robust error handling that helps users and developers.

## User-Friendly Messages

- Provide clear, actionable error messages to users
- Do not expose technical details or security information
- Include guidance on how to resolve the issue when possible
- Use consistent error message formatting

## Fail Fast and Explicitly

- Validate input and check preconditions early
- Fail with clear error messages rather than allowing invalid state
- Do not silently swallow errors or continue with bad data
- Make failures visible and debuggable

## Specific Exception Types

- Use specific exception/error types rather than generic ones
- Enable targeted handling with meaningful error hierarchies
- Include relevant context in error objects
- Avoid catch-all handlers that hide problems

## Centralized Error Handling

- Handle errors at appropriate boundaries (controllers, API layers)
- Avoid scattering try-catch blocks throughout the codebase
- Use middleware or error boundaries for consistent handling
- Log errors centrally with appropriate context

## Graceful Degradation

- Design systems to degrade gracefully when non-critical services fail
- Provide fallback behavior where appropriate
- Inform users when operating in degraded mode
- Prioritize core functionality over optional features

## Retry Strategies

- Implement exponential backoff for transient failures
- Set maximum retry limits to prevent infinite loops
- Use circuit breakers for external service calls
- Log retry attempts for debugging

## Clean Up Resources

- Always clean up resources (file handles, connections) in finally blocks
- Use try-with-resources or equivalent mechanisms
- Implement proper disposal patterns
- Test cleanup behavior under error conditions
