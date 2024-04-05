import 'dart:io';

import 'package:chat_junkies/constants.dart';
import 'package:chat_junkies/pages/home/home_page.dart';
import 'package:chat_junkies/pages/welcome/forget.dart';
import 'package:chat_junkies/pages/welcome/policy.dart';
import 'package:chat_junkies/widgets/round_button.dart';
import 'package:country_code_picker/country_code_picker.dart';
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

class PhoneNumberPage extends StatefulWidget {
  @override
  _PhoneNumberPageState createState() => _PhoneNumberPageState();
}

class _PhoneNumberPageState extends State<PhoneNumberPage> {
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
  String country_code = "+92";
  Function onSignUpButtonClick;

  void _onCountryChange(CountryCode countryCode) {
    country_code = countryCode.toString();
    print("New Country selected: " + countryCode.toString());
  }

  Future CheckUserName() async {
    ProgressDialog dialog = new ProgressDialog(context);
    dialog.style(message: 'Please wait...');
    await dialog.show();
    var url = base_url + "check_number.php";

    var response = await http.post(url, body: {
      "country_code": country_code,
      "mobile_no": _phoneNumberController.text,
      "email": _emailController.text,
      "auth_key": auth_key
    });
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
      var route = new MaterialPageRoute(
          builder: (BuildContext context) => new FullNamePage(
                country_code: country_code,
                number: _phoneNumberController.text,
                email: _emailController.text,
              ));
      Navigator.of(context).push(route);
    }
    if (code == 2) {
      dialog.hide();
      Fluttertoast.showToast(
          msg: "Wrong email with this mobile number",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white,
          textColor: Colors.purple,
          fontSize: 16.0);
    } else if (code == 0) {
      dialog.hide();
      var route = new MaterialPageRoute(
          builder: (BuildContext context) => new Password(
                country_code: country_code,
                number: _phoneNumberController.text,
              ));
      Navigator.of(context).push(route);
    }
  }

  Future<bool> _onBackPressed() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to exit an App'),
            actions: <Widget>[
              new GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
                child: Text("NO"),
              ),
              SizedBox(height: 16),
              new GestureDetector(
                onTap: () {
                  if (Platform.isAndroid) {
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                  } else if (Platform.isIOS) {
                    // iOS-specific code
                  }
                },
                child: Text("YES"),
              ),
            ],
          ),
        ) ??
        false;
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
              buildForm(),
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
      'Enter Below',
      style: TextStyle(fontSize: 25, color: Colors.white),
    );
  }

  Widget buildForm() {
    return Container(
      width: 330,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CountryCodePicker(
            onChanged: _onCountryChange,
            initialSelection: 'P',
            showCountryOnly: false,
            alignLeft: false,
            padding: const EdgeInsets.all(8),
            textStyle: TextStyle(
              fontSize: 20,
            ),
          ),
          Expanded(
            child: Form(
              child: TextFormField(
                controller: _phoneNumberController,
                autocorrect: false,
                autofocus: false,
                decoration: InputDecoration(
                  hintText: 'Phone Number',
                  hintStyle: TextStyle(
                    fontSize: 20,
                  ),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  // disabledBorder: InputBorder.none,
                ),
                keyboardType: TextInputType.numberWithOptions(
                    signed: true, decimal: true),
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
        Text(
          'By registering here, you\'re agreeing to out\nTerms or Services and Privacy Policy. Thanks!',
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(
          height: 10,
        ),
        GestureDetector(
          onTap: () {
            var route = new MaterialPageRoute(
                builder: (BuildContext context) => new Policy());
            Navigator.of(context).push(route);
          },
          child: Text(
            'Tap to view Terms and policies',
            style: TextStyle(color: Colors.white),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        GestureDetector(
          onTap: () {
            var route = new MaterialPageRoute(
                builder: (BuildContext context) => new ForgetPassword());
            Navigator.of(context).push(route);
          },
          child: Text(
            'Forget Passowrd?',
            style: TextStyle(color: Colors.white),
          ),
        ),
        SizedBox(
          height: 30,
        ),
        InkWell(
          onTap: () {
            if (_phoneNumberController.text.length < 10) {
              Fluttertoast.showToast(
                  msg: "Please enter a valid number",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.white,
                  textColor: Colors.purple,
                  fontSize: 16.0);
            } else if (!_emailController.text.contains("@") ||
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
}
