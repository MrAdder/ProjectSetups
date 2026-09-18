FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY . .
RUN dotnet publish src/{{NAME}} --configuration Release --output /out

FROM mcr.microsoft.com/dotnet/runtime:10.0
WORKDIR /app
COPY --from=build /out .
USER $APP_UID
ENTRYPOINT ["dotnet", "{{NAME}}.dll"]
