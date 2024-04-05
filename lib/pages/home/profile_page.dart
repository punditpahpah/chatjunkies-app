import 'dart:io';

import 'package:chat_junkies/config/palette.dart';
import 'package:chat_junkies/constants.dart';
import 'package:chat_junkies/models/user.dart';
import 'package:chat_junkies/pages/welcome/welcome_page.dart';
import 'package:chat_junkies/util/data.dart';
import 'package:chat_junkies/widgets/round_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chat_junkies/widgets/round_button.dart';
import 'package:chat_junkies/util/style.dart';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:chat_junkies/pages/update_profile/update_profile.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  String show, user_id;
  ProfilePage({Key key, this.show, this.user_id}) : super(key: key);
  @override
  _ProfilePage createState() => new _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {
  String profile =
          "data:image/jpeg;base64,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",
      id = "0",
      first_name = "....",
      last_name = "....",
      username = "@....",
      followers = "....",
      who_you_follow = "....",
      status = "....",
      bio = "......";
  @override
  Future<void> initState() {
    super.initState();
    if (widget.show == "no") {
      getStringValuesSF();
    } else {
      GetUser();
    }
  }

  Future GetUser() async {
    var Users = await http.get(base_url +
        "get_users_profile.php?user_id=${widget.user_id}&auth_key=$auth_key");

    var data = json.decode(Users.body);

    profile = base_url + data[0]['profile'];
    id = data[0]['id'];
    username = data[0]['username'];
    first_name = data[0]['first_name'];
    last_name = data[0]['id'];
    status = data[0]['status'];
    who_you_follow = data[0]['who_you_follow'];
    followers = data[0]['followers'];
    bio = data[0]['bio'];
    setState(() {});
  }

  getStringValuesSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    profile = base_url + prefs.getString('profile');
    id = prefs.getString('id');
    first_name = prefs.getString('first_name');
    last_name = prefs.getString('first_name');
    username = prefs.getString('username');
    followers = prefs.getString('followers');
    who_you_follow = prefs.getString('who_you_follow');
    bio = prefs.getString('bio');
    setState(() {});
  }

  File image;

  Future getimg() async {
    var img = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      // image=img;
      image = File(img.path);
      if (image != null) {
        UpdateImage();
      }
    });
  }

  Future UpdateImage() async {
    ProgressDialog dialog = new ProgressDialog(context);
    dialog.style(message: 'Please wait...');
    await dialog.show();
    final uri = Uri.parse(base_url + "update_profile.php");
    var request = http.MultipartRequest('POST', uri);
    request.fields['user_id'] = '$id';
    request.fields['username'] = '$username';
    request.fields['auth_key'] = auth_key;
    var pic = await http.MultipartFile.fromPath("image", image.path);
    request.files.add(pic);
    var response = await request.send().then((result) async {
      http.Response.fromStream(result).then((response) async {
        var data = json.decode(response.body);
        var code = data[0]['code'];
        if (code == "updated") {
          dialog.hide();
          addStringToSF() async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('profile', data[0]['profile']);
            prefs.reload();
            getStringValuesSF();
          }

          addStringToSF();

          // setState(() {
          //   getStringValuesSF();
          // });

          // var route = new MaterialPageRoute(
          //     builder: (BuildContext context) => new PhoneNumberPage());
          // Navigator.of(context).push(route);
          //
        } else if (code == "not updated") {
          dialog.hide();
          Fluttertoast.showToast(
              msg: "Profile picture not updated",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.settings_rounded),
        //     onPressed: () {},
        //   ),
        // ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Palette.main),
          iconSize: 28.0,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Column(
            children: [
              buildProfile(),
              SizedBox(
                height: 20,
              ),
              // builderInviter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProfile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            if (widget.show == "no") {
              getimg();
            }
          },
          child: CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(profile),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Text(
          "$first_name $last_name",
          style: TextStyle(
              fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          "@$username",
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(
          height: 15,
        ),
        Text(
          "$bio",
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        // Flexible(
        //       child: RichText(
        //         overflow: TextOverflow.ellipsis,
        //         maxLines: 2,
        //         strutStyle: StrutStyle(fontSize: 12.0),
        //         text: TextSpan(
        //           text: "$bio",
        //           style: TextStyle(
        //               fontWeight: FontWeight.w600, color: kPrimaryColor),
        //         ),
        //       ),
        //     ),
        SizedBox(
          height: 15,
        ),
        Row(
          children: [
            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(
                    text: followers.toString(),
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  TextSpan(
                    text: ' followers',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ],
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(
              width: 50,
            ),
            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(
                    text: who_you_follow.toString(),
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  TextSpan(
                    text: ' following',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ],
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 30),
        if (widget.show == "no")
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: RoundButton(
                onPressed: () async {
                  var route = new MaterialPageRoute(
                      builder: (BuildContext context) => new UpdateProfile());
                  Navigator.of(context).push(route);
                },
                color: Style.AccentGreen,
                text: 'Update profile'),
          ),
        if (widget.show == "no")
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: RoundButton(
                onPressed: () async {
                  var url = base_url + "logout.php";
                  var response = await http
                      .post(url, body: {"user_id": id, "auth_key": auth_key});
                  // var data = json.decode(response.body);
                  // var code = data[0]['code'];
                  // if (code == 0) {
                  //   Fluttertoast.showToast(
                  //       msg: 'Some Error',
                  //       toastLength: Toast.LENGTH_SHORT,
                  //       gravity: ToastGravity.CENTER,
                  //       timeInSecForIosWeb: 1,
                  //       backgroundColor: Colors.red,
                  //       textColor: Colors.white,
                  //       fontSize: 16.0);
                  // }
                  SharedPreferences preferences =
                      await SharedPreferences.getInstance();
                  await preferences.clear();
                  setState(() {});
                  void makeRoutePage({BuildContext context, Widget pageRef}) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => pageRef),
                        (Route<dynamic> route) => false);
                  }

                  makeRoutePage(context: context, pageRef: WelcomePage());
                },
                color: Style.AccentGreen,
                text: 'Sign out'),
          ),
      ],
    );
  }

  Widget builderInviter() {
    return Row(
      children: [
        RoundImage(
          path: 'assets/images/puzzleleaf.png',
        ),
        SizedBox(
          width: 10,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Joined Mar 28, 2021'),
            SizedBox(
              height: 3,
            ),
            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(
                    text: 'Nominated by ',
                  ),
                  TextSpan(
                    text: 'Puzzleleaf',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
