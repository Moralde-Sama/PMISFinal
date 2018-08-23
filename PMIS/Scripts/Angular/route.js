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
    .when("/Project/NewTask/projectId=:projId", {
        templateUrl: "../PartialViews/ProjTask",
        controller: "projTask"
    })
    .when("/project/mytasks", {
        templateUrl: "../PartialViews/UserTask",
        controller: "userTask"
    })
    .when("/user/profile/userId=:userId", {
        templateUrl: "../PartialViews/UserProfile",
        controller: "profileCtrl"
    })
    $locationProvider.html5Mode(true);
})