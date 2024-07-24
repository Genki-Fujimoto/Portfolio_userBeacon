import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staffe_beacon/firebase_options.dart';
import 'package:staffe_beacon/pages/becon_page.dart';
import 'package:staffe_beacon/pages/top_page.dart';
import 'Class/StaffBeacon.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //値取得
  var prefs = await SharedPreferences.getInstance();
  String rute = prefs.getString('route') ?? "/";

  //StaffBeacon型作成
  StaffBeacon? saveBeaconInfo = StaffBeacon(
      uuid: prefs.getString('uuid'),
      major: prefs.getString('uuid'),
      miner: prefs.getString('miner'),
      url:  prefs.getString('url'),
      user:  prefs.getString('user')
  );

  bool isLogin =  prefs.getBool('isOn') ?? false;
  String mailText =  prefs.getString('mailText') ?? "";
  String passText =  prefs.getString('passText') ?? "";

  print(isLogin);
  print(mailText);
  print(passText);

  //LoginState型作成
  LoginState? _loginState = LoginState(
      isLogin: isLogin,
      mailText: mailText,
      passText: passText,
  );

  print("かくにん3");
  runApp(MyApp(rute,saveBeaconInfo,_loginState));
}


class MyApp extends StatelessWidget {

  final String? rute;
  final StaffBeacon? saveBeaconInfo;
  final LoginState loginState;

  const MyApp(String? this.rute, StaffBeacon this.saveBeaconInfo, LoginState this.loginState, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      initialRoute: rute, // 初期画面を'/'とする
      routes: {
        "/": (context) => TopPage(loginState),// Screen0()を'/'とする
        "beaconPage": (context) => BeaconTrancePage(saveBeaconInfo),// Screen1()を'/first'とする
      },
    );
  }
}

