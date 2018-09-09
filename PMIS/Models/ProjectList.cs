using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace PMIS.Models
{
    public class ProjectList
    {
        public int projId { get; set; }
        public string status { get; set; }
        public string title { get; set; }
        public string creator { get; set; }
        public int percentage { get; set; }
        public int percentage2 { get; set; }
        public int percentage3 { get; set; }
    }
}