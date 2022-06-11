import 'dart:async';

import 'package:flutter/material.dart';
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
                ' id          Integer PRIMARY KEY AUTOINCREMENT,'
                ' userId      TEXT,'
                ' status      TEXT,'
                ' search      Integer,'
                ' suggestion  Integer,'
                ' ghost       Integer,'
                ' replies     Integer,'
                ' dateTime    TEXT'
            ')'
        );
      },
      version: 1,
    );
  }

  /// DBへshadowbanStateを登録する
  static createState(ShadowbanState state) async {
    final Database db = await database;
    await db.insert('state', state.toMap());
    getState(state.userId).then((value) => debugPrint(value.toMap().toString()));
  }

  /// 直近に取得したデータを取得する
  static Future<ShadowbanState> getLatestState() async {
    final Database db = await database;
    final List<Map<String, dynamic>> states = await db.query(
      'state',
      orderBy: 'dateTime desc',
      limit: 1,
    );
    if(states.isNotEmpty) {
      return ShadowbanState.fromDb(states[0]);
    } else {
      return ShadowbanState.nothing();
    }
  }

  /// DBからshadowbanStateの最新状態を取得する
  static Future<ShadowbanState> getState(userId) async {
    final Database db = await database;
    final List<Map<String, dynamic>> states = await db.query(
      'state',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'dateTime desc',
      limit: 1,
    );
    if(states.isNotEmpty) {
      return ShadowbanState.fromDb(states[0]);
    } else {
      return ShadowbanState.nothing();
    }
  }

  /// DBのshadowbanStateを更新する
  static updateState(ShadowbanState state) async {
    final Database db = await database;
    db.update(
      'state',
      state.toMap(),
      where: 'userId = ? AND id = ?',
      whereArgs: [state.userId, state.id],
      conflictAlgorithm: ConflictAlgorithm.abort 
    );
  }

  /// DBのshadowbanStateを削除する
  static deleteState(ShadowbanState state) async {
    final Database db = await database;
    db.delete(
      'state',
      where: 'userId = ? AND id = ?',
      whereArgs: [state.userId, state.id],
    );
  }
}