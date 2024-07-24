//ビーコンクラス作成

class StaffBeacon{

  String? uuid;
  String? major;
  String? miner;
  String? url;
  String? user;

  StaffBeacon({
    this.uuid,
    this.major,
    this.miner,
    this.url,
    this.user
  });
}

class LoginState{

  bool? isLogin;
  String? mailText;
  String? passText;

  LoginState({
    this.isLogin,
    this.mailText,
    this.passText,
  });
}