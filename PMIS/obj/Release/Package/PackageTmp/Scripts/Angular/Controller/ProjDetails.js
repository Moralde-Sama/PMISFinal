module.controller("ProjDetailsCtrl", ["$scope", "$http", "$routeParams", function (s, h, rp) {

    var spamCount = 0;
    var spamLimit = 3;
    var mute = 0;

    var x = window.matchMedia("(max-width: 764px)")
    myFunction(x)
    x.addListener(myFunction)

    var chat = $.connection.chatHub;
    if ($.connection.hub.state == 4 || $.connection.hub.state == 0) {
        $.connection.hub.start().done(function () {
            getProjDetails(rp.projId);
            refreshTask();
        })
    }
    else {
        getProjDetails(rp.projId);
        refreshTask();
    }

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
            chat.server.join(s.projDetails.projId);
        })
        
        h.post("../Project/getParticipantsByProjId?projId="+projId).then(function (r) {
            s.projParticipants = r.data;
        })
    }

    var interval = null;
    var interval2 = null;
    s.sendMessage = function () {
        spamCount++;
        if(!mute){
            if($("#message").val() != ""){
                chat.server.sendToGroup($("#userName").val(), $("#message").val(),  $("#profPath").val(), $("#getGroup").val());
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
                    chat.server.sendToGroup($("#userName").val(), $("#message").val(), $("#profPath").val(), $("#getGroup").val());
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

