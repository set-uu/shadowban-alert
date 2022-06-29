import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shadowban_alert/ad_interstitial.dart';
import 'package:shadowban_alert/my_android_alarm_manager.dart';
import 'package:shadowban_alert/my_settings.dart';
import 'package:shadowban_alert/shadowban_state.dart';

import 'ad_banner.dart';
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

  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

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
  Future<bool> _isChangedOnly = MySettings.isChangedOnly;
  Future<int> _duration = MySettings.duration;
  MyAdInterstitial myAd = MyAdInterstitial();
  late BannerAd banner;

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
    banner = MyAdBanner.createBanner();
    myAd.createAd();
  }

  @override
  void dispose() {
    super.dispose();
    myAd.dispose();
    banner.dispose();
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
    myAd.showAd();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        children: <Widget>[
          Center(
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
                                  if (value) {
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
                            child: Text("チェック間隔(時間おき)"),
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
                                  _duration = MySettings.duration;
                                  MyAndroidAlarmManager.cancelAlarm();
                                  MyAndroidAlarmManager.setAlarm();
                                });
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
                FutureBuilder(
                  future: _isChangedOnly,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Row(
                        children: <Widget>[
                          const Expanded(
                            flex: 8,
                            child: Text("変更があった時だけ通知する"),
                          ),
                          Expanded(
                            flex: 2,
                            child: Switch(
                              value: snapshot.data as bool,
                              onChanged: (value) {
                                MySettings.setIsChangedOnly(value);
                                setState(() {
                                  _isChangedOnly = MySettings.isChangedOnly;
                                });
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
          Positioned(
            bottom: 0,
            width: MediaQuery.of(context).size.width,
            height: banner.size.height.toDouble(),
            child: Center(
              child: AdWidget(
                ad: banner,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startCheck,
        tooltip: 'Start',
        child: const Icon(Icons.send),
      ),
    );
  }
}
