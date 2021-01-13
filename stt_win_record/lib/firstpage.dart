import 'dart:async';
import 'dart:io' as io;

import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sttwinrecorder/data/user.dart';
import 'package:sttwinrecorder/main.dart';

void main() {
  // SystemChrome.setEnabledSystemUIOverlays([]);
  return runApp(new MyAppForm());
}

class MyAppForm extends StatefulWidget {
  @override
  _MyAppFormState createState() => new _MyAppFormState();
}

class _MyAppFormState extends State<MyAppForm> {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        body: SafeArea(
          child: new Form(),
        ),
      ),
    );
  }
}

// Data class
// class Person {
//   final String name;
//   final String age;

//   Person(this.name, this.age);
// }

class Form extends StatefulWidget {
  // final Person person;
  // Form({Key key, @required this.person}) : super(key: key);
  @override
  _FormState createState() => _FormState();
}

class _FormState extends State<Form> {
  @override
  Widget build(BuildContext context) {
    // final person = Person("jaler", "26");
    return new Center(
      child: new Padding(
        padding: new EdgeInsets.all(8.0),
        child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              SizedBox(height: 0.0),
              // Text(person.name),
              // Text(person.age),
              RaisedButton(
                child: Text(
                  'SUBMIT',
                  style: TextStyle(fontSize: 24),
                ),
                onPressed: () {
                  print("A");
                  navigateToRecordPage(context);
                },
              ),
            ]),
      ),
    );
  }

  Future navigateToRecordPage(context) async {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => new MyApp(),
        ));
  }
}
