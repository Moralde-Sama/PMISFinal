module.config(function ($routeProvider, $locationProvider) {
   
    $routeProvider
    .when("/Project/List", {
        templateUrl: "../PartialViews/ProjList",
        controller: "projectCtrl"
    })
    .when("/Project/Details/projectId=:projId", {
        templateUrl: "../PartialViews/ProjDetails",
        controller: "ProjDetailsCtrl"
    })
    .when("/Project/Add", {
        templateUrl: "../PartialViews/ProjAdd",
        controller: "projAddCtrl"
    })
    .when("/Project/Tasks/projectId=:projId", {
        templateUrl: "../PartialViews/ProjTask",
        controller: "projTask"
    })
    .when("/project/myprojects", {
        templateUrl: "../PartialViews/UserTask",
        controller: "myprojects"
    })
    .when("/user/profile/userId=:userId", {
        templateUrl: "../PartialViews/UserProfile",
        controller: "urprofCtrl"
        
    })
    .when("/user/profile/myprofile", {
        templateUrl: "../PartialViews/MyProfile",
        controller: "profileCtrl"
    })
    .when("/user/dashboard", {
        templateUrl: "../PartialViews/Dashboard",
        controller: "dashboardCtrl"
    })
    $locationProvider.html5Mode(true);
})