//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace WatchStore.Models
{
    using System;
    using System.Collections.Generic;
    
    public partial class Post
    {
        public int Id { get; set; }
        public int Topid { get; set; }
        public string Title { get; set; }
        public string Slug { get; set; }
        public string Detail { get; set; }
        public string Img { get; set; }
        public string Type { get; set; }
        public string MetaKey { get; set; }
        public string MetaDesc { get; set; }
        public System.DateTime Created_At { get; set; }
        public Nullable<int> Created_By { get; set; }
        public System.DateTime Updated_At { get; set; }
        public Nullable<int> Updated_By { get; set; }
        public int Status { get; set; }
    
        public virtual Topic Topic { get; set; }
    }
}