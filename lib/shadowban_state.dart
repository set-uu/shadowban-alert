import 'package:flutter/material.dart';

import 'status.dart';

class ShadowbanState {
  int id;
  final String userId;
  final Status status;

  // true:バンされていない。
  final bool search; // 検索バン (Level2)
  final bool suggestion; // 検索サジェスチョンバン（Level1）
  final bool ghost; // ゴーストバン (Level3)
  final bool replies; // リプライバン(Level4)
  final DateTime dateTime;

  ShadowbanState({
    required this.id,
    required this.userId,
    required this.status,
    required this.search,
    required this.suggestion,
    required this.ghost,
    required this.replies,
    required this.dateTime,
  });

  factory ShadowbanState.nothing() {
    return ShadowbanState(
      id: 0,
      userId: '',
      status: Status.nothing,
      search: false,
      suggestion: false,
      ghost: false,
      replies: false,
      dateTime: DateTime.now(),
    );
  }

  factory ShadowbanState.otherError(String userId) {
    var state = ShadowbanState(
      id: 0,
      userId: userId,
      status: Status.error,
      search: false,
      suggestion: false,
      ghost: false,
      replies: false,
      dateTime: DateTime.now(),
    );
    return state;
  }

  /// HTTPのレスポンスから状態を生成する
  factory ShadowbanState.fromHttpResponse(String userId, Map<dynamic, dynamic> json) {
    Status status = Status.ok;
    if (json['profile'].containsKey('protected') &&
        json['profile']['protected']) {
      status = Status.closed;
    }

    if (json['profile'].containsKey('suspended') &&
        json['profile']['suspended']) {
      status = Status.frozen;
    }

    if (!json['profile']['exists']) {
      status = Status.notExists;
    }

    if (status != Status.ok) {
      return ShadowbanState(
        id: 0,
        userId: userId,
        status: status,
        search: false,
        suggestion: false,
        ghost: false,
        replies: false,
        dateTime: DateTime.now(),
      );
    }

    return ShadowbanState(
      id: 0,
      userId: userId,
      status: Status.ok,
      search: json['tests']['search'],
      suggestion: json['tests']['typeahead'],
      ghost: !json['tests']['ghost']['ban'],
      replies: !json['tests']['more_replies']['ban'],
      dateTime: DateTime.now(),
    );
  }

  ///DBから取得した結果から状態を作成する
  factory ShadowbanState.fromDb(Map<String, dynamic> stat) {
    return ShadowbanState(
        id: stat['id'],
        userId: stat['userId'],
        status: Status.values.byName(stat['status'] as String),
        search: stat['search'] == 1,
        suggestion: stat['suggestion'] == 1,
        ghost: stat['ghost'] == 1,
        replies: stat['replies'] == 1,
        dateTime: DateTime.parse(stat['dateTime']).toLocal(),
    );
  }

  /// DBに登録するためのMapへ変換する
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId' : userId,
      'status' : status.name,
      'search' : search ? 1 : 0,
      'suggestion' : suggestion ? 1 : 0,
      'ghost' : ghost ? 1 : 0,
      'replies' : replies ? 1 : 0,
      'dateTime' : dateTime.toIso8601String(),
    };
  }

  Widget get  makeWidget {
    if (status != Status.ok) {
      return Text(
        status.wording,
        style: const TextStyle(
            color: Colors.redAccent,
            fontSize: 20.0,
            fontWeight: FontWeight.w500
        ),
      );
    }
    return Column(
      children: <Widget>[
        Text(
          status.wording,
          style: const TextStyle(
              color: Colors.blueAccent,
              fontSize: 20.0,
              fontWeight: FontWeight.w500
          ),
        ),
        Row(
          children: <Widget>[
            const Text("検索順位ダウン:"),
            Text(
              suggestion ? 'not ban' : 'ban',
              style: TextStyle(
                  color: suggestion ? Colors.green : Colors.redAccent,
              ),
            )
          ],
        ),
        Row(
          children: <Widget>[
            const Text("検索に出ない:"),
            Text(
              search ? 'not ban' : 'ban',
              style: TextStyle(
                color: search ? Colors.green : Colors.redAccent,
              ),
            )
          ],
        ),
        Row(
          children: <Widget>[
            const Text("ゴーストバン:"),
            Text(
              ghost ? 'not ban' : 'ban',
              style: TextStyle(
                color: ghost ? Colors.green : Colors.redAccent,
              ),
            )
          ],
        ),
        Row(
          children: <Widget>[
            const Text("リプライバン:"),
            Text(
              replies ? 'not ban' : 'ban',
              style: TextStyle(
                color: replies ? Colors.green : Colors.redAccent,
              ),
            )
          ],
        ),
      ],
    );
  }
}
