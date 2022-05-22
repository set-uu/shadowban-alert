class ShadowbanState {
  final String userId;
  final String stateName;
  final String id;
  final bool search;
  final bool suggestion;
  final bool ghost;
  final bool replies;
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

  factory ShadowbanState.fromJson(String userId, Map<dynamic, dynamic> json) {
    if (json['profile'].containsKey('protected') &&
        json['profile']['protected']) {
      var state = ShadowbanState(
        userId: userId,
        stateName: '鍵アカウントのため確認できません',
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
        stateName: '凍結されたアカウントのため確認できません',
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
        stateName: 'アカウントが存在しません',
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
      stateName: 'ステータスは以下の通りです',
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
