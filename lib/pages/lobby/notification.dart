import 'package:chat_junkies/call/call.dart';
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
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPage createState() => new _NotificationPage();
}

class _NotificationPage extends State<NotificationPage> {
  ClientRole _role = ClientRole.Broadcaster;
  String cliked_user_id;
  String room_id;
  Future<List<user_item>> _GetUsers() async {
    var Users = await http
        .get(base_url + "get_notifications.php?user_id=$id&auth_key=$auth_key");
    var JsonData = json.decode(Users.body);
    List<user_item> users = [];
    for (var u in JsonData) {
      user_item item = user_item(u["ur_id"], u["req_id"], u["req_first_name"],
          u["req_profile"], u["room_id"], u["code"]);
      users.add(item);
    }
    return users;
  }

  Future Accept(String room_id) async {
    ProgressDialog dialog = new ProgressDialog(context);
    dialog.style(message: 'Please wait...');
    await dialog.show();
    var Users = await http.get(base_url +
        "accept_meeting.php?user_id=$id&room_id=$room_id&auth_key=$auth_key");
    var JsonData = json.decode(Users.body);
    var code = JsonData[0]['code'];
    if (code == 0) {
      dialog.hide();
      Fluttertoast.showToast(
          msg: "Some error occured while joining room",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else if (code == 1) {
      addStringToSF() async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('room_id', room_id);
      }

      addStringToSF();
      dialog.hide();
      Future<void> _handleCameraAndMic(Permission permission) async {
        final status = await permission.request();
        print(status);
      }

      await _handleCameraAndMic(Permission.camera);
      await _handleCameraAndMic(Permission.microphone);
      // push video page with given channel name
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallPage(
            channelName: room_id,
            role: _role,
          ),
        ),
      );
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
          'Notifications',
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
                "No Notification",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )),
            );
          } else {
            return ListView.builder(
              shrinkWrap: true,
              physics: ScrollPhysics(),
              itemBuilder: (lc, index) {
                return InkWell(
                  onTap: () async {
                    room_id = snapshot.data[index].req_id;
                    Accept(room_id);
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
                                  base_url + snapshot.data[index].req_profile),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    snapshot.data[index].req_first_name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white
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
                                      '+ Join',
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
}

class user_item {
  final String ur_id;
  final String req_id;
  final String req_first_name;
  final String req_profile;
  final String room_id;
  final int code;

  user_item(this.ur_id, this.req_id, this.req_first_name, this.req_profile,
      this.room_id, this.code);
}
