
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
}])