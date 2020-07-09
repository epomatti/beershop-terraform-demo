# Functions

## Local development

Pull and start SQL Server

```
docker pull mcr.microsoft.com/mssql/server
docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=StrongPassword#999' -p 1433:1433 -d mcr.microsoft.com/mssql/server
```

Create the settings file and fill it with the required parameters

```
cp local.settings.development local.settings
```

Start the function

```
dotnet restore
func start
```

## References

[Azure Functions Bindings](https://docs.microsoft.com/en-us/azure/azure-functions/functions-bindings-service-bus-trigger?tabs=csharp)