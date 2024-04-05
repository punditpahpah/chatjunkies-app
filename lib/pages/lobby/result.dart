import 'package:chat_junkies/config/palette.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'User.dart';
import 'Services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Result extends StatefulWidget {
  Result() : super();

  final String title = "Search Rooms";

  @override
  ResultState createState() => ResultState();
}

class Debouncer {
  final int milliseconds;
  VoidCallback action;
  Timer _timer;

  Debouncer({this.milliseconds});

  run(VoidCallback action) {
    if (null != _timer) {
      _timer.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

class ResultState extends State<Result> {
  Future<bool> _onBackPressed() {
    Navigator.pop(context, null);
  }
  // https://jsonplaceholder.typicode.com/users

  final _debouncer = Debouncer(milliseconds: 500);
  List<User> users = List();
  List<User> filteredUsers = List();

  @override
  void initState() {
    super.initState();
    Services.getUsers().then((usersFromServer) {
      setState(() {
        users = usersFromServer;
        filteredUsers = users;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Palette.main),
            iconSize: 28.0,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(5),
              width: 330,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Form(
                child: TextFormField(
                  textAlign: TextAlign.left,
                  autocorrect: false,
                  autofocus: false,
                  decoration: InputDecoration(
                    hintText: 'Type here....',
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
                  onChanged: (string) {
                    _debouncer.run(() {
                      setState(() {
                        filteredUsers = users
                            .where((u) => (u.room_name
                                    .toLowerCase()
                                    .contains(string.toLowerCase()) ||
                                u.req_first_name
                                    .toLowerCase()
                                    .contains(string.toLowerCase())))
                            .toList();
                      });
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: filteredUsers.isEmpty
                  ? Center(
                      child: Text(
                      "Loading....",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ))
                  : ListView.builder(
                      padding: EdgeInsets.all(10.0),
                      itemCount: filteredUsers.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context, filteredUsers[index].room_id);
                            // Fluttertoast.showToast(
                            //     msg: filteredUsers[index].req_first_name,
                            //     toastLength: Toast.LENGTH_SHORT,
                            //     gravity: ToastGravity.CENTER,
                            //     timeInSecForIosWeb: 1,
                            //     backgroundColor: Colors.red,
                            //     textColor: Colors.white,
                            //     fontSize: 16.0);
                          },
                          child: Card(
                            child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "Room: " + filteredUsers[index].room_name,
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  Text(
                                    "Broadcaster: " +
                                        filteredUsers[index].req_first_name,
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
