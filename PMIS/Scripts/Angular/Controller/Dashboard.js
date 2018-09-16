module.controller("dashboardCtrl", ["$scope", "$http", "$routeParams", "$location", function (s, h, rp, l) {

    document.title = "PMIS | Dashboard"

    var userInfo = JSON.parse(localStorage.userInfo);

    if (userInfo[0].role == "User") {
        s.myprojects = "My Projects";
        $("#mytasks").css("display", "block");
        $("#mytaskcontent").css("display", "block");
        $("#myactivites").css("display", "block");
        $("#myactivitescont").css("display", "block");
    }
    else {
        s.myprojects = "Projects";
    }

    var chat = $.connection.chatHub;

    if ($.connection.hub.state == 4 || $.connection.hub.state == 0) {
        $.connection.hub.start().done(function () {
            chat.server.saveConnectionId();
        })
    }

    getList();

    function getList() {
        //h.post("../User/getParticipants").then(function (r) {
        //    s.participants = r.data;
        //    console.log(s.participants);

        //    var userplParam = { "userId": userInfo[0].userId };
        //    h.post("../Project/getUserProjectList", userplParam).then(function (r) {
        //        s.projlist = r.data;
        //    })
        //})
        if(userInfo[0].role == "User"){
            h.post("../Project/getProjectStatCount", { userId: userInfo[0].userId, role: userInfo[0].role }).then(function (r) {
                s.statCount = r.data;
            })
            h.post("../Account/getUserTaskCount", { userId: userInfo[0].userId }).then(function (r) {
                s.taskCount = r.data;
            })
            h.post("../User/getuserActivities", { userId: userInfo[0].userId }).then(function (r) {
                s.activities = r.data;
                console.log(s.activities);
                //for (i = 0; i < Object.keys(s.activities).length; i++) {
                //    var type;
                //    if (s.activities[i].type == "Project")
                //        type = "fa fa-folder bg-aqua"

                //    $("#ultimeline").prepend('<li id="activity' + i + '" style="cursor:pointer;"> <i class="' + type + '" style="color:white;"></i>' +
                //        '<div class="timeline-item"> <span class="time"><i class="fa fa-clock-o"></i> 5 mins ago</span>' +
                //        '<h3 class="timeline-header no-border"><a href="#"></a> ' + s.activities[i].actcontent + ' </h3> </div> </li>');
                //    $("#activity" + i).click(function () {

                //    })
                //}
            })
        }
        else {
            h.post("../Project/getProjectStatCount", { userId: 0, role: userInfo[0].role }).then(function (r) {
                s.statCount = r.data;
            })
        }
        //h.post("../Project/getUserTasks", { userId: userInfo[0].userId }).then(function (r) {
        //    s.tasks = r.data;
        //})
    }

    var timelinedate;
    s.timelabel = function (date, index) {
        var dateR = new Date(parseInt(date.substr(6)));
        if (timelinedate == null) {
            timelinedate = dateR;
            $(".tline").eq(index).before($('<li class="time-label"><span class="bg-red" style="color:white;">' +
                moment(timelinedate).format('LL') + '</span></li>'));
        }
        else {

        }

        console.log(dateR.getDate()+ " " + index);

        if (timelinedate.getMonth() == dateR.getMonth() && timelinedate.getDate() == dateR.getDate() && timelinedate.getFullYear() == dateR.getFullYear()) {

            console.log(timelinedate.getDate() + "==" + dateR.getDate());
        }
        else {
            console.log("asd " + ((timelinedate.getDate()) - 1));
            timelinedate.setDate(((timelinedate.getDate()) - 1));
            $(".tline").eq(index).before($('<li class="time-label"><span class="bg-red" style="color:white;">' +
                moment(timelinedate).format('LL') + '</span></li>'));
            timelinedate = dateR;
        }
        
        //if (Object.keys(s.activities).length - 1 == index) {
        //    console.log("KLSJDF");
        //    $(".tline").eq(index).before($('<li class="time-label"><span class="bg-red" style="color:white;">' +
        //        moment(dateR).format('LL') + '</span></li>'));
        //}
    }

    s.timelineType = function (Ttype, type) {
        if (Ttype == type)
            return true;
        else
            return false
    }

    s.changeURL = function (id, type) {
        if(type == "Project")
            l.path("/Project/Details/projectId=" + id);
        else if(type == "Task")
            l.path("/Project/Tasks/projectId=" + id);
    }

    s.timelineIcon = function (type) {
        if (type == "Project")
            return type = "fa fa-folder bg-aqua";
        else if (type == "Task")
            return type = "fa fa-tasks bg-aqua";
    }

    s.timelineTime = function (date) {
        var dateR = new Date(parseInt(date.substr(6)));
        return moment(dateR).format('LT');
    }

    
    s.activityClick = function (id, type) {
        alert(type);
        //if (type == "Project")
        //    $location.path = "../Project/Details/projectId=" + id;
    }
    //s.setStatusColor2 = function (status) {
    //    if (status == "Completed") {
    //        return "labelPrimary";
    //    }
    //    else if (status == "Active") {
    //        return "label label-info";
    //    }
    //    else {
    //        return "label label-default";
    //    }
    //}

    //s.setStatusColor = function (status) {
    //    if (status == "Completed") {
    //        return "labelPrimary";
    //    }
    //    else if (status == "Pending") {
    //        return "label label-warning";
    //    }
    //    else {
    //        return "label label-info";
    //    }
    //}
    //s.data = {};
    //s.showData = function (projTitle, taskId) {
    //    s.projtitle = projTitle;

    //    document.getElementById("tasklog").style.display = "none";
    //    var btn = document.getElementById("btnSubmit1");
    //    var btnWrapper = document.getElementById("showBtn");
    //    btnWrapper.style.display = "none";
    //        var taskparam = { "taskId": taskId };
    //        h.post("../Project/getTaskDetails", taskparam).then(function (r) {
    //            s.task = r.data;
    //            console.log(s.task);
    //            s.data.title = s.task.title;
    //            s.data.description = s.task.description;
    //            s.data.taskId = s.task.taskId;
    //            s.data.projId = s.task.projId;
    //            s.projuserId = s.task.createdby;

    //            if (s.task.status == "Pending") {
    //                btnWrapper.style.display = "block";
    //                btn.innerHTML = '<i class="fa fa-remove"> Cancel</i>';
    //                btn.className = "btn btn-warning";
    //            }
    //            else if (s.task.status == "Completed") {
    //                btnWrapper.style.display = "none";
    //            }
    //            else {
    //                btnWrapper.style.display = "block";
    //                btn.innerHTML = '<i class="fa fa-send"> Submit</i>';
    //                btn.className = "btn btn-info";
    //            }

    //            var logparam = { "taskId": s.data.taskId };
    //            h.post("../Project/getTaskLog", logparam).then(function (r) {
    //                s.tasklogs = r.data;
    //                $("#tasklog").css("display", "block");
    //                $("#tasklog").animateCss("fadeIn", function () {
    //                })
    //            })
    //        })

    //        $("#myModal").css("display", "block");
    //        $("#ModalDialog").animateCss("zoomIn", function () { })
    //}

    //s.submitCancelTask = function () {
    //    var btn = document.getElementById("btnSubmit1");
    //    var text = $("#btnSubmit1").text();
    //    if (text == " Submit") {
    //        var updatetuParam = { "taskId": s.data.taskId, "status": "Pending" };
    //        h.post("../Project/updateTaskUser", updatetuParam).then(function (r) {
    //            if (r.data == "Success") {
    //                console.log("Submit = Success");
    //                s.nf = {};

    //                s.nf.createdby = userInfo[0].firstname + " " + userInfo[0].lastname;
    //                s.nf.projTitle = s.projtitle;
    //                s.nf.type = "Task Submit";
    //                s.nf.projId = s.data.projId;
    //                s.nf.assignTo = s.projuserId;

    //                h.post("../Account/notification", s.nf).then(function (r) {
    //                    console.log(r.data);
    //                    if (r.data != "Error") {
    //                        Snarl.addNotification({
    //                            title: 'Update Successfully!',
    //                            icon: '<i class="fa fa-check"></i>',
    //                            timeout: 3000
    //                        });
    //                        btn.innerHTML = '<i class="fa fa-remove"> Cancel</i>';
    //                        btn.className = "btn btn-warning";
    //                        chat.server.notification(r.data.connId, r.data.content, r.data.type, r.data.id);
    //                    }
    //                    else {
    //                        alert(r.data);
    //                    }
    //                })
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

    //                s.nf = {};

    //                s.nf.createdby = userInfo[0].firstname + " " + userInfo[0].lastname;
    //                s.nf.projTitle = s.projtitle;
    //                s.nf.type = "Task Cancel";
    //                s.nf.projId = s.data.projId;
    //                s.nf.assignTo = s.projuserId;

    //                h.post("../Account/notification", s.nf).then(function (r) {
    //                    if (r.data != "Error") {
    //                        Snarl.addNotification({
    //                            title: 'Updated Successfully!',
    //                            icon: '<i class="fa fa-check"></i>',
    //                            timeout: 3000
    //                        });
    //                        btn.innerHTML = '<i class="fa fa-send"> Submit</i>';
    //                        btn.className = "btn btn-info";
    //                        chat.server.notification(r.data.connId, r.data.content, r.data.type, r.data.id);
    //                    }
    //                    else {
    //                        alert(r.data);
    //                    }
    //                })
    //            }
    //            else {
    //                alert("Error!");
    //            }
    //        })
    //    }


    //    $('#ModalDialog').animateCss('zoomOut', function () {
    //        document.getElementById("myModal").style.display = "none";
    //    });


    //    h.post("../Account/getUserTaskCount", { userId: userInfo[0].userId }).then(function (r) {
    //        s.taskCount = r.data;
    //    })
    //    h.post("../Project/getUserTasks", { userId: userInfo[0].userId }).then(function (r) {
    //        s.tasks = r.data;
    //    })
    //}

    //s.convertJsonDate = function (date) {
    //    var dateR = new Date(parseInt(date.substr(6)));
    //    var Rtime = moment(dateR).fromNow();
    //    return Rtime;
    //}
    //s.showCreatedBy = function (userId, fullname, index, content, userId2, fullname2) {
    //    if (content == "finished the task" || content == "canceled the submission") {
    //        if (userId2 == userInfo[0].userId) {
    //            $("#" + index + "log1").css("color", "black");
    //            return "You";
    //        }
    //        else {
    //            $("#" + index + "log3").attr("href", "/user/profile/userId=" + userId);
    //            return fullname2;
    //        }
    //    }
    //    else if (userId == userInfo[0].userId) {
    //        $("#" + index + "log3").css("color", "black");
    //        return "You";
    //    }
    //    else {
    //        $("#" + index + "log1").attr("href", "/user/profile/userId=" + userId);
    //        return fullname;
    //    }
    //}
    //s.showAssignTo = function (userId, log, index, fullname) {
    //    if (log != "assigned task to") {
    //        return "";
    //    }
    //    else if (userId == userInfo[0].userId) {
    //        $("#" + index + "log2").css("color", "black");
    //        return "you"
    //    }
    //    else {
    //        $("#" + index + "log2").attr("href", "/user/profile/userId=" + userId);
    //        $("#" + index + "log4").attr("href", "/user/profile/userId=" + userId);
    //        return fullname;
    //    }
    //}

    //s.closeAssignTo = function () {
    //    $('#ModalDialog').animateCss('zoomOut', function () {
    //        document.getElementById("myModal").style.display = "none";
    //    });
    //}

    //s.participantsCount = function (length) {
    //    return "+" + (length - 4);
    //}
}])