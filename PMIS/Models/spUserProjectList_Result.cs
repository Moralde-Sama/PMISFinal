//------------------------------------------------------------------------------
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
    
    public partial class spUserProjectList_Result
    {
        public int projId { get; set; }
        public string status { get; set; }
        public string title { get; set; }
        public string creator { get; set; }
        public Nullable<int> Completed { get; set; }
        public Nullable<int> Pending { get; set; }
        public Nullable<int> Available { get; set; }
    }
}
