module.controller("projectCtrl", ["$scope", "$http", function (s, h) {
    
    document.title = "PMIS | Project List"

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



}])