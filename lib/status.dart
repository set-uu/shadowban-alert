enum Status {
  from, //拡張用キー
  error, // エラーだった
  closed, // 鍵垢
  frozen, // 凍結
  notExists, // 存在しない
  ok,
  nothing, // 未チェック
}

extension StatusExt on Status {
  /// Enumから文字列へ変換する
  String get name => toString().split(".").last;

  /// 文字列からEnumへ変換する
  operator [](String key) => Status.values.firstWhere((e) => e.name == key);

  /// 結果文言を返却する
  String get wording {
    switch (this) {
      case Status.error:
        return '状態を取得できませんでした';
      case Status.closed:
        return '鍵アカウントのため確認できません';
      case Status.frozen:
        return '凍結されたアカウントのため確認できません';
      case Status.notExists:
        return 'アカウントが存在しません';
      case Status.ok:
        return 'ステータスは以下の通りです';
      case Status.from:
        return 'ステータスは以下の通りです';
      case Status.nothing:
        return '';
    }
  }
}
