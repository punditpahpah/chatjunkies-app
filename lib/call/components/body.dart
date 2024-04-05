import 'package:chat_junkies/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'user_calling_card.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Body extends StatefulWidget {
  
  @override
  _Body createState() => new _Body();
}

class _Body extends State<Body> {
  String room_id;
  Future<List<user_item>> _GetUsers() async {
    Fluttertoast.showToast(
          msg: "assad",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    var Users = await http.get(
        base_url + "users_in_meeting.php?room_id=4&auth_key=$auth_key");
        Fluttertoast.showToast(
          msg: Users.body,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    var JsonData = json.decode(Users.body);
    List<user_item> users = [];
    for (var u in JsonData) {
      user_item item = user_item(u["ur_id"], u["meet_first_name"],
          u["meet_last_name"], u["meet_profile"], u["room_id"], u["code"]);
      users.add(item);
    }
    return users;
  }

  Timer timer;

  @override
  void initState() {
    super.initState();
    getStringValuesSF();
    // timer = Timer.periodic(Duration(seconds: 10), (Timer t) => setState(() {}));
  }
  getStringValuesSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    room_id = prefs.getString('room_id');
    setState(() {});
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _GetUsers(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return Container(
              child: Center(child: Text("Loading...")),
            );
          } else if (snapshot.data[0].code == 0) {
            return Container(
              child: Center(child: Text("All left")),
            );
          } else {
            return GridView.builder(
                padding: EdgeInsets.zero,
                itemCount: snapshot.data.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 0.60,
                  crossAxisCount: 2,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return Hero(
                    tag: snapshot.data[index].meet_first_name,
                    child: InkWell(
                      child: GridTile(
                        footer: Container(
                          height: 50,
                          color: Colors.black54,
                          child: ListTile(
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 1.0),
                            leading: IconButton(
                              icon:
                                  SvgPicture.asset("assets/icons/Icon Mic.svg"),
                              onPressed: () {},
                            ),
                            title: Transform.translate(
                              offset: Offset(-16, 0),
                              child: Text(
                                snapshot.data[index].meet_first_name,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        child: Image.network(
                            base_url + snapshot.data[index].meet_profile,
                            fit: BoxFit.cover),
                      ),
                    ),
                  );
                });
          }
        });
  }
}

List<Map<String, dynamic>> demoData = [
  {
    "isCalling": false,
    "name": "User 1User 1User 1User 1",
    "image": "assets/images/goup_call_1.png",
  },
];

class user_item {
  final String ur_id;
  final String meet_first_name;
  final String meet_last_name;
  final String meet_profile;
  final String room_id;
  final int code;

  user_item(this.ur_id, this.meet_first_name, this.meet_last_name,
      this.meet_profile, this.room_id, this.code);
}
