using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace PMIS.Models
{
    public class notif
    {
        public string createdBy { get; set; }
        public string projTitle { get; set; }
        public string type { get; set; }
        public int assignTo { get; set; }
        public int taskId { get; set; }
        public int projId { get; set; }
    }
}