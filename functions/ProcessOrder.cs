using System;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;

namespace functions
{
    public static class ProcessOrder
    {
        [FunctionName("ProcessOrder")]
        public static void Run([ServiceBusTrigger("myqueue", Connection = "")]string myQueueItem, ILogger log)
        {
            log.LogInformation($"C# ServiceBus queue trigger function processed message: {myQueueItem}");
        }
    }
}
