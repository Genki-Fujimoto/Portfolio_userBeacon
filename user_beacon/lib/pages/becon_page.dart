import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staffe_beacon/Class/StaffBeacon.dart';
import 'package:staffe_beacon/pages/top_page.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BeaconTrancePage extends StatefulWidget {
  //受け取り用変数の定義①
  final StaffBeacon? staffBeaconInfo;
  //this.〇〇を追記する②
  const BeaconTrancePage(this.staffBeaconInfo,{Key? key}) : super(key: key);
  @override
  State<BeaconTrancePage> createState() => _BeaconTranceState();
}

class _BeaconTranceState extends State<BeaconTrancePage> {

  //webview
  final Completer<WebViewController> _controller = Completer<WebViewController>();
  bool _canGoBack = false;
  bool _canGoForward = false;

  //Loading
  bool _isLoading = false;

  //switch
  var isOn = false;

  @override
  void initState() {
    super.initState();
    // Androidに対応させる
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
  }

  @override
  Widget build(BuildContext context) {
    //変数に変換
    String? userName = widget.staffBeaconInfo?.user;
    //変数に変換
    String? url = widget.staffBeaconInfo?.url;

    return Scaffold(
      appBar: AppBar(
        // 中央寄せを解除
        centerTitle: false,
        title: Text("ログイン名: $userName"),
        backgroundColor: Colors.orangeAccent,
        //✖️ボタン非表示
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            //リロードボタン
            icon: Icon(Icons.refresh_outlined),
            onPressed: () async {
              final controller = await _controller.future;
              controller.reload(); // リロード
            },
          ),
          IconButton(
            icon: Icon(Icons.home_filled),
            onPressed: () async {
              final controller = await _controller.future;
              controller.loadUrl(url!);
            },
          ),
        ],
      ),
      body: SafeArea(
          child: _buildBody()
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        //if (_isLoading) const LinearProgressIndicator(),
        Expanded(
          child: _buildWebView(),
        ),
        _botomBarBtns(),
      ],
    );
  }

  //webview表示
  Widget _buildWebView() {

    //変数に変換
    String? url = widget.staffBeaconInfo?.url;

    return WebView(
      //表示させたいURL
      initialUrl: url,
      // jsを有効化
      javascriptMode: JavascriptMode.unrestricted,
      // controllerを登録
      onWebViewCreated: _controller.complete,
      // ページの読み込み開始
      onPageStarted: (String url) async{
        final controller = await _controller.future;
        _canGoBack = await controller.canGoBack();
        _canGoForward = await controller.canGoForward();

        // ローディング開始
        setState(() {
          _isLoading = true;
        });
      },
      // ページ読み込み終了
      onPageFinished: (String url) async {
        final controller = await _controller.future;
        _canGoBack = await controller.canGoBack();
        _canGoForward = await controller.canGoForward();

        print("_canGoBack　$_canGoBack");
        print("_canGoForward　$_canGoForward");

        // ローディング終了
        setState(() {
          _isLoading = false;
        });
        // ページタイトル取得

        final title = await controller.getTitle();
        setState(() {
          if (title != null) {
            //_title = title;
          }
        });
      },
    );
  }

  //下のバーアイテム
  Widget _botomBarBtns(){
    return Container(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          //戻るボタン
          ElevatedButton(
            child: Icon(Icons.arrow_back_ios),
            onPressed: !_canGoBack ? null :() async {
              print("戻るボタン配下$_canGoBack");
              final controller = await _controller.future;
              //_canGoBack = await controller.canGoBack();
              controller.goBack(); // 戻る
              //_canGoBack ? controller.goBack() : null;
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.transparent,
              elevation: 0,
              onPrimary: Colors.blue,
            ),
          ),

          //進むボタン
          ElevatedButton(
            child: Icon(Icons.arrow_forward_ios),
            onPressed: !_canGoForward ? null : () async {
              print("→ボタン配下$_canGoForward");
              final controller = await _controller.future;
              //_canGoForward = await controller.canGoForward();
              controller.goForward(); // 戻る
              //_canGoForward ? controller.goForward() : null;
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.transparent,
              elevation: 0,
              onPrimary: Colors.blue,
            ),
          ),

          //ログアウトボタン
          ElevatedButton(
            child: Icon(Icons.logout),
            onPressed: () {

              //アラート表示
              _showSimpleDialog();

              //受け取り変数利用widget.を追記する③
              print(widget.staffBeaconInfo?.url);

              //画面閉じる
              //Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.transparent,
              elevation: 0,
              onPrimary: Colors.blue,
            ),
          ),

          //テキスト表示関数
          showText(),

          //トグルボタン
          CupertinoSwitch(
            value: isOn,
            onChanged: (bool? value) {
              if (value != null) {
                setState(() {
                  isOn = value;
                  print("$isOn");
                  beaconSwith();
                }
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // Textウィジェットを返す関数
  Text showText() {
    if (isOn) {
      return const Text('発進中',
          style: TextStyle(
            fontSize: 20,
            color: Colors.red,
          ));
    } else {
      return const Text('停止中',
          style: TextStyle(
            fontSize: 20,
            color: Colors.blueAccent,
          )
      );
    }
  }

  //ibeacon発進停止
  void beaconSwith() async {
    if (isOn) {

      //変数に変換
      String uuid = widget.staffBeaconInfo!.uuid.toString();
      String major = widget.staffBeaconInfo!.major.toString();
      String miner = widget.staffBeaconInfo!.miner.toString();

      await flutterBeacon.startBroadcast(BeaconBroadcast(
        proximityUUID: uuid,
        major: int.tryParse(major) ?? 0,
        minor: int.tryParse(miner) ?? 0,
      ));
    } else {
      await flutterBeacon.stopBroadcast();
    }
  }

  // ダイアログを生成（IOS風アラート）
  Future _showSimpleDialog() async {

    var prefs = await SharedPreferences.getInstance();

    LoginState? _loginState = LoginState(
      isLogin: prefs.getBool('isLogin'),
      mailText: prefs.getString('mailText'),
      passText: prefs.getString('passText'),
    );

    return showDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text("確認"),
            content: const Text("ログアウトします"),
            actions: [
              CupertinoDialogAction(
                child: const Text('Cancel'),
                isDestructiveAction: true,
                //アラート閉じる
                onPressed: () => Navigator.pop(context),
              ),
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () async {

                  //データを端末に保存する
                  var prefs = await SharedPreferences.getInstance();
                  // Key-Value形式で保存していく。
                  await prefs.setString('route', "/");

                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => TopPage(_loginState),
                    //モーダル遷移
                    fullscreenDialog: true,
                  ));
                }
              ),
            ],
          );
        }
    );
  }
}

//Navigator.popUntil(context, (_) => count++ >= 2),//戻りたい数を指定
//最初の画面に戻る
//Navigator.of(context).popUntil((route) => route.isFirst),

