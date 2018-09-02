var userInfo = JSON.parse(localStorage.userInfo);


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

    chat.client.Notify = function (connectionId, notifContent) {
        $("#notification").prepend(
            '<li id="notifliN' + notifCount + '">' +
            '<a href="#">' +
            '<i class="fa fa-tasks text-aqua"></i> ' + notifContent + ' </a>' +
            '<p id="notifN' + notifCount + '" style="text-align:center; border-bottom:1px solid #EEEEEE; padding: 5px; display:none;">' + notifContent + '</p></li>');

        $("#notifliN" + notifCount).hover(function () {
            $("#notifN" + notifCount).css("display", "block");
            $("#notifN" + notifCount).animateCss("fadeInLeft", function () { });
        }, function () {
            $("#notifN" + notifCount).animateCss("fadeOutRight", function () {
                $("#notifN" + notifCount).css("display", "none");
            });
        })
    }


    chat.client.sendToAll = function (name, message) {
        alert(name + ": " + message);
    }

    chat.client.sendToGroup = function (name, message, profPath) {
        if(name == $("#userName").val()){
            $('#messageContainer').append('<div class="direct-chat-msg right">'+
                '<div class="direct-chat-info clearfix">'+
                '<div style="color:#00BCD4; text-align:end;">' +
                '<span class="direct-chat-name pull-right">' + name + '</span></div>' +
                '<img style="margin-right:-35px; margin-top: 17px;" class="direct-chat-img" src="'+profPath+'" alt="message user image">' +
                '<div class="direct-chat-text" style="color:white; background-color:#00BCD4; margin-top: 23px; word-break:break-all;">' +
                message + '</div></div>');
        }
        else {
            $('#messageContainer').append('<div class="direct-chat-msg">' +
                               '<div class="direct-chat-info clearfix">' +
                               '<span class="direct-chat-name pull-left">' + name + '</span>' +
                               '</div><!-- /.direct-chat-info -->' +
                               ' <img class="direct-chat-img" style="margin-right:-33px;" src="' + profPath + '" alt="message user image"><!-- /.direct-chat-img -->' +
                               '<div class="direct-chat-text" style="word-break:break-all; font-size: 20px;"> '
                                    + message +
                               '</div><!-- /.direct-chat-text -->  </div><!-- /.direct-chat-msg -->');
        }

        $("#messageContainer").val('').focus();
        $("#messageContainer").scrollTop($("#messageContainer")[0].scrollHeight);
        $(document).scrollTop($(document)[0].scrollHeight);
    }
})