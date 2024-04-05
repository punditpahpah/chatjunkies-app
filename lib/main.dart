import 'package:chat_junkies/pages/home/home_page.dart';
import 'package:chat_junkies/pages/welcome/welcome_page.dart';
import 'package:chat_junkies/util/style.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat Junkies',
      theme: ThemeData(
        fontFamily: 'Montserrat',
        scaffoldBackgroundColor: Style.LightBrown,
        appBarTheme: AppBarTheme(
          color: Style.LightBrown,
          elevation: 0.0,
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
        ),
      ),
      home: WelcomePage(),
    );
  }
}
