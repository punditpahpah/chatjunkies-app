import 'package:chat_junkies/call/call.dart';
import 'package:chat_junkies/constants.dart';
import 'package:flutter/material.dart';
import 'package:chat_junkies/pages/lobby/widgets/room_card.dart';
import 'package:chat_junkies/pages/lobby/widgets/schedule_card.dart';
import 'package:chat_junkies/models/room.dart';
//import 'package:chat_junkies/util/data.dart';
import 'package:chat_junkies/widgets/round_button.dart';
import 'package:chat_junkies/util/style.dart';
import 'package:chat_junkies/pages/lobby/widgets/lobby_bottom_sheet.dart';
import 'package:chat_junkies/pages/room/room_page.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:chat_junkies/widgets/round_image.dart';

class LobbyPage extends StatefulWidget {
  @override
  _LobbyPageState createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  ClientRole _role = ClientRole.Broadcaster;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.loadComplete();
  }

  List<user_item> filtered = [];
  String cliked_user_id;
  String room_id;
  Future<List<user_item>> _GetUsers() async {
    var Users = await http
        .get(base_url + "get_public_rooms.php?user_id=$id&auth_key=$auth_key");
    var JsonData = json.decode(Users.body);
    final List<user_item> users = [];
    for (var u in JsonData) {
      user_item item = user_item(
          u["ur_id"],
          u["req_id"],
          u["req_first_name"],
          u["req_profile"],
          u["room_id"],
          u["room_name"],
          u["no_of_people"],
          u["code"]);
      users.add(item);
      filtered.add(item);
    }
    return users;
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

  Future CreatePublicRoom(String room_name) async {
    ProgressDialog dialog = new ProgressDialog(context);
    dialog.style(message: 'Please wait...');
    await dialog.show();
    var url = base_url + "create_public_room.php";
    var response = await http.post(url,
        body: {"user_id": id, "room_name": room_name, "auth_key": auth_key});
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
      // Scaffold.of(context).hideCurrentSnackBar();

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
        _getFAB();
      }
      // Fluttertoast.showToast(
      //     msg: "$RouteResponse",
      //     toastLength: Toast.LENGTH_SHORT,
      //     gravity: ToastGravity.CENTER,
      //     timeInSecForIosWeb: 1,
      //     backgroundColor: Colors.red,
      //     textColor: Colors.white,
      //     fontSize: 16.0);
    } else if (code == 0) {
      await dialog.hide();
      Fluttertoast.showToast(
          msg: "Error while creating room",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
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

  CreateAlertDialog(BuildContext context) {
    TextEditingController room_name_controller = new TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Enter room name"),
            content: TextField(
              controller: room_name_controller,
            ),
            actions: [
              MaterialButton(
                elevation: 5.0,
                child: Text("Create room"),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  CreatePublicRoom(room_name_controller.text);
                },
              )
            ],
          );
        });
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
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Positioned(
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
                      "No Public Rooms",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )),
                  );
                } else {
                  return ListView.builder(
                    padding: const EdgeInsets.only(
                      bottom: 80,
                      left: 20,
                      right: 20,
                    ),
                    itemBuilder: (lc, index) {
                      // if (index == 0) {
                      //   return buildScheduleCard();
                      // }

                      // return buildRoomCard();

                      return GestureDetector(
                        // onTap: () {
                        //   enterRoom(room);
                        // },
                        onTap: () async {
                          room_id = snapshot.data[index].req_id;
                          String room_name = snapshot.data[index].room_name;
                          Accept(room_id, room_name);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 20,
                            ),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    offset: Offset(0, 1),
                                  )
                                ]),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  snapshot.data[index].room_name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  children: [
                                    Stack(
                                      children: [
                                        // RoundImage(
                                        //   margin: const EdgeInsets.only(top: 15, left: 25),
                                        //   path: base_url + profile,
                                        // ),
                                        // RoundImage(

                                        //   path: base_url + profile,
                                        // ),
                                        //  CircleAvatar(
                                        //   margin: const EdgeInsets.only(top: 15, left: 25),
                                        //   radius: 25,
                                        //   backgroundImage: NetworkImage(base_url + profile),
                                        // ),
                                        CircleAvatar(
                                          radius: 25,
                                          backgroundImage: NetworkImage(
                                              base_url +
                                                  snapshot
                                                      .data[index].req_profile),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        //buildUserList(),

                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            for (var i = 0; i < 1; i++)
                                              Container(
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      snapshot.data[index]
                                                              .req_first_name +
                                                          " (Broadcaster)",
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Icon(
                                                      Icons.chat,
                                                      color: Colors.grey,
                                                      size: 14,
                                                    ),
                                                  ],
                                                ),
                                              )
                                          ],
                                        ),

                                        SizedBox(
                                          height: 5,
                                        ),
                                        // buildRoomInfo(),

                                        Row(
                                          children: [
                                            Text(
                                              snapshot.data[index].no_of_people
                                                  .toString(),
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Icon(
                                              Icons.supervisor_account,
                                              color: Colors.grey,
                                              size: 14,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: snapshot.data.length,
                  );
                }
              }),
        ),
        buildGradientContainer(),
        buildStartRoomButton(),
      ],
    );
  }

  Widget buildScheduleCard() {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: ScheduleCard(),
    );
  }

  Widget buildRoomCard() {
    return GestureDetector(
      // onTap: () {
      //   enterRoom(room);
      // },
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 10,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  offset: Offset(0, 1),
                )
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Assad",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  Stack(
                    children: [
                      // RoundImage(
                      //   margin: const EdgeInsets.only(top: 15, left: 25),
                      //   path: base_url + profile,
                      // ),
                      // RoundImage(

                      //   path: base_url + profile,
                      // ),
                      //  CircleAvatar(
                      //   margin: const EdgeInsets.only(top: 15, left: 25),
                      //   radius: 25,
                      //   backgroundImage: NetworkImage(base_url + profile),
                      // ),
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(base_url + profile),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //buildUserList(),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var i = 0; i < 2; i++)
                            Container(
                              child: Row(
                                children: [
                                  Text(
                                    "Saad",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Icon(
                                    Icons.chat,
                                    color: Colors.grey,
                                    size: 14,
                                  ),
                                ],
                              ),
                            )
                        ],
                      ),

                      SizedBox(
                        height: 5,
                      ),
                      // buildRoomInfo(),

                      Row(
                        children: [
                          Text(
                            '15',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          Icon(
                            Icons.supervisor_account,
                            color: Colors.grey,
                            size: 14,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _getFAB() {
      return FloatingActionButton(
          backgroundColor: Colors.deepOrange[800],
          child: Icon(Icons.add_shopping_cart),
          onPressed: null);
  }

  Widget buildGradientContainer() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
          gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Style.LightBrown.withOpacity(0.2),
          Style.LightBrown,
        ],
      )),
    );
  }

  Widget buildStartRoomButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: RoundButton(
          onPressed: () {
            // showBottomSheet();
            //
            // CreatePublicRoom();
            CheckRoom();
            // CreateAlertDialog(context);
          },
          color: Style.AccentGreen,
          text: '+ Start a room'),
    );
  }

  enterRoom(Room room) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (rc) {
        return RoomPage(
          room: room,
        );
      },
    );
  }

  showBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
        topLeft: Radius.circular(15),
        topRight: Radius.circular(15),
      )),
      builder: (context) {
        return Wrap(
          children: [
            LobbyBottomSheet(
              onButtonTap: () {
                Navigator.pop(context);

                // enterRoom(
                //   Room(
                //     title: '${myProfile.name}\'s Room',
                //     users: [myProfile],
                //     speakerCount: 1,
                //   ),
                //);
              },
            ),
          ],
        );
      },
    );
  }

  CheckRoom() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String room_id = prefs.getString('room_id');
    setState(() {});

    if (room_id == null) {
      CreateAlertDialog(context);
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
}

class user_item {
  final String ur_id;
  final String req_id;
  final String req_first_name;
  final String req_profile;
  final String room_id;
  final String room_name;
  final int no_of_people;
  final int code;

  user_item(this.ur_id, this.req_id, this.req_first_name, this.req_profile,
      this.room_id, this.room_name, this.no_of_people, this.code);
}
