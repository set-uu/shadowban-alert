import 'package:flutter/material.dart';
import 'package:shadowban_alert/shadowban_state.dart';
import 'package:shadowban_alert/status.dart';

import 'http_service.dart';

void main() {
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
  ShadowbanState? state;

  void _onChangedId(String s) {
    setState(() {
      twitterId = s;
    });
  }

  void _startCheck() {
    setState(() {
      var httpService = HttpService();
      httpService.getPosts(twitterId)
          .then((value) => state = value);
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
                  fontWeight: FontWeight.w500
              ),
            ),
            TextField(
              enabled: true,
              style: const TextStyle(color: Colors.lightBlue),
              maxLines: 1,
              onChanged: _onChangedId,
              decoration: const InputDecoration(hintText: '@は不要です'),
            ),
            if (state != null) ...{
              state!.makeWidget
            },
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
