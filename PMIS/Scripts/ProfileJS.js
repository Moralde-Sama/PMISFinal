

userProfile(localStorage.userInfo);

function userProfile(storage) {
    var Info = JSON.parse(storage);
    var fullname = Info[0].firstname + " " + Info[0].lastname;
    var profpath = Info[0].profpath;
    var coverpath = Info[0].coverpath;
    var userId = Info[0].userId;
    $("#profilePicture").attr("src", profpath);
    $("#profilePicture2").attr("src", profpath);
    $("#profilePicture3").attr("src", profpath);
    $("#profilePicture4").attr("src", profpath);
    $("#file").attr("src", profpath);
    $("#coverid").css("background-image", 'url("'+coverpath+'")');
    $("#fullname2").text(fullname);
    $("#fullname3").html(fullname + '<br /> Web Developer');
    $("#fullname4").text(fullname);
    $("#userProfile").attr("href", '/user/profile/userId=' + userId);

}

function readURL(input) {
    if (input.files && input.files[0]) {
        var reader = new FileReader();

        reader.onload = function (e) {
            $('#file')
                .attr('src', e.target.result)
                //.width(100)
                //.height(100);

        };

        reader.readAsDataURL(input.files[0]);
    }
    //$('#exampleModalCenter').modal({ backdrop: 'static', keyboard: false });
    //$('#exampleModalCenter').modal('show');
}





function functionConfirm(event) {
    swal({
        title: "Are you sure?",
        text: "Once deleted, you will not be able to recover this imaginary file!",

        buttons: true,
        dangerMode: true,
    }).then(function (yes) {
        // Called if you click Yes.
        if (yes) {
            // Make Ajax call.
            swal('Deleted', '', 'success');
        }
    },
    function (no) {
        // Called if you click No.
        if (no == 'cancel') {
            swal('Cancelled', '', 'error');
        }
    });
}
function refreshpage() {
    window.location.reload();
}
function ProfilePictureModalTitle() {
    $(document).ready(function () {
        $("#modaltitle").text("Edit Profile Picture");
    })

}

function CoverImageModalTitle() {
    $(document).ready(function () {
        $("#modaltitle").text("Edit Cover Image");

    })

}
//function Upload() {
//    //Get reference of FileUpload.
//    var fileUpload = document.getElementById("selectedFile");

//    //Check whether the file is valid Image.
//    var regex = new RegExp("([a-zA-Z0-9\s_\\.\-:])+(.jpg|.png|.gif)$");
//    if (regex.test(fileUpload.value.toLowerCase())) {

//        //Check whether HTML5 is supported.
//        if (typeof (fileUpload.files) != "undefined") {
//            //Initiate the FileReader object.
//            var reader = new FileReader();
//            //Read the contents of Image File.
//            reader.readAsDataURL(fileUpload.files[0]);
//            reader.onload = function (e) {
//                //Initiate the JavaScript Image object.
//                var image = new Image();

//                //Set the Base64 string return from FileReader as source.
//                image.src = e.target.result;

//                //Validate the File Height and Width.
//                image.onload = function () {
//                    var height = this.height;
//                    var width = this.width;
//                    //851 width
//                    //315
//                    alert(height);
//                    alert(width);
//                    if (height > 100 || width > 100) {
//                        alert("Height and Width must not exceed 100px.");
//                        return false;
//                    }
//                    alert("Uploaded image has valid Height and Width.");
//                    return true;
//                };

//            }
//        } else {
//            alert("This browser does not support HTML5.");
//            return false;
//        }
//    } else {
//        alert("Please select a valid Image file.");
//        return false;
//    }
//}

