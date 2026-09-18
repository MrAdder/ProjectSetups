# {{NAME}}

{{DESCRIPTION}}

## Layout

- `src/{{NAME}}` — worker service
- `tests/{{NAME}}.Tests` — xUnit tests
- `Directory.Build.props` — shared compiler settings (nullable, warnings as errors)

## Development

```sh
dotnet run --project src/{{NAME}}
dotnet test
```

## Docker

```sh
docker build -t {{NAME}} .
```
