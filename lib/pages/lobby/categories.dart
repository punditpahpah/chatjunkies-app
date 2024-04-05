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

class Topics extends StatefulWidget {
  String from;
  Topics({Key key, this.from}) : super(key: key);

  @override
  _Topics createState() => _Topics();
}

class _Topics extends State<Topics> {
  String action;
  ScrollController _ScrollControlleer = ScrollController();

  Future<List<user_item>> _GetUsers() async {
    var Users = await http.get(
        base_url + "get_categories.php?user_id=$user_id&auth_key=$auth_key");
    var JsonData = json.decode(Users.body);
    List<user_item> users = [];
    for (var u in JsonData) {
      user_item item =
          user_item(u["cat_id"], u["cat_name"], u["action"], u["code"]);
      users.add(item);
    }
    return users;
  }

  Future Follow(cat_id) async {
    ProgressDialog dialog = new ProgressDialog(context);
    dialog.style(message: 'Please wait...');
    await dialog.show();
    var url = base_url + "choose_cat.php";
    var response = await http.post(url,
        body: {"user_id": user_id, "cat_id": cat_id, "auth_key": auth_key});
    var data = json.decode(response.body);
    var code = data[0]['code'];

    if (code == 1) {
      await dialog.hide();
      setState(() {});
    } else if (code == 0) {
      await dialog.hide();
      Fluttertoast.showToast(
          msg: "Error occured while following",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  String user_id;
  @override
  Future<void> initState() {
    super.initState();
    getStringValuesSF();
  }

  getStringValuesSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    user_id = prefs.getString('id');
    // Fluttertoast.showToast(
    //       msg: "${widget.from}",
    //       toastLength: Toast.LENGTH_SHORT,
    //       gravity: ToastGravity.CENTER,
    //       timeInSecForIosWeb: 1,
    //       backgroundColor: Colors.red,
    //       textColor: Colors.white,
    //       fontSize: 16.0);
    if ("${widget.from}" == "register") {
      action = "NEXT";
    } else {
      action = "CLOSE";
    }
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Palette.main),
          iconSize: 28.0,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Choose topics'),
        actions: <Widget>[
          GestureDetector(
            onTap: () {
              if ("${widget.from}" == "register") {
                var route = new MaterialPageRoute(
                    builder: (BuildContext context) =>
                        new HomePage(from: "regiter"));
                Navigator.of(context).push(route);
              } else {
                Navigator.pop(context);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  "$action",
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
                  child: Center(child: Text("No Topics")),
                );
              } else {
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        Follow(snapshot.data[index].cat_id);
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                // Container(
                                //   width:50.0,
                                //   height: 50.0,

                                //   child:CircleAvatar(
                                //     backgroundImage: NetworkImage(
                                //       snapshot.data[index].img
                                //     ),
                                //   ),
                                // ),
                                SizedBox(width: 10.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      snapshot.data[index].cat_name,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Montserrat'),
                                    ),
                                    //   Text('Start date: '+snapshot.data[index].start_date,
                                    // style: TextStyle(
                                    //     color: Colors.black,
                                    //     fontSize: 11,
                                    //     fontWeight: FontWeight.w800,
                                    //     fontFamily: 'Montserrat'),
                                    //   ),
                                  ],
                                )
                              ],
                            ),
                            SizedBox(width: 10.0),
                            Container(
                              alignment: Alignment.center,
                              child: Chip(
                                label: Text(
                                  snapshot.data[index].action,
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
  final String cat_id;
  final String cat_name;
  final String action;
  final int code;

  user_item(this.cat_id, this.cat_name, this.action, this.code);
}
