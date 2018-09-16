
var dashboard = document.getElementById("dashboard");
var user = document.getElementById("user");
var admin = document.getElementById("sadmin");
var breadbtm = $(".breadcrumb");
var title = $("#breadTitle");
var addProject = $("#addProject");
addProject.hide();
$("#editProj").hide();
$("#projTask").hide();

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
