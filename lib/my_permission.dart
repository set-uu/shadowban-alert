import 'package:permission_handler/permission_handler.dart';

Future<bool> isGrantedForeGroundService(bool withConfirm) async {
  var status = await Permission.systemAlertWindow.status;
  if (status.isGranted) {
    return true;
  }

  if (status == PermissionStatus.denied) {
    // 一度もリクエストしてないので権限のリクエスト.
    if(withConfirm) {
      status = await Permission.systemAlertWindow.request();
    }
  }
  // 権限がない場合の処理.
  if (status.isRestricted ||
      status.isPermanentlyDenied) {
    // 端末の設定画面へ遷移.
    if(withConfirm){
      await openAppSettings();
    }
  }
  return false;
}