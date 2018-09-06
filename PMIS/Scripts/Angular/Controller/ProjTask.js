module.controller("projTask", ["$scope", "$http", "$routeParams", function (s, h, rp) {
    
    document.title = "PMIS | Project Tasks"

    var userInfo = JSON.parse(localStorage.userInfo);

    //Chat

    var chat = $.connection.chatHub;

    if ($.connection.hub.state == 4 || $.connection.hub.state == 0) {
        $.connection.hub.start().done(function () {
            alert($.connection.hub.state);
            chat.server.saveConnectionId();
        })
    }

    //chat end

    s.data = {};
    s.marks1 = ["Accept", "Available"];
    s.marks2 = ["Accept", "Return"];
    
    s.projCreator;
    

    $("#inputSuccess").click(function () {
        $("#inputSuccess1").val("").focus();
    })
    $("#inputSuccess").focus(function () {
        document.getElementById("inputSuccess").style.cursor = "text";
        if ($("#inputSuccess").val() == "Write a task name") {
            $("#inputSuccess").val("");
        }
    })

    s.projId = rp.projId;
    s.data.title = "Write a task name";
    var projDetailsParam = {'ProjId': rp.projId};
    h.post("../Project/getProjDetails", projDetailsParam).then(function (r) {
        s.projuserId = r.data.userId;
        s.projtitle = r.data.title;
        if (r.data.userId != userInfo[0].userId) {
            s.taskTable = false;
            $("#tab1").css("display", "block");
            s.data.title = "Select a Task";
        }
        else {
            s.taskTable = true;
            $("#tab2").css("display", "block");
        }

        refreshTask(r.data.userId);
        getParticipants();
    })


    function refreshTask(id) {
        if (id == userInfo[0].userId) {
            s.projCreator = true;
            var taskparam = { "projId": s.projId };
            h.post("../Project/getProjTask", taskparam).then(function (r) {
                s.tasks = r.data;
            })
        }
        else {
            s.projCreator = false;
            console.log(userInfo[0].userId + " == " + s.projId);
            var taskparam = { "userId": userInfo[0].userId, "projId": s.projId };
            h.post("../Project/getUserTask", taskparam).then(function (r) {
                s.tasks = r.data;
            })
            $("#writeTask").css("display", "none");
        }
    }

    function getParticipants() {
        var partiparam = {'projId': rp.projId };
        h.post("../Project/getParticipantsByProjId", partiparam).then(function (r) {
            s.participants = r.data;
        })
    }

    s.createUPTask = function (data) {
        data.assignto = s.data.assignto;
        data.createdby = userInfo[0].userId;
        data.projId = rp.projId;
        data.status = s.data.status;
        console.log("update status = " + data.status);
        if ($("#btnCreate").text() == "Create Task") {
            //data.title = s.tasktitle;
            h.post("../Project/addTask", data).then(function (r) {
                if (r.data == "Success") {
                    s.nf = {};
                    
                    s.nf.createdby = userInfo[0].firstname + " " + userInfo[0].lastname;
                    s.nf.projTitle = s.projtitle;
                    s.nf.type = "Task";
                    s.nf.projId = rp.projId;
                    s.nf.assignTo = s.data.assignto;

                    h.post("../Account/notification", s.nf).then(function (r) {
                        if (r.data != "Error") {
                            chat.server.notification(r.data.connId, r.data.content, r.data.type, r.data.id);
                            Snarl.addNotification({
                                title: 'Saved Successfully!',
                                icon: '<i class="fa fa-check"></i>',
                                timeout: 3000
                            });
                            s.clear();
                            refreshTask(s.projuserId);
                        }
                        else {
                            alert(r.data);
                        }
                    })
                }
                else {
                    alert("Error");
                }
            })
        }
        else {
            h.post("../Project/updateTask", data).then(function (r) {
                console.log(r.data);
                if (r.data == "Success") {

                    s.nf = {};

                    s.nf.createdby = userInfo[0].firstname + " " + userInfo[0].lastname;
                    s.nf.projTitle = s.projtitle;
                    if(data.status == "Completed")
                        s.nf.type = "Task Approve";
                    else
                        s.nf.type = "Task Return";

                    s.nf.projId = rp.projId;
                    s.nf.assignTo = s.data.assignto;;

                    h.post("../Account/notification", s.nf).then(function (r) {
                        if (r.data != "Error") {
                            chat.server.notification(r.data.connId, r.data.content, r.data.type, r.data.id);
                            Snarl.addNotification({
                                title: 'Updated Successfully!',
                                icon: '<i class="fa fa-check"></i>',
                                timeout: 3000
                            });
                            s.clear();
                            refreshTask(s.projuserId);
                        }
                        else {
                            alert(r.data);
                        }
                    })
                }
                else {
                    alert("Error");
                }
            })
        }
    }

    s.submitCancelTask = function () {
        var btn = document.getElementById("btnSubmit1");
        var text = $("#btnSubmit1").text();
        if (text == " Submit") {
            var updatetuParam = { "taskId": s.data.taskId, "status": "Pending" };
            h.post("../Project/updateTaskUser", updatetuParam).then(function (r) {
                if (r.data == "Success") {

                    s.nf = {};

                    s.nf.createdby = userInfo[0].firstname + " " + userInfo[0].lastname;
                    s.nf.projTitle = s.projtitle;
                    s.nf.type = "Task Submit";
                    s.nf.projId = rp.projId;
                    s.nf.assignTo = s.projuserId;

                    h.post("../Account/notification", s.nf).then(function (r) {
                        if (r.data != "Error") {
                            chat.server.notification(r.data.connId, r.data.content, r.data.type, r.data.id);
                            btn.innerHTML = '<i class="fa fa-remove"> Cancel</i>';
                            btn.className = "btn btn-warning";
                            Snarl.addNotification({
                                title: 'Updated Successfully!',
                                icon: '<i class="fa fa-check"></i>',
                                timeout: 3000
                            });
                            s.clear();
                            refreshTask(s.projuserId);
                        }
                        else {
                            alert(r.data);
                        }
                    })
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

                    s.nf = {};

                    s.nf.createdby = userInfo[0].firstname + " " + userInfo[0].lastname;
                    s.nf.projTitle = s.projtitle;
                    s.nf.type = "Task Cancel";
                    s.nf.projId = rp.projId;
                    s.nf.assignTo = s.projuserId;

                    h.post("../Account/notification", s.nf).then(function (r) {
                        if (r.data != "Error") {
                            chat.server.notification(r.data.connId, r.data.content, r.data.type, r.data.id);
                            btn.innerHTML = '<i class="fa fa-send"> Submit</i>';
                            btn.className = "btn btn-info";
                            Snarl.addNotification({
                                title: 'Updated Successfully!',
                                icon: '<i class="fa fa-check"></i>',
                                timeout: 3000
                            });
                            s.clear();
                            refreshTask(s.projuserId);
                        }
                        else {
                            alert(r.data);
                        }
                    })
                }
                else {
                    alert("Error!");
                }
            })
        }
    }

    s.keyDown = function (input, id) {
        if(input == "New"){
            if ($("#inputSuccess").val() == "") {
                $("#title2").text("Write a task name");
            }
            else{
                s.data.title = $("#inputSuccess").val();
            }
        }
        else {
            if ($("#"+id).val() == "") {
                $("#title2").text("Write a task name");
            }
            else {
                s.data.title = $("#" + id).val();
            }
        }
    }

    s.clear = function () {
        s.data.title = "Write a task name";
        s.data.description = "";
        s.markAs("Available");
        $("#inputSuccess").val("");
        $("#MySelectImg").attr("src", "../uploads/userimage.png");
        $("#MySelectName").text("Click to assign");
        $("#tasklog").animateCss("fadeOut", function () {
            $("#tasklog").css("display", "none");
        })
        $("#tasklog2").animateCss("fadeOut", function () {
            $("#tasklog2").css("display", "none");
        })
        $("#btnSubmit1").animateCss("fadeOut", function () {
            $("#btnSubmit1").css("display", "none");
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

    s.convertJsonDate = function (date) {
        var dateR = new Date(parseInt(date.substr(6)));
        var Rtime = moment(dateR).fromNow();
        return Rtime;
    }
    s.showCreatedBy = function (userId, fullname, index, content, userId2, fullname2) {
        if (content == "finished the task" || content == "canceled the submission") {
            if (userId2 == userInfo[0].userId){
                $("#" + index + "log1").css("color", "black");
                return "You";
            }
            else {
                $("#" + index + "log3").attr("href", "/user/profile/userId=" + userId);
                return fullname2;
            }
        }
        else if (userId == userInfo[0].userId) {
            $("#" + index + "log3").css("color", "black");
            return "You";
        }
        else {
            $("#" + index + "log1").attr("href", "/user/profile/userId=" + userId);
            return fullname;
        }
    }
    s.showAssignTo = function (userId, log, index, fullname) {
        if (log != "assigned task to"){
            return "";
        }
        else if (userId == userInfo[0].userId) {
            $("#" + index + "log2").css("color", "black");
            return "you"
        }
        else {
            $("#" + index + "log2").attr("href", "/user/profile/userId=" + userId);
            $("#" + index + "log4").attr("href", "/user/profile/userId=" + userId);
            return fullname;
        }
    }


    s.showData = function (index, taskId) {
        document.getElementById("tasklog").style.display = "none";
        var btn = document.getElementById("btnSubmit1");
        var btnWrapper = document.getElementById("showBtn");
        if (taskId == "NewTask") {
            s.clear();
            $("#btnCreate").text("Create Task");
        }
        else {
            var taskparam = { "taskId": taskId };
            h.post("../Project/getTaskDetails", taskparam).then(function (r) {
                s.task = r.data;
                s.data.title = s.task.title;
                s.data.description = s.task.description;
                s.data.taskId = s.task.taskId;
                if (s.task.status == "Completed") {
                    s.markAs("Accept");
                    s.defValMark = "Accepted";
                    $("#showBtn").animateCss("fadeOut", function () {
                        btnWrapper.style.display = "none";
                    })
                }
                else if (s.task.status == "Pending") {
                    s.markAs("Pending");
                    btn.innerHTML = '<i class="fa fa-remove"> Cancel</i>';
                    btn.className = "btn btn-warning";
                    btnWrapper.style.display = "block";
                    $("#showBtn").animateCss("fadeIn", function () {
                    })
                }
                else {
                    s.markAs("Available");
                    btn.innerHTML = '<i class="fa fa-send"> Submit</i>';
                    btn.className = "btn btn-info";
                    btnWrapper.style.display = "block";
                    $("#showBtn").animateCss("fadeIn", function () {
                    })
                }

                h.post("../User/getUser?userId=" + s.task.assignto).then(function (r) {
                    s.user = r.data;
                    $("#MySelectImg").attr("src", s.user.profpath);
                    $("#MySelectName").text(s.user.firstname + " " + s.user.middlename.substring(0, 1) + ". " + s.user.lastname);
                    s.data.assignto = s.user.userId;
                })
                var logparam = { "taskId": taskId };
                h.post("../Project/getTaskLog", logparam).then(function (r) {
                    s.tasklogs = r.data;
                    if (s.tasklogs.length > 0) {
                        document.getElementById("tasklog").style.display = "block";
                        $('#tasklog').animateCss("fadeIn", function () {
                        })
                    }
                })
                $("#tasklog").css("display", "block");
                $("#tasklog").animateCss("fadeIn", function () {
                })
                $("#tasklog2").css("display", "block");
                $("#tasklog2").animateCss("fadeIn", function () {
                })
                $("#btnCreate").text("Update");
            })
        }
    }

    s.defValMark = "Available";
    s.markAs = function (mark) {
        if (mark == "Available"){
            s.defValMark = "Available";
            s.data.status = "Available";
        }
        else if (mark == "Accept") {
            s.marks1 = ["Accept", "Return"];
            s.defValMark = "Accept";
            s.data.status = "Completed";
        }
        else if (mark == "Pending") {
            s.marks1 = ["Accept", "Return"];
            s.defValMark = "Pending";
            s.data.status = "Pending";
        }
        else {
            s.marks1 = ["Accept", "Available"];
            s.defValMark = "Return";
            s.data.status = "Return";
        }
    }

    s.assignTo = function (profPath, fullname, userId) {
        $("#MySelectImg").attr("src", profPath);
        $("#MySelectName").text(fullname);
        s.data.assignto = userId;
        $('#myModal').animateCss('zoomOut', function () {
            document.getElementById("myModal").style.display = "none";
        });
    }

    s.clickAssignTo = function () {
        document.getElementById("myModal").style.display = "block";
        $('#myModal').animateCss('zoomIn', function () {
        });
    }
    s.closeAssignTo = function () {
        $('#myModal').animateCss('zoomOut', function () {
            document.getElementById("myModal").style.display = "none";
        });
    }

    //s.timeSince = function(date) {

    //    var seconds = Math.floor((new Date() - date) / 1000);

    //    var interval = Math.floor(seconds / 31536000);

    //    if (interval > 1) {
    //        return interval + " years ago";
    //    }
    //    interval = Math.floor(seconds / 2592000);
    //    if (interval > 1) {
    //        return interval + " months ago";
    //    }
    //    interval = Math.floor(seconds / 86400);
    //    if (interval > 1) {
    //        return interval + " days ago";
    //    }
    //    interval = Math.floor(seconds / 3600);
    //    if (interval > 1) {
    //        return interval + " hours ago";
    //    }
    //    interval = Math.floor(seconds / 60);
    //    if (interval > 1) {
    //        return interval + " minutes ago";
    //    }
    //    return " Just Now";
    //}
}])