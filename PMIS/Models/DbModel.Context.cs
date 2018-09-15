﻿//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace PMIS.Models
{
    using System;
    using System.Data.Entity;
    using System.Data.Entity.Infrastructure;
    using System.Data.Entity.Core.Objects;
    using System.Linq;
    
    public partial class PMISEntities : DbContext
    {
        public PMISEntities()
            : base("name=PMISEntities")
        {
        }
    
        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            throw new UnintentionalCodeFirstException();
        }
    
        public virtual DbSet<notification> notifications { get; set; }
        public virtual DbSet<project> projects { get; set; }
        public virtual DbSet<projectactivity> projectactivities { get; set; }
        public virtual DbSet<task> tasks { get; set; }
        public virtual DbSet<tasklog> tasklogs { get; set; }
        public virtual DbSet<projecmessage> projecmessages { get; set; }
        public virtual DbSet<participant> participants { get; set; }
        public virtual DbSet<user> users { get; set; }
        public virtual DbSet<useractivity> useractivities { get; set; }
    
        public virtual ObjectResult<spgetTaskLog_Result> spgetTaskLog(Nullable<int> taskId)
        {
            var taskIdParameter = taskId.HasValue ?
                new ObjectParameter("taskId", taskId) :
                new ObjectParameter("taskId", typeof(int));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<spgetTaskLog_Result>("spgetTaskLog", taskIdParameter);
        }
    
        public virtual ObjectResult<spGetUserTask_Result> spGetUserTask(Nullable<int> projId, Nullable<int> userId)
        {
            var projIdParameter = projId.HasValue ?
                new ObjectParameter("projId", projId) :
                new ObjectParameter("projId", typeof(int));
    
            var userIdParameter = userId.HasValue ?
                new ObjectParameter("userId", userId) :
                new ObjectParameter("userId", typeof(int));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<spGetUserTask_Result>("spGetUserTask", projIdParameter, userIdParameter);
        }
    
        public virtual ObjectResult<spGetProjTask_Result> spGetProjTask(Nullable<int> projId)
        {
            var projIdParameter = projId.HasValue ?
                new ObjectParameter("projId", projId) :
                new ObjectParameter("projId", typeof(int));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<spGetProjTask_Result>("spGetProjTask", projIdParameter);
        }
    
        public virtual ObjectResult<spGetProjectActivity_Result> spGetProjectActivity(Nullable<int> projId)
        {
            var projIdParameter = projId.HasValue ?
                new ObjectParameter("projId", projId) :
                new ObjectParameter("projId", typeof(int));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<spGetProjectActivity_Result>("spGetProjectActivity", projIdParameter);
        }
    
        public virtual ObjectResult<spProjectStatCount_Result> spProjectStatCount(Nullable<int> userId)
        {
            var userIdParameter = userId.HasValue ?
                new ObjectParameter("userId", userId) :
                new ObjectParameter("userId", typeof(int));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<spProjectStatCount_Result>("spProjectStatCount", userIdParameter);
        }
    
        public virtual ObjectResult<spgetUserTaskCount_Result> spgetUserTaskCount(Nullable<int> userId)
        {
            var userIdParameter = userId.HasValue ?
                new ObjectParameter("userId", userId) :
                new ObjectParameter("userId", typeof(int));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<spgetUserTaskCount_Result>("spgetUserTaskCount", userIdParameter);
        }
    
        public virtual ObjectResult<spgetAllUserTask_Result> spgetAllUserTask(Nullable<int> userId)
        {
            var userIdParameter = userId.HasValue ?
                new ObjectParameter("userId", userId) :
                new ObjectParameter("userId", typeof(int));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<spgetAllUserTask_Result>("spgetAllUserTask", userIdParameter);
        }
    
        public virtual ObjectResult<spGetParticipantsByProj_Result> spGetParticipantsByProj(Nullable<int> projId)
        {
            var projIdParameter = projId.HasValue ?
                new ObjectParameter("projId", projId) :
                new ObjectParameter("projId", typeof(int));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<spGetParticipantsByProj_Result>("spGetParticipantsByProj", projIdParameter);
        }
    
        public virtual ObjectResult<spGetParticipants_Result> spGetParticipants()
        {
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<spGetParticipants_Result>("spGetParticipants");
        }
    
        public virtual ObjectResult<spGetProjList_Result> spGetProjList()
        {
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<spGetProjList_Result>("spGetProjList");
        }
    
        public virtual ObjectResult<spUserProjectList_Result> spUserProjectList(Nullable<int> userId)
        {
            var userIdParameter = userId.HasValue ?
                new ObjectParameter("userId", userId) :
                new ObjectParameter("userId", typeof(int));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<spUserProjectList_Result>("spUserProjectList", userIdParameter);
        }
    
        public virtual ObjectResult<spProjectDetails_Result> spProjectDetails(Nullable<int> projId)
        {
            var projIdParameter = projId.HasValue ?
                new ObjectParameter("projId", projId) :
                new ObjectParameter("projId", typeof(int));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<spProjectDetails_Result>("spProjectDetails", projIdParameter);
        }
    
        public virtual ObjectResult<spgetuseractivites_Result> spgetuseractivites(Nullable<int> userId)
        {
            var userIdParameter = userId.HasValue ?
                new ObjectParameter("userId", userId) :
                new ObjectParameter("userId", typeof(int));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<spgetuseractivites_Result>("spgetuseractivites", userIdParameter);
        }
    }
}
