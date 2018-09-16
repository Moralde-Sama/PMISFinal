﻿var userInfo = JSON.parse(localStorage.userInfo);


function logout() {
    $.post("../Account/Logout", function (data, status) {
        localStorage.removeItem("userInfo");
        location.href = "../Account/Login";
    });
}

function alertasd() {
    document.getElementById("MySelectList").style.display = "block";
}

$(document).ready(function () {
    $.protip();
})

window.onbeforeunload = function () {
    $.post("../Account/onDisconnect",
        {userId: userInfo[0].userId},
        function (result) {

        }
    )
}
window.onload = function () {
    if (userInfo[0].role == "Super Admin") {
        $("#sadmin").css("display", "block");
        $("#user").css("display", "none");
    }
    else {
        $("#user").css("display", "block");
        $("#sadmin").css("display", "none");
    }
}

$(function () {
    var notifCount = 50;
    //chat

    var chat = $.connection.chatHub;
    
    if ($.connection.hub.state == 4 || $.connection.hub.state == 0) {
        $.connection.hub.start().done(function () {
            chat.server.saveConnectionId();
        })
    }
    else {
        $.connection.hub.start().done(function () {
            chat.server.saveConnectionId();
        })
    }

    chat.client.ConnectionId = function (connectionId) {
        $.post("../Account/saveConnectionId",
            {
                conId: connectionId,
                userId: userInfo[0].userId
            },
            function (result) {
                localStorage.userInfo = JSON.stringify(result);
            })
    }

    chat.client.Notify = function (connectionId, notifContent, type, id) {
        $("#notification").prepend(
            '<li id="notifliN' + notifCount + '">' +
            '<a href="' + notifAddress(type, id) + '">' +
            '<i class="' + notifIcon(type) + '"></i> ' + notifContent + ' </a>' +
            '<p id="notifN' + notifCount + '" style="text-align:center; border-bottom:1px solid #EEEEEE; padding: 5px; display:none;">' + notifContent + '</p></li>');

        $("#notifliN" + notifCount).hover(function () {
            $("#notifN" + notifCount).css("display", "block");
            $("#notifN" + notifCount).animateCss("fadeInLeft", function () { });
        }, function () {
            $("#notifN" + notifCount).animateCss("fadeOutRight", function () {
                $("#notifN" + notifCount).css("display", "none");
            });
        })

        Snarl.addNotification({
            title: "New Notification",
            icon: '<i class="fa fa-bell-o"></i>',
            timeout: 3000
        });

        $.post("../Account/getNotifications", { userId: userInfo[0].userId }, function (result) {
            $("#notifCount").text("" + result.countNotif);
            $("#notifHeader").text("You have " + result.countNotif + " notifications");
        })
    }

    function notifAddress(type, id) {
        if (type == "Task") {
            return "/Project/Tasks/projectId=" + id;
        }
        else {
            return "/Project/Details/projectId=" + id;
        }
    }

    function notifIcon(type) {
        if (type == "Task") {
            return "fa fa-tasks text-aqua";
        }
        else {
            return "fa fa-folder text-aqua";
        }
    }


    chat.client.sendToAll = function (name, message) {
        alert(name + ": " + message);
    }

    chat.client.sendToGroup = function (name, message, profPath) {
        if(name == userInfo[0].username){
            $('#messageContainer').append('<div class="direct-chat-msg right">' +
                '<div class="direct-chat-info clearfix">' +
                '<span class="direct-chat-name pull-right">' + name + '</span>' +
                '<span class="direct-chat-timestamp pull-left">23 Jan 2:05 pm</span></div>' +
                '<img class="direct-chat-img" src="' + profPath + '" alt="message user image">' +
                '<div class="direct-chat-text" style="background-color:#3E8DBC; color:white; word-break:break-all;">' +
                message + '</div></div>');
        }
        else {
            $('#messageContainer').append('<div class="direct-chat-msg">' +
                               '<div class="direct-chat-info clearfix">' +
                               '<span class="direct-chat-name pull-left">' + name + '</span>' +
                               '<span class="direct-chat-timestamp pull-right">23 Jan 2:00 pm</span>' +
                               '</div><!-- /.direct-chat-info -->' +
                               '<img class="direct-chat-img" style="margin-right:-33px;" src="' + profPath + '" alt="message user image"><!-- /.direct-chat-img -->' +
                               '<div class="direct-chat-text" style="color:white; background-color:#3E8DBC; word-break:break-all;"> '
                                    + message +
                               '</div><!-- /.direct-chat-text -->  </div><!-- /.direct-chat-msg -->');
        }

        $("#messageContainer").val('').focus();
        $("#messageContainer").scrollTop($("#messageContainer")[0].scrollHeight);
        $(document).scrollTop($(document)[0].scrollHeight);
    }
})