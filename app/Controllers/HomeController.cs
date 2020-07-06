using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using app.Models;

namespace app.Controllers
{
    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;
        private MasterContext _context;

        public HomeController(ILogger<HomeController> logger, MasterContext context)
        {
            _logger = logger;
            this._context = context;
        }

        public IActionResult Index()
        {
            List<Beer> beers = _context.Beers.ToList();
            ViewData["Beers"] = beers;
            return View();
        }

        public IActionResult Orders()
        {
            List<Order> orders = _context.Orders.ToList();
            ViewData["Orders"] = orders;
            return View();
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }

        [HttpPost]
        public IActionResult Buy(BeerOrder beerOrder)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    var order = new Order
                    {
                        Processed = false
                    };
                    _context.Orders.Add(order);
                    _context.SaveChanges();
                    return RedirectToAction(nameof(Orders));
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.ToString());
                //Log the error (uncomment ex variable name and write a log.
                ModelState.AddModelError("", "Unable to save changes. " +
                    "Try again, and if the problem persists " +
                    "see your system administrator.");
            }

            return RedirectToAction(nameof(Orders));
        }
    }
}
