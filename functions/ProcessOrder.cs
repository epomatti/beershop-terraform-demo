using System;
using System.Data.SqlClient;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;

namespace functions
{
    public static class ProcessOrder
    {
        [FunctionName("ProcessOrder")]
        public static void Run([ServiceBusTrigger("sbq-orders")] string order, ILogger log)
        {
            log.LogInformation($"C# ServiceBus queue trigger function processed message: {order}");

            var str = Environment.GetEnvironmentVariable("sqldb_connection");
            using (SqlConnection conn = new SqlConnection(str))
            {
                conn.Open();
                var text = "SELECT * from Orders";

                using (SqlCommand cmd = new SqlCommand(text, conn))
                {
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            Console.WriteLine(reader["Beer"]);
                            Console.WriteLine(reader["Processed"]);
                        }
                    }
                }
            }
        }
    }
}