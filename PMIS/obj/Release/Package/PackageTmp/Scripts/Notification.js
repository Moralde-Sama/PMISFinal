

var userInfo = JSON.parse(localStorage.userInfo);

$.post("../Account/getNotifications", { userId: userInfo[0].userId}, function (result) {
    $.each(result, function (i, item) {
        $("#notification").prepend(
            '<li id="notifli' + i + '">' +
            '<a href="#">'+
            '<i class="fa fa-tasks text-aqua"></i> '+result[i].notifcontent+' </a>'+
            '<p id="notif' + i + '" style="text-align:center; border-bottom:1px solid #EEEEEE; padding: 5px; display:none;">' + result[0].notifcontent + '</p></li>');

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