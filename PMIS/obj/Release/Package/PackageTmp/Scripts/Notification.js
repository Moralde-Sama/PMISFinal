

var userInfo = JSON.parse(localStorage.userInfo);

$.post("../Account/getNotifications", { userId: userInfo[0].userId }, function (result) {
    
    $("#notifCount").text("" + result.countNotif);
    $("#notifHeader").text("You have "+result.countNotif+" notifications");

    $.each(result.notification, function (i, item) {
        $("#notification").prepend(
            '<li id="notifli' + i + '">' +
            '<a href="#">'+
            '<i class="' + notifIcon(result.notification[i].type) + '"></i> ' + result.notification[i].notifcontent + ' </a>' +
            '<p id="notif' + i + '" style="text-align:center; border-bottom:1px solid #EEEEEE; padding: 5px; display:none;">' + result.notification[i].notifcontent + '</p></li>');

        $("#notifli" + i).hover(function () {
            $("#notif" + i).css("display", "block");
            $("#notif" + i).animateCss("fadeInLeft", function () { });
        }, function () {
            $("#notif" + i).animateCss("fadeOutRight", function () {
                $("#notif" + i).css("display", "none");
            });
        })
    })
})

function notifIcon(type) {
    if (type == "Task") {
        return "fa fa-tasks text-aqua";
    }
    else {
        return "fa fa-folder text-aqua";
    }
}

$("#notifMenu").click(function () {
    if($("#notifCount").text() != 0){
        $.post("../Account/updateNotification", { userId: userInfo[0].userId }, function (result) {
        })

        $("#notifCount").text("" + 0);
        $("#notifHeader").text("You have " + 0 + " notifications");
    }
})

