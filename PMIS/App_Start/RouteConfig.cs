﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;

namespace PMIS
{
    public class RouteConfig
    {
        public static void RegisterRoutes(RouteCollection routes)
        {
            routes.IgnoreRoute("{resource}.axd/{*pathInfo}");
            routes.MapRoute(
                "Add Project",
                "Project/Add",
                defaults: new { controller = "Project", action = "List", id = UrlParameter.Optional }
                );
            routes.MapRoute(
                "projdetails",
                "Project/Details/projectId={id}",
                defaults: new { controller = "Project", action = "List", id = UrlParameter.Optional }
                );
            routes.MapRoute(
                "dashboard",
                "user/dashboard",
                defaults: new { controller = "Project", action = "List", id = UrlParameter.Optional }
                );
            routes.MapRoute(
                "ProjectTask",
                "Project/Tasks/projectId={id}",
                defaults: new { controller = "Project", action = "List", id = UrlParameter.Optional }
                );
            routes.MapRoute(
                "MyTask",
                "project/myprojects",
                defaults: new { controller = "Project", action = "List", id = UrlParameter.Optional }
                );
                routes.MapRoute(
                "Profile",
                "user/profile/userId={id}",
                defaults: new { controller = "Project", action = "List", id = UrlParameter.Optional }
                );
                routes.MapRoute(
                    "MyProfile",
                    "user/profile/myprofile",
                    defaults: new { controller = "Project", action = "List", id = UrlParameter.Optional }
                    );
            routes.MapRoute(
                "Login",
                "Project/Account/Login",
                defaults: new { controller = "Account", action = "Login", id = UrlParameter.Optional }
                );
            routes.MapRoute(
                name: "Default",
                url: "{controller}/{action}/{id}",
                defaults: new { controller = "Account", action = "Login", id = UrlParameter.Optional }
            );
        }
    }
}
