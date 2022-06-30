import 'package:shared_preferences/shared_preferences.dart';

const keyIsCheck = 'isCheck';
const keyIsChangedOnly = 'isChangedOnly';
const keyDuration = 'duration';

class MySettings {
  /// 定期チェックを行うか否かを取得する
  static Future<bool> get isCheck async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    return  prefs.getBool(keyIsCheck)??true;
  }

  /// 定期チェックを行うか否かを設定する
  static Future<void> setIsCheck(bool isCheck) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyIsCheck, isCheck);
  }

  /// 結果が変わったときだけ通知するか否かを取得する
  static Future<bool> get isChangedOnly async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    return prefs.getBool(keyIsChangedOnly)?? false;
  }

  /// 結果が変わったときだけ通知するか否かを設定する
  static Future<void> setIsChangedOnly(bool isChangedOnly) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyIsChangedOnly, isChangedOnly);
  }

  /// 定期チェックを行う際の期間を取得する(時間)
  static Future<int> get duration async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    return prefs.getInt(keyDuration)??12;
  }

  /// 定期チェックを行う際の期間を設定する(時間)
  static Future<void> setDuration(int duration) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyDuration, duration);
  }

  static Future<void> setDurationStr(String duration) async {
    int? parsed = int.tryParse(duration);
    if (parsed != null) await setDuration(parsed);
  }
}
