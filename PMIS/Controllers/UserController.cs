using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using PMIS.Models;

namespace PMIS.Controllers
{
    public class UserController : Controller
    {
        PMISEntities db = new PMISEntities();
        // GET: User
        public ActionResult Index()
        {
            return View();
        }

        [HttpPost]
        public ActionResult getParticipants()
        {
            var participants = db.spGetParticipants().ToList();
            return Json(participants, JsonRequestBehavior.AllowGet);
        }
        [HttpPost]
        public ActionResult getUsers(string userid)
        {
            int userId = Convert.ToInt32(userid);
            var users = db.users.Where(e => e.userId != userId).ToList();
            return Json(users, JsonRequestBehavior.AllowGet);
        }
        [HttpPost]
        public ActionResult getUser(int userId)
        {
            var users = db.users.Where(e => e.userId == userId).Select(s => new { s.userId, s.firstname, s.middlename, s.lastname, s.profpath, s.coverpath }).First();
            return Json(users, JsonRequestBehavior.AllowGet);
        }
        [HttpPost]
        public ActionResult addNotification(int userId, string type, string content)
        {

            return Json("", JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public ActionResult getuserActivities(int userId)
        {
            
            var activities = db.spgetuseractivites(userId).ToList();
            return Json(activities, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public ActionResult saveMessages(projecmessage message)
        {
                message.date = DateTime.Now;
                db.projecmessages.Add(message);
                db.SaveChanges();
                var multiVal = new { status = "Success", date = message.date };
                return Json(multiVal, JsonRequestBehavior.AllowGet);
        }
    }
}