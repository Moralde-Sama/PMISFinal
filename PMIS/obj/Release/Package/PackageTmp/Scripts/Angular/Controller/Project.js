module.controller("projectCtrl", ["$scope", "$http", function (s, h) {
    
    s.try = "sdf";
    getList();
    s.index = 0;

    function getList() {
        h.post("../Project/getProjectList").then(function (r) {
            s.projlist = r.data;
        })

        h.post("../User/getParticipants").then(function (r) {
            s.participants = r.data;
        })
    }

    s.click = function () {
        console.log("sdf");
    }
}])