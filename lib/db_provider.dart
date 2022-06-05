import 'dart:async';

import 'package:path/path.dart';
import 'package:shadowban_alert/shadowban_state.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  static Database? _database;
  static Future<Database> get database async {
    return _database ??= await openDatabase(
      join(await getDatabasesPath(), 'shadowban_state.db'),
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE state('
                ' id          Integer,'
                ' userId      TEXT,'
                ' status      TEXT,'
                ' search      Integer,'
                ' suggestion  Integer,'
                ' ghost       Integer,'
                ' replies     Integer,'
                ' dateTime    TEXT,'
        );
      },
      version: 1,
    );
  }

  /// DBへshadowbanStateを登録する
  static createState(ShadowbanState state) {
    // TODO 作る
  }

  /// DBからshadowbanStateの最新状態を取得する
  static Future<ShadowbanState> getState(userId) async {
    final Database db = await database;
    final List<Map<String, dynamic>> states = await db.query(
      'state',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'id',
      limit: 1,
    );
    return ShadowbanState.fromDb(states[0]);
  }

  static updateState(ShadowbanState state) {
    // TODO 作る
  }

  static deleteState(ShadowbanState state) {
    // TODO 作る
  }
}