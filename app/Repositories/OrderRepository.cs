using System;
using app.Models;
using System.Linq;

namespace app.Repositories
{

    public class OrderRepository
    {

        private MasterContext _context;

        public OrderRepository(MasterContext context)
        {
            this._context = context;
        }

        public void CreateOrder(BeerOrder beerOrder)
        {
            this.InsertOrder(beerOrder);
            this.Enqueue(beerOrder);
        }

        private void InsertOrder(BeerOrder beerOrder)
        {
            var order = new Order
            {
                Beer = _context.Beers.Where(x => x.Id == beerOrder.BeerId).SingleOrDefault(),
                Processed = false,
                CreatedAt = DateTime.Now
            };
            _context.Orders.Add(order);
            _context.SaveChanges();
        }

        private void Enqueue(BeerOrder beerOrder)
        {
            
        }

    }
}