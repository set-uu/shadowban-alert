import 'package:flutter/material.dart';
import 'package:shadowban_alert/shadowban_state.dart';

import 'http_service.dart';
import 'db_provider.dart';

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
  Future<ShadowbanState>? state;

  _MyHomePageState() {
    state = DBProvider.getLatestState();
    state?.then((value) => {
      setState(() {
        twitterId = value.userId;
      })
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
