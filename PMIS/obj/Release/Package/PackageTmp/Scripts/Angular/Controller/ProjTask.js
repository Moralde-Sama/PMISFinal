module.controller("projTask", ["$scope", "$http", "$routeParams", function (s, h, rp) {
    
    var userInfo = JSON.parse(localStorage.userInfo);

    s.data = {};

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
        $("#inputSuccess").val("");
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

    s.showData = function (index, taskId) {
        if (taskId == "NewTask") {
            s.clear();
            $("#btnCreate").text("Create Task");
        }
        else{
            var taskparam = { "taskId": taskId };
            h.post("../Project/getTaskDetails", taskparam).then(function (r) {
                s.task = r.data;
                s.data.title = s.task.title;
                s.data.description = s.task.description;
                s.data.taskId = s.task.taskId;

                h.post("../User/getUser?userId=" + s.task.assignto).then(function (r) {
                    s.user = r.data;
                    $("#MySelectImg").attr("src", s.user.profpath);
                    $("#MySelectName").text(s.user.firstname + " " + s.user.middlename.substring(0, 1) + ". " + s.user.lastname);
                    s.data.assignto = s.user.userId;
                })
                $("#btnCreate").text("Update");
            })
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