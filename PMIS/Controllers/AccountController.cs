using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using PMIS.Models;
using System.IO;
using System.Security.Cryptography;
using System.Text;
using System.Data.Entity;

namespace PMIS.Controllers
{
    public class AccountController : Controller
    {
        PMISEntities db = new PMISEntities();
        // GET: Account
        [HttpGet]
        public ActionResult Login()
        {
            return View();
        }
        [HttpPost]
        public ActionResult Login(string username, string password)
        {
            string EncryptPass = EncryptMeth(password);
            var userInfo = db.users.Where(x => x.username == username && x.password == EncryptPass).Select(e => new {e.userId, e.firstname, e.middlename, e.lastname, e.profpath, e.coverpath, e.status, e.username, e.connectionid, e.role }).ToList();
            if (userInfo.Count() == 1)
            {
                //Session["userInfo"] = userInfo[0];
                return Json(userInfo, JsonRequestBehavior.AllowGet);
            }
            return Json("notfound", JsonRequestBehavior.AllowGet);
        }
        [HttpGet]
        public ActionResult Register()
        {
            return View();
        }
        [HttpPost]
        public ActionResult Register(user p, HttpPostedFileBase file)
        {
            var usercount = db.users.Where(x => x.username == p.username);
            if (usercount.Count() > 0)
            {
                ViewBag.UserExist = true;
                if (p.password != p.password)
                {
                    ViewBag.UserExist = false;
                    ViewBag.UserAndPass = true;
                }
                return View("Register");

            }
            else if (p.password != p.password)
            {
                ViewBag.NotMatch = true;
                return View("Register");
            }
            else
            {
                if (file != null)
                {
                    string extension = Path.GetExtension(file.FileName);
                    string location = "/Uploads/" + p.username.Replace(" ", "") + extension;
                    file.SaveAs(Server.MapPath(location));
                    p.profpath = location;
                    p.status = "Active";
                    p.password = EncryptMeth(p.password);

                    db.users.Add(p);
                    db.SaveChanges();

                }
                else
                {
                    string location = "/uploads/Default.png";

                    p.profpath = location;
                    p.status = "Active";
                    p.password = EncryptMeth(p.password);

                    db.users.Add(p);
                    db.SaveChanges();
                }
                return RedirectToAction("Login");
            }
        }
        public ActionResult Logout()
        {
            Session["userInfo"] = null;
            return RedirectToAction("../Account/Login");
        }
        private string EncryptMeth(string pw)
        {
            MD5CryptoServiceProvider md5 = new MD5CryptoServiceProvider();
            md5.ComputeHash(ASCIIEncoding.ASCII.GetBytes(pw));
            byte[] result = md5.Hash;
            StringBuilder sb = new StringBuilder();
            for (int i = 1; i < result.Length; i++)
            {
                sb.Append(result[i].ToString("x2"));
            }
            return sb.ToString();
        }
        [HttpPost]
        public ActionResult saveConnectionId(string conId, int userId)
        {
            try { 
                var user = db.users.Where(e => e.userId == userId).First();
                user.connectionid = conId;
                user.status = "online";
                db.Entry(user).State = EntityState.Modified;
                db.SaveChanges();

                var userInfo = db.users.Where(x => x.userId == userId).Select(e => new { e.userId, e.firstname, e.middlename, e.lastname, e.profpath, e.coverpath, e.status, e.username, e.connectionid, e.role }).ToList();
                return Json(userInfo, JsonRequestBehavior.AllowGet);
            }
            catch (Exception e)
            {
                return Json("Failed", JsonRequestBehavior.AllowGet);
            }
        }

        [HttpPost]
        public ActionResult onDisconnect(int userId)
        {
            var user = db.users.Where(e => e.userId == userId).First();
                user.status = "offline";
                db.Entry(user).State = EntityState.Modified;
                db.SaveChanges();
            return Json("", JsonRequestBehavior.AllowGet);
        }

        public ActionResult check_username_duplicate(user p)
        {
            var usercount = db.users.Where(x => x.username == p.username);
            if (usercount.Count() > 0)
            {
                return Json("username already exist", JsonRequestBehavior.AllowGet);

            }
            else
            {
                return Json("notexist", JsonRequestBehavior.AllowGet);
            }

            
        }
        [HttpPost]
        public ActionResult updateusername(user data)
        {
            var user = db.users.Where(x => x.userId == data.userId).FirstOrDefault();
            var profpath = user.profpath;
            var coverpath = user.coverpath;
            var profileextension = profpath.Substring(profpath.Length - 27);
            var coverextension = coverpath.Substring(coverpath.Length - 27);
            string filename_profile = "/uploads/"+data.username+profileextension;
            string filename_cover = "/uploads/"+data.username + coverextension;
            var oldpic = Path.Combine(Server.MapPath(profpath));
            var newpic = Path.Combine(Server.MapPath(filename_profile));
            var oldcover = Path.Combine(Server.MapPath(coverpath));
            var newcover = Path.Combine(Server.MapPath(filename_cover));
            System.IO.File.Move(oldpic, newpic);
            System.IO.File.Move(oldcover, newcover);
            user f = db.users.FirstOrDefault(x => x.userId == data.userId);
            f.firstname = data.firstname;
            f.username = data.username;
            f.middlename = data.middlename;
            f.lastname = data.lastname;
            f.profpath = filename_profile;
            f.coverpath = filename_cover;
            db.SaveChanges();

            var userInfo = db.users.Where(x => x.userId == data.userId).Select(e => new { e.userId, e.firstname, e.middlename, e.lastname, e.profpath, e.coverpath, e.status, e.username, e.connectionid, e.role }).ToList();

            return Json(userInfo, JsonRequestBehavior.AllowGet);
        }
        public ActionResult editprofile_info(user data)
        {
            user f = db.users.FirstOrDefault(x => x.userId == data.userId);
            f.firstname = data.firstname;
            f.username = data.username;
            f.middlename = data.middlename;
            f.lastname = data.lastname;
            f.profpath = data.profpath;
            f.coverpath = data.coverpath;
            db.SaveChanges();
            var userInfo = db.users.Where(x => x.userId == data.userId).Select(e => new { e.userId, e.firstname, e.middlename, e.lastname, e.profpath, e.coverpath, e.status, e.username, e.connectionid, e.role }).ToList();
            return Json(userInfo, JsonRequestBehavior.AllowGet);
        }
        public ActionResult checkpassword(string oldpassword, int userid)
        {
            string EncryptPass = EncryptMeth(oldpassword);
            List<user> ur = db.users.Where(e => e.userId == userid && e.password == EncryptPass).ToList();
            if (ur.Count() > 0)
            {
                return Json("exist", JsonRequestBehavior.AllowGet);
            }
            else
            {
                return Json("notexist", JsonRequestBehavior.AllowGet);
            }
        }
        public ActionResult changedpassword(string password, int userid)
        {
            user f = db.users.FirstOrDefault(x => x.userId == userid);
            f.password =EncryptMeth(password);
            db.SaveChanges();
            return Json("Succesfully Updated", JsonRequestBehavior.AllowGet);
        }
        public JsonResult SaveFiles(string username, int userid)
        {
            user u = db.users.FirstOrDefault(x => x.userId == userid);
            string Message, fileName, actualFileName;
            Message = fileName = actualFileName = string.Empty;
            bool flag = false;
            if (Request.Files != null)
            {

                var file = Request.Files[0];
                actualFileName = file.FileName;
                fileName = username + "_pp_" + DateTime.Now.ToString("MM_dd_yyyy_hh_mm_ss") + Path.GetExtension(file.FileName);
                int size = file.ContentLength;
                var extension = Path.GetExtension(file.FileName);



                try
                {
                    var serverpath = Path.Combine(Server.MapPath(u.profpath));
                    if (System.IO.File.Exists(serverpath))
                    {
                        System.IO.File.Delete(serverpath);
                    }


                    file.SaveAs(Path.Combine(Server.MapPath("/uploads"), fileName));
                    //var filepath = Path.Combine(Server.MapPath("~/UploadFiles"), fileName);
                    var filepath = "/uploads/" + fileName;

                    user f = db.users.FirstOrDefault(x => x.userId == userid);
                    f.profpath = filepath;
                    db.SaveChanges();
                    var userInfo = db.users.Where(x => x.userId == userid).Select(e => new { e.userId, e.firstname, e.middlename, e.lastname, e.profpath, e.coverpath, e.status, e.username, e.connectionid, e.role }).ToList();

                    return Json(userInfo, JsonRequestBehavior.AllowGet);

                }
                catch (Exception)
                {
                    Message = "File upload failed! Please try again";
                }

            }

            return new JsonResult { Data = new { Message = Message, Status = flag } };
        }
        public JsonResult UpdateCover(string username, int userid)
        {
            user u = db.users.FirstOrDefault(x => x.userId == userid);
            string Message, fileName, actualFileName;
            Message = fileName = actualFileName = string.Empty;
            bool flag = false;
            if (Request.Files != null)
            {

                var file = Request.Files[0];
                actualFileName = file.FileName;
                fileName = username + "_cv_" + DateTime.Now.ToString("MM_dd_yyyy_hh_mm_ss") + Path.GetExtension(file.FileName);
                int size = file.ContentLength;
                var extension = Path.GetExtension(file.FileName);


                try
                {
                    var serverpath = Path.Combine(Server.MapPath(u.coverpath));
                    if (System.IO.File.Exists(serverpath))
                    {
                        System.IO.File.Delete(serverpath);
                    }


                    file.SaveAs(Path.Combine(Server.MapPath("/uploads"), fileName));
                    //var filepath = Path.Combine(Server.MapPath("~/UploadFiles"), fileName);
                    var filepath = "/uploads/" + fileName;

                    user f = db.users.FirstOrDefault(x => x.userId == userid);
                    f.coverpath = filepath;
                    db.SaveChanges();
                    var userInfo = db.users.Where(x => x.userId == userid).Select(e => new { e.userId, e.firstname, e.middlename, e.lastname, e.profpath, e.coverpath, e.status, e.username, e.connectionid, e.role }).ToList();

                    return Json(userInfo, JsonRequestBehavior.AllowGet);

                }
                catch (Exception)
                {
                    Message = "File upload failed! Please try again";
                }

            }

            return new JsonResult { Data = new { Message = Message, Status = flag } };
        }
        public ActionResult getUser(int id)
        {
            List<user> ur = db.users.Where(e => e.userId == id).ToList();
            return Json(ur[0], JsonRequestBehavior.AllowGet);
        }
        [HttpPost]
        public ActionResult notification(notif nf)
        {
            //try
            //{
                notification notif = new notification();
                notif.date = DateTime.Now;
                if (nf.type == "Task"){
                    notif.userId = nf.assignTo;
                    notif.type = nf.type;
                    notif.notifcontent = nf.createdBy+ " assigned you a task in " + nf.projTitle + " Project";
                    notif.id = nf.projId;
                    notif.status = "New";
                }
                else if (nf.type == "Task Submit")
                {
                    notif.userId = nf.assignTo;
                    notif.type = "Task";
                    notif.notifcontent = nf.createdBy + " finished a task in " + nf.projTitle + " Project";
                    notif.id = nf.projId;
                    notif.status = "New";
                }
                else if (nf.type == "Task Cancel")
                {
                    notif.userId = nf.assignTo;
                    notif.type = "Task";
                    notif.notifcontent = nf.createdBy + " cancelled the submission of task in " + nf.projTitle + " Project";
                    notif.id = nf.projId;
                    notif.status = "New";
                }
                else if (nf.type == "Task Approve")
                {
                    notif.userId = nf.assignTo;
                    notif.type = "Task";
                    notif.notifcontent = nf.createdBy + " approved the submission of your task in " + nf.projTitle + " Project";
                    notif.id = nf.projId;
                    notif.status = "New";
                }
                else if (nf.type == "Task Return")
                {
                    notif.userId = nf.assignTo;
                    notif.type = "Task";
                    notif.notifcontent = nf.createdBy + " returned your task in " + nf.projTitle + " Project";
                    notif.id = nf.projId;
                    notif.status = "New";
                }
                else if (nf.type == "Project")
                {
                    notif.userId = nf.assignTo;
                    notif.type = "Project";
                    notif.notifcontent = nf.createdBy + " added you in " + nf.projTitle + " Project";
                    notif.id = nf.projId;
                    notif.status = "New";
                }
                else if (nf.type == "Project Remove")
                {
                    notif.userId = nf.assignTo;
                    notif.type = "Project";
                    notif.notifcontent = nf.createdBy + " removed you in " + nf.projTitle + " Project";
                    notif.id = nf.projId;
                    notif.status = "New";
                }

                db.notifications.Add(notif);
                db.SaveChanges();
                

                var connectionId = db.users.Where(e => e.userId == notif.userId).Select(e => e.connectionid).First();
                var multipleVal = new { connId = connectionId, content = notif.notifcontent, type = notif.type, id = notif.id };
                return Json(multipleVal, JsonRequestBehavior.AllowGet);
            //}
            //catch (Exception e)
            //{
            //    return Json("Error", JsonRequestBehavior.AllowGet);
            //}
        }
        [HttpPost]
        public ActionResult getNotifications(int userId)
        {
            var notifications = db.notifications.Where(e => e.userId == userId).ToList();
            var count = db.notifications.Where(e => e.userId == userId && e.seen == 0).Count();
            var multipleVal = new { notification = notifications, countNotif = count };
            return Json(multipleVal, JsonRequestBehavior.AllowGet);
        }
        [HttpPost]
        public ActionResult updateNotification(int userId)
        {
            var notifications = db.notifications.Where(e => e.userId == userId && e.seen == 0).ToList();

            foreach (notification notif in notifications)
            {
                notif.seen = 1;
                db.Entry(notif).State = EntityState.Modified;
                db.SaveChanges();
            }

            return Json("", JsonRequestBehavior.AllowGet);
        }
        [HttpPost]
        public ActionResult getConnectionId(int userId)
        {
            var connId = db.users.Where(e => e.userId == userId).Select(e => e.connectionid).First();
            return Json(connId, JsonRequestBehavior.AllowGet);
        }
        
        [HttpPost]
        public ActionResult getUserTaskCount(int userId)
        {
            spgetUserTaskCount_Result taskCount = new spgetUserTaskCount_Result();
            taskCount.Completed = db.tasks.Where(e => e.assignto == userId && e.status == "Completed").Count();
            taskCount.Pending = db.tasks.Where(e => e.assignto == userId && e.status == "Pending").Count();
            taskCount.Available = db.tasks.Where(e => e.assignto == userId && e.status == "Available").Count();
            return Json(taskCount, JsonRequestBehavior.AllowGet);
        }
    }
}