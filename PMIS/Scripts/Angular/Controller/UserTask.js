module.controller("myprojects", ["$scope", "$http", "$routeParams", function (s, h, rp) {

    var userInfo = JSON.parse(localStorage.userInfo);

    s.data = {};
    var userarray = [];
    userarray.push(userInfo[0].userId);
    s.index = 0;

    //initialize();

    //function initialize() {
    //    var taskParam = { "projId": rp.taskId };
    //    h.post("../Project/getProjTask", taskParam).then(function (r) {
    //        s.tasks = r.data;
    //    })
    //}

    document.title = "PMIS | My Projects"
    getList();

    function getList() {
        h.post("../User/getParticipants").then(function (r) {
            s.participants = r.data;

            h.post("../User/getUsers?userid=" + userInfo[0].userId).then(function (r) {
                s.users = r.data;

                var userplParam = { "userId": userInfo[0].userId };
                h.post("../Project/getUserProjectList", userplParam).then(function (r) {
                    s.projlist = r.data;
                    console.log(s.projlist);
                })
            })
        })

        //refreshTask();
        
    }

    //function refreshTask() {
    //    var taskparam = { "userId": userInfo[0].userId };
    //    h.post("../Project/getUserTask", taskparam).then(function (r) {
    //        s.tasks = r.data;
    //    })
    //}

    //s.submitCancelTask = function (Index, taskId) {
    //    var btn = document.getElementById("btnSubmit" + Index);
    //    var text = $("#btnSubmit" + Index).text();
    //    if (text == " Submit") {
    //        var updatetuParam = { "taskId": s.data.taskId, "status": "Pending" };
    //        h.post("../Project/updateTaskUser", updatetuParam).then(function (r) {
    //            if (r.data == "Success") {
    //                btn.innerHTML = '<i class="fa fa-remove"> Cancel</i>';
    //                btn.className = "btn btn-warning";
    //                refreshTask();
    //                alert("Updated Successfull!");
    //            }
    //            else {
    //                alert("Error!");
    //            }
    //        })
    //    }
    //    else {
    //        var updatetuParam = { "taskId": s.data.taskId, "status": "Available" };
    //        h.post("../Project/updateTaskUser", updatetuParam).then(function (r) {
    //            if (r.data == "Success") {
    //                btn.innerHTML = '<i class="fa fa-send"> Submit</i>';
    //                btn.className = "btn btn-info";
    //                refreshTask();
    //                alert("Updated Successfull!");
    //            }
    //            else {
    //                alert("Error!");
    //            }
    //        })
    //    }
    //    s.showData(Index, taskId);
    //}

    //s.showCreatedBy = function (userId, fullname, fullname2, content, index, index2) {
    //    if (content == "submitted the task") {
    //        if (userId == userInfo[0].userId) {
    //            return fullname;
    //        }
    //        else {
    //            $("#" + index + 'log' + index2).css("color", "black");
    //            return "You";
    //        }
    //    }
    //    else if (content == "canceled the submission") {
    //        if (userId == userInfo[0].userId) {
    //            return fullname;
    //        }
    //        else {
    //            $("#" + index + 'log' + index2).css("color", "black");
    //            return "You";
    //        }
    //    }
    //    else if (userId == userInfo[0].userId) {
    //        $("#" + index + "log").css("color", "black");
    //        return "You";
    //    }
    //    else {
    //        console.log("here");
    //        $("#" + index + "log" + index2).attr("href", "sdf");
    //        return fullname;
    //    }
    //}
    //s.showAssignTo = function (userId, log, fullname, index, index2) {
    //    if (log != "assigned task to")
    //        return "";
    //    else if (userId == userInfo[0].userId){
    //        $("#assign" + index + index2).css("color", "black");
    //        return "you"
    //    }
    //    else {
    //        return fullname;
    //    }
    //}

    //s.showData = function (index, taskId) {
    //    var btn = document.getElementById("btnSubmit" + index);
    //        var taskparam = { "taskId": taskId };
    //        h.post("../Project/getTaskDetails", taskparam).then(function (r) {
    //            s.task = r.data;
    //            s.data.taskId = s.task.taskId;
    //            $("#title" + index).text(s.task.title);
    //            $("#comment" + index).text(s.task.description);

    //            if (s.task.status == "Completed")
    //                $("#btn" + index).css("display", "none");
    //            else
    //                $("#btn" + index).css("display", "block");


    //            if (s.task.status == "Pending") {
    //                btn.innerHTML = '<i class="fa fa-remove"> Cancel</i>';
    //                btn.className = "btn btn-warning";
    //            }
    //            else {
    //                btn.innerHTML = '<i class="fa fa-send"> Submit</i>';
    //                btn.className = "btn btn-info";
    //            }

    //            var logparam = { "taskId": taskId };
    //            h.post("../Project/getTaskLog", logparam).then(function (r) {
    //                s.tasklogs = r.data;
    //                if (s.tasklogs.length > 0) {
    //                    var id = "tasklog" + index;
    //                    $("#tasklog" + index).css("display", "block");
    //                    $('#tasklog' + index).animateCss("fadeIn", function () {
    //                    })
    //                }
    //            })
    //        })
    //}

    //s.showhideTask = function (index) {
    //    var coll = document.getElementsByClassName("mycollapsible");
    //    var interval2;
    //    var content = coll[index].nextElementSibling;
    //            content.style.overflow = "hidden";
    //            coll[index].classList.toggle("myactive");
    //            if (content.style.maxHeight) {
    //                content.style.maxHeight = null;
    //            } else {
    //                content.style.maxHeight = content.scrollHeight + "px";
    //                interval2 = setInterval(function () {
    //                    content.style.overflow = "visible";
    //                    clearInterval(interval2);
    //                }, 800);
    //            }

    //    if ($("#tasklist" + index).text() == " Show Tasks") {
    //        $("#tasklist" + index).text(" Hide Tasks");
    //    }
    //    else {
    //        $("#tasklist" + index).text(" Show Tasks");
    //    }
    //}

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
                if (r.data.status == "Success") {

                    console.log("arraycount " + userarray.length);
                    if (userarray.length > 0) {
                        for (o = 0; o < userarray.length; o++) {

                            if (userarray[o] != userInfo[0].userId) {
                                console.log("count " + o);
                                s.nf = {};

                                s.nf.createdby = userInfo[0].firstname + " " + userInfo[0].lastname;
                                s.nf.projTitle = d.title;
                                s.nf.type = "Project";
                                s.nf.projId = r.data.projId;
                                s.nf.assignTo = userarray[o];

                                h.post("../Account/notification", s.nf).then(function (r) {
                                    chat.server.notification(r.data.connId, r.data.content, r.data.type, r.data.id);
                                })

                                if (userarray.length - 1 == o) {
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
                            }
                        }
                    }
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