import 'package:chat_junkies/util/history.dart';
import 'package:chat_junkies/widgets/round_button.dart';
import 'package:chat_junkies/util/style.dart';
import 'package:chat_junkies/pages/welcome/username_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'username_page.dart';

class FullNamePage extends StatefulWidget {
  String country_code, number,email;
  FullNamePage({Key key, this.country_code, this.number, this.email}) : super(key: key);
  @override
  _FullNamePageState createState() => _FullNamePageState();
}

class _FullNamePageState extends State<FullNamePage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _firstNameFormKey = GlobalKey<FormState>();
  final _lastNameFormKey = GlobalKey<FormState>();
  Function onNextButtonClick;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.only(top: 30, bottom: 60),
        child: Column(
          children: [
            buildTitle(),
            SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: buildForm(),
            ),
            Spacer(),
            buildBottom(),
          ],
        ),
      ),
    );
  }

  Widget buildTitle() {
    return Text(
      'What\'s your full name?',
      style: TextStyle(fontSize: 25, color: Colors.white),
    );
  }

  Widget buildForm() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Form(
              child: TextFormField(
                textAlign: TextAlign.center,
                controller: _firstNameController,
                autocorrect: false,
                autofocus: false,
                decoration: InputDecoration(
                  hintText: 'First Name',
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
              ),
            ),
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Form(
              child: TextFormField(
                textAlign: TextAlign.center,
                controller: _lastNameController,
                autocorrect: false,
                autofocus: false,
                decoration: InputDecoration(
                  hintText: 'Last Name',
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
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget buildBottom() {
    return InkWell(
      onTap: () {
        if (_firstNameController.text.length >= 3 &&
            _lastNameController.text.length >= 3) {
          var route = new MaterialPageRoute(
              builder: (BuildContext context) => new UsernamePage(
                  country_code: '${widget.country_code}',
                  number: '${widget.number}',
                  email: '${widget.email}',
                  first_name: _firstNameController.text,
                  last_name: _lastNameController.text));
          Navigator.of(context).push(route);
        } else {
          Fluttertoast.showToast(
              msg: "Please enter your full name",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.white,
              textColor: Colors.purple,
              fontSize: 16.0);
        }
      },
      child: RoundButton(
        color: Style.AccentBlue,
        minimumWidth: 230,
        disabledColor: Style.AccentBlue.withOpacity(0.3),
        onPressed: onNextButtonClick,
        child: Container(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Next',
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
    );
  }

  next() {
    // History.pushPage(context, UsernamePage());
    //
    if (_firstNameController.text.length >= 3 &&
        _lastNameController.text.length >= 3) {
      var route = new MaterialPageRoute(
          builder: (BuildContext context) => new UsernamePage(
              country_code: '${widget.country_code}',
              number: '${widget.number}',
              first_name: _firstNameController.text,
              last_name: _lastNameController.text));
      Navigator.of(context).push(route);
    } else {
      Fluttertoast.showToast(
          msg: "Please enter your full name",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white,
          textColor: Colors.purple,
          fontSize: 16.0);
    }
  }
}
