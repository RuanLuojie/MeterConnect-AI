using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Concurrent;

namespace MeterConnectAIWeb.Controllers
{
    public class HomeController : Controller
    {
        public IActionResult Home()
        {
            return View();
        }
    }
}
