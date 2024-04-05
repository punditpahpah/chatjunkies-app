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

class UsernamePage extends StatefulWidget {
  String country_code, number,email, first_name, last_name;
  UsernamePage(
      {Key key,
      this.country_code,
      this.number,
      this.email,
      this.first_name,
      this.last_name})
      : super(key: key);

  @override
  _UsernamePageState createState() => _UsernamePageState();
}

class _UsernamePageState extends State<UsernamePage> {
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _userNameformKey = GlobalKey<FormState>();
  Function onNextButtonClick;
  
  Future CheckUserName() async {
    if (_passwordController.text.length >= 6) {

      ProgressDialog dialog = new ProgressDialog(context);
      dialog.style(message: 'Please wait...');
      await dialog.show();
      var url = base_url + "check_username.php";
      var response = await http.post(url,
          body: {"username": _userNameController.text, "auth_key": auth_key});
      var data = json.decode(response.body);
      var code = data[0]['code'];
      if (code == 0) {
        await dialog.hide();
        Fluttertoast.showToast(
            msg: "Username already exist",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else if (code == 1) {
        dialog.hide();
        var route = new MaterialPageRoute(
            builder: (BuildContext context) => new PickPhotoPage(
                  country_code: '${widget.country_code}',
                  number: '${widget.number}',
                  email: '${widget.email}',
                  first_name: '${widget.first_name}',
                  last_name: '${widget.last_name}',
                  username: _userNameController.text,
                  password: _passwordController.text,
                ));
        Navigator.of(context).push(route);
      }
    } else {
      Fluttertoast.showToast(
          msg: "Password must be 6 characters long",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white,
          textColor: Colors.purple,
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
      'Pick a username and \npassword',
      style: TextStyle(fontSize: 25, color: Colors.white),
    );
  }

  Widget buildForm() {
    return Column(
      children: [
        Container(
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
                hintText: '@username',
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
        ),
        SizedBox(height: 50),
        Container(
          width: 330,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Form(
            child: TextFormField(
              textAlign: TextAlign.center,
              controller: _passwordController,
              autocorrect: false,
              autofocus: false,
              decoration: InputDecoration(
                hintText: 'Password',
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
        ),
      ],
    );
  }

  Widget buildBottom() {
    return InkWell(
      onTap: () {
        if (_userNameController.text.length >= 3) {
          CheckUserName();
        } else {
          Fluttertoast.showToast(
              msg: "Username must be 4 characters long",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.white,
              textColor: Colors.purple,
              fontSize: 16.0);
        }
        //     Fluttertoast.showToast(
        // msg: '${widget.country_code} ${widget.number} ${widget.first_name} ${widget.last_name}',
        // toastLength: Toast.LENGTH_SHORT,
        // gravity: ToastGravity.CENTER,
        // timeInSecForIosWeb: 1,
        // backgroundColor: Colors.red,
        // textColor: Colors.white,
        // fontSize: 16.0);
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
