using MeterConnectAIWeb.Models;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Concurrent;

namespace MeterConnectAIWeb.Controllers
{
    public class HomeController : Controller
    {
        private readonly FlyIoSqlService _FlyIoSqlServer;

        public HomeController(FlyIoSqlService service) 
        {
            _FlyIoSqlServer = service;
        }

        public IActionResult Dashboard() 
        { 
            return View();
        }

        public IActionResult Home()
        {


            return View();
        }
    }
}
