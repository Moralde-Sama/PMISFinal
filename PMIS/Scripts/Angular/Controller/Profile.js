module.controller("profileCtrl", ["$scope", "$http", "$routeParams", "FileUploadService", function (s, r, rp, FileUploadService) {
    s.Message = "";
    s.FileInvalidMessage = "";
    s.SelectedFileForUpload = null;
    s.FileDescription = "";
    s.IsFormSubmitted = false;
    s.IsFileValid = false;
    s.IsFormValid = false;
    var name = JSON.parse(localStorage.userInfo);
    s.USERID = "";
    s.USERNAME = "";
    s.PROFPATH = "";

    
    
    $(document).ready(function () {
        $("#file").attr("src", name[0].profpath);
    })
    $("#modaltitle").text("Edit Profile Picture");
        
    
    $(document).ready(function () {
        $('#coverid').css("background-image", "url('" + name[0].coverpath + "')");
    })
    $("#fullname").text(name[0].firstname + " " + name[0].lastname);
    s.click = function (id) {
        r.post("../Account/getUser?id=" + id).then(function (d) {

            s.data = d.data;
            s.USERID = d.data.userId;
            s.USERNAME = d.data.username;
            s.PROFPATH = d.data.profpath;
            console.log(d.data);
        });
    }
    s.click_editprofile=function()
    {

        
        
            $("#modaltitle").text("Edit Profile Picture");
        
    }
    s.click_editcover=function()
    {


        
            $("#modaltitle").text("Edit Cover Image");

    }



    s.updateprofile = function (d) {
        r.post("../Account/updateprofile", d).then(function (d) {
            console.log(d);
            swal("Successfully Updated", "", "success");

            $("#fullname").text(d.data.firstname + " " + d.data.lastname);
            //$window.location.reload();   
            //location.href("../home/profile2"); 


        })
    }
    s.checkpassword = function (oldpassword, userid, password, retype) {
        console.log(password);
        r.post("../Account/checkpassword?oldpassword=" + oldpassword + "&userid=" + userid).then(function (d) {

            if (d.data == "exist") {
                if (password != retype) {
                    alert("New Password does not match");
                }
                else {
                    r.post("../Account/changedpassword?password=" + password + "&userid=" + userid).then(function (d) {

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
                            swal("Minumum height 315px and Minimum width 815px", "", "error");
                            return false;

                        }
                        FileUploadService.changecover(s.SelectedFileForUpload, s.USERNAME, s.USERID, s.PROFPATH).then(function (d) {


                        }, function (e) {
                            alert(e);
                        });
                        return true;
                    };

                }
            } else {
                swal("This browser does not support HTML5.", "", "error");
                return false;
            }
        } else {
            swal("Image Required!", "", "error");
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
            swal("Image Required!", "", "error");
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
                swal("Image Required!", "", "error");
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
                swal("Successfully Updated", "", "success");
                localStorage.userinfo = JSON.stringify(response.data);
                location.reload();
            });

        //return defer.promise;

    }
    fac.changecover = function (file, username, userid, profpath) {
        var formData = new FormData();
        formData.append("file", file);
        formData.append("username", username);
        formData.append("userid", userid);
        formData.append("profpath", profpath);
        //We can send more data to server using append         
        //var defer = $q.defer();
        $http.post("/Account/UpdateCover", formData,
            {
                withCredentials: true,
                headers: { 'Content-Type': undefined },
                transformRequest: angular.identity
            }).then(function (response) {
                swal("Successfully Updated", "", "success");
                localStorage.userinfo = JSON.stringify(response.data);
                location.reload();
            });

        //return defer.promise;

    }
    return fac;



});