using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace PMIS.Controllers
{
    public class PartialViewsController : Controller
    {
        // GET: PartialViews
        public ActionResult ProjList()
        {
            return View();
        }
        public ActionResult modal()
        {
            return View();
        }
        public ActionResult ProjDetails()
        {
            return View();
        }
        public ActionResult WorkList()
        {
            return View();
        }
        public ActionResult ProjAdd()
        {
            return View();
        }
        public ActionResult ProjTask()
        {
            return View();
        }
        public ActionResult UserTask()
        {
            return View();
        }
        public ActionResult UserProfile()
        {
            return View();
        }
        public ActionResult MyProfile()
        {
            return View();
        }
    }
}