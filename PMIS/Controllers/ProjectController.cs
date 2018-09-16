using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using PMIS.Models;
using System.Data.Entity;
using PMIS.Controllers;

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
                getlist.Completed = db.tasks.Where(e => e.projId == getlist.projId && e.status == "Completed").Count();
                getlist.Pending = db.tasks.Where(e => e.projId == getlist.projId && e.status == "Pending").Count();
                getlist.Available = db.tasks.Where(e => e.projId == getlist.projId && e.status == "Available").Count();
                ProjectList store = new ProjectList();
                store.projId = getlist.projId;
                store.title = getlist.title;
                store.creator = getlist.creator;
                if (countAll == 0)
                {
                    store.percentage = 0;
                    store.percentage2 = 0;
                    store.percentage3 = 0;
                    store.status = "Active";
                }
                else
                {
                    double percentage = (Convert.ToDouble(getlist.Completed) / Convert.ToDouble(countAll)) * 100;
                    store.percentage = (int)Math.Round(percentage, 0);
                    double percentage2 = (Convert.ToDouble(getlist.Pending) / Convert.ToDouble(countAll)) * 100;
                    store.percentage2 = (int)Math.Round(percentage2, 0);
                    double percentage3 = (Convert.ToDouble(getlist.Available) / Convert.ToDouble(countAll)) * 100;
                    store.percentage3 = (int)Math.Round(percentage3, 0);

                    if (store.status == "Cancelled")
                    {
                        store.status = "Cancelled";
                    }
                    if (store.percentage == 100)
                    {
                        store.status = "Completed";
                    }
                    else
                    {
                        store.status = "Active";
                    }
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
                getlist.Completed = db.tasks.Where(e => e.projId == getlist.projId && e.status == "Completed").Count();
                getlist.Pending = db.tasks.Where(e => e.projId == getlist.projId && e.status == "Pending").Count();
                getlist.Available = db.tasks.Where(e => e.projId == getlist.projId && e.status == "Available").Count();
                ProjectList store = new ProjectList();
                store.projId = getlist.projId;
                store.title = getlist.title;
                store.creator = getlist.creator;
                if (countAll == 0)
                {
                    store.percentage = 0;
                    store.percentage2 = 0;
                    store.percentage3 = 0;
                    if (getlist.status == "Cancelled")
                    {
                        store.status = "Cancelled";
                    }
                    else { 
                        store.status = "Active";
                    }
                }
                else
                {
                    double percentage = (Convert.ToDouble(getlist.Completed) / Convert.ToDouble(countAll)) * 100;
                    store.percentage = (int)Math.Round(percentage, 0);
                    double percentage2 = (Convert.ToDouble(getlist.Pending) / Convert.ToDouble(countAll)) * 100;
                    store.percentage2 = (int)Math.Round(percentage2, 0);
                    double percentage3 = (Convert.ToDouble(getlist.Available) / Convert.ToDouble(countAll)) * 100;
                    store.percentage3 = (int)Math.Round(percentage3, 0);

                    if (getlist.status == "Cancelled")
                    {
                        store.status = "Cancelled";
                    }
                    else if (store.percentage == 100)
                    {
                        store.status = "Completed";
                    }
                    else
                    {
                        store.status = "Active";
                    }
                }
                listFinal.Add(store);
            }
            return Json(listFinal, JsonRequestBehavior.AllowGet);
        }
        [HttpPost]
        public ActionResult getProjDetails(int projId)
        {
            var projList = db.spGetProjList().Where(e => e.projId == projId).FirstOrDefault();
            projList.Completed = db.tasks.Where(e => e.projId == projId && e.status == "Completed").Count();
            projList.Pending = db.tasks.Where(e => e.projId == projId && e.status == "Pending").Count();
            projList.Available = db.tasks.Where(e => e.projId == projId && e.status == "Available").Count();
            var Details = db.spProjectDetails(projId).FirstOrDefault();
            int countAll = db.tasks.Where(e => e.projId == projId).Count();
            Details.Completed = Convert.ToInt32(projList.Completed);
            Details.Pending = Convert.ToInt32(projList.Pending);
            Details.Available = Convert.ToInt32(projList.Available);
            
            if (countAll == 0)
            {
                Details.Percentage = 0;
                Details.Percentage2 = 0;
                Details.Percentage3 = 0;
                if (projList.status == "Cancelled")
                {
                    Details.status = "Cancelled";
                }
                else { 
                    Details.status = "Active";
                }
            }
            else
            {
                double percentage = (Convert.ToDouble(projList.Completed) / Convert.ToDouble(countAll)) * 100;
                Details.Percentage = (int)Math.Round(percentage, 0);
                double percentage2 = (Convert.ToDouble(projList.Pending) / Convert.ToDouble(countAll)) * 100;
                Details.Percentage2 = (int)Math.Round(percentage2, 0);
                double percentage3 = (Convert.ToDouble(projList.Available) / Convert.ToDouble(countAll)) * 100;
                Details.Percentage3 = (int)Math.Round(percentage3, 0);
            }

            if (projList.status == "Cancelled")
            {
                Details.status = "Cancelled";
            }
            else if (Details.Percentage == 100)
            {
                Details.status = "Completed";
            }
            else
            {
                Details.status = "Active";
            }

            return Json(Details, JsonRequestBehavior.AllowGet);
        }
        [HttpPost]
        public ActionResult getParticipantsByProjId(int projId)
        {
            var participants = db.spGetParticipantsByProj(projId).ToList();
            List<participantsProj> pFinal = new List<participantsProj>();

            foreach (spGetParticipantsByProj_Result p in participants)
            {
                participantsProj participant = new participantsProj();

                participant.userId = p.userId;
                participant.fullname = p.fullname;
                participant.creator = p.creator;
                participant.profpath = p.profpath;
                participant.coverpath = p.coverpath;
                if (p.creator == 1)
                {
                    participant.position = "Creator";
                }
                else
                {
                    participant.position = "Member";
                }

                participant.projects = db.participants.Where(e => e.userId == participant.userId).Count();

                participant.tasks = db.tasks.Where(e => e.assignto == participant.userId).Count();

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
            //try {
                pj.userId = array[0];
                pj.lastupdated = DateTime.Now.ToString("dddd, dd MMMM yyyy hh:mm tt");
                pj.createddate = DateTime.Now.ToString("dddd, dd MMMM yyyy hh:mm tt");
                pj.status = "Active";
                db.projects.Add(pj);
                db.SaveChanges();

                projId = pj.projId;

                useractivity activity = new useractivity();
                activity.userId = pj.userId;
                activity.type = "Project";
                activity.actcontent = "You created a project titled " + pj.title;
                activity.date = DateTime.Now;
                activity.id = projId;
                db.useractivities.Add(activity);
                db.SaveChanges();

                for (int i = 0; i < array.Length; i++)
                {
                    
                    pp.projId = projId;
                    pp.userId = array[i];
                    pp.status = "Active";
                    db.participants.Add(pp);
                    db.SaveChanges();
                }

                var data = new { status= "Success", projId = pj.projId };
                return Json(data, JsonRequestBehavior.AllowGet);
            //}
            //catch (Exception e)
            //{
            //    return Json(projId, JsonRequestBehavior.AllowGet);
            //}



        }

        [HttpPost]
        public ActionResult cancelProject(int cId, string password)
        {
            AccountController acc = new AccountController();

            string pass = acc.EncryptMeth(password);
            int count = db.users.Where(e => e.userId == cId && e.password == pass).Count();
            return Json(count, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public ActionResult updateProject(project project, int[] users, int[] Rusers)
        {
            //try {


                db.Entry(project).State = EntityState.Modified;
                db.SaveChanges();

                

                if (users != null)
                {
                    for (int i = 0; i < users.Length; i++)
                    {
                        int userId = users[i];
                        var pps = db.participants.Where(e => e.projId == project.projId && e.userId == userId).ToList();
                        if (pps.Count() == 1)
                        {
                            participant pp = pps[0];
                            pp.status = "Active";
                            db.Entry(pp).State = EntityState.Modified;
                            db.SaveChanges();
                        }
                        else
                        {
                            participant pp = new participant();
                            pp.projId = project.projId;
                            pp.userId = users[i];
                            pp.status = "Active";
                            db.participants.Add(pp);
                            db.SaveChanges();
                        }
                    }
                }


                if (Rusers != null)
                {
                    for (int i = 0; i < Rusers.Length; i++)
                    {
                        var userId = Rusers[i];
                        var participant = db.participants.Where(e => e.projId == project.projId && e.userId == userId).First();
                        participant.status = "Removed";
                        db.Entry(participant).State = EntityState.Modified;
                        db.SaveChanges();
                    }
                }
                

                return Json("Success", JsonRequestBehavior.AllowGet);
            //}
            //catch (Exception e)
            //{
            //    return Json("Success", JsonRequestBehavior.AllowGet);
            //}
        }
        
        [HttpPost]
        public ActionResult addTask(task task)
        {
        //    try { 
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

                useractivity activity = new useractivity();
                activity.userId = task.createdby;
                activity.type = "Task";
                activity.actcontent = "You created a task and assign to";
                activity.date = DateTime.Now;
                activity.id = task.projId;
                activity.assignto = task.assignto;
                activity.taskId = task.taskId;
                db.useractivities.Add(activity);
                db.SaveChanges();

                projectactivity pact = new projectactivity();
                pact.projId = task.projId;
                pact.taskId = task.taskId;
                pact.status = task.status;
                pact.assignto = task.assignto;
                pact.datetime = date;
                pact.logContent = "created a task and assign to";
                db.projectactivities.Add(pact);
                db.SaveChanges();

                updateLastActDate(task.projId);

                return Json("Success", JsonRequestBehavior.AllowGet);
            //}
            //catch (Exception e)
            //{
            //    return Json("Failed", JsonRequestBehavior.AllowGet);
            //}
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

                updateLastActDate(task.projId);

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
            bool finished;
            try { 
                var task = db.tasks.Where(e => e.taskId == taskId).First();
                var projdetails = db.projects.Where(e => e.projId == task.projId).First();
                task.status = status;
                db.Entry(task).State = EntityState.Modified;
                db.SaveChanges();

                useractivity activity = new useractivity();
                activity.userId = task.assignto;
                activity.type = "Task";
                activity.date = DateTime.Now;
                activity.taskId = task.taskId;
                activity.id = task.projId;

                tasklog log = new tasklog();
                log.taskId = task.taskId;
                log.date = DateTime.Now;

                if (task.status != "Pending"){
                    log.logcontent = "canceled the submission";
                    activity.actcontent = "You canceled the submission of " + task.title;
                    finished = false;
                }
                else {
                    log.logcontent = "finished the task";
                    activity.actcontent = "You finished the task ";
                    finished = true;
                }

                log.assignto = task.assignto;
                db.tasklogs.Add(log);
                db.SaveChanges();

                projectactivity pact = new projectactivity();
                pact.projId = task.projId;
                pact.taskId = task.taskId;
                pact.status = task.status;
                pact.assignto = task.assignto;
                pact.datetime = DateTime.Now;

                if (finished)
                    pact.logContent = "finished the task.";
                else
                    pact.logContent = "canceled the submission.";


                db.useractivities.Add(activity);
                db.SaveChanges();
                db.projectactivities.Add(pact);
                db.SaveChanges();

                updateLastActDate(task.projId);

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
        public ActionResult getUserTask(int userId, int projId)
        {
            var tasks = db.spGetUserTask(projId, userId).ToList();
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
        [HttpPost]
        public ActionResult getProjectActivity(int projId)
        {
            var activites = db.spGetProjectActivity(projId).ToList();
            return Json(activites, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public ActionResult getProjectStatCount(int userId, string role)
        {
            int Completed = 0;
            int Active = 0;
            int Cancelled = 0;
            if (role == "User"){
                 List<spUserProjectList_Result> list = db.spUserProjectList(userId).ToList();
                 List<ProjectList> listFinal = new List<ProjectList>();
                 foreach (spUserProjectList_Result getlist in list)
                 {
                     int countAll = db.tasks.Where(e => e.projId == getlist.projId).Count();

                     double percentage = (Convert.ToDouble(getlist.Completed) / Convert.ToDouble(countAll)) * 100;
                     int percentageF = (int)Math.Round(percentage, 0);

                     if (getlist.status == "Cancelled")
                     {
                         Cancelled++;
                     }
                     if (percentageF == 100)
                     {
                         Completed++;
                     }
                     else
                     {
                         Active++;
                     }
                 }

                 var multiVal = new { Completed = Completed, Active = Active, Cancelled = Cancelled };
                 return Json(multiVal, JsonRequestBehavior.AllowGet);
            }
            else { 
               List<spGetProjList_Result> list = db.spGetProjList().ToList();
               List<ProjectList> listFinal = new List<ProjectList>();
               foreach (spGetProjList_Result getlist in list)
               {
                   int countAll = db.tasks.Where(e => e.projId == getlist.projId).Count();

                   double percentage = (Convert.ToDouble(getlist.Completed) / Convert.ToDouble(countAll)) * 100;
                   int percentageF = (int)Math.Round(percentage, 0);

                   if (getlist.status == "Cancelled")
                   {
                       Cancelled++;
                   }
                   if (percentageF == 100)
                   {
                       Completed++;
                   }
                   else
                   {
                       Active++;
                   }
               }

               var multiVal = new { Completed = Completed, Active = Active, Cancelled = Cancelled };
               return Json(multiVal, JsonRequestBehavior.AllowGet);
            }
            
        }

        [HttpPost]
        public ActionResult getUserTasks(int userId)
        {
            var tasks = db.spgetAllUserTask(userId).ToList();
            return Json(tasks, JsonRequestBehavior.AllowGet);
        }

        private void updateLastActDate(int projId)
        {
            var details = db.projects.Where(e => e.projId == projId).First();
            details.lastupdated = DateTime.Now.ToString("dddd, dd MMMM yyyy hh:mm tt");
            db.Entry(details).State = EntityState.Modified;
            db.SaveChanges();
        }

        private tasklog checkChanged(task task)
        {
            var oldtask = db.tasks.Where(e => e.taskId == task.taskId).First();
            tasklog log = new tasklog();

            useractivity activity = new useractivity();
            activity.userId = task.createdby;
            activity.type = "Task";
            activity.date = DateTime.Now;
            activity.id = task.projId;
            activity.taskId = task.taskId;
            activity.assignto = task.assignto;

            projectactivity pact = new projectactivity();
            pact.projId = oldtask.projId;
            pact.taskId = oldtask.taskId;
            pact.assignto = oldtask.assignto;
            pact.datetime = DateTime.Now;

                if (task.status == "Completed")
                {
                    log.logcontent = "approved the submission";
                    pact.logContent = "approved the submission of";
                    activity.actcontent = "You approved the submission of ";
                    pact.status = task.status;
                }
                else if (task.status == "Return")
                {
                    task.status = "Available";
                    log.logcontent = "returned your task";
                    pact.logContent = "returned the task of";
                    activity.actcontent = "You returned the task of ";
                    pact.status = task.status;
                }
                else if (task.assignto != oldtask.assignto)
                {
                    log.logcontent = "assigned task to";
                    pact.logContent = "assigned task to";
                    activity.actcontent = "You assigned task to";
                    pact.status = task.status;
                }
                else
                {
                    log.logcontent = "assigned task to";
                    pact.logContent = "assigned task to";
                    activity.actcontent = "You assigned task to";
                    pact.status = task.status;
                }

            db.useractivities.Add(activity);
            db.SaveChanges();
            db.projectactivities.Add(pact);
            db.SaveChanges();

            return log;
        }

        [HttpPost]
        public ActionResult getMessages(int projId)
        {
            var messages = db.spgetMessages(projId).ToList();
            return Json(messages, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public ActionResult getProjectTitle(int projId)
        {
            var title = db.projects.Where(e => e.projId == projId).Select(e => e.title).First();
            return Json(new { projTitle = title }, JsonRequestBehavior.AllowGet);
        }
    }
}