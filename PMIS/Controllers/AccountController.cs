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
            if (Session["userInfo"] != null)
            {
                return Redirect("../Project/List");
            }
            else { 
                return View();
            }
        }
        [HttpPost]
        public ActionResult Login(string username, string password)
        {
            string EncryptPass = EncryptMeth(password);
            var userInfo = db.users.Where(x => x.username == username && x.password == EncryptPass).Select(e => new {e.userId, e.firstname, e.middlename, e.lastname, e.profpath, e.coverpath, e.status, e.username }).ToList();
            if (userInfo.Count() == 1)
            {
                Session["userInfo"] = userInfo[0];
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
        public ActionResult updateprofile(user data)
        {
            //var profpath = ((user)Session["userInfo"]).profpath;
            //var coverpath = ((user)Session["userInfo"]).coverpath;

            //var extension = profpath.Substring(profpath.Length - 3);
            //string filename = data.username + "." + extension;
            //string filenamecover = data.username + "_" + data.userId + "." + extension;
            ////var old = Path.Combine(Server.MapPath(((user)Session["userInfo"]).profpath));
            ////var path = Path.Combine(Server.MapPath("/uploads"), filename);

            //var oldpic = Path.Combine(Server.MapPath(profpath));
            //var newpic = Path.Combine(Server.MapPath("/uploads"), filename);

            //var oldcover = Path.Combine(Server.MapPath(coverpath));
            //var newcover = Path.Combine(Server.MapPath("/uploads"), filenamecover);


            //System.IO.File.Move(oldpic, newpic);
            //System.IO.File.Move(oldcover, newcover);
            //data.coverpath = "/uploads/" + data.username + "_" + data.userId + "." + extension;
            //data.profpath = "/uploads/" + data.username + "." + extension;
            //db.Entry(data).State = EntityState.Modified;
            //db.SaveChanges();
            //List<user> ur = db.users.Where(e => e.userId == data.userId).ToList();
            //Session["userInfo"] = ur[0];

            var profpath = data.profpath;
            var coverpath = data.coverpath;
            var profileextension = profpath.Substring(profpath.Length - 4);
            var coverextension = coverpath.Substring(profpath.Length - 4);
            string filename_profile = data.username + "_pp_" + DateTime.Now.ToString("MM_dd_yyyy_hh_mm_ss") + profileextension;
            string filename_cover = data.username + "_cv_" + DateTime.Now.ToString("MM_dd_yyyy_hh_mm_ss") + coverextension;


            var oldpic = Path.Combine(Server.MapPath(profpath));
            var newpic = Path.Combine(Server.MapPath("/uploads"), filename_profile);

            var oldcover = Path.Combine(Server.MapPath(coverpath));
            var newcover = Path.Combine(Server.MapPath("/uploads"), filename_cover);
            System.IO.File.Move(oldpic, newpic);
            System.IO.File.Move(oldcover, newcover);
            user f = db.users.FirstOrDefault(x => x.userId == data.userId);
            f.firstname = data.firstname;
            f.username = data.username;
            f.middlename = data.middlename;
            f.lastname = data.lastname;
            f.profpath = "/uploads/" + data.username + "_pp_" + DateTime.Now.ToString("MM_dd_yyyy_hh_mm_ss") + profileextension;
            f.coverpath = "/uploads/" + data.username + "_cv_" + DateTime.Now.ToString("MM_dd_yyyy_hh_mm_ss") + coverextension;
            db.SaveChanges();
            List<user> ur = db.users.Where(e => e.userId == data.userId).ToList();
            return Json(ur, JsonRequestBehavior.AllowGet);


        }
        public ActionResult checkpassword(string oldpassword, int userid)
        {

            List<user> ur = db.users.Where(e => e.userId == userid && e.password == oldpassword).ToList();
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
            f.password = password;
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
                    var ur = db.users.Where(e => e.userId == userid).Select(e => new { e.userId, e.firstname, e.middlename, e.lastname, e.profpath, e.coverpath, e.status, e.username }).ToList();

                    return Json(ur, JsonRequestBehavior.AllowGet);

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
                    var ur = db.users.Where(e => e.userId == userid).Select(e => new { e.userId, e.firstname, e.middlename, e.lastname, e.profpath, e.coverpath, e.status, e.username }).ToList();

                    return Json(ur, JsonRequestBehavior.AllowGet);

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
    }
}