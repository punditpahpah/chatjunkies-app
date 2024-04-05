import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:chat_junkies/constants.dart';
import 'package:chat_junkies/pages/home/profile_page.dart';
import 'package:chat_junkies/pages/lobby/add_user_meeting.dart';
import 'package:flutter/material.dart';
import 'settings.dart';
import 'package:chat_junkies/constants/size_config.dart';
import 'package:chat_junkies/call/components/rounded_button.dart';
import 'package:chat_junkies/constants/constants.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CallPage extends StatefulWidget {
  /// non-modifiable channel name of the page
  final String channelName;

  /// non-modifiable client role of the page
  final ClientRole role;

  /// Creates a call page with given channel name.
  const CallPage({Key key, this.channelName, this.role}) : super(key: key);

  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  Future<bool> _onBackPressed() {
    //Navigator.pop(context, 'Nope.');
  }

  final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  RtcEngine _engine;
  Timer timer;

  String room_id;
  String id;
  bool hand_raised = false;
  String hand_raise = "Raise hand";
  String pic = "assets/icons/Icon Mic.svg";
  Future<List<user_item>> _GetUsers() async {
    var Users = await http.get(
        base_url + "users_in_meeting.php?room_id=$room_id&auth_key=$auth_key");
    var JsonData = json.decode(Users.body);
    List<user_item> users = [];
    for (var u in JsonData) {
      user_item item = user_item(
          u["ur_id"],
          u["user_id"],
          u["meet_first_name"],
          u["meet_last_name"],
          u["meet_profile"],
          u["room_id"],
          u["status"],
          u["meet_status"],
          u["hand_raise"],
          u["code"]);
      users.add(item);
    }
    return users;
  }

  Future CloseCall() async {
    addStringToSF() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('room_id', null);
    }

    addStringToSF();
    ProgressDialog dialog = new ProgressDialog(context);
    dialog.style(message: 'Please wait...');
    await dialog.show();
    var url = base_url + "close_call.php";
    var response = await http.post(url,
        body: {"user_id": id, "room_id": room_id, "auth_key": auth_key});
    var data = json.decode(response.body);
    var code = data[0]['code'];
    if (code == 1) {
      await dialog.hide();
      _users.clear();
      // destroy sdk
      timer.cancel();
      _engine.leaveChannel();
      _engine.destroy();
      _onCallEnd(context);
    }
    if (code == 0) {
      await dialog.hide();
      Fluttertoast.showToast(
          msg: 'Some error occured while closing call',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future HandAction(String action) async {
    var url = base_url + "hand_action.php";
    var response = await http.post(url, body: {
      "user_id": id,
      "room_id": room_id,
      "action": action,
      "auth_key": auth_key
    });
    var data = json.decode(response.body);
    var code = data[0]['code'];
    if (code == 0) {
      Fluttertoast.showToast(
          msg: 'Some Error',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  void initState() {
    super.initState();
    // initialize agora sdk
    getStringValuesSF();
    // addStringToSF() async {
    //   SharedPreferences prefs = await SharedPreferences.getInstance();
    //   prefs.setString('is_room', "1");
    // }
    // addStringToSF();
    timer = Timer.periodic(Duration(seconds: 2), (Timer t) => setState(() {}));
    initialize();
  }

  getStringValuesSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    room_id = prefs.getString('room_id');
    id = prefs.getString('id');
    setState(() {});
  }

  Future<void> initialize() async {
    if (APP_ID.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await _engine.enableWebSdkInteroperability(true);
    // VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    // configuration.dimensions = VideoDimensions(1920, 1080);
    // await _engine.setVideoEncoderConfiguration(configuration);
    // await _engine.joinChannel(Token, widget.channelName, null, 0);
    await _engine.joinChannel(null, widget.channelName, null, 0);
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(APP_ID);
    // await _engine.enableVideo();
    await _engine.disableVideo();
    await _engine.enableAudio();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(widget.role);
    //await _engine.stopEchoTest();
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(error: (code) {
      setState(() {
        final info = 'onError: $code';
        _infoStrings.add(info);
      });
    }, joinChannelSuccess: (channel, uid, elapsed) {
      setState(() {
        final info = 'onJoinChannel: $channel, uid: $uid';
        // Fluttertoast.showToast(
        //     msg: 'onJoinChannel: $channel, uid: $uid',
        //     toastLength: Toast.LENGTH_SHORT,
        //     gravity: ToastGravity.CENTER,
        //     timeInSecForIosWeb: 1,
        //     backgroundColor: Colors.red,
        //     textColor: Colors.white,
        //     fontSize: 16.0);
        _infoStrings.add(info);
      });
    }, leaveChannel: (stats) {
      setState(() {
        _infoStrings.add('onLeaveChannel');
        _users.clear();
      });
    }, userJoined: (uid, elapsed) {
      setState(() {
        final info = 'userJoined: $uid';
        _infoStrings.add(info);
        _users.add(uid);
      });
    }, userOffline: (uid, elapsed) {
      setState(() {
        final info = 'userOffline: $uid';

        _infoStrings.add(info);
        _users.remove(uid);
        // Fluttertoast.showToast(
        //     msg: 'userOffline: $uid',
        //     toastLength: Toast.LENGTH_SHORT,
        //     gravity: ToastGravity.CENTER,
        //     timeInSecForIosWeb: 1,
        //     backgroundColor: Colors.red,
        //     textColor: Colors.white,
        //     fontSize: 16.0);
      });
    }, firstRemoteVideoFrame: (uid, width, height, elapsed) {
      setState(() {
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        _infoStrings.add(info);
      });
    }));
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<StatefulWidget> list = [];
    if (widget.role == ClientRole.Broadcaster) {
      list.add(RtcLocalView.SurfaceView());
    }
    _users.forEach((int uid) => list.add(RtcRemoteView.SurfaceView(uid: uid)));
    return list;
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  /// Video layout wrapper
  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
            child: Column(
          children: <Widget>[_videoView(views[0])],
        ));
      case 2:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow([views[0]]),
            _expandedVideoRow([views[1]])
          ],
        ));
      case 3:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 3))
          ],
        ));
      case 4:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4))
          ],
        ));
      default:
    }
    return Container();
  }

  /// Toolbar layout
  Widget _toolbar() {
    if (widget.role == ClientRole.Audience) return Container();
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () => _onCallEnd(context),
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          RawMaterialButton(
            onPressed: _onSwitchCamera,
            child: Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          )
        ],
      ),
    );
  }

  /// Info panel to show logs
  Widget _panel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: ListView.builder(
            reverse: true,
            itemCount: _infoStrings.length,
            itemBuilder: (BuildContext context, int index) {
              if (_infoStrings.isEmpty) {
                return null;
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.yellowAccent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          _infoStrings[index],
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onCallEnd(BuildContext context) {
    Navigator.pop(context, null);
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    _engine.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: buildAppBar(),
        body: Center(child: Stack(children: [Body()])),
        bottomNavigationBar: buildBottomNavBar(),
      ),
    );
  }

  Container buildBottomNavBar() {
    return Container(
      color: kBackgoundColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              RoundedButton(
                color: kRedColor,
                iconColor: Colors.white,
                size: 48,
                iconSrc: "assets/icons/Icon Close.svg",
                press: () {
                  CloseCall();
                },
              ),
              Spacer(flex: 3),
              Spacer(),
              // RoundedButton(
              //   color: Color(0xFF2C384D),
              //   iconColor: Colors.white,
              //   size: 48,
              //   iconSrc: "assets/icons/Icon Mic.svg",
              //   press: () {
              //     _onToggleMute();
              //   },
              // ),
              RawMaterialButton(
                onPressed: _onToggleMute,
                child: Icon(
                  muted ? Icons.mic_off : Icons.mic,
                  color: muted ? Colors.white : Colors.blueAccent,
                  size: 20.0,
                ),
                shape: CircleBorder(),
                elevation: 2.0,
                fillColor: muted ? Colors.blueAccent : Colors.white,
                padding: const EdgeInsets.all(12.0),
              ),
              GestureDetector(
                onTap: () {
                  if (hand_raised) {
                    HandAction("0");
                    hand_raised = !hand_raised;
                    hand_raise = "Raise hand";
                    setState(() {});
                  } else {
                    HandAction("1");
                    hand_raised = !hand_raised;
                    hand_raise = "Down hand";
                    setState(() {});
                  }
                },
                child: Chip(
                  backgroundColor: Colors.white,
                  label: Text(
                    hand_raise,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat'),
                  ),
                  avatar: SvgPicture.asset("assets/icons/hand.svg"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      // leading: IconButton(
      //   icon: SvgPicture.asset("assets/icons/Icon Back.svg"),
      //   onPressed: () {},
      // ),
      actions: [
        IconButton(
          icon: SvgPicture.asset(
            "assets/icons/Icon User.svg",
            height: 24,
          ),
          onPressed: () {
            if (room_id == id) {
              var route = new MaterialPageRoute(
                  builder: (BuildContext context) => new Add_User_To_Room());
              Navigator.of(context).push(route);
            } else {
              Fluttertoast.showToast(
                  msg: 'You cannot add participants',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
            }
          },
        ),
      ],
    );
  }

  Container Body() {
    return Container(
      color: kBackgoundColor,
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
                  "No Junkies",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )),
              );
            } else {
              return SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: GridView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: snapshot.data.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio: 0.7,
                        crossAxisCount: 2,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        if (snapshot.data[index].meet_status == "Deleted") {
                          timer.cancel();
                          _engine.leaveChannel();
                          _engine.destroy();
                          return Container(
                            child: Center(
                                child: Text(
                              "Broadcaster deleted room",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )),
                          );
                        } else {
                          // if(snapshot.data[index].hand_raise == "1"){
                          //   pic="assets/icons/Icon Mic.svg";
                          // }
                          // else if(snapshot.data[index].hand_raise == "0"){
                          //   pic="assets/icons/hand.svg";
                          // }
                          return Padding(
                            padding: EdgeInsets.all(5),
                            child: GestureDetector(
                              onTap: () {
                                var route = new MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        new ProfilePage(
                                            show: 'yes',
                                            user_id:
                                                snapshot.data[index].user_id));
                                Navigator.of(context).push(route);
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Hero(
                                  tag: snapshot.data[index].hand_raise,
                                  child: InkWell(
                                    child: GridTile(
                                      footer: Container(
                                        height: 50,
                                        color: Colors.white,
                                        child: ListTile(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 1.0),
                                          leading: Container(
                                              child: (snapshot.data[index]
                                                          .hand_raise ==
                                                      "1")
                                                  ? IconButton(
                                                      icon: SvgPicture.asset(
                                                          "assets/icons/hand.svg"),
                                                      onPressed: () {},
                                                    )
                                                  : IconButton(
                                                      icon: SvgPicture.asset(
                                                          "$pic"),
                                                      onPressed: () {},
                                                    )),
                                          title: Transform.translate(
                                            offset: Offset(-25, 0),
                                            child: Text(
                                              snapshot
                                                  .data[index].meet_first_name,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                  fontSize: 15),
                                            ),
                                          ),
                                        ),
                                      ),
                                      child: Image.network(
                                          base_url +
                                              snapshot.data[index].meet_profile,
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      }),
                ),
              );
            }
          }),
    );
  }
}

class user_item {
  final String ur_id;
  final String user_id;
  final String meet_first_name;
  final String meet_last_name;
  final String meet_profile;
  final String room_id;
  final String status;
  final String meet_status;
  final String hand_raise;
  final int code;

  user_item(
      this.ur_id,
      this.user_id,
      this.meet_first_name,
      this.meet_last_name,
      this.meet_profile,
      this.room_id,
      this.status,
      this.meet_status,
      this.hand_raise,
      this.code);
}
