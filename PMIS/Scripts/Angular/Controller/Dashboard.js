module.controller("dashboardCtrl", ["$scope", "$http", "$routeParams", function (s, h, rp) {

    document.title = "PMIS | Dashboard"

    var userInfo = JSON.parse(localStorage.userInfo);

    getList();

    function getList() {
        h.post("../User/getParticipants").then(function (r) {
            s.participants = r.data;

            var userplParam = { "userId": userInfo[0].userId };
            h.post("../Project/getUserProjectList", userplParam).then(function (r) {
                s.projlist = r.data;
            })
        })
        h.post("../Project/getProjectStatCount", { userId: userInfo[0].userId }).then(function (r) {
            s.statCount = r.data;
        })
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
}])