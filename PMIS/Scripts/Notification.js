

var userInfo = JSON.parse(localStorage.userInfo);

$.post("../Account/getNotifications", { userId: userInfo[0].userId }, function (result) {
    
    $("#notifCount").text("" + result.countNotif);
    $("#notifHeader").text("You have "+result.countNotif+" notifications");

    $.each(result.notification, function (i, item) {
        $("#notification").prepend(
            '<li id="notifli' + i + '">' +
            '<a href="' + notifAddress(result.notification[i].type, result.notification[i].id) + '">' +
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

        $("#notifli" + i).click(function () {
            $.post("../Project/getProjectTitle", { projId: result.notification[i].id }, function (r) {
                
                if(result.notification[i].type == "Task"){
                    user.className = "treeview";
                    dashboard.className = "treeview active";
                    $("#breadTitle").text(r.projTitle + " Tasks");
                    $(".breadcrumb").empty();
                    $(".breadcrumb").append('<li><a id="myproject" href="/user/dashboard">Dashboard</a></li><li class="active"><a id="projectTitle" href="/Project/Details/projectId=' + result.notification[i].id + '">' + r.projTitle + '</a></li><li class="active"><strong>Task</strong></li>');

                    $("#myproject").click(function () {
                        $("#editProj").hide();
                        $("#projTask").hide();
                        $("#addProject").hide();
                        $(".breadcrumb").empty();
                        $("#breadTitle").text("Dashboard");
                        $(".breadcrumb").append('<li><strong>Dashboard</strong></li><li id="second" class="active"></li>');
                    })
                    $("#projectTitle").click(function () {
                        $(".breadcrumb").empty();
                        $("#breadTitle").text("My Projects");
                        $(".breadcrumb").append('<li><a id="myproject" href="/user/dashboard">Dashboard</a></li><li class="active"><strong>' + r.projTitle + '</strong></li>');

                        $("#myproject").click(function () {
                            $("#editProj").hide();
                            $("#projTask").hide();
                            $("#addProject").hide();
                            $(".breadcrumb").empty();
                            $("#breadTitle").text("Dashboard");
                            $(".breadcrumb").append('<li><strong>Dashboard</strong></li><li id="second" class="active"></li>');
                        })
                    })
                }
                else {
                    dashboard.className = "treeview active";
                    user.className = "treeview";
                    $("#addProject").hide();
                    $("#breadTitle").text("Project Details");
                    $(".breadcrumb").empty();
                    $(".breadcrumb").append('<li><a id="myproject" href="/user/dashboard">Dashboard</a></li><li class="active"><strong>' + r.projTitle + '</strong></li>');

                    $("#myproject").click(function () {
                        $("#editProj").hide();
                        $("#projTask").hide();
                        $("#addProject").show();
                        $(".breadcrumb").empty();
                        $("#breadTitle").text("Dashboard");
                        $(".breadcrumb").append('<li><strong>Dashboard</strong></li><li id="second" class="active"></li>');
                    })
                }
            })
        })
    })
})

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

$("#notifMenu").click(function () {
    if($("#notifCount").text() != 0){
        $.post("../Account/updateNotification", { userId: userInfo[0].userId }, function (result) {
        })

        $("#notifCount").text("" + 0);
        $("#notifHeader").text("You have " + 0 + " notifications");
    }
})

