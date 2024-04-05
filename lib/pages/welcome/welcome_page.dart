import 'package:chat_junkies/util/history.dart';
import 'package:chat_junkies/widgets/round_button.dart';
import 'package:chat_junkies/util/style.dart';
import 'package:chat_junkies/pages/welcome/phone_number_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key key}) : super(key: key);
  @override
  _WelcomePage createState() => new _WelcomePage();
}

class _WelcomePage extends State {
  String profile,
      id,
      first_name,
      last_name,
      username,
      followers,
      who_you_follow;
  @override
  Future<void> initState() {
    super.initState();
    getStringValuesSF();
  }

  getStringValuesSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: const EdgeInsets.only(
          left: 50,
          right: 50,
          bottom: 60,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTitle(),
            SizedBox(
              height: 40,
            ),
            Expanded(
              child: buildContents(),
            ),
            buildBottom(context),
          ],
        ),
      ),
    );
  }

  Widget buildTitle() {
    return Text(
      '🎉 Welcome!',
      style: TextStyle(
        fontSize: 25,
        color: Colors.white
      ),
    );
  }

  Widget buildContents() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chatjunkies is space for casual,drop-audio conversations-with friends and other interesting people. Chatjunkies is a rapidly growing audio-chat iPhone and Android app platform which connects tens of thousands of people from around the world.',
            style: TextStyle(
              height: 1.8,
              fontSize: 15,
              color: Colors.white
            ),
          ),
          SizedBox(
            height: 40,
          ),
          Text(
            '🏠 Launched in May 2021 by Leslie Graham',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBottom(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RoundButton(
          color: Style.AccentBlue,
          onPressed: () {
            History.pushPage(context, PhoneNumberPage());
          },
          child: Container(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Signup/Login',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                Icon(
                  Icons.arrow_right_alt,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     Text(
        //       'Have an invite text?',
        //       style: TextStyle(
        //         color: Style.AccentBlue,
        //       ),
        //     ),
        //     SizedBox(
        //       width: 5,
        //     ),
        //     Text(
        //       'Sign in',
        //       style: TextStyle(
        //         color: Style.AccentBlue,
        //         fontWeight: FontWeight.bold,
        //       ),
        //     ),
        //     Icon(
        //       Icons.arrow_right_alt,
        //       color: Style.AccentBlue,
        //     ),
        //   ],
        // ),
      ],
    );
  }
}
