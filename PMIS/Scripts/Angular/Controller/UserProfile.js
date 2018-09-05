
module.controller("urprofCtrl", ["$scope", "$http", "$routeParams", function (s, h, rp) {
   
  
    initialize();

    function initialize() {
        var userParam = { "userId": rp.userId };
        h.post("../User/getUser", userParam).then(function (r) {
            $("#file").attr("src", r.data.profpath);
            $('#coverid').css("background-image", "url('" + r.data.coverpath + "')");
            $("#fullname").text(r.data.firstname +" "+ r.data.lastname);
        })
    }

    h.post("../User/getParticipants").then(function (r) {
        s.participants = r.data;

        var userplParam = { "userId": userInfo[0].userId };
        h.post("../Project/getUserProjectList", userplParam).then(function (r) {
            s.projlist = r.data;
        })
    })


    h.post("../Project/getUserTasks", { userId: userInfo[0].userId }).then(function (r) {
        s.tasks = r.data;
    })

    s.setStatusColor2 = function (status) {
        if (status == "Completed") {
            return "labelPrimary";
        }
        else if (status == "Active") {
            return "label label-info";
        }
        else {
            return "label label-default";
        }
    }

    s.setStatusColor = function (status) {
        if (status == "Completed") {
            return "labelPrimary";
        }
        else if (status == "Pending") {
            return "label label-warning";
        }
        else {
            return "label label-info";
        }
    }

    s.tabcontrol = function (tab) {
        if (tab == "tab_project") {

            $('#tab-task').removeClass('active in');
            $('#tab-project').addClass('active in');
        }
        else if (tab == "tab_task") {

            $('#tab-project').removeClass('active in');
            $('#tab-task').addClass('active in');
        }
    }


}])