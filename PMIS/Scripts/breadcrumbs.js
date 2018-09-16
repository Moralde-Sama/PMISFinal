
var dashboard = document.getElementById("dashboard");
var user = document.getElementById("user");
var admin = document.getElementById("sadmin");
var breadbtm = $(".breadcrumb");
var title = $("#breadTitle");
var addProject = $("#addProject");
addProject.hide();
$("#editProj").hide();
$("#projTask").hide();
refresh();

dashboard.addEventListener("click", function () {
    $("#breadcrumbsM").show();
    dashboard.className = "treeview active";
    user.className = "treeview";
    admin.className = "treeview";

    $("#addProject").hide();
    $("#editProj").hide();
    $("#projTask").hide();

    if (dashboard.className == "treeview active") {
        breadbtm.empty();
        title.text("Dashboard");
        breadbtm.append('<li><strong>Dashboard<strong></li><li class="active"></li>');
        addProject.hide();
    }
});

admin.addEventListener("click", function () {
    $("#breadcrumbsM").show();
    admin.className = "treeview active";
    dashboard.className = "treeview";
    user.className = "treeview";
    breadbtm.empty();
    title.text("Project List");
    breadbtm.append('<li><strong>Project List</strong></li><li id="second" class="active"></li>');
});

user.addEventListener("click", function () {
    $("#breadcrumbsM").show();
    user.className = "treeview active";
    admin.className = "treeview";
    dashboard.className = "treeview";
    breadbtm.empty();
    title.text("My Projects");
    breadbtm.append('<li><strong>My Projects</strong></li><li id="second" class="active"></li>');

    $("#editProj").hide();
    $("#projTask").hide();
    addProject.show();
});


function Modal() {
        $("#editmodal").css("display", "block");
        document.getElementById("tab-6").style.display = "none";
        document.getElementById("tab-5").style.display = "block";
        document.getElementById("tab1").className = "active";
        document.getElementById("tab2").className = "";
        $("#editmodal2").animateCss("zoomIn", function () {
        })
}

function myprofile() {
    dashboard.className = "treeview";
    user.className = "treeview";
    admin.className = "treeview";
    $("#breadcrumbsM").hide();
}

function refresh() {
    if (localStorage.Prev == "List" && localStorage.Current == "List") {
        $("#breadcrumbsM").show();
        user.className = "treeview active";
        admin.className = "treeview";
        dashboard.className = "treeview";
        breadbtm.empty();
        title.text("My Projects");
        breadbtm.append('<li><strong>My Projects</strong></li><li id="second" class="active"></li>');

        $("#editProj").hide();
        $("#projTask").hide();
        addProject.show();
    }
    else if (localStorage.Prev == "List" && localStorage.Current == "Details" || localStorage.Prev == "Task" && localStorage.Current == "Details") {
        dashboard.className = "treeview";
        user.className = "treeview active";
        $("#addProject").hide();
        $("#breadTitle").text("Project Details");
        $(".breadcrumb").empty();
        $(".breadcrumb").append('<li><a id="myproject" href="/project/myprojects">My Projects</a></li><li class="active"><strong>' + localStorage.Title + '</strong></li>');

        $("#myproject").click(function () {
            $("#editProj").hide();
            $("#projTask").hide();
            $("#addProject").show();
            $(".breadcrumb").empty();
            $("#breadTitle").text("My Projects");
            $(".breadcrumb").append('<li><strong>My Projects</strong></li><li id="second" class="active"></li>');
        })
    }
    else if (localStorage.Prev == "Details" && localStorage.Current == "Task") {

        dashboard.className = "treeview";
        user.className = "treeview active";
        $("#breadTitle").text(localStorage.Title + " Tasks");
        $(".breadcrumb").empty();
        $(".breadcrumb").append('<li><a id="myproject" href="/project/myprojects">My Projects</a></li><li class="active"><a id="projectTitle" href="/Project/Details/projectId=' + localStorage.projId + '">' + localStorage.Title + '</a></li><li class="active"><strong>Task</strong></li>');

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
            $("#breadTitle").text("My Projects");
            $(".breadcrumb").append('<li><a id="myproject" href="/project/myprojects">My Projects</a></li><li class="active"><strong>' + localStorage.Title + '</strong></li>');

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
    else if (localStorage.Prev == "Dashboard" && localStorage.Current == "Task") {
        
        user.className = "treeview";
        dashboard.className = "treeview active";
        $("#breadTitle").text(localStorage.Title + " Tasks");
        $(".breadcrumb").empty();
        $(".breadcrumb").append('<li><a id="myproject" href="/user/dashboard">Dashboard</a></li><li class="active"><a id="projectTitle" href="/Project/Details/projectId=' + localStorage.projId + '">' + localStorage.Title + '</a></li><li class="active"><strong>Task</strong></li>');

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
            $(".breadcrumb").append('<li><a id="myproject" href="/user/dashboard">Dashboard</a></li><li class="active"><strong>' + localStorage.Title + '</strong></li>');

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
    else if (localStorage.Prev == "ListA" && localStorage.Current == "Details" || localStorage.Prev == "Task" && localStorage.Current == "Details") {
        dashboard.className = "treeview";
        admin.className = "treeview active";
        $("#addProject").hide();
        $("#breadTitle").text("Project Details");
        $(".breadcrumb").empty();
        $(".breadcrumb").append('<li><a id="myproject" href="/Project/List">Project List</a></li><li class="active"><strong>' + localStorage.Title + '</strong></li>');

        $("#myproject").click(function () {
            $("#editProj").hide();
            $("#projTask").hide();
            $("#addProject").hide();
            $(".breadcrumb").empty();
            $("#breadTitle").text("Project List");
            $(".breadcrumb").append('<li><strong>Project List</strong></li><li id="second" class="active"></li>');
        })
    }
}
