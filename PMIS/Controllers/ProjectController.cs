using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using PMIS.Models;
using System.Data.Entity;

namespace PMIS.Controllers
{
    public class ProjectController : Controller
    {
        PMISEntities db = new PMISEntities();
        // GET: Project
        public ActionResult List()
        {
            return View();
        }

        [HttpPost]
        public ActionResult getProjectList()
        {
            List<spGetProjList_Result> list = db.spGetProjList().ToList();
            List<ProjectList> listFinal = new List<ProjectList>();
            foreach (spGetProjList_Result getlist in list)
            {
                int countAll = db.tasks.Where(e => e.projId == getlist.projId).Count();
                ProjectList store = new ProjectList();
                store.projId = getlist.projId;
                store.status = getlist.status;
                store.title = getlist.title;
                store.creator = getlist.creator;
                if (countAll == 0)
                {
                    store.percentage = 0;
                }
                else
                {
                    double percentage = (Convert.ToDouble(getlist.Completed) / Convert.ToDouble(countAll)) * 100;
                    store.percentage = (int)Math.Round(percentage, 0);
                }
                listFinal.Add(store);
            }
            return Json(listFinal, JsonRequestBehavior.AllowGet);
        }
        [HttpPost]
        public ActionResult getUserProjectList(int userId)
        {
            List<spUserProjectList_Result> list = db.spUserProjectList(userId).ToList();
            List<ProjectList> listFinal = new List<ProjectList>();
            foreach (spUserProjectList_Result getlist in list)
            {
                int countAll = db.tasks.Where(e => e.projId == getlist.projId).Count();
                ProjectList store = new ProjectList();
                store.projId = getlist.projId;
                store.status = getlist.status;
                store.title = getlist.title;
                store.creator = getlist.creator;
                if (countAll == 0)
                {
                    store.percentage = 0;
                }
                else
                {
                    double percentage = (Convert.ToDouble(getlist.Completed) / Convert.ToDouble(countAll)) * 100;
                    store.percentage = (int)Math.Round(percentage, 0);
                }
                listFinal.Add(store);
            }
            return Json(listFinal, JsonRequestBehavior.AllowGet);
        }
        [HttpPost]
        public ActionResult getProjDetails(int projId)
        {
            var projList = db.spGetProjList().Where(e => e.projId == projId).FirstOrDefault();
            var Details = db.spProjectDetails(projId).FirstOrDefault();
            int countAll = db.tasks.Where(e => e.projId == projId).Count();
            
            if (countAll == 0)
            {
                Details.Percentage = 0;
            }
            else
            {
                double percentage = (Convert.ToDouble(projList.Completed) / Convert.ToDouble(countAll)) * 100;
                Details.Percentage = (int)Math.Round(percentage, 0);
            }

            return Json(Details, JsonRequestBehavior.AllowGet);
        }
        [HttpPost]
        public ActionResult getParticipantsByProjId(int projId)
        {
            var participants = db.spGetParticipantsByProj(projId).ToList();
            List<spGetParticipantsByProj_Result> pFinal = new List<spGetParticipantsByProj_Result>();

            foreach (spGetParticipantsByProj_Result p in participants)
            {
                spGetParticipantsByProj_Result participant = new spGetParticipantsByProj_Result();

                participant.userId = p.userId;
                participant.fullname = p.fullname;
                participant.creator = p.creator;
                participant.profpath = p.profpath;
                if (p.creator == 1)
                {
                    participant.position = "Creator";
                }
                else
                {
                    participant.position = "Member";
                }
                pFinal.Add(participant);
            }

            return Json(pFinal, JsonRequestBehavior.AllowGet);
        }
        [HttpPost]
        public ActionResult getParticipantsCount(int projId)
        {
            int count = db.participants.Where(e => e.projId == projId).Count();
            return Json(count, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public ActionResult addProject(project pj, int[] array)
        {
            int projId = 0;
            participant pp = new participant();
            try {
                pj.userId = array[0];
                pj.lastupdated = DateTime.Now.ToString("dddd, dd MMMM yyyy hh:mm tt");
                pj.createddate = DateTime.Now.ToString("dddd, dd MMMM yyyy hh:mm tt");
                pj.status = "Active";
                db.projects.Add(pj);
                db.SaveChanges();

                projId = pj.projId;
                for (int i = 0; i < array.Length; i++)
                {
                    
                    pp.projId = projId;
                    pp.userId = array[i];
                    db.participants.Add(pp);
                    db.SaveChanges();
                }
                    return Json("Success", JsonRequestBehavior.AllowGet);
            }
            catch (Exception e)
            {
                return Json(projId, JsonRequestBehavior.AllowGet);
            }

        }
        
        [HttpPost]
        public ActionResult addTask(task task)
        {
            try { 
                DateTime date = DateTime.Now;
                task.status = "Available";
                task.startdate = date;
                db.tasks.Add(task);
                db.SaveChanges();

                for (int i = 0; i < 2; i++)
                {
                    DateTime date2 = DateTime.Now;
                    tasklog log = new tasklog();
                    log.taskId = task.taskId;
                    if(i == 0)
                        log.logcontent = "created the task";
                    else
                        log.logcontent = "assigned task to";
                    log.date = date2;
                    log.assignto = task.assignto;
                    db.tasklogs.Add(log);
                    db.SaveChanges();
                }
                return Json("Success", JsonRequestBehavior.AllowGet);
            }
            catch (Exception e)
            {
                return Json("Failed", JsonRequestBehavior.AllowGet);
            }
        }
        [HttpPost]
        public ActionResult updateTask(task task)
        {
            try
            {
                task.startdate = DateTime.Now;
                db.Entry(task).State = EntityState.Modified;
                db.SaveChanges();

                tasklog log = checkChanged(task);
                log.taskId = task.taskId;
                log.date = DateTime.Now;
                log.assignto = task.assignto;
                db.tasklogs.Add(log);
                db.SaveChanges();

                return Json("Success", JsonRequestBehavior.AllowGet);
            }
            catch (Exception e)
            {
                return Json(e.Message, JsonRequestBehavior.AllowGet);
            }
        }
        [HttpPost]
        public ActionResult updateTaskUser(int taskId, string status)
        {
            try { 
                var task = db.tasks.Where(e => e.taskId == taskId).First();
                task.status = status;
                db.Entry(task).State = EntityState.Modified;
                db.SaveChanges();

                tasklog log = new tasklog();
                log.taskId = task.taskId;
                log.date = DateTime.Now;

                if (task.status != "Pending")
                    log.logcontent = "canceled the submission";
                else
                    log.logcontent = "submitted the task";

                log.assignto = task.assignto;
                db.tasklogs.Add(log);
                db.SaveChanges();

                return Json("Success", JsonRequestBehavior.AllowGet);
            }
            catch (Exception e)
            {
                return Json("Error", JsonRequestBehavior.AllowGet);
            }
        }
        [HttpPost]
        public ActionResult getProjTask(int projId)
        {
            var tasks = db.spGetProjTask(projId).ToList();
            return Json(tasks, JsonRequestBehavior.AllowGet);
        }
        [HttpPost]
        public ActionResult getUserTask(int userId)
        {
            var tasks = db.spGetUserTask(userId).ToList();
            return Json(tasks, JsonRequestBehavior.AllowGet);
        }
        [HttpPost]
        public ActionResult getTaskDetails(int taskId)
        {
            var task = db.tasks.Where(e => e.taskId == taskId).First();
            return Json(task, JsonRequestBehavior.AllowGet);
        }
        [HttpPost]
        public ActionResult getTaskLog(int taskId)
        {
            var tasklog = db.spgetTaskLog(taskId).ToList();
            return Json(tasklog, JsonRequestBehavior.AllowGet);
        }

        private tasklog checkChanged(task task)
        {
            var oldtask = db.tasks.Where(e => e.taskId == task.taskId).First();
            tasklog log = new tasklog();
            if (task.assignto != oldtask.assignto)
            {
                log.logcontent = "assigned task to";
            }
            else
            {
                log.logcontent = "assigned task to";
            }
            return log;
        }
    }
}