import 'package:chat_junkies/pages/lobby/categories.dart';
import 'package:chat_junkies/pages/welcome/phone_number_page.dart';
import 'package:chat_junkies/util/history.dart';
import 'package:chat_junkies/widgets/round_button.dart';
import 'package:chat_junkies/util/style.dart';
import 'package:chat_junkies/pages/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:chat_junkies/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PickPhotoPage extends StatefulWidget {
  String country_code, number, email, first_name, last_name, username, password;
  PickPhotoPage(
      {Key key,
      this.country_code,
      this.number,
      this.email,
      this.first_name,
      this.last_name,
      this.username,
      this.password})
      : super(key: key);
  @override
  _PickPhotoPage createState() => new _PickPhotoPage();
}

class _PickPhotoPage extends State<PickPhotoPage> {
  File image;
  Future getimg() async {
    var img = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      // image=img;
      image = File(img.path);
    });
  }

  Future Register() async {
    ProgressDialog dialog = new ProgressDialog(context);
    dialog.style(message: 'Please wait...');
    await dialog.show();
    final uri = Uri.parse(base_url + "register_user.php");
    var request = http.MultipartRequest('POST', uri);
    request.fields['country_code'] = '${widget.country_code}';
    request.fields['mobile_no'] = '${widget.number}';
    request.fields['email'] = '${widget.email}';
    request.fields['first_name'] = '${widget.first_name}';
    request.fields['last_name'] = '${widget.last_name}';
    request.fields['username'] = '${widget.username}';
    request.fields['password'] = '${widget.password}';
    request.fields['auth_key'] = auth_key;
    var pic = await http.MultipartFile.fromPath("image", image.path);
    request.files.add(pic);
    var response = await request.send().then((result) async {
      http.Response.fromStream(result).then((response) {
        if (response.body == "registered") {
          dialog.hide();
          // var route = new MaterialPageRoute(
          //     builder: (BuildContext context) => new PhoneNumberPage());
          // Navigator.of(context).push(route);
          //
          Login();
        } else if (response.body == "not registered") {
          dialog.hide();
          Fluttertoast.showToast(
              msg: "Not registered or email address already exist",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        } else if (response.body == "not uploaded") {
          dialog.hide();
          Fluttertoast.showToast(
              msg: "Not registered",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        } else {
          dialog.hide();
          Fluttertoast.showToast(
              msg: "Some error occured",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      });
    });
  }

  Future Login() async {
    ProgressDialog dialog = new ProgressDialog(context);
    dialog.style(message: 'Please wait...');
    await dialog.show();
    var url = base_url + "login.php";
    var response = await http.post(url, body: {
      "country_code": '${widget.country_code}',
      "mobile_no": '${widget.number}',
      "password": "${widget.password}",
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
          builder: (BuildContext context) => new Topics(from: "register"));
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
      appBar: AppBar(
        actions: [
          buildActionButton(context),
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.only(
          top: 30,
          bottom: 60,
        ),
        child: Column(
          children: [
            buildTitle(),
            Spacer(
              flex: 1,
            ),
            buildContents(),
            Spacer(
              flex: 3,
            ),
            buildBottom(),
          ],
        ),
      ),
    );
  }

  Widget buildActionButton(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: GestureDetector(
        // onTap: () {
        //   History.pushPageReplacement(context, HomePage());
        // },
        child: Text(
          '',
          style: TextStyle(
            color: Style.DarkBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget buildTitle() {
    return Text(
      'Great! Now add a photo?',
      style: TextStyle(fontSize: 25, color: Colors.white),
    );
  }

  Widget buildContents() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(80),
      ),
      child: InkWell(
        onTap: () {
          getimg();
        },
        child: image == null
            ? Image.asset("assets/images/rozarpay.png",
                width: 60, height: 60, fit: BoxFit.cover)
            : Image.file(image, width: 60, height: 60, fit: BoxFit.cover),
      ),
    );
  }

  Widget buildBottom() {
    return RoundButton(
      color: Style.AccentBlue,
      minimumWidth: 230,
      disabledColor: Style.AccentBlue.withOpacity(0.3),
      onPressed: () {
        Register();
      },
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
    );
  }
}
