import 'package:chat_junkies/constants.dart';
import 'package:chat_junkies/models/user.dart';
import 'package:chat_junkies/pages/home/profile_page.dart';
import 'package:chat_junkies/widgets/round_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:chat_junkies/pages/lobby/notification.dart';

class HomeAppBar extends StatefulWidget {
  final User profile;
  final Function onProfileTab;
  const HomeAppBar({Key key, this.profile, this.onProfileTab})
      : super(key: key);
  @override
  _HomeAppBar createState() => new _HomeAppBar();
}

class _HomeAppBar extends State<HomeAppBar> {
  PageController _pageController =PageController(initialPage:0);
  String profile;
  @override
  Future<void> initState() {
    super.initState();
    getStringValuesSF();
    //_pageController = PageController();
  }

  getStringValuesSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    profile = prefs.getString('profile');

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          child: IconButton(
            onPressed: () {},
            iconSize: 30,
            icon: Icon(Icons.search),
          ),
        ),
        Spacer(),
        Row(
          children: [
            IconButton(
              onPressed: () {},
              iconSize: 30,
              icon: Icon(Icons.mail),
            ),
            SizedBox(
              width: 10,
            ),
            IconButton(
              onPressed: () {},
              iconSize: 30,
              icon: Icon(Icons.calendar_today),
            ),
            SizedBox(
              width: 10,
            ),
            IconButton(
              onPressed: () {
                if (_pageController.hasClients) {
                  _pageController.animateToPage(
                    2,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                }
              },
              iconSize: 30,
              icon: Icon(Icons.notifications_active_outlined),
            ),
            SizedBox(
              width: 10,
            ),
            InkWell(
              onTap: () {
                var route = new MaterialPageRoute(
                    builder: (BuildContext context) => new NotificationPage());
                Navigator.of(context).push(route);
              },
              child: CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(base_url + profile),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
