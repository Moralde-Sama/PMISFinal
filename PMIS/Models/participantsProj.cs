using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace PMIS.Models
{
    public class participantsProj
    {
        public int userId { get; set; }
        public string fullname { get; set; }
        public string profpath { get; set; }
        public string coverpath { get; set; }
        public Nullable<int> creator { get; set; }
        public string position { get; set; }
        public int projects { get; set; }
        public int tasks { get; set; }
    }
}