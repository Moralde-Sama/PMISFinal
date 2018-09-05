var module = angular.module("myApp", []);

module.controller("UserMgmt", ["$scope", "$http", function (s, h) {
    s.Login = function (data) {
        h.post("../Account/Login?username=" + data.username + "&password=" + data.password)
        .then(function (r) {
            if (r.data == "notfound") {
                alert("Account does not exist");
                s.data.password = "";
            }
            else {
                localStorage.userInfo = JSON.stringify(r.data);
                location.href = "../user/dashboard";
            }
        })

    }

    s.Logout = function () {
        h.post("../Account/Logout").then(function (r) {
            location.href = "..Account/Login";
        })
    }
}])
