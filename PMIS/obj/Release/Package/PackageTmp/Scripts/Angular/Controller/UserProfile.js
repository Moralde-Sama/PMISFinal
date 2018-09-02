
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