module.controller("projTask", ["$scope", "$http", "$routeParams", function (s, h, rp) {
    
    document.title = "PMIS | Project Tasks"

    var userInfo = JSON.parse(localStorage.userInfo);

    s.data = {};
    s.marks1 = ["Accept", "Available"];
    s.marks2 = ["Accept", "Return"];
    

    refreshTask();
    getParticipants();

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
        s.projtitle = r.data.title;
    })

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
        if ($("#btnCreate").text() == "Create Task") {
            //data.title = s.tasktitle;
            h.post("../Project/addTask", data).then(function (r) {
                if (r.data == "Success") {
                    alert("Save Successfully");
                    s.clear();
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
                    alert("Update Successfully");
                    s.clear();
                }
                else {
                    alert("Error");
                }
            })
        }
        refreshTask();
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
    }

    function refreshTask() {
        var taskparam = { "projId": rp.projId };
        h.post("../Project/getProjTask", taskparam).then(function (r) {
            s.tasks = r.data;
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

    var shit = "S";

    s.convertJsonDate = function (date) {
        var date = new Date(parseInt(s.tasklog[0].date.substr(6)));
        return date;
    }
    s.showCreatedBy = function (userId, fullname, index, content) {
        if (content == "submitted the task" || content == "canceled the submission") {
            return fullname;
        }
        else if (userId == userInfo[0].userId) {
            $("#"+index+"log").css("color", "black");
            return "You";
        }
        else {
            $("#" + index + "log").attr("href", "sdf");
            return fullname;
        }
    }
    s.showAssignTo = function (userId, log, fullname) {
        if (log != "assigned task to"){
            return "";
        }
        else if (userId == userInfo[0].userId){
            return "you"
        }
        else {
            return fullname;
        }
    }


    s.showData = function (index, taskId) {
        document.getElementById("tasklog").style.display = "none";
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
                }
                else if (s.task.status == "Pending") {
                    s.markAs("Pending");
                }
                else {
                    s.markAs("Available");
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
            s.data.status = "Available";
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
}])