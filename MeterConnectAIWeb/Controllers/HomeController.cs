using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Concurrent;

namespace MeterConnectAIWeb.Controllers
{
    public class HomeController : Controller
    {
        private static readonly ConcurrentDictionary<Guid, string> TempGuidToActionMap = new ConcurrentDictionary<Guid, string>();

        public IActionResult GenerateGuidForHome()
        {
            Guid newGuid = Guid.NewGuid();
            TempGuidToActionMap[newGuid] = "Home";
            return RedirectToAction("RedirectToGuid", new { id = newGuid });
        }

        public IActionResult RedirectToGuid(Guid id)
        {
            if (TempGuidToActionMap.TryGetValue(id, out string action))
            {
                TempGuidToActionMap.TryRemove(id, out _);
                return View(action);
            }

            return NotFound();
        }

        public IActionResult Home()
        {
            Guid newGuid = Guid.NewGuid();
            TempGuidToActionMap[newGuid] = "Home";
            return RedirectToAction("RedirectToGuid", new { id = newGuid });
        }
    }
}
