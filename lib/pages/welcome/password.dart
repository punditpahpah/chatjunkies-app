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

class Password extends StatefulWidget {
  String country_code, number;
  Password({Key key, this.country_code, this.number}) : super(key: key);

  @override
  _PasswordState createState() => _PasswordState();
}

class _PasswordState extends State<Password> {
  final _userNameController = TextEditingController();
  final _userNameformKey = GlobalKey<FormState>();
  Function onNextButtonClick;
  Future CheckUserName() async {
    ProgressDialog dialog = new ProgressDialog(context);
    dialog.style(message: 'Please wait...');
    await dialog.show();
    var url = base_url + "login.php";
    var response = await http.post(url, body: {
      "country_code": '${widget.country_code}',
      "mobile_no": '${widget.number}',
      "password": _userNameController.text,
      "auth_key": auth_key
    });
    var data = json.decode(response.body);
    var code = data[0]['code'];
    if (code == 1) {
      await dialog.hide();
      addStringToSF() async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('id', data[0]['id']);
        prefs.setString('country_code', data[0]['country_code']);
        prefs.setString('mobile_no', data[0]['mobile_no']);
        prefs.setString('first_name', data[0]['first_name']);
        prefs.setString('last_name', data[0]['last_name']);
        prefs.setString('username', data[0]['username']);
        prefs.setString('profile', data[0]['profile']);
        prefs.setString('followers', data[0]['followers']);
        prefs.setString('who_you_follow', data[0]['who_you_follow']);
        prefs.setString('bio', data[0]['bio']);
        prefs.setString('is_logged_in', 'yes');
      }
      addStringToSF();
      var route = new MaterialPageRoute(
          builder: (BuildContext context) => new HomePage());
      Navigator.of(context).push(route);
    } else if (code == 0) {
      dialog.hide();
      Fluttertoast.showToast(
          msg: "Invalid passowrd",
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
          top: 30,
          bottom: 60,
        ),
        child: Column(
          children: [
            buildTitle(),
            SizedBox(
              height: 50,
            ),
            buildForm(),
            Spacer(),
            buildBottom(),
          ],
        ),
      ),
    );
  }

  Widget buildTitle() {
    return Text(
      'Enter password',
      style: TextStyle(
        fontSize: 25,
        color: Colors.white
      ),
    );
  }

  Widget buildForm() {
    return Container(
      width: 330,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Form(
        child: TextFormField(
          textAlign: TextAlign.center,
          controller: _userNameController,
          autocorrect: false,
          autofocus: false,
          decoration: InputDecoration(
            hintText: '**********',
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
        CheckUserName();
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
                'Next',
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
