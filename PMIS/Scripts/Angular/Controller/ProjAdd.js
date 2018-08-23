module.controller("projAddCtrl", ["$scope", "$http", "$location", function (s, h, l) {

    var userInfo = JSON.parse(localStorage.userInfo);

    var array = [];
    array.push(userInfo[0].userId);

    var checkCount = 0;

    getUser();

    s.tab = function (tab) {
        if (tab == "tab1") {
            document.getElementById("tab-1").style.display = "block";
            document.getElementById("tab-2").style.display = "none";
        }
        else if (tab == "tab2") {
            document.getElementById("tab-2").style.display = "block";
            document.getElementById("tab-1").style.display = "none";
        }
    }

    function getUser() {
        h.post("../User/getUsers?userid="+$("#userId").val()).then(function (r) {
            s.users = r.data;
        })
    }

    s.create = function (d) {
        if(d.title && d.version != ""){
            var Indata = { 'pj': d, 'array': array };
            h.post("../Project/addProject", Indata).then(function (r) {
                if (r.data == "Success") {
                    alert("Save Successfully");
                    l.path("/Project/List");
                }
                else {
                    alert("Check your connection.");
                }
            })
        }

        //array.splice(index, 1);
        //for (var i = 0; i < array.length; i++) {
        //    console.log(array[i] + " = " + i);
        //}

        
        //console.log(s.userInfo[0].firstname);
    }

    s.participants = function (id) {
        var index = array.indexOf(id);
        if (index == -1) {
            array.push(id);
        }
        else {
            array.splice(index, 1);
        }
        
    }

    s.checkbox = function (id, eq) {
        if (array.indexOf(id) != -1) {
            $('.checkParticipants').eq(eq).prop('checked', true);
        }
    }

    //var x = window.matchMedia("(max-width: 764px)")
    //myFunction(x)
    //x.addListener(myFunction)

    //function myFunction(x) {
    //    if (x.matches) { // If media query matches
    //        document.getElementById("progressDetails").style.marginRight = 0;
    //        document.getElementById("breadcrumbs").style.textAlign = "center";
    //    } else {
    //        document.getElementById("progressDetails").style.marginRight = "140px";
    //        document.getElementById("breadcrumbs").style.textAlign = "end";
    //    }
    //}
}])