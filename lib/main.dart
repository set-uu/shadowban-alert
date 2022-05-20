import 'package:flutter/material.dart';

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
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  void _startCheck() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: const Center(
        child: TwitterIdForm()
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startCheck,
        tooltip: 'Start',
        child: const Icon(Icons.send),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class TwitterIdForm extends StatefulWidget {
  const TwitterIdForm({Key? key}) : super(key: key);

  @override
  _TwitterIdFormState createState() => _TwitterIdFormState();
}

class _TwitterIdFormState extends State<TwitterIdForm> {
  String twitterId = '';

  void _onChangedId(String s) {
    setState(() {
      twitterId = s;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(50.0),
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
              maxLines:1 ,
              onChanged: _onChangedId,
              decoration: const InputDecoration(
                hintText: '@は不要です'
              ),
            ),
          ],
        )
    );
  }
}