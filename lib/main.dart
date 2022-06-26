import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadowban_alert/my_android_alarm_manager.dart';
import 'package:shadowban_alert/my_settings.dart';
import 'package:shadowban_alert/shadowban_state.dart';

import 'db_provider.dart';
import 'http_service.dart';

/// A port used to communicate from a background isolate to the UI isolate.
final ReceivePort port = ReceivePort();

void main() {
  // Register the UI isolate's SendPort to allow for communication from the
  // background isolate.
  IsolateNameServer.registerPortWithName(
    port.sendPort,
    isolateName,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Twitter shadowban alerter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Twitter shadowban alerter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String twitterId = '';
  Future<ShadowbanState>? state;
  Future<bool> _isCheck = MySettings.isCheck;
  Future<int> _duration = MySettings.duration;

  @override
  void initState() {
    super.initState();
    MyAndroidAlarmManager.init();
    // Register for events from the background isolate. These messages will
    // always coincide with an alarm firing.
    port.listen((_) async => await _onChecked());

    state = DBProvider.getLatestState();
    state?.then((value) => {
          setState(() {
            twitterId = value.userId;
          })
        });
  }

  /// 画面表示中にバックグラウンドでチェックが完了したとき
  Future<void> _onChecked() async {
    debugPrint('_onChecked');
    setState(() {
      state = DBProvider.getLatestState();
      state?.then((value) => twitterId = value.userId);
    });
  }

  void _onChangedId(String s) {
    twitterId = s;
  }

  void _startCheck() {
    setState(() {
      var httpService = HttpService();
      state = httpService.getPosts(twitterId);
      state?.then((value) => DBProvider.createState(value));
      MyAndroidAlarmManager.setAlarm();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            const Text(
              "Twitter ID を入力してください",
              style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w500),
            ),
            TextField(
              controller: TextEditingController(text: twitterId),
              enabled: true,
              style: const TextStyle(color: Colors.lightBlue),
              maxLines: 1,
              onChanged: _onChangedId,
              decoration: const InputDecoration(hintText: '@は不要です'),
            ),
            FutureBuilder(
                future: state,
                builder: (context, snapshot) {
                  List<Widget> child = [Column()];

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasData) {
                    child = [(snapshot.data as ShadowbanState).makeWidget];
                  } else if (snapshot.hasError) {
                    child = [const Text('エラー')];
                  }

                  return Column(
                    children: child,
                  );
                }),
            FutureBuilder(
              future: _isCheck,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Row(
                    children: <Widget>[
                      const Expanded(
                        flex: 8,
                        child: Text("定期チェックを行う"),
                      ),
                      Expanded(
                        flex: 2,
                        child: Switch(
                          value: snapshot.data as bool,
                          onChanged: (value) {
                            MySettings.setIsCheck(value).then((_) {
                              if(value) {
                                MyAndroidAlarmManager.setAlarm();
                              } else {
                                MyAndroidAlarmManager.cancelAlarm();
                              }
                            });
                            setState(() {
                              _isCheck = MySettings.isCheck;
                            });
                          },
                        ),
                      ),
                    ],
                  );
                } else {
                  return const Text('設定取得中');
                }
              },
            ),
            FutureBuilder(
              future: _duration,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Row(
                    children: <Widget>[
                      const Expanded(
                        flex: 8,
                        child: Text("チェック間隔(時間)"),
                      ),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: TextEditingController(
                              text: snapshot.data.toString()),
                          enabled: true,
                          maxLines: 1,
                          textAlign: TextAlign.right,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onChanged: (value) {
                            MySettings.setDurationStr(value).then((_) {
                              MyAndroidAlarmManager.cancelAlarm();
                              MyAndroidAlarmManager.setAlarm();
                            });
                            _duration = MySettings.duration;
                            },
                        ),
                      ),
                    ],
                  );
                } else {
                  return const Text('');
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startCheck,
        tooltip: 'Start',
        child: const Icon(Icons.send),
      ),
    );
  }
}
