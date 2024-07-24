import 'dart:convert';
import 'package:http/http.dart';
import 'package:staffe_beacon/Class/StaffBeacon.dart';

class Api{
  static Future<StaffBeacon> getBeaconInfo(String email) async{

    //emailを追加してAPIコール
    String apiurl = 'http://=$email';
    print("URL ===> $apiurl");

    try{

      //GETでパース
      var result = await get(Uri.parse(apiurl));

      //辞書型でJson取得
      Map<String ,dynamic> data = jsonDecode(result.body);

      //取得
      StaffBeacon staffBeaconInfo = StaffBeacon(
          uuid:data['result'][0]['uuid'],
          major:data['result'][0]['major'],
          miner:data['result'][0]['miner'],
          url:data['result'][0]['url'],
          user:data['result'][0]['user']
      );

      //返却
      return staffBeaconInfo;

    } catch(error) {
      print("APIエラー ===> $error");

      //ダミー返却
      StaffBeacon dummyBeaconInfo = StaffBeacon(
          uuid: "00000000-0000-0000-0000-000000000000",
          major:"0",
          miner:"41534",
          url:'https://www.google.com/?hl=ja',
          user:'藤本'
      );
      return dummyBeaconInfo;
    }
  }
}



