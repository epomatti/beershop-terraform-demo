# Functions

## Local development

```
docker pull mcr.microsoft.com/mssql/server
docker run -e 'ACCEPT_EULA=Y' -e 'MSSQL_SA_PASSWORD=<YourPassword>' -p 1433:1433 -d mcr.microsoft.com/mssql/server
```

```
init.sh
```

```
func start
```

## Reference

[Azure Functions Bindings](https://docs.microsoft.com/en-us/azure/azure-functions/functions-bindings-service-bus-trigger?tabs=csharp)