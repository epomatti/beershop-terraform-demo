using System;
using app.Models;
using System.Linq;
using Microsoft.Azure.ServiceBus;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;

namespace app.Repositories
{

    public class OrderRepository
    {

        private MasterContext _context;
        private readonly IConfiguration _config;
        

        public OrderRepository(MasterContext context, IConfiguration config)
        {
            this._context = context;
            this._config = config;
        }

        public async void CreateOrder(BeerOrder beerOrder)
        {
            Guid orderId = this.InsertOrder(beerOrder);
            await this.Enqueue(orderId);
        }

        private Guid InsertOrder(BeerOrder beerOrder)
        {
            var order = new Order
            {
                Beer = _context.Beers.Where(x => x.Id == beerOrder.BeerId).SingleOrDefault(),
                Processed = false,
                CreatedAt = DateTime.Now
            };
            _context.Orders.Add(order);
            _context.SaveChanges();
            return order.Id;
        }

        private async Task Enqueue(Guid orderId)
        {            
            IQueueClient queueClient = null;
            try {
                var connectionString = _config["SERVICE_BUS_CONNECTION_STRING"];
                queueClient = new QueueClient(connectionString, "sbq-orders");
                var message = new Message(Encoding.UTF8.GetBytes(orderId.ToString()));
                await queueClient.SendAsync(message);
            } finally {
                if(queueClient != null) {
                    await queueClient.CloseAsync();
                }
            }
        }

    }
}