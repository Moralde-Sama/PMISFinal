
var dashboard = document.getElementById("dashboard");
var user = document.getElementById("user");
var admin = document.getElementById("sadmin");

dashboard.addEventListener("click", function () {
    dashboard.className = "treeview active";
    user.className = "treeview";
    admin.className = "treeview";
});

admin.addEventListener("click", function () {
    admin.className = "treeview active";
    dashboard.className = "treeview";
    user.className = "treeview";
});

user.addEventListener("click", function () {
    user.className = "treeview active";
    admin.className = "treeview";
    dashboard.className = "treeview";
});