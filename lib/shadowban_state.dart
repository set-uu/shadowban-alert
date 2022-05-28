import 'status.dart';

class ShadowbanState {
  final String userId;
  final Status stateName;
  final String id;

  // true:バンされていない。
  final bool search; // 検索バン (Level2)
  final bool suggestion; // 検索サジェスチョンバン（Level1）
  final bool ghost; // ゴーストバン (Level3)
  final bool replies; // リプライバン(Level4)
  final DateTime dateTime;

  ShadowbanState({
    required this.userId,
    required this.stateName,
    required this.id,
    required this.search,
    required this.suggestion,
    required this.ghost,
    required this.replies,
    required this.dateTime,
  });

  factory ShadowbanState.otherError(String userId) {
    var state = ShadowbanState(
      userId: userId,
      stateName: Status.error,
      id: '',
      search: false,
      suggestion: false,
      ghost: false,
      replies: false,
      dateTime: DateTime.now(),
    );
    return state;
  }

  factory ShadowbanState.fromJson(String userId, Map<dynamic, dynamic> json) {
    if (json['profile'].containsKey('protected') &&
        json['profile']['protected']) {
      var state = ShadowbanState(
        userId: userId,
        stateName: Status.closed,
        id: '',
        search: false,
        suggestion: false,
        ghost: false,
        replies: false,
        dateTime: DateTime.now(),
      );
      return state;
    }

    if (json['profile'].containsKey('suspended') &&
        json['profile']['suspended']) {
      var state = ShadowbanState(
        userId: userId,
        stateName: Status.frozen,
        id: '',
        search: false,
        suggestion: false,
        ghost: false,
        replies: false,
        dateTime: DateTime.now(),
      );
      return state;
    }

    if (!json['profile']['exists']) {
      var state = ShadowbanState(
        userId: userId,
        stateName: Status.notExists,
        // stateName: 'アカウントが存在しません',
        id: '',
        search: false,
        suggestion: false,
        ghost: false,
        replies: false,
        dateTime: DateTime.now(),
      );
      return state;
    }

    var state = ShadowbanState(
      userId: userId,
      stateName: Status.ok,
      id: json['profile']['id'] as String,
      search: json['tests']['search'],
      suggestion: json['tests']['typeahead'],
      ghost: !json['tests']['ghost']['ban'],
      replies: !json['tests']['more_replies']['ban'],
      dateTime: DateTime.now(),
    );
    return state;
  }
}
