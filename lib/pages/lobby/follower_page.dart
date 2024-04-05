import 'package:chat_junkies/call/call.dart';
import 'package:chat_junkies/call/create_and_join.dart';
import 'package:chat_junkies/constants.dart';
import 'package:chat_junkies/models/room.dart';
import 'package:chat_junkies/pages/home/profile_page.dart';
import 'package:chat_junkies/pages/lobby/widgets/follower_item.dart';
import 'package:chat_junkies/pages/room/room_page.dart';
import 'package:chat_junkies/util/data.dart';
import 'package:chat_junkies/util/history.dart';
import 'package:chat_junkies/util/style.dart';
import 'package:flutter/material.dart';
import 'package:chat_junkies/widgets/round_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class FollowerPage extends StatefulWidget {
  @override
  _FollowerPage createState() => new _FollowerPage();
}

class _FollowerPage extends State<FollowerPage> {
  final _channelController = TextEditingController();

  /// if channel textField is validated to have error
  bool _validateError = false;

  ClientRole _role = ClientRole.Broadcaster;

  String cliked_user_id;

  Future<List<user_item>> _GetUsers() async {
    var Users = await http
        .get(base_url + "get_users.php?user_id=$id&auth_key=$auth_key");

    var JsonData = json.decode(Users.body);
    //  Fluttertoast.showToast(
    // msg: Users.body,
    // toastLength: Toast.LENGTH_SHORT,
    // gravity: ToastGravity.CENTER,
    // timeInSecForIosWeb: 1,
    // backgroundColor: Colors.red,
    // textColor: Colors.white,
    // fontSize: 16.0);
    List<user_item> users = [];
    for (var u in JsonData) {
      user_item item = user_item(u["id"], u["username"], u["first_name"],
          u["profile"], u["status"], u["code"]);
      users.add(item);
    }
    return users;
  }

  Future CheckUserInRoom() async {
    ProgressDialog dialog = new ProgressDialog(context);
    dialog.style(message: 'Please wait...');
    await dialog.show();
    var Users = await http.get(base_url +
        "check_user_in_room.php?user_id=$cliked_user_id&auth_key=$auth_key");
    // Fluttertoast.showToast(
    //     msg: Users.body,
    //     toastLength: Toast.LENGTH_SHORT,
    //     gravity: ToastGravity.CENTER,
    //     timeInSecForIosWeb: 1,
    //     backgroundColor: Colors.red,
    //     textColor: Colors.white,
    //     fontSize: 16.0);
    var JsonData = json.decode(Users.body);
    var code = JsonData[0]['code'];
    if (code == 0) {
      await dialog.hide();
      Fluttertoast.showToast(
          msg: "This user is in another room",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else if (code == 1) {
      CreateRome();
    }
  }

  Future CreateRome() async {
    ProgressDialog dialog = new ProgressDialog(context);
    dialog.style(message: 'Please wait...');
    await dialog.show();
    var url = base_url + "create_room.php";
    var response = await http.post(url, body: {
      "user_id": id,
      "clicked_user_id": cliked_user_id,
      "from": "new",
      "auth_key": auth_key
    });
    var data = json.decode(response.body);

    var code = data[0]['code'];
    if (code == 1) {
      await dialog.hide();
      addStringToSF() async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('room_id', id);
      }

      addStringToSF();
      Future<void> _handleCameraAndMic(Permission permission) async {
        final status = await permission.request();
        print(status);
      }

      await _handleCameraAndMic(Permission.camera);
      await _handleCameraAndMic(Permission.microphone);
      // push video page with given channel name
      final RouteResponse = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallPage(
            channelName: id,
            role: _role,
          ),
        ),
      );
      if ("$RouteResponse" == "Nope.") {
        ShowSnackBar();
      }
    } else if (code == 0) {
      await dialog.hide();
      Fluttertoast.showToast(
          msg: response.body,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  String profile, id, first_name, last_name, username;
  @override
  Future<void> initState() {
    super.initState();
    getStringValuesSF();
  }

  getStringValuesSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    profile = prefs.getString('profile');
    id = prefs.getString('id');
    first_name = prefs.getString('first_name');
    last_name = prefs.getString('first_name');
    username = prefs.getString('username');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 10,
      ),
      child: Column(
        children: [
          buildAvailableChatTitle(),
          buildAvailableChatList(context),
        ],
      ),
    );
  }

  Widget buildAvailableChatTitle() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'AVAILABLE TO CHAT',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: Style.DarkBrown,
          ),
        ),
      ],
    );
  }

  Widget buildAvailableChatList(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: _GetUsers(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return Container(
              child: Center(
                  child: Text(
                "Loading...",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )),
            );
          } else if (snapshot.data[0].code == 0) {
            return Container(
              child: Center(
                  child: Text(
                "No Junkies",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 25,
                ),
              )),
            );
          } else {
            return ListView.builder(
              shrinkWrap: true,
              physics: ScrollPhysics(),
              itemBuilder: (lc, index) {
                return InkWell(
                  onTap: () {

                    if (snapshot.data[index].status == "Offline") {
                      Fluttertoast.showToast(
                          msg: "User is offline",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    } else if (snapshot.data[index].status == "Online") {
                      cliked_user_id = snapshot.data[index].id;
                      CheckRoom();
                    }
                  },
                  child: Container(
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            // GestureDetector(
                            //   onTap: onProfileTap,
                            //   child: RoundImage(
                            //     path: user.profileImage,
                            //     borderRadius: 15,
                            //   ),
                            // ),
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(
                                  base_url + snapshot.data[index].profile),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    snapshot.data[index].first_name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    snapshot.data[index].status,
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 25,
                              child: RoundButton(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                onPressed: () {},
                                color: Style.LightGreen,
                                child: Row(
                                  children: [
                                    Text(
                                      '+ Room',
                                      style: TextStyle(
                                        color: Style.AccentGreen,
                                      ),
                                    ),
                                    Icon(
                                      Icons.lock,
                                      color: Style.AccentGreen,
                                      size: 15,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        )),
                  ),
                );
              },
              itemCount: snapshot.data.length,
            );
          }
        },
      ),
    );
  }

  ShowSnackBar() {
    final snackBar = SnackBar(
      duration: Duration(days: 1),
      content: Text('You are in a call'),
      action: SnackBarAction(
        label: 'Go To Room',
        onPressed: () async {
          final RouteResponse = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CallPage(
                channelName: id,
                role: _role,
              ),
            ),
          );
          if ("$RouteResponse" == "Nope.") {
            ShowSnackBar();
          }
        },
      ),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  CheckRoom() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String room_id = prefs.getString('room_id');
    setState(() {});

    if (room_id == null) {
      CheckUserInRoom();
    } else {
     // CheckUserInRoom();
      Fluttertoast.showToast(
          msg: "Room Already Exist",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }
}

class user_item {
  final String id;
  final String username;
  final String first_name;
  final String profile;
  final String status;
  final int code;

  user_item(this.id, this.username, this.first_name, this.profile, this.status,
      this.code);
}
