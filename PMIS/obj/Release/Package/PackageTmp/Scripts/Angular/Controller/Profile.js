module.controller("profileCtrl", ["$scope", "$http", "$routeParams", "FileUploadService", function (s, r, rp, FileUploadService) {
    s.SelectedFileForUpload = null;
    s.IsFormSubmitted = false;
    s.IsFileValid = false;
    s.IsFormValid = false;
    s.coverIsFileValid = false;
    s.USERID = "";
    s.USERNAME = "";
    s.PROFPATH = "";
    s.COVERPATH = "";
    s.FIRSTNAME = "";
    s.MIDDLENAME = "";
    s.LASTNAME = "";
    var userInfo = "";
    userInfo = JSON.parse(localStorage.userInfo);
    $("#ProfilePictureModal").css("display", "none");


    r.post("../User/getParticipants").then(function (r) {
        s.participants = r.data;
    })

    var userplParam = { "userId": userInfo[0].userId };
    r.post("../Project/getUserProjectList", userplParam).then(function (r) {
        s.projlist = r.data;
    })

    r.post("../Project/getUserTasks", { userId: userInfo[0].userId }).then(function (r) {
        s.tasks = r.data;
    })


    $(document).ready(function () {
        $("#file").attr("src", userInfo[0].profpath);
    })

    $(document).ready(function () {
        $('#coverid').css("background-image", "url('" + userInfo[0].coverpath + "')");
    })
    $("#fullname").text(userInfo[0].firstname + " " + userInfo[0].lastname);
    s.click = function () {
        r.post("../Account/getUser?id=" + userInfo[0].userId).then(function (d) {
            s.data = d.data;
            s.USERID = d.data.userId;
            s.USERNAME = d.data.username;
            s.PROFPATH = d.data.profpath;
            s.COVERPATH - d.data.coverpath;
            s.FIRSTNAME = d.data.firstname;
            s.MIDDLENAME = d.data.middlename;
            s.LASTNAME = d.data.lastname;
        });
    }
    s.tabcontrol = function (tab) {
        if (tab == "tab_project") {

            $('#tab-schedule').removeClass('active in');
            $('#tab-setting').removeClass('active in');
            $('#tab-project').addClass('active in');
        }
        else if (tab == "tab_schedule") {
            $('#tab-project').removeClass('active in');
            $('#tab-setting').removeClass('active in');
            $('#tab-schedule').addClass('active in');
        }
        else if (tab == "tab_setting") {
            $('#tab-schedule').removeClass('active in');
            $('#tab-project').removeClass('active in');
            $('#tab-setting').addClass('active in');
        }
    }

    s.ChechFileValid = function (file) {
        var isValid = false;
        if (s.SelectedFileForUpload != null) {
            if ((file.type == 'image/png' || file.type == 'image/jpeg' || file.type == 'image/gif')) {
                s.FileInvalidMessage = "";
                isValid = true;
            }
            else {
                s.FileInvalidMessage = "Selected file is Invalid. (only file type png, jpeg and gif)";
                alert("Selected file is Invalid. (only file type png, jpeg and gif and 512 kb size allowed)");
                document.getElementById("nganu").value = null;
            }
        }
        else {
            s.FileInvalidMessage = "Image required!";
            //swal("Image Required!", "", "error");
            alert("Image Required!");
        }
        s.IsFileValid = isValid;

    }
    s.CheckCoverValid = function (file) {
        var fileUpload = document.getElementById("nganu");
        if ((file.type == 'image/png' || file.type == 'image/jpeg' || file.type == 'image/gif')) {
            var reader = new FileReader();
            var height = "";
            var width = "";
            reader.readAsDataURL(fileUpload.files[0]);
            reader.onload = function (e) {
                var image = new Image();
                image.src = e.target.result;
                image.onload = function (e) {
                    height = this.height;
                    width = this.width;
                    if (width >= 850 && height >= 314) {
                        document.getElementById("myModal").style.display = "block";
                    }
                    else {
                        alert("Minumum height 315px and Minimum width 815px");
                        document.getElementById("nganu").value = null;
                        height = "";
                        width = "";
                    }
                }
            }
        }
        else {
            alert("Selected file is Invalid. (only file type png, jpeg and gif and 512 kb size allowed)");
            document.getElementById("nganu").value = null;
            height = "";
            width = "";
        }

    }
    s.selectCoverforUpload = function (file) {
        s.selectCoverforUpload = file[0];
        alert("onload");
    }
    s.selectFileforUpload = function (file) {
        s.SelectedFileForUpload = file[0];
        if ((document.getElementById("modal-title").innerText) == "Edit Profile Picture") {
            s.IsFormSubmitted = true;
            s.Message = "";

            s.ChechFileValid(s.SelectedFileForUpload);
            if (s.IsFileValid == true) {
                document.getElementById("myModal").style.display = "block";
                $('#myModal').animateCss('zoomIn', function () {
                });
            }
        }
        if ((document.getElementById("modal-title").innerText) == "Edit Cover Image") {
            s.CheckCoverValid(s.SelectedFileForUpload);
        }
    }
    s.showmodal_profilepic = function () {

        $('#nganu').trigger('click');
        $('#modal-title').text("Edit Profile Picture");
        //$(document).ready(function () {
        //    $('#selectedFile').trigger('click');
        //})

        //$('#myModal').animateCss('zoomIn', function () {
        //});
    }
    s.showmodal_coverimage = function () {
        $('#nganu').trigger('click');
        $('#modal-title').text("Edit Cover Image");
        //$('#selectedFile').trigger('click');
        //$('#myModal').animateCss('zoomIn', function () {
        //});
    }
    s.hidemodal = function () {
        $('#myModal').animateCss('zoomOut', function () {
            document.getElementById("myModal").style.display = "none";
            document.getElementById("nganu").value = null;
        });
    }
    s.updateprofile = function (d) {
        if (d.username != s.USERNAME) {
            r.post("../Account/check_username_duplicate", d).then(function (response) {

                if (response.data == "username already exist") {
                    alert(response.data);
                }
                else {
                    r.post("../Account/updateusername", d).then(function (response) {
                        console.log(response.data);
                        alert("Successfully Updated");
                        localStorage.userInfo = JSON.stringify(response.data);
                        userProfile(JSON.stringify(response.data));
                        $("#fullname").text(d.firstname + " " + d.lastname);
                        s.USERID = response.data[0].userId;
                        s.USERNAME = response.data[0].username;
                        s.PROFPATH = response.data[0].profpath;
                        s.COVERPATH - response.data[0].coverpath;
                        s.FIRSTNAME = response.data[0].firstname;
                        s.MIDDLENAME = response.data[0].middlename;
                        s.LASTNAME = response.data[0].lastname;
                    })
                }
            })
        }
        else {
            if (d.username == s.USERNAME
                && d.firstname == s.FIRSTNAME
                && d.middlename == s.MIDDLENAME
                && d.lastname == s.LASTNAME) {
                alert("No data to update");
            }
            else {
                r.post("../Account/editprofile_info", d).then(function (response) {
                    console.log(response.data);
                    alert("Successfully Updated");
                    localStorage.userInfo = JSON.stringify(response.data);
                    userProfile(JSON.stringify(response.data));
                    $("#fullname").text(d.firstname + " " + d.lastname);
                    s.USERID = response.data[0].userId;
                    s.USERNAME = response.data[0].username;
                    s.PROFPATH = response.data.profpath;
                    s.COVERPATH - response.data[0].coverpath;
                    s.FIRSTNAME = response.data[0].firstname;
                    s.MIDDLENAME = response.data[0].middlename;
                    s.LASTNAME = response.data[0].lastname;
                })
            }
        }
    }
    s.checkpassword = function (oldpassword, password, retype) {
        r.post("../Account/checkpassword?oldpassword=" + oldpassword + "&userid=" + userInfo[0].userId).then(function (d) {
            if (d.data == "exist") {
                if (password != retype) {
                    alert("New Password does not match");
                    $('#newpassword').val("");
                    $('#retypepassword').val("");
                }
                else {
                    r.post("../Account/changedpassword?password=" + password + "&userid=" + userInfo[0].userId).then(function (d) {
                        alert("succesfully change");
                        $('#password').val("");
                        $('#newpassword').val("");
                        $('#retypepassword').val("");
                    })
                }
            }
            else if (d.data == "notexist") {
                alert("Incorrect Current Password");
                $('#password').val("");
            }
        })
    }
    s.SaveFile = function () {
        if ((document.getElementById("modal-title").innerText) == "Edit Profile Picture") {
            FileUploadService.UploadFile(s.SelectedFileForUpload, s.USERNAME, s.USERID);
        }
        else if ((document.getElementById("modal-title").innerText) == "Edit Cover Image") {
            FileUploadService.changecover(s.SelectedFileForUpload, s.USERNAME, s.USERID);
        }
    }

    s.setStatusColor2 = function (status) {
        if (status == "Completed") {
            return "labelPrimary";
        }
        else if (status == "Active") {
            return "label label-info";
        }
        else {
            return "label label-default";
        }
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

    s.participantsCount = function (length) {
        return "+" + (length - 4);
    }


}]).factory('FileUploadService', function ($http, $q) {
    var fac = {};
    fac.UploadFile = function (file, username, userid) {
        var formData = new FormData();
        formData.append("file", file);
        formData.append("username", username);
        formData.append("userid", userid);
        $http.post("/Account/SaveFiles", formData, {
            withCredentials: true,
            headers: { 'Content-Type': undefined },
            transformRequest: angular.identity
        }).then(function (response) {
            alert("Successfully Updated");
            localStorage.userInfo = JSON.stringify(response.data);
            userProfile(JSON.stringify(response.data));
        });
    }
    fac.changecover = function (file, username, userid) {
        var formData = new FormData();
        formData.append("file", file);
        formData.append("username", username);
        formData.append("userid", userid);
        $http.post("/Account/UpdateCover", formData, {
            withCredentials: true,
            headers: { 'Content-Type': undefined },
            transformRequest: angular.identity
        }).then(function (response) {
            alert("Successfully Updated");
            localStorage.userInfo = JSON.stringify(response.data);
            userProfile(JSON.stringify(response.data));
        });
    }
    return fac;
});