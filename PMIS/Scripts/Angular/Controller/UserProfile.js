
module.controller("userprofileCtrl", ["$scope", "$http", "$routeParams", "FileUploadService", function (s, r, rp, FileUploadService) {
    s.Message = "";
    s.FileInvalidMessage = "";
    s.SelectedFileForUpload = null;
    s.FileDescription = "";
    s.IsFormSubmitted = false;
    s.IsFileValid = false;
    s.IsFormValid = false;
    s.USERID = "";
    s.USERNAME = "";
    s.PROFPATH = "";
    s.COVERPATH = "";
    var userInfo = "";
    userInfo = JSON.parse(localStorage.userInfo);

    $("#ProfilePictureModal").css("display", "none");

    $(document).ready(function () {
        $("#file").attr("src", userInfo[0].profpath);
    })


    $("#modaltitle").text("Edit Profile Picture");



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
            console.log(d.data);
        });
    }
    s.click_editprofile = function () {
        s.modaltitle = "Edit Profile Picture";
        //$("#modaltitle").text("Edit Profile Picture");

    }
    s.click_editcover = function () {
        s.modaltitle = "Edit Cover Image";
        //$("#modaltitle").text("Edit Cover Image");

    }



    s.updateprofile = function (d) {
        r.post("../Account/updateprofile", d).then(function (d) {
            console.log(d);
            //swal("Successfully Updated", "", "success");
            alert("Successfully Updated");

            $("#fullname").text(d.data.firstname + " " + d.data.lastname);
            //$window.location.reload();   
            //location.href("../home/profile2"); 


        })
    }
    s.checkpassword = function (oldpassword, password, retype) {
        console.log(password);
        r.post("../Account/checkpassword?oldpassword=" + oldpassword + "&userid=" + userInfo[0].userId).then(function (d) {

            if (d.data == "exist") {
                if (password != retype) {
                    alert("New Password does not match");
                }
                else {
                    r.post("../Account/changedpassword?password=" + password + "&userid=" + userInfo[0].userId).then(function (d) {

                        alert("succesfully change");
                    })
                }


            }
            else if (d.data == "notexist") {
                alert("false")
            }



        })
    }
    function cover() {
        var fileUpload = document.getElementById("selectedFile");

        //Check whether the file is valid Image.
        var regex = new RegExp("([a-zA-Z0-9\s_\\.\-:])+(.jpg|.png|.gif)$");
        if (regex.test(fileUpload.value.toLowerCase())) {

            //Check whether HTML5 is supported.
            if (typeof (fileUpload.files) != "undefined") {
                //Initiate the FileReader object.
                var reader = new FileReader();
                //Read the contents of Image File.
                reader.readAsDataURL(fileUpload.files[0]);
                reader.onload = function (e) {
                    //Initiate the JavaScript Image object.
                    var image = new Image();

                    //Set the Base64 string return from FileReader as source.
                    image.src = e.target.result;

                    //Validate the File Height and Width.
                    image.onload = function () {
                        var height = this.height;
                        var width = this.width;
                        if (width < 815 && height < 315) {
                            //swal("Minumum height 315px and Minimum width 815px", "", "error");
                            alert("Minumum height 315px and Minimum width 815px");
                            return false;

                        }
                        FileUploadService.changecover(s.SelectedFileForUpload, s.USERNAME, s.USERID, s.COVERPATH).then(function (d) {


                        }, function (e) {
                            alert(e);
                        });
                        return true;
                    };

                }
            } else {
                //swal("This browser does not support HTML5.", "", "error");
                alert("This browser does not support HTML5.");
                return false;
            }
        } else {
            //swal("Image Required!", "", "error");
            alert("Image Required!");
            return false;
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
            }
        }
        else {
            s.FileInvalidMessage = "Image required!";
            //swal("Image Required!", "", "error");
            alert("Image Required!");
        }
        s.IsFileValid = isValid;
    };

    s.selectFileforUpload = function (file) {
        s.SelectedFileForUpload = file[0];
    }

    s.SaveFile = function () {



        if ((document.getElementById("modaltitle").innerText) == "Edit Profile Picture") {
            s.IsFormSubmitted = true;
            s.Message = "";

            s.ChechFileValid(s.SelectedFileForUpload);
            if (s.IsFileValid) {
                FileUploadService.UploadFile(s.SelectedFileForUpload, s.USERNAME, s.USERID, s.PROFPATH).then(function (d) {
                    alert("Save");

                }, function (e) {
                    alert(e);
                });
            }
            else {
                s.Message = "All the fields are required.";
                //swal("Image Required!", "", "error");

            }
        }
        else if ((document.getElementById("modaltitle").innerText) == "Edit Cover Image") {
            cover();

        }



    }

}]).factory('FileUploadService', function ($http, $q) { // explained abour controller and service in part 2

    var fac = {};
    fac.UploadFile = function (file, username, userid, profpath) {
        var formData = new FormData();
        formData.append("file", file);
        formData.append("username", username);
        formData.append("userid", userid);
        formData.append("profpath", profpath);
        //We can send more data to server using append         
        //var defer = $q.defer();
        $http.post("/Account/SaveFiles", formData,
            {
                withCredentials: true,
                headers: { 'Content-Type': undefined },
                transformRequest: angular.identity
            }).then(function (response) {
                //swal("Successfully Updated", "", "success");
                alert("Successfully Updated");
                localStorage.userInfo = JSON.stringify(response.data);
                userProfile(JSON.stringify(response.data));
                //location.reload();
            });

        //return defer.promise;

    }
    fac.changecover = function (file, username, userid, coverpath) {
        var formData = new FormData();
        formData.append("file", file);
        formData.append("username", username);
        formData.append("userid", userid);
        formData.append("coverpath", coverpath);
        //We can send more data to server using append         
        //var defer = $q.defer();
        $http.post("/Account/UpdateCover", formData,
            {
                withCredentials: true,
                headers: { 'Content-Type': undefined },
                transformRequest: angular.identity
            }).then(function (response) {
                //swal("Successfully Updated", "", "success");
                alert("Successfully Updated");
                localStorage.userInfo = JSON.stringify(response.data);
                //location.reload();
                userProfile(JSON.stringify(response.data));
            });


        //return defer.promise;

    }
    return fac;




});