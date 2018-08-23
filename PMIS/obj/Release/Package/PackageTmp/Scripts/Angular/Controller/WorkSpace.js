module.controller("wspaceCtrl", ["$scope", "$http", function (s, h) {

    wspaceList();

    function wspaceList() {
        h.post("../Workspace/getWspace").then(function (r) {
            s.workspaces = r.data;
        })
    }
}])