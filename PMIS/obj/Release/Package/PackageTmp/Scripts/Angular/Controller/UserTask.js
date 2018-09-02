module.controller("userTask", ["$scope", "$http", "$routeParams", function (s, h, rp) {

    var userInfo = JSON.parse(localStorage.userInfo);

    s.data = {};

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

            var userplParam = { "userId": userInfo[0].userId };
            h.post("../Project/getUserProjectList", userplParam).then(function (r) {
                s.projlist = r.data;
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

    s.submitCancelTask = function (Index, taskId) {
        var btn = document.getElementById("btnSubmit" + Index);
        var text = $("#btnSubmit" + Index).text();
        if (text == " Submit") {
            var updatetuParam = { "taskId": s.data.taskId, "status": "Pending" };
            h.post("../Project/updateTaskUser", updatetuParam).then(function (r) {
                if (r.data == "Success") {
                    btn.innerHTML = '<i class="fa fa-remove"> Cancel</i>';
                    btn.className = "btn btn-warning";
                    refreshTask();
                    alert("Updated Successfull!");
                }
                else {
                    alert("Error!");
                }
            })
        }
        else {
            var updatetuParam = { "taskId": s.data.taskId, "status": "Available" };
            h.post("../Project/updateTaskUser", updatetuParam).then(function (r) {
                if (r.data == "Success") {
                    btn.innerHTML = '<i class="fa fa-send"> Submit</i>';
                    btn.className = "btn btn-info";
                    refreshTask();
                    alert("Updated Successfull!");
                }
                else {
                    alert("Error!");
                }
            })
        }
        s.showData(Index, taskId);
    }

    s.showCreatedBy = function (userId, fullname, fullname2, content, index, index2) {
        if (content == "submitted the task") {
            if (userId == userInfo[0].userId) {
                return fullname;
            }
            else {
                $("#" + index + 'log' + index2).css("color", "black");
                return "You";
            }
        }
        else if (content == "canceled the submission") {
            if (userId == userInfo[0].userId) {
                return fullname;
            }
            else {
                $("#" + index + 'log' + index2).css("color", "black");
                return "You";
            }
        }
        else if (userId == userInfo[0].userId) {
            $("#" + index + "log").css("color", "black");
            return "You";
        }
        else {
            console.log("here");
            $("#" + index + "log" + index2).attr("href", "sdf");
            return fullname;
        }
    }
    s.showAssignTo = function (userId, log, fullname, index, index2) {
        if (log != "assigned task to")
            return "";
        else if (userId == userInfo[0].userId){
            $("#assign" + index + index2).css("color", "black");
            return "you"
        }
        else {
            return fullname;
        }
    }

    s.showData = function (index, taskId) {
        var btn = document.getElementById("btnSubmit" + index);
            var taskparam = { "taskId": taskId };
            h.post("../Project/getTaskDetails", taskparam).then(function (r) {
                s.task = r.data;
                s.data.taskId = s.task.taskId;
                $("#title" + index).text(s.task.title);
                $("#comment" + index).text(s.task.description);

                if (s.task.status == "Completed")
                    $("#btn" + index).css("display", "none");
                else
                    $("#btn" + index).css("display", "block");


                if (s.task.status == "Pending") {
                    btn.innerHTML = '<i class="fa fa-remove"> Cancel</i>';
                    btn.className = "btn btn-warning";
                }
                else {
                    btn.innerHTML = '<i class="fa fa-send"> Submit</i>';
                    btn.className = "btn btn-info";
                }

                var logparam = { "taskId": taskId };
                h.post("../Project/getTaskLog", logparam).then(function (r) {
                    s.tasklogs = r.data;
                    if (s.tasklogs.length > 0) {
                        var id = "tasklog" + index;
                        $("#tasklog" + index).css("display", "block");
                        $('#tasklog' + index).animateCss("fadeIn", function () {
                        })
                    }
                })
            })
    }

    s.showhideTask = function (index) {
        var coll = document.getElementsByClassName("mycollapsible");
        var interval2;
        var content = coll[index].nextElementSibling;
                content.style.overflow = "hidden";
                coll[index].classList.toggle("myactive");
                if (content.style.maxHeight) {
                    content.style.maxHeight = null;
                } else {
                    content.style.maxHeight = content.scrollHeight + "px";
                    interval2 = setInterval(function () {
                        content.style.overflow = "visible";
                        clearInterval(interval2);
                    }, 800);
                }

        if ($("#tasklist" + index).text() == " Show Tasks") {
            $("#tasklist" + index).text(" Hide Tasks");
        }
        else {
            $("#tasklist" + index).text(" Show Tasks");
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

    s.participantsCount = function (length) {
        return "+" + (length - 4);
    }
}])