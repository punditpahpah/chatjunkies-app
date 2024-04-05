import 'dart:io';

import 'package:chat_junkies/constants.dart';
import 'package:chat_junkies/pages/home/home_page.dart';
import 'package:chat_junkies/pages/welcome/policy.dart';
import 'package:chat_junkies/widgets/round_button.dart';
import 'package:chat_junkies/util/style.dart';
import 'package:chat_junkies/pages/welcome/invitation_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'full_name_page.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'password.dart';
import 'dart:math';

class ForgetPassword extends StatefulWidget {
  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  @override
  void initState() {
    super.initState();
    getStringValuesSF();
  }

  getStringValuesSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String is_logged_in = prefs.getString('is_logged_in');
    setState(() {});

    if (is_logged_in == "yes") {
      var route = new MaterialPageRoute(
          builder: (BuildContext context) => new HomePage());
      Navigator.of(context).push(route);
    }
  }

  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  // final _formKey = GlobalKey<FormState>();
  int emailValue;
  Random random = new Random();
  Function onSignUpButtonClick;

  Future CheckUserName() async {
    ProgressDialog dialog = new ProgressDialog(context);
    dialog.style(message: 'Please wait...');
    await dialog.show();
    var url = base_url + "check_pass.php";

    var response = await http.post(url,
        body: {"email": _emailController.text, "auth_key": auth_key});
    // Fluttertoast.showToast(
    //     msg: response.body,
    //     toastLength: Toast.LENGTH_SHORT,
    //     gravity: ToastGravity.CENTER,
    //     timeInSecForIosWeb: 1,
    //     backgroundColor: Colors.red,
    //     textColor: Colors.white,
    //     fontSize: 16.0);
    var data = json.decode(response.body);
    var code = data[0]['code'];

    if (code == 1) {
      dialog.hide();
      SendEmail(_emailController.text,data[0]['password']);
    } else if (code == 0) {
      dialog.hide();
      Fluttertoast.showToast(
          msg: 'This email does not exist',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future SendEmail(email,pass) async {
    emailValue = random.nextInt(9999) + 1111;
    // ProgressDialog dialog = new ProgressDialog(context);
    // dialog.style(message: 'Please wait...');
    // await dialog.show();
    final uri = Uri.parse(base_url + "send_email.php");
    var request = http.MultipartRequest('POST', uri);
    request.fields['pin'] = emailValue.toString();
    request.fields['user_email'] = email;
    request.fields['auth_key'] = auth_key;
    var response = await request.send().then((result) async {
      http.Response.fromStream(result).then((response) {
        if (response.body == "sent") {
          //dialog.hide();
          Fluttertoast.showToast(
              msg: "Email Sent",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);

              CreateAlertDialog(context, email,pass);
        } else if (response.body == "not") {
          //dialog.hide();
          Fluttertoast.showToast(
              msg: "Email not sent",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      });
    });
  }

  Future<bool> _onBackPressed() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(),
        body: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.only(
            top: 1,
            bottom: 10,
          ),
          child: Column(
            children: [
              buildTitle(),
              SizedBox(
                height: 20,
              ),
              SizedBox(height: 20),
              buildForm1(),
              Spacer(),
              buildBottom(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTitle() {
    return Text(
      'Enter Email',
      style: TextStyle(fontSize: 25, color: Colors.white),
    );
  }

  Widget buildForm1() {
    return Container(
      width: 330,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Form(
              child: TextFormField(
                textAlign: TextAlign.center,
                controller: _emailController,
                autocorrect: false,
                autofocus: false,
                decoration: InputDecoration(
                  hintText: ' Email address',
                  hintStyle: TextStyle(
                    fontSize: 20,
                  ),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  // disabledBorder: InputBorder.none,
                ),
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBottom() {
    return Column(
      children: [
        InkWell(
          onTap: () {
            if (!_emailController.text.contains("@") ||
                !_emailController.text.contains(".")) {
              Fluttertoast.showToast(
                  msg: "Please enter a valid email",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.white,
                  textColor: Colors.purple,
                  fontSize: 16.0);
            } else {
              CheckUserName();
            }
          },
          child: RoundButton(
            color: Style.AccentBlue,
            minimumWidth: 230,
            // disabledColor: Style.AccentBlue.withOpacity(0.3),
            onPressed: onSignUpButtonClick,
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
        ),
      ],
    );
  }

  CreateAlertDialog(BuildContext context, String email, pass) {
    TextEditingController room_name_controller = new TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Enter Code sent to $email"),
            content: TextField(
              keyboardType: TextInputType.number,
              controller: room_name_controller,
            ),
            actions: [
              MaterialButton(
                elevation: 5.0,
                child: Text("Continue"),
                onPressed: () {
                  if (room_name_controller.text.toString() ==
                      emailValue.toString()) {
                    Navigator.of(context, rootNavigator: true).pop();
                    ChooseWinner(pass);
                  } else {
                    Fluttertoast.showToast(
                        msg: "Invalid Code",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  }
                },
              )
            ],
          );
        });
  }

  ChooseWinner(String pass) {
    Widget whatsappButton = FlatButton(
      child: Text("OK"),
      onPressed: () async {
        Navigator.pop(context);
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("Your password is: $pass"),
      actions: [
        whatsappButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
