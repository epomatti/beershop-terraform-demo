using System;
using Beershop.Models;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using Azure.Messaging.ServiceBus;

namespace Beershop.Repositories
{

    public class OrderRepository
    {

        private BeershopContext _context;
        private readonly IConfiguration _config;


        public OrderRepository(BeershopContext context, IConfiguration config)
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
            var connectionString = _config["BEERSHOP_SERVICEBUS_PRIMARY_CONNECTION_STRING"];
            await using var client = new ServiceBusClient(connectionString);
            ServiceBusSender sender = client.CreateSender("sbq-orders");
            ServiceBusMessage message = new ServiceBusMessage(Encoding.UTF8.GetBytes(orderId.ToString()));
            await sender.SendMessageAsync(message);
        }

    }
}