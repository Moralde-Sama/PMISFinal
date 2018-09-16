module.controller("ProjDetailsCtrl", ["$scope", "$http", "$routeParams", "$location", function (s, h, rp, l) {

    document.title = "PMIS | Project Details"

    var userInfo = JSON.parse(localStorage.userInfo);
    if(localStorage.Current != "Details"){
        localStorage.Prev = localStorage.Current;
        localStorage.Current = "Details";
    }
    localStorage.projId = rp.projId;

    var spamCount = 0;
    var spamLimit = 3;
    var mute = 0;
    var creatorId = null;
    var ppArray = null;
    var userarray = [];
    var olduserarray = [];
    var removeuser = [];
    var showbtnEdit;
    var showbtnTask;

    s.data = {};

    var x = window.matchMedia("(max-width: 764px)")
    myFunction(x)
    x.addListener(myFunction)

    var chat = $.connection.chatHub;
    var message = [];
    var messageCount = 0;
    s.creatorPass = "";

    //else {
    //    getProjDetails(rp.projId);
    //    refreshTask();
    //}
    getProjDetails(rp.projId);
    refreshTask();

    function initializeSR() {
        if ($.connection.hub.state == 4 || $.connection.hub.state == 0) {
            $.connection.hub.start().done(function () {
                chat.server.saveConnectionId();
                chat.server.join(s.projDetails.projId);
            })
        }
        else {
            chat.server.join(s.projDetails.projId);
        }
    }

    //$(document).ready(function () {
    //    $("#message").emojioneArea({
    //        events: {
    //            keydown: function (editor, event) {
    //                if (event.keyCode == 13) {

                        

    //                }
    //            }
    //        }
    //    });
    //});

    s.saveMessages = function (event, action) {
        if(event.keyCode == 13 || action == "send"){
        if (message.length == 0) {
            message.push({
                "messId": null,
                "projId": rp.projId,
                "message": $("#message").val(),
                "date": null,
                "userId": userInfo[0].userId
            })
        }
        if (message.length != 0) {

            console.log(message);
            h.post("../User/saveMessages", { message: message[0] }).then(function (r) {

                console.log(r.data.status);
                if (r.data.status == "Success") {
                    message.splice(0, 1);
                    console.log(message.length);
                    var fullname = userInfo[0].firstname + " " + userInfo[0].lastname;
                    chat.server.sendToGroup(fullname, $("#message").val(), userInfo[0].profpath, userInfo[0].userId, r.data.date, rp.projId);
                    $("#message").val("");
                }
            })
        }
      }
    }

    s.setScrollMessage = function (index) {
        if(Object.keys(s.projMessages).length - 1 == index){
            $("#messageContainer").scrollTop($("#messageContainer")[0].scrollHeight);
            $(document).scrollTop($(document)[0].scrollHeight);
        }
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

    s.participants = function (id) {
        var index = userarray.indexOf(id);
        var indexR = removeuser.indexOf(id);

        if (index == -1) {
            userarray.push(id);
            if (indexR != -1) {
                removeuser.splice(index, 1);
            }
        }
        else {
            userarray.splice(index, 1);
            removeuser.push(id);
        }

        console.log(removeuser);
    }

    s.remUsers = function (id) {
        var index = userarray.indexOf(id);

        if (index != -1) {
            userarray.splice(index, 1);
        }
    }

    s.checkbox = function (id, eq) {
        if (userarray.indexOf(id) != -1) {
            $('.checkParticipants').eq(eq).prop('checked', true);
        }
    }

    //s.btnStatus = function (status) {
    //    if (status == "Active") {
    //        $("#btnActive").html('<i class="fa fa-check"></i> Active');
    //        $("#btnSuccess").text("Completed");
    //        $("#btnDefault").text("Cancelled");
    //        s.data.status = "Active";
    //    }
    //    else if (status == "Completed") {
    //        $("#btnSuccess").html('<i class="fa fa-check"></i> Completed');
    //        $("#btnActive").text("Active");
    //        $("#btnDefault").text("Cancelled");
    //        s.data.status = "Completed";
    //    }
    //    else {
    //        $("#btnDefault").html('<i class="fa fa-check"></i> Cancelled');
    //        $("#btnActive").text("Active");
    //        $("#btnSuccess").text("Completed");
    //        s.data.status = "Cancelled";
    //    }
    //}

    s.updateProject = function (data) {
        data.status = "Active";
        for (i = 0; i < olduserarray.length; i++) {
            s.remUsers(olduserarray[i]);

            if (olduserarray.length - 1 == i) {

                console.log(userarray);

                if (s.creatorPass == "") {
                    var updateProjParam = { "project": data, "users": userarray, "Rusers": removeuser };
                    h.post("../Project/updateProject", updateProjParam).then(function (r) {
                        if (r.data == "Success") {

                            console.log("arraycount " + userarray.length);
                            if (userarray.length > 0) {
                                for (o = 0; o < userarray.length; o++) {

                                    console.log("count " + o);
                                    s.nf = {};

                                    s.nf.createdby = userInfo[0].firstname + " " + userInfo[0].lastname;
                                    s.nf.projTitle = data.title;
                                    s.nf.type = "Project";
                                    s.nf.projId = rp.projId;
                                    s.nf.assignTo = userarray[o];

                                    h.post("../Account/notification", s.nf).then(function (r) {
                                        chat.server.notification(r.data.connId, r.data.content, r.data.type, r.data.id);
                                    })

                                    if (userarray.length - 1 == o) {
                                        Snarl.addNotification({
                                            title: 'Updated Successfully!',
                                            icon: '<i class="fa fa-check"></i>',
                                            timeout: 3000
                                        });
                                        getProjDetails(rp.projId);
                                        s.Modal("hide");
                                    }
                                }
                            }
                            else if (removeuser.length > 0) {
                                for (o = 0; o < removeuser.length; o++) {

                                    console.log("count " + o);
                                    s.nf = {};

                                    s.nf.createdby = userInfo[0].firstname + " " + userInfo[0].lastname;
                                    s.nf.projTitle = data.title;
                                    s.nf.type = "Project Remove";
                                    s.nf.projId = rp.projId;
                                    s.nf.assignTo = removeuser[o];

                                    h.post("../Account/notification", s.nf).then(function (r) {
                                        chat.server.notification(r.data.connId, r.data.content, r.data.type, r.data.id);
                                    })

                                    if (removeuser.length - 1 == o) {
                                        Snarl.addNotification({
                                            title: 'Updated Successfully!',
                                            icon: '<i class="fa fa-check"></i>',
                                            timeout: 3000
                                        });
                                        getProjDetails(rp.projId);
                                        s.Modal("hide");
                                    }
                                }
                            }
                            else {
                                Snarl.addNotification({
                                    title: 'Updated Successfully!',
                                    icon: '<i class="fa fa-check"></i>',
                                    timeout: 3000
                                });
                                getProjDetails(rp.projId);
                                s.Modal("hide");
                            }
                        }
                        else {
                            alert(r.data);
                        }
                    })
                }
                else{
                    h.post("../Project/cancelProject", { cId: s.projDetails.userId, password: s.creatorPass }).then(function (r) {
                        if (r.data) {
                            data.status = "Cancelled";

                            var updateProjParam = { "project": data, "users": userarray, "Rusers": removeuser };
                            h.post("../Project/updateProject", updateProjParam).then(function (r) {
                                if (r.data == "Success") {

                                    console.log("arraycount " + userarray.length);
                                    if (userarray.length > 0) {
                                        for (o = 0; o < userarray.length; o++) {

                                            console.log("count " + o);
                                            s.nf = {};

                                            s.nf.createdby = userInfo[0].firstname + " " + userInfo[0].lastname;
                                            s.nf.projTitle = data.title;
                                            s.nf.type = "Project";
                                            s.nf.projId = rp.projId;
                                            s.nf.assignTo = userarray[o];

                                            h.post("../Account/notification", s.nf).then(function (r) {
                                                chat.server.notification(r.data.connId, r.data.content, r.data.type, r.data.id);
                                            })

                                            if (userarray.length - 1 == o) {
                                                Snarl.addNotification({
                                                    title: 'Updated Successfully!',
                                                    icon: '<i class="fa fa-check"></i>',
                                                    timeout: 3000
                                                });
                                                getProjDetails(rp.projId);
                                                s.Modal("hide");
                                            }
                                        }
                                    }
                                    else if (removeuser.length > 0) {
                                        for (o = 0; o < removeuser.length; o++) {

                                            console.log("count " + o);
                                            s.nf = {};

                                            s.nf.createdby = userInfo[0].firstname + " " + userInfo[0].lastname;
                                            s.nf.projTitle = data.title;
                                            s.nf.type = "Project Remove";
                                            s.nf.projId = rp.projId;
                                            s.nf.assignTo = removeuser[o];

                                            h.post("../Account/notification", s.nf).then(function (r) {
                                                chat.server.notification(r.data.connId, r.data.content, r.data.type, r.data.id);
                                            })

                                            if (removeuser.length - 1 == o) {
                                                Snarl.addNotification({
                                                    title: 'Updated Successfully!',
                                                    icon: '<i class="fa fa-check"></i>',
                                                    timeout: 3000
                                                });
                                                getProjDetails(rp.projId);
                                                s.Modal("hide");
                                            }
                                        }
                                    }
                                    else {
                                        Snarl.addNotification({
                                            title: 'Updated Successfully!',
                                            icon: '<i class="fa fa-check"></i>',
                                            timeout: 3000
                                        });
                                        getProjDetails(rp.projId);
                                        s.Modal("hide");
                                    }
                                }
                                else {
                                    alert(r.data);
                                }
                            })

                        }
                        else {
                            alert("Invalid Password");
                            s.creatorPass = "";
                        }
                    })
                }
            }
        }
    }

    //Modal End

    s.click = function (tab) {
        if (tab == "tab1") {
            document.getElementById("tab-1").style.display = "block";
            document.getElementById("tab-2").style.display = "none";
            document.getElementById("tab-3").style.display = "none";
            document.getElementById("tab-4").style.display = "none";
        }
        else if (tab == "tab2") {
            document.getElementById("tab-2").style.display = "block";
            document.getElementById("tab-1").style.display = "none";
            document.getElementById("tab-3").style.display = "none";
            document.getElementById("tab-4").style.display = "none";
        }
        else if (tab == "tab3") {
            document.getElementById("tab-2").style.display = "none";
            document.getElementById("tab-1").style.display = "none";
            document.getElementById("tab-3").style.display = "block";
            document.getElementById("tab-4").style.display = "none";
        }
        else if (tab == "tab4") {
            document.getElementById("tab-4").style.display = "block";
            document.getElementById("tab-2").style.display = "none";
            document.getElementById("tab-1").style.display = "none";
            document.getElementById("tab-3").style.display = "none";
        }
    }

    function getProjDetails(projId) {
        h.post("../project/getProjDetails?projId=" + projId).then(function (r) {
            s.projDetails = r.data;
            s.data = r.data;
            creatorId = s.projDetails.userId;

            initializeSR();
        })

        h.post("../Project/getMessages", { projId: rp.projId }).then(function (r) {
            s.projMessages = r.data;
        })
        
        h.post("../Project/getParticipantsByProjId?projId="+projId).then(function (r) {

            s.projParticipants = r.data;
            console.log(r.data);
            ppArray = r.data;

            console.log("projParticipants");
            for (i = 0; Object.keys(r.data).length; i++) {
                userarray.push(s.projParticipants[i].userId);
                olduserarray.push(s.projParticipants[i].userId);

                if (Object.keys(r.data).length - 1 == i) {
                    h.post("../User/getUsers?userid=" + userInfo[0].userId).then(function (r) {
                        s.users = r.data;
                        console.log("users");

                        showBtns();
                    })
                }
            }
        })

        h.post("../Project/getProjectActivity?projId=" + rp.projId).then(function (r) {
            s.activities = r.data;
        })
    }

    s.messageClassT = function (id) {
        if (id == userInfo[0].userId) {
            return "direct-chat-msg right";
        }
        else {
            return "direct-chat-msg";
        }
    }
    s.messageClassN = function (id) {
        if (id == userInfo[0].userId) {
            return "direct-chat-name pull-right";
        }
        else {
            return "direct-chat-name pull-left";
        }
    }
    s.messageClassTM = function (id) {
        if (id == userInfo[0].userId) {
            return "direct-chat-timestamp pull-left";
        }
        else {
            return "direct-chat-timestamp pull-right";
        }
    }

    s.convertJsonDate = function (date) {
        var date2 = new Date(parseInt(date.substr(6)));
        return moment().format('DD MMM h:mm a');
    }

    s.logcontent = function (content, userId, fullname, userId2, fullname2, index) {
        if (content == "created a task and assign to" || content == "approved the submission of" || content == "returned the task of" || content == "assigned task to") {
            $("#anchor" + index).text(fullname).attr("href", "user/profile/userId=" + userId);
            $("#anchor2" + index).text(fullname2).attr("href", "user/profile/userId=" + userId2);
            
            return content;
        }
        else if (content == "finished the task.") {
            $("#anchor" + index).text(fullname2).attr("href", "user/profile/userId=" + userId2);
            return content;
        }
        else if (content == "canceled the submission.") {
            $("#anchor" + index).text(fullname2).attr("href", "user/profile/userId=" + userId);
            return content;
        }
    }

    var interval = null;
    var interval2 = null;
    s.sendMessage = function () {
        spamCount++;
        if(!mute){
            if($("#message").val() != ""){
                chat.server.sendToGroup(userInfo[0].username, $("#message").val(),  userInfo[0].profpath, $("#getGroup").val());
                $("#message").val('').focus();
            }
            if(interval == null){
                interval = setInterval(function () {
                    if (spamCount > spamLimit) {
                        clearInterval(interval);
                        interval = null;
                        mute = 1;
                    }
                    else {
                        spamCount = 0;
                    }
            }, 700);
            }
        } else {
            alert("You have been muted for spamming please wait for 5 secs to send messages")
        }

    }
    s.sendMessageEnter = function (event) {
        if (event.keyCode == 13 && $("#message").val() != "") {
            spamCount++;
            if (!mute) {
                if ($("#message").val() != "") {
                    chat.server.sendToGroup(userInfo[0].username, $("#message").val(), userInfo[0].profpath, s.projDetails.projId);
                    $("#message").val('').focus();
                }
                if (interval == null && interval2 == null) {
                    interval = setInterval(function () {
                        if (spamCount > spamLimit) {
                            clearInterval(interval);
                            interval = null;
                            mute = 1;
                            interval2 = setInterval(function () {
                                mute = 0;
                                clearInterval(interval2);
                                interval2 = null;
                            }, 5000);
                        }
                        else {
                            spamCount = 0;
                        }
                    }, 1000);
                }
            } else {
                alert("You have been muted for spamming please wait for 5 secs to send messages")
            }
        }
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

    
    //s.showBtns = function (btn) {

    //    if (btn == "edit") {
    //        if (userInfo[0].userId == creatorId) {
    //            return true;
    //        }
    //        else {
    //            return false;
    //        }
    //    }
    //    else if (btn == "task") {
    //        if (userInfo[0].userId == creatorId) {
    //            return true;
    //        }
    //        else {
    //            if (ppArray.some(function (it) {
    //                return it.userId == userInfo[0].userId;
    //            })) {
    //                return true;
    //            }
    //            else {
    //                return false;
    //            }
    //        }
    //    }
    //}

    function showBtns() {
        $("#addProject").hide();
        if (s.projDetails.status == "Cancelled") {
            $("#editProj").hide();
            $("#projTask").hide();
        }
        else if (userInfo[0].userId == creatorId) {
            $("#editProj").show();
            $("#projTask").show();
            $("#projTask").attr("href", "/Project/Tasks/projectId=" + s.projDetails.projId);
            $("#projTask").click(function () {
                $("#editProj").hide();
                $("#projTask").hide();
                btnActions();
            })
        }
        else
        {
            $("#editProj").hide();
            if (ppArray.some(function (it) {
                    return it.userId == userInfo[0].userId;
            })) {
                $("#projTask").show();
                $("#projTask").attr("href", "/Project/Tasks/projectId=" + s.projDetails.projId);
                $("#projTask").click(function () {
                    $("#editProj").hide();
                    $("#projTask").hide();
                    btnActions();
                })
            }
            else {
                $("#projTask").hide();
            }
        }
    }

    function btnActions() {
        localStorage.projId = s.projDetails.projId;
        localStorage.Title = s.projDetails.title;

        $("#breadTitle").text(s.projDetails.title + "Tasks");
        $(".breadcrumb").empty();
        $(".breadcrumb").append('<li><a id="myproject" href="/project/myprojects">My Projects</a></li><li class="active"><a id="projectTitle" href="/Project/Details/projectId=' + s.projDetails.projId + '">' + s.projDetails.title + '</a></li><li class="active"><strong>Task</strong></li>');

        $("#myproject").click(function () {
            $("#editProj").hide();
            $("#projTask").hide();
            $("#addProject").show();
            $(".breadcrumb").empty();
            $("#breadTitle").text("My Projects");
            $(".breadcrumb").append('<li><strong>My Projects</strong></li><li id="second" class="active"></li>');
        })
        $("#projectTitle").click(function () {
            $(".breadcrumb").empty();
            $("#breadTitle").text("Project Details");
            $(".breadcrumb").append('<li><a id="myproject" href="/project/myprojects">My Projects</a></li><li class="active"><strong>' + s.projDetails.title + '</strong></li>');

            $("#myproject").click(function () {
                $("#editProj").hide();
                $("#projTask").hide();
                $("#addProject").show();
                $(".breadcrumb").empty();
                $("#breadTitle").text("My Projects");
                $(".breadcrumb").append('<li><strong>My Projects</strong></li><li id="second" class="active"></li>');
            })
        })
    }

    s.profile = function (userId) {
        l.path("/user/profile/userId=" + userId);
    }

    s.timelineType = function (Ttype, type) {
        if (Ttype == type)
            return true;
        else
            return false
    }
    s.timelineTime = function (date) {
        var dateR = new Date(parseInt(date.substr(6)));
        return moment(dateR).format('LT');
    }
    s.timelineIcon = function (type) {
        if (type == "Project")
            return type = "fa fa-folder";
        else if (type == "Task")
            return type = "fa fa-tasks";
    }
    s.timelineIconBG = function (status) {
        if (status == "Completed") {
            return "#04A65E";
        }
        else if (status == "Pending") {
            return "#F39C14";
        }
        else {
            return "#3E8DBC";
        }
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

        console.log(dateR.getDate() + " " + index);

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

    function myFunction(x) {
        if (x.matches) { // If media query matches
            document.getElementById("progressDetails").style.marginRight = 0;
            document.getElementById("breadcrumbs").style.textAlign = "center";
        } else {
            document.getElementById("progressDetails").style.marginRight = "140px";
            document.getElementById("breadcrumbs").style.textAlign = "end";
        }

        var h = window.innerHeight;
        h = h - 231;
        document.getElementById("messageContainer").style.maxHeight = h + "px";
        document.getElementById("tab-2").style.maxHeight = h + "px";
        document.getElementById("tab-4").style.maxHeight = h + "px";
    }
}])

