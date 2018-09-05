﻿module.controller("projectCtrl", ["$scope", "$http", function (s, h) {
    
    document.title = "PMIS | Project List";


    var userInfo = JSON.parse(localStorage.userInfo);

    var chat = $.connection.chatHub;

    if ($.connection.hub.state == 4 || $.connection.hub.state == 0) {
        $.connection.hub.start().done(function () {
            alert($.connection.hub.state);
            chat.server.saveConnectionId();
        })
    }

    s.try = "sdf";
    var userarray = [];
    userarray.push(userInfo[0].userId);
    getList();
    s.index = 0;

    function getList() {
        h.post("../User/getParticipants").then(function (r) {
            s.participants = r.data;

            h.post("../User/getUsers?userid=" + userInfo[0].userId).then(function (r) {
                s.users = r.data;

                h.post("../Project/getProjectList").then(function (r) {
                    s.projlist = r.data;
                })
            })
        })
    }

    s.setProjStatusColor = function (status) {
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

    s.participantsCount = function (length) {
        return "+" + (length - 4);
    }

    //Modal

    s.tab = function (tab) {
        if (tab == "tab1") {
            document.getElementById("tab-5").style.display = "block";
            document.getElementById("tab-6").style.display = "none";
        }
        else if (tab == "tab2") {
            document.getElementById("tab-6").style.display = "block";
            document.getElementById("tab-5").style.display = "none";
        }
    }

    s.Modal = function (action) {
        if (action == "show") {
            $("#editmodal").css("display", "block");
            document.getElementById("tab-6").style.display = "none";
            document.getElementById("tab-5").style.display = "block";
            document.getElementById("tab1").className = "active";
            document.getElementById("tab2").className = "";
            $("#editmodal2").animateCss("zoomIn", function () {
            })
        }
        else {
            $("#editmodal2").animateCss("zoomOut", function () {
                $("#editmodal").css("display", "none");
            })
        }
    }

    s.setParticipants = function (id) {
        var index = userarray.indexOf(id);

        if (index == -1) {
            userarray.push(id);
        }
        else {
            userarray.splice(index, 1);
        }

        console.log(userarray);
    }

    s.checkbox = function (id, eq) {
        if (userarray.indexOf(id) != -1) {
            $('.checkParticipants').eq(eq).prop('checked', true);
        }
    }

    s.create = function (d) {
        if (d.title && d.version != "") {
            var Indata = { 'pj': d, 'array': userarray };
            h.post("../Project/addProject", Indata).then(function (r) {
                if (r.data == "Success") {
                    Snarl.addNotification({
                        title: 'Saved Successfully!',
                        icon: '<i class="fa fa-check"></i>',
                        timeout: 3000
                    });
                    userarray = [];
                    userarray.push(userInfo[0].userId);
                    getList();
                    s.data = "";
                    s.Modal('close');
                }
                else {
                    alert("Check your connection.");
                }
            })
        }

        //array.splice(index, 1);
        //for (var i = 0; i < array.length; i++) {
        //    console.log(array[i] + " = " + i);
        //}


        //console.log(s.userInfo[0].firstname);
    }

    //Modal End

}])