﻿using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Beershop;

namespace Beershop.Controllers
{
    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;
        private OrderRepository _repository;
        private BeershopContext _context;

        public HomeController(ILogger<HomeController> logger, OrderRepository _repository, BeershopContext _context)
        {
            _logger = logger;
            this._repository = _repository;
            this._context = _context;
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
            if (ModelState.IsValid)
            {
                this._repository.CreateOrder(beerOrder);
                return RedirectToAction(nameof(Orders));
            }

            return RedirectToAction(nameof(Index));
        }
    }
}

