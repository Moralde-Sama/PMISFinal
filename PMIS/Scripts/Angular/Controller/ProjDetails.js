module.controller("ProjDetailsCtrl", ["$scope", "$http", "$routeParams", "$location", function (s, h, rp, l) {

    document.title = "PMIS | Project Details"

    var userInfo = JSON.parse(localStorage.userInfo);

    var spamCount = 0;
    var spamLimit = 3;
    var mute = 0;
    var creatorId = null;
    var ppArray = null;

    var x = window.matchMedia("(max-width: 764px)")
    myFunction(x)
    x.addListener(myFunction)

    var chat = $.connection.chatHub;

    if ($.connection.hub.state == 4 || $.connection.hub.state == 0) {
        $.connection.hub.start().done(function () {
            alert($.connection.hub.state);
            chat.server.saveConnectionId();
            chat.server.join(s.projDetails.projId);
        })
    }
    //else {
    //    getProjDetails(rp.projId);
    //    refreshTask();
    //}

    getProjDetails(rp.projId);
    refreshTask();

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
            creatorId = s.projDetails.userId;
        })
        
        h.post("../Project/getParticipantsByProjId?projId="+projId).then(function (r) {
            s.projParticipants = r.data;
            ppArray = r.data;
        })

        h.post("../Project/getProjectActivity?projId=" + rp.projId).then(function (r) {
            s.activities = r.data;
        })
    }

    s.convertJsonDate = function (date) {
        var date2 = new Date(parseInt(date.substr(6)));
        let options = {
            weekday: "long", year: "numeric", month: "short",
            day: "numeric", hour: "2-digit", minute: "2-digit"
        };
        return date2.toLocaleTimeString("en-us", options);
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
            $("#anchor" + index).text(fullname).attr("href", "user/profile/userId=" + userId);
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
    s.sendMessageEnter = function ($event) {
        if ($event.keyCode == 13 && $("#message").val() != "") {
            spamCount++;
            if (!mute) {
                if ($("#message").val() != "") {
                    chat.server.sendToGroup(userInfo[0].username, $("#message").val(), userInfo[0].profpath, $("#getGroup").val());
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

    
    s.showBtns = function () {
        if (userInfo[0].userId == creatorId) {
            return true;
        }
        else {
            if (ppArray.some(function (it) {
                return it.userId == userInfo[0].userId;
            })) {
                return true;
            }
            else {
                return false;
            }
        }
    }

    s.profile = function (userId) {
        l.path("/user/profile/userId=" + userId);
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

