import 'dart:io';

import 'package:chat_junkies/call/call.dart';
import 'package:chat_junkies/constants.dart';
import 'package:chat_junkies/pages/home/profile_page.dart';
import 'package:chat_junkies/pages/lobby/follower_page.dart';
import 'package:chat_junkies/pages/lobby/lobby_page.dart';
import 'package:chat_junkies/pages/lobby/notification.dart';
import 'package:chat_junkies/pages/lobby/follow_people.dart';
import 'package:chat_junkies/util/data.dart';
import 'package:chat_junkies/util/history.dart';
import 'package:chat_junkies/pages/home/widgets/home_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:chat_junkies/config/palette.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:chat_junkies/pages/lobby/categories.dart';
import 'package:chat_junkies/pages/lobby/result.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:progress_dialog/progress_dialog.dart';

class HomePage extends StatefulWidget {
  String from;
  HomePage({Key key, this.from}) : super(key: key);
  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  ClientRole _role = ClientRole.Broadcaster;
  int page_no = 0;
  PageController _pageController;
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    getStringValuesSF();
    // Fluttertoast.showToast(
    //                 msg: "${widget.from}",
    //                 toastLength: Toast.LENGTH_SHORT,
    //                 gravity: ToastGravity.CENTER,
    //                 timeInSecForIosWeb: 1,
    //                 backgroundColor: Colors.red,
    //                 textColor: Colors.white,
    //                 fontSize: 16.0);
    if ("${widget.from}" == "register") {
      _pageController.animateToPage(
        2,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  String profile, id;

  getStringValuesSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    profile = prefs.getString('profile');
    id = prefs.getString('id');

    setState(() {});
  }

  Future<bool> _onBackPressed() {
    if (page_no == 0) {
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
                    }
                    
                  },
                  child: Text("YES"),
                ),
              ],
            ),
          ) ??
          false;
    } else {
      setState(() {
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Palette.appbar,
          elevation: 0.0,
          // title: Text(
          //   'Balance Sheet',
          //   style: TextStyle(color: Colors.black, fontFamily: 'Montserrat'),
          // ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Palette.main),
            iconSize: 28.0,
            onPressed: () {
              if (page_no == 0) {
                _onBackPressed();
              } else {
                setState(() {
                  if (_pageController.hasClients) {
                    _pageController.animateToPage(
                      0,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOut,
                    );
                  }
                });
              }
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.search, color: Palette.main),
              iconSize: 28.0,
              onPressed: () async {
                // var route = new MaterialPageRoute(
                //   builder: (BuildContext context) => new Result(),
                // );
                // Navigator.of(context).push(route);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Result()),
                );
                if ("$result" != "null") {
                  CheckRoom(result, "1");
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.topic_outlined, color: Palette.main),
              iconSize: 28.0,
              onPressed: () {
                var route = new MaterialPageRoute(
                  builder: (BuildContext context) => new Topics(from: "login"),
                );
                Navigator.of(context).push(route);
              },
            ),
            IconButton(
              icon:
                  const Icon(Icons.notification_important, color: Palette.main),
              iconSize: 28.0,
              onPressed: () {
                // setState(() {
                if (_pageController.hasClients) {
                  _pageController.animateToPage(
                    2,
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOut,
                  );
                }
                // });

                // var route=new MaterialPageRoute(
                //     builder:(BuildContext context)=>
                //     new UserServicesList(),
                //     );
                //     Navigator.of(context).push(route);
                //
                // Fluttertoast.showToast(
                //     msg: page_no.toString(),
                //     toastLength: Toast.LENGTH_SHORT,
                //     gravity: ToastGravity.CENTER,
                //     timeInSecForIosWeb: 1,
                //     backgroundColor: Colors.red,
                //     textColor: Colors.white,
                //     fontSize: 16.0);
              },
            ),
            GestureDetector(
              onTap: () {
                var route = new MaterialPageRoute(
                    builder: (BuildContext context) =>
                        new ProfilePage(show: "no"));
                Navigator.of(context).push(route);
              },
              child: CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(base_url + profile),
              ),
            ),
          ],
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: (int page) {
            page_no = page;
          },
          children: [
            LobbyPage(),
            FollowerPage(),
            NotificationPage(),
            DoFollow(),
          ],
        ),
      ),
    );
  }

  CheckRoom(String room_id, String room_name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String room_id = prefs.getString('room_id');
    setState(() {});

    if (room_id == null) {
      Accept(room_id, room_name);
    } else {
      Fluttertoast.showToast(
          msg: "Room Exist",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future Accept(String room_id, String room_name) async {
    ProgressDialog dialog = new ProgressDialog(context);
    dialog.style(message: 'Please wait...');
    await dialog.show();
    var Users = await http.get(base_url +
        "accept_public_meeting.php?user_id=$id&room_id=$room_id&room_name=$room_name&auth_key=$auth_key");
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
}
