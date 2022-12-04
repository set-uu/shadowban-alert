import 'dart:convert';

import 'package:http/http.dart';
import 'package:logger/logger.dart';

import 'shadowban_state.dart';

class HttpService {
  Future<ShadowbanState> getPosts(String id) async {
    var _id = id.replaceFirst('@', '');
    var res =
        await get(Uri(scheme: 'https', host: 'sb.hisubway.online', path: _id));
    if (res.statusCode == 200) {
      var body = jsonDecode(res.body);
      Logger().d(body);

      var state = ShadowbanState.fromHttpResponse(_id, body);
      return state;
    } else {
      return ShadowbanState.otherError(_id);
    }
  }
}
