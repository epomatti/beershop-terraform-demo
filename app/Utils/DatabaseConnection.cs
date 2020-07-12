using Microsoft.Extensions.Configuration;

namespace Beershop
{
    public class DatabaseConnection
    {
        public static string GetConnectionString(IConfiguration Configuration)
        {
            var user = Configuration["PGUSER"];
            var host = Configuration["PGHOST"];
            var password = Configuration["PGPASSWORD"];
            var database = Configuration["PGDATABASE"];
            var port = Configuration["PGPORT"];
            return $"Host={host};Port={port};Username={user};Password={password};Database={database};SSL Mode=prefer";
        }
    }
}