import 'package:chat_junkies/pages/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:chat_junkies/constants.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:chat_junkies/config/palette.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chat_junkies/config/styles.dart';
import 'package:progress_dialog/progress_dialog.dart';

class Add_User_To_Room extends StatefulWidget {
  Add_User_To_Room({
    Key key,
  }) : super(key: key);

  @override
  _Add_User_To_Room createState() => _Add_User_To_Room();
}

class _Add_User_To_Room extends State<Add_User_To_Room> {
  String action;

  String cliked_user_id;

  Future<List<user_item>> _GetUsers() async {
    var Users = await http
        .get(base_url + "get_users.php?user_id=$user_id&auth_key=$auth_key");

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
      "user_id": user_id,
      "clicked_user_id": cliked_user_id,
      "from": "add",
      "auth_key": auth_key
    });
    var data = json.decode(response.body);
    var code = data[0]['code'];
    if (code == 1) {
      await dialog.hide();
      Fluttertoast.showToast(
          msg: "Requested",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
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

  ScrollController _ScrollControlleer = ScrollController();

  String user_id;
  @override
  Future<void> initState() {
    super.initState();
    getStringValuesSF();
  }

  getStringValuesSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    user_id = prefs.getString('id');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // user_id=ModalRoute.of(context).settings.arguments;
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Palette.appbar,
        elevation: 0.0,
        title: Text('Add JUNKIES'),
        leading: Container(),
        actions: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  "Back To Room",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
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
                  child: Center(child: Text("No Users")),
                );
              } else {
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
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
                          CheckUserInRoom();
                        }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Row(
                                children: [
                                  Container(
                                    width: 50.0,
                                    height: 50.0,
                                    child: CircleAvatar(
                                      backgroundImage: NetworkImage(base_url +
                                          snapshot.data[index].profile),
                                    ),
                                  ),
                                  SizedBox(width: 10.0),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          snapshot.data[index].first_name,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Montserrat'),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(width: 10.0),
                            Container(
                              alignment: Alignment.center,
                              child: Chip(
                                label: Text(
                                  snapshot.data[index].status,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'Montserrat'),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            }),
      ),
    );
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
