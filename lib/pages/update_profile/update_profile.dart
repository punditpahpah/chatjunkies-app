import 'package:chat_junkies/pages/home/home_page.dart';
import 'package:chat_junkies/util/history.dart';
import 'package:chat_junkies/widgets/round_button.dart';
import 'package:chat_junkies/util/style.dart';
import 'package:chat_junkies/pages/welcome/pick_photo_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:chat_junkies/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class UpdateProfile extends StatefulWidget {
  @override
  _UpdateProfileState createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  final bio_controller = TextEditingController();
  final pass_controller = TextEditingController();
  final pass1_controller = TextEditingController();
  final _userNameformKey = GlobalKey<FormState>();
  Function onNextButtonClick;

  String bio, id;
  getStringValuesSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id');
    bio = prefs.getString('bio');
    bio_controller.text = bio;
    setState(() {});
  }

  @override
  Future<void> initState() {
    super.initState();
    getStringValuesSF();
  }

  Future Update(String pass,pass1,bio) async {
    var url = base_url + "update_bio.php";
    var response = await http.post(url, body: {
      "user_id": id,
      "bio": bio,
      "pass": pass,
      "auth_key": auth_key
    });
    var data = json.decode(response.body);
    var code = data[0]['code'];
    if (code == 0) {
      Fluttertoast.showToast(
          msg: 'Some Error occured',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.only(
          top: 10,
          bottom: 10,
        ),
        child: Column(
          children: [
            buildTitle(),
            SizedBox(
              height: 10,
            ),
            buildForm("Enter new password", 1, pass_controller),
            SizedBox(
              height: 10,
            ),
            buildForm("Confirm password", 1, pass1_controller),
            SizedBox(
              height: 10,
            ),
            buildForm("Bio", 3, bio_controller),
            Spacer(),
            buildBottom(),
          ],
        ),
      ),
    );
  }

  Widget buildTitle() {
    return Text(
      'Update',
      style: TextStyle(fontSize: 25, color: Colors.white),
    );
  }

  Widget buildForm(String text, int lines, TextEditingController controller) {
    return Container(
      width: 330,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Form(
        child: TextFormField(
          maxLines: lines,
          textAlign: TextAlign.center,
          controller: controller,
          autocorrect: false,
          autofocus: false,
          decoration: InputDecoration(
            hintText: text,
            hintStyle: TextStyle(
              fontSize: 20,
            ),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
          ),
          keyboardType: TextInputType.text,
          style: TextStyle(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget buildBottom() {
    return InkWell(
      onTap: () {
        var pass = pass_controller.text;
        var pass1 = pass1_controller.text;
        var bio = bio_controller.text;
        if (pass.length < 6 || pass1.length < 6) {
          Fluttertoast.showToast(
              msg: 'Password length must be 6 characters',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        } else if (pass != pass1) {
          Fluttertoast.showToast(
              msg: 'Password not matching',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        } else if (bio.length < 15) {
          Fluttertoast.showToast(
              msg: 'Bio length must be 15 characters long',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        } else if (bio.contains('"') ||
            bio.contains(';') ||
            bio.contains("'")) {
          Fluttertoast.showToast(
              msg: 'Bio cannot contain special characters you entered',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        } else {
          Update(pass,pass1,bio);
        }
      },
      child: RoundButton(
        color: Style.AccentBlue,
        minimumWidth: 230,
        disabledColor: Style.AccentBlue.withOpacity(0.3),
        onPressed: onNextButtonClick,
        child: Container(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Update',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              Icon(
                Icons.arrow_right_alt,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  next() {
    History.pushPageUntil(context, PickPhotoPage());
  }
}
