# {{NAME}}

{{DESCRIPTION}}

.NET 10 worker service (`src/{{NAME}}`) with xUnit tests (`tests/{{NAME}}.Tests`).

## Commands

- `dotnet run --project src/{{NAME}}` — run
- `dotnet test` — tests
- `dotnet build` — warnings are errors (`Directory.Build.props`); must be clean before finishing

## Conventions

- Nullable reference types are on; do not suppress warnings, fix them.
- Configuration via `appsettings.json` + environment variables; secrets via user-secrets or env, never committed.

{{RULES}}

## This stack

- Local secrets go in `dotnet user-secrets`; deployed secrets come from environment variables or a secret store. Never put them in `appsettings*.json`.
- Use parameterized queries (EF Core LINQ, or Dapper/ADO.NET parameters), never string-built SQL. Validate options at startup with `ValidateOnStart()`.
- NuGet audit is on in `Directory.Build.props` (high severity, transitive packages included) and warnings are errors, so a vulnerable package fails the build locally and in the weekly CI run. The Docker image runs as `$APP_UID` (non-root); keep it that way.
- Async all the way: no `.Result`/`.Wait()`/`.GetAwaiter().GetResult()`. Pass `CancellationToken` through and honor it in `BackgroundService.ExecuteAsync`.
- Create `HttpClient` through `IHttpClientFactory` (or a single shared instance), never per call. Use `LoggerMessage` source generators for logging on hot paths, and `Span<T>`/pooling only after profiling shows a need.
- Log with `ILogger` message templates (`"Processed {ItemId}"`), not string interpolation, and do not log personal data or secrets.
