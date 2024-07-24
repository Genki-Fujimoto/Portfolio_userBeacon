import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:staffe_beacon/Class/api_beacon.dart';
import 'package:staffe_beacon/Class/StaffBeacon.dart';
import 'package:staffe_beacon/pages/becon_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TopPage extends StatefulWidget {

  //受け取り用変数の定義①
  final LoginState loginState;
  const TopPage(LoginState this.loginState, {Key? key}) : super(key: key);

  @override
  State<TopPage> createState() => _TopPageStates();
}

class _TopPageStates extends State<TopPage> {

  //fitebace認証
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //swithフラグ
  var isOn = true;

  // 入力したメールアドレス・パスワード
  String maillAdres = '';
  String password = '';
  StaffBeacon? beaconInfo;

  //テキストフィールド
  TextEditingController _mailTextController = TextEditingController();
  TextEditingController _passTextController = TextEditingController();

  //受け取り用変数の定義②
  // 引数の値があれば、_textController.textに代入する
   void initState() {
     super.initState();
     if (widget.loginState != null) {
       this._mailTextController.text =  widget.loginState.mailText!;
       maillAdres = this._mailTextController.text;
       this._passTextController.text =  widget.loginState.passText!;
       password =  this._passTextController.text;
     }
   }

  //firebaceユーザーIDクリエイトメソッド（未使用）
  Future<void> createUserFromEmail() async{
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: "test@test.com",
        password: "testtest"
    );
    print("Emailからユーザ作業完了");
  }

  //firebaceユーザーログインメソッド
  Future<void> sinInFromEmail(String email,String password) async{

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password
      );

      //ログイン成功時メールアドレスを受け取る
      String? resEmail = userCredential.user?.email;
      print("ログイン成功 ====> $resEmail");

      //メールアドレスをキーにしてAPI通信をしスタッフビーコン情報を受け取る
      StaffBeacon _getBeaconInfo = await Api.getBeaconInfo(resEmail!);

      if (_getBeaconInfo.uuid == "error" ) {
        print("if文エラー ===>　$_getBeaconInfo");
      } else {
        //ぐるぐる閉じる
        Navigator.pop(context);

        //ログイン状態データを端末に保存する
        var prefs = await SharedPreferences.getInstance(); // インスタンスを取得

        String? uuid = _getBeaconInfo.uuid;
        String? major = _getBeaconInfo.major;
        String? miner = _getBeaconInfo.miner;
        String? url = _getBeaconInfo.url;
        String? user = _getBeaconInfo.user;

        // Key-Value形式で保存していく。
        await prefs.setString('route', "beaconPage");
        await prefs.setString('uuid', uuid!);
        await prefs.setString('major', major!);
        await prefs.setString('miner', miner!);
        await prefs.setString('url', url!);
        await prefs.setString('user', user!);
        print('######保存完了######');

        //画面遷移
        // ignore: use_build_context_synchronously
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => BeaconTrancePage(_getBeaconInfo),
          //モーダル遷移
          fullscreenDialog: true,
        ));
      }
    } catch (error) {

      //ぐるぐる閉じる
      Navigator.pop(context);

      //エラー処理
      print(error.runtimeType);
      print("エラー ====> $error");
      _showSimpleDialog("$error");
    }
  }

  @override
  Widget build(BuildContext context) {
    //スクリーンサイズ取得
    var screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SafeArea(
            child: _buildBody(screenSize),
        ),
      ),
    );
  }

  Widget _buildBody(Size screenSize) {
    return Column(
      children: [
        _logoImaage(),
        _maillAdressTextFild(screenSize),
        Container(height: 20,),
        _PasswordTextFild(screenSize),
        _TogleSwitch(screenSize),
        _loginBtn(screenSize),
      ],
    );
  }

  Widget _logoImaage(){
    return Padding(
      //上下に40の余白
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Image.asset("assets/images/logos.png"),
    );
  }

  // Widget _CompanyText(Size screenSize){
  //   return  Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       SizedBox(
  //         width: screenSize.width*0.3,
  //
  //         // 組織ID入力
  //         child: TextFormField(
  //             decoration: const InputDecoration(
  //                 border: OutlineInputBorder(),
  //                 contentPadding: EdgeInsets.all(10),
  //                 labelText: '組織ID'
  //             ),
  //
  //             //入力した値を代入
  //             onChanged: (String value) {
  //               setState(() {
  //                 companyID = value;
  //               });
  //             }),
  //
  //       ),
  //       SizedBox(
  //         width: screenSize.width*0.6,
  //
  //         child: TextFormField(
  //           decoration: const InputDecoration(
  //             border: OutlineInputBorder(),
  //             contentPadding: EdgeInsets.all(10),
  //             labelText: 'メールアドレス',
  //           ),
  //
  //           onChanged: (String value) {
  //             setState(() {
  //               myID = value;
  //             });
  //           }),
  //
  //       )
  //     ],
  //   );
  // }

  Widget _maillAdressTextFild(Size screenSize) {

    //bool isLogin = widget.loginState.isLogin!;
    String mailText = widget.loginState.mailText!;
    //TextEditingController _mailTextController = TextEditingController(text: "f");

    return SizedBox(
      width: screenSize.width,
      child: TextFormField(
          controller: _mailTextController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(10),
            labelText: 'メールアドレス',
          ),
          onChanged: (String value) {
            setState(() {
              maillAdres = value;
            });
          }),
    );
  }

  Widget _PasswordTextFild(Size screenSize) {

    //bool isLogin = widget.loginState.isLogin!;
    String passText = widget.loginState.passText!;
    //TextEditingController _passTextController = TextEditingController(text: "fff");


    return SizedBox(
      width: screenSize.width,
      child: TextFormField(
          controller: _passTextController,
          obscureText: true,
          decoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.all(10),
          labelText: 'パスワード',
        ),
          onChanged: (String value) {
            setState(() {
              password = value;
            });
          }),
    );
  }

  Widget _TogleSwitch(Size screenSize) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("ログイン状態保存",
            style: TextStyle(
              fontSize: 15,
              color: Colors.blueAccent,
            ),
          ),
          CupertinoSwitch(
            value: isOn,
            onChanged: (bool? value) {
              if (value != null) {
                setState(() {
                  isOn = value;
                  print("$isOn");
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _loginBtn(Size screenSize) {
    return SizedBox(
      width: screenSize.width,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Colors.orange,
          onPrimary: Colors.white,
        ),
        child: const Text('ログイン',
        style: TextStyle(fontSize: 20,
        ),),

        onPressed: () async {

          //ログイン状態保存がonの場合保存
          var prefs = await SharedPreferences.getInstance(); // インスタンスを取得

          if (isOn){
            String mailText = maillAdres;
            String passText = password;
            await prefs.setBool('isLogin', true);
            await prefs.setString('mailText', mailText);
            await prefs.setString('passText', passText);
          } else {
            await prefs.setBool('isLogin', false);
            await prefs.setString('mailText',"");
            await prefs.setString('passText',"");
          }

          //入力した値の確認
          print(maillAdres);
          print(password);

          //アラート
          showDialog(
            context: context,
            builder: (context) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          );
          //firebaceユーザーログイン
          await sinInFromEmail(maillAdres,password);
        },
      ),
    );
  }

  // ダイアログを生成（IOS風アラート）
  Future _showSimpleDialog(String? str) async {
    return showDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text("確認"),
            content: Text(str!),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                isDestructiveAction: true,
                //アラート閉じる
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        }
    );
  }
}
