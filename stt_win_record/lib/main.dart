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
import 'package:stt_win_record/firstpage.dart';

void main() {
  // SystemChrome.setEnabledSystemUIOverlays([]);
  return runApp(new MyApp());
}

class User {
  const User(this.name);
  final String name;
}

class IndexTranscript {
  IndexTranscript({this.number, this.dirName, this.fileName});
  int number; // format number 001, 0001, 01, ...
  String dirName; // custom directory name
  // String fileName; // custom file name (dirName + increment index)
  List<String> fileName;
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        body: SafeArea(
          child: new RecorderExample(),
        ),
      ),
    );
  }
}

class RecorderExample extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new RecorderExampleState();
}

class RecorderExampleState extends State<RecorderExample> {
  FlutterAudioRecorder _recorder;
  Recording _current;
  RecordingStatus _currentStatus = RecordingStatus.Unset;

  User jenisKelaminUser;
  List<User> users = <User>[User('Perempuan'), User('Laki-laki')];

  // IndexTranscript indextranscript;
  // var directoryName = new IndexTranscript(0, 'dirName');
  final indextranscript = IndexTranscript(
      // number: new NumberFormat("000"),
      number: 1,
      dirName: 'dirName',
      fileName: ['fileName1', 'index', 'fileName2']); // initiation
  // >> Form
  TextEditingController usernameField = TextEditingController();
  TextEditingController dialekField = TextEditingController();
  TextEditingController jenisKelaminField = TextEditingController();
  // String _jenisKelamin = "Perempuan";
  String _transcript = "audiobuku";

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new Padding(
        padding: new EdgeInsets.all(8.0),
        child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              SizedBox(height: 0.0),
              // Text Box Username
              SizedBox(height: 20.0),
              TextField(
                controller: usernameField,
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  labelText: 'username',
                  icon: Icon(Icons.supervisor_account),
                  hintText: '6 digit username. contoh: jal098',
                  helperText: 'contoh: jal098',
                  border: const OutlineInputBorder(),
                ),
              ),
              // >> Dropdown Jenis Kelamin
              SizedBox(height: 20.0),
              DropdownButtonFormField<User>(
                  value: jenisKelaminUser,
                  items: users
                      .map((User user) => DropdownMenuItem(
                            value: user,
                            child: new Text(
                              user.name,
                            ),
                          ))
                      .toList(),
                  // hint: Text('Jenis Kelamin'),
                  onChanged: (User newValue) {
                    setState(() {
                      jenisKelaminUser = newValue;
                    });
                  },
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: 'jenis kelamin',
                    icon: Icon(Icons.wc),
                    border: const OutlineInputBorder(),
                  )),
              // >> Dropdown Jenis Kelamin
              // Text Box Dialek
              SizedBox(height: 20.0),
              TextField(
                controller: dialekField,
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  labelText: 'dialek',
                  icon: Icon(Icons.record_voice_over),
                  hintText: '',
                  helperText: '',
                  border: const OutlineInputBorder(),
                ),
              ),
              // >> Dropdown transcript
              SizedBox(height: 20.0),
              DropdownButtonFormField<String>(
                  value: _transcript,
                  items: [
                    "audiobuku",
                    "ayatalkitab1",
                    "dongeng",
                    "dongengwidya",
                    "faqislami1",
                    "kontenfaq",
                    "kontenislami1",
                    "kumpulanistilah01",
                    "kumpulanistilah02",
                    "kumpulanistilah03",
                    "kumpulanistilah04",
                    "kumpulanistilah05",
                    "kumpulanistilah06",
                    "kumpulanistilah07",
                    "kumpulanistilah08",
                    "kumpulanistilah09",
                    "kumpulanistilah10",
                    "matematika1",
                    "mvpsmalltalk",
                    "olahragawidya1",
                    "quran2",
                    "radio",
                    "radio2",
                    "reading",
                    "resep",
                    "surahalquran",
                    "transfitur",
                    "warungwidya",
                    "wilayah1",
                    "wilayah2"
                  ]
                      .map((label) => DropdownMenuItem(
                            child: Text(label.toString()),
                            value: label,
                          ))
                      .toList(),
                  hint: Text('Text Transcript'),
                  onChanged: (String value) {
                    setState(() {
                      _transcript = value;
                    });
                  },
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: 'text transcript',
                    icon: Icon(Icons.sticky_note_2),
                    border: const OutlineInputBorder(),
                  )),
              // >> Dropdown Jenis Kelamin
              SizedBox(height: 10.0),
              RaisedButton(
                child: Text(
                  'SUBMIT',
                  style: TextStyle(fontSize: 24),
                ),
                onPressed: () {
                  print("a");
                  // _getDirName;

                  var now = new DateTime.now();
                  var formatter = new DateFormat('yyyyMMdd');
                  String _formattedDate = formatter.format(now);
                  String _jenisKelamin;
                  // // ganti kode jenis kelamin
                  // String jenisKelamin =
                  jenisKelaminUser.name == "Perempuan"
                      ? _jenisKelamin = "f"
                      : _jenisKelamin = "m";
                  String _username = usernameField.text;
                  String _dialek = dialekField.text;

                  // String _index = '${}';
                  // String number = format(count, '0' + digit_space + 'd');
                  // final formatterIndex = new NumberFormat("000");
                  // 1 -> 001
                  // final formatterIndex = indextranscript.number;
                  // String _index = formatterIndex.format(1);
                  int _index = indextranscript.number;
                  // String _index = formatterIndex.format(1);
                  print(_index);
                  String _dirname =
                      "$_username\_$_jenisKelamin\_$_formattedDate\_$_transcript\_$_dialek\_hp";
                  String _filename1 =
                      "$_username\_$_jenisKelamin\_$_formattedDate\_";
                  String _filename2 = "\_$_transcript\_$_dialek\_hp";
                  String _filename = "$_filename1$_index$_filename2";

                  // example: rut122_f_20201216_001_audiobuku_yogyakarta_hp
                  print(_dirname);
                  print(_filename);
                  setState(() {
                    indextranscript.dirName = _dirname;
                    indextranscript.fileName = [
                      _filename1,
                      _index.toString(),
                      _filename2
                    ];
                  });
                  // directoryName.dirName = _dirname;
                  print('b');
                  print(indextranscript.dirName);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            RecorderPage(indextranscript: indextranscript)),
                    // RecorderPage(
                    //     dir_name: new IndexTranscript(0, _dirname))),
                  );
                },
              ),
            ]),
      ),
    );
  }
}

/*
 * Recording Page
 */

// class RecordingPage extends StatefulWidget {
//   @override
//   _RecordingPageState createState() => new _RecordingPageState();
// }

// class _RecordingPageState extends State<RecordingPage> {
//   @override
//   Widget build(BuildContext context) {
//     return new MaterialApp(
//       home: new Scaffold(
//         body: SafeArea(
//           child: new RecorderPage(),
//         ),
//       ),
//     );
//   }
// }

class RecorderPage extends StatefulWidget {
  final LocalFileSystem localFileSystem;
  // final IndexTranscript directoryName;
  final IndexTranscript indextranscript;
  final initNumber;

  RecorderPage({localFileSystem, this.indextranscript, this.initNumber})
      : this.localFileSystem = localFileSystem ?? LocalFileSystem();

  @override
  // State<StatefulWidget> createState() => new RecorderPageState();
  RecorderPageState createState() => new RecorderPageState(indextranscript);
}

class RecorderPageState extends State<RecorderPage> {
  // final IndexTranscript directoryName;
  // IndexTranscript dir_name;
  IndexTranscript indextranscript;
  RecorderPageState(this.indextranscript);
  FlutterAudioRecorder _recorder;
  Recording _current;
  RecordingStatus _currentStatus = RecordingStatus.Unset;

  int _currentIndexTranscript;

  // RecorderPageState({Key key, @required this.dirName});

  // RecorderPageState({this.directoryName});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        body: SafeArea(
          child: new Padding(
            padding: new EdgeInsets.all(8.0),
            child: new Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  // new Text("Status : $_currentStatus"),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: new Text('${indextranscript.fileName.join()}'),
                      ),
                      new Text(indextranscript.number.toString()),
                    ],
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: new FlatButton(
                          onPressed: () {
                            switch (_currentStatus) {
                              case RecordingStatus.Initialized:
                                {
                                  _start();
                                  break;
                                }
                              case RecordingStatus.Recording:
                                {
                                  _pause();
                                  break;
                                }
                              case RecordingStatus.Paused:
                                {
                                  _resume();
                                  break;
                                }
                              case RecordingStatus.Stopped:
                                {
                                  _init();
                                  break;
                                }
                              default:
                                break;
                            }
                          },
                          child: _buildText(_currentStatus),
                          color: Colors.lightBlue,
                        ),
                      ),
                      new FlatButton(
                        onPressed: _currentStatus != RecordingStatus.Unset
                            ? _stop
                            : null,
                        child: new Text("Stop",
                            style: TextStyle(color: Colors.white)),
                        color: Colors.blueAccent.withOpacity(0.5),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      new FlatButton(
                        onPressed: onPlayAudio,
                        child: new Text("Play",
                            style: TextStyle(color: Colors.white)),
                        color: Colors.blueAccent.withOpacity(0.5),
                      ),
                    ],
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(0),
                        child: new FlatButton(
                          onPressed: onPreviousTranscript, //
                          child: new Icon(Icons.navigate_before),
                          color: Colors.lightBlue,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: new FlatButton(
                          onPressed: onRecordTranscript,
                          child: new Icon(Icons.fiber_manual_record_outlined),
                          color: Colors.redAccent,
                        ),
                      ),
                      new FlatButton(
                        onPressed: onNextTranscript, //
                        child: new Icon(Icons.navigate_next),
                        color: Colors.lightBlue,
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  new Text("File path of the record: ${_current?.path}"),
                ]),
          ),
        ),
      ),
    );
    // return new Center(
    // );
  }

  _init() async {
    try {
      if (await FlutterAudioRecorder.hasPermissions) {
        // print(directoryName.)
        // String customDir = '/20201218/';
        // indextranscript.dirName = "test";
        // String customDir = '/${indextranscript.dirName}/';
        // print(directoryName.dirName);
        // print()
        // print()
        // String customDir = '/test/';
        String customDir = '/${indextranscript.dirName}/';
        String customFileName = '${indextranscript.fileName.join()}';
        // example: rut122_f_20201216_001_audiobuku_yogyakarta_hp
        // String customFileName =

        io.Directory appDocDirectory;
        if (io.Platform.isIOS) {
          appDocDirectory = await getApplicationDocumentsDirectory();
        } else {
          appDocDirectory = await getExternalStorageDirectory();
        }

        //create Variable
        String directory = appDocDirectory.path;

        //create directory and its subdirectory
        if (await io.Directory(directory + customDir).exists() != true) {
          print("Directory not exist");
          new io.Directory(directory + customDir).createSync(recursive: true);
        } else {
          print("Directoryexist");
        }

        customDir = directory + customDir + customFileName;
        // print('$customDir.wav');
        String fileName = '$customDir.wav';
        // print()
        // String customDir_wav;
        // if (customDir != null && customDir.length >= 5) {
        //   customDir_wav = customDir.substring(0, customDir.length - 5);
        // }
        // print(customDir);
        print('deleting$fileName');
        deleteFile(fileName);

        // File file = widget.localFileSystem.file(customDir);
        // File file = io.File(
        //     '/storage/emulated/0/Android/data/com.example.stt_win_record/files/jaler_f_20210111_audiobuku_jogja_hp/jaler_f_20210111_1_audiobuku_jogja_hp.wav');
        // print(file);
        // await file.delete();
        // if (file.existsSync()) {
        //   print("file deleteing");
        //   // file.deleteSync(recursive: true);

        //   print("file deleted");
        // }
        // print("customDir checked");
        // .wav <---> AudioFormat.WAV
        // .mp4 .m4a .aac <---> AudioFormat.AAC`
        // AudioFormat is optional, if given value, will overwrite path extension when there is conflicts.
        _recorder = FlutterAudioRecorder(customDir,
            audioFormat: AudioFormat.WAV, sampleRate: 16000);
        // print("_recorder checked");

        await _recorder.initialized;
        // print("_recorder initialized");
        // after initialization
        var current = await _recorder.current(channel: 0);
        print(current);
        // should be "Initialized", if all working fine
        setState(() {
          _current = current;
          _currentStatus = current.status;
          print(_currentStatus);
        });
      }
      // else {
      //   Scaffold.of(context).showSnackBar(
      //       new SnackBar(content: new Text("You must accept permissions")));
      // }
    } catch (e) {
      print("cek");
      print(e);
      print("ricek");
    }
  }

  _start() async {
    try {
      await _recorder.start();
      var recording = await _recorder.current(channel: 0);
      setState(() {
        _current = recording;
      });

      const tick = const Duration(milliseconds: 50);
      new Timer.periodic(tick, (Timer t) async {
        if (_currentStatus == RecordingStatus.Stopped) {
          t.cancel();
        }

        var current = await _recorder.current(channel: 0);
        // print(current.status);
        setState(() {
          _current = current;
          _currentStatus = _current.status;
        });
      });
    } catch (e) {
      print(e);
    }
  }

  _resume() async {
    await _recorder.resume();
    setState(() {});
  }

  _pause() async {
    await _recorder.pause();
    setState(() {});
  }

  _stop() async {
    var result = await _recorder.stop();
    print("Stop recording: ${result.path}");
    print("Stop recording: ${result.duration}");
    File file = widget.localFileSystem.file(result.path);
    print("File length: ${await file.length()}");
    setState(() {
      _current = result;
      _currentStatus = _current.status;
    });
  }

  Widget _buildText(RecordingStatus status) {
    var text = "";
    switch (_currentStatus) {
      case RecordingStatus.Initialized:
        {
          text = 'Start';
          break;
        }
      case RecordingStatus.Recording:
        {
          text = 'Pause';
          break;
        }
      case RecordingStatus.Paused:
        {
          text = 'Resume';
          break;
        }
      case RecordingStatus.Stopped:
        {
          text = 'Init';
          break;
        }
      default:
        break;
    }
    return Text(text, style: TextStyle(color: Colors.white));
  }

  void onPlayAudio() async {
    AudioPlayer audioPlayer = AudioPlayer();
    await audioPlayer.play(_current.path, isLocal: true);
  }

  void onPreviousTranscript() async {
    print("before");
    // 1. if index > 1 then index--
    if (indextranscript.number > 1) {
      setState(() {
        indextranscript.number--;
        // 2. filename.update
        indextranscript.fileName[1] = indextranscript.number.toString();
      });
      // 3. if file exist -> delete
      // File file =
      // 3. _init
      // _init();
    }
  }

  void onRecordTranscript() async {
    print("record");
  }

  void onNextTranscript() async {
    print("next");
    // 1. if index < max(index) then index++
    if (indextranscript.number < 255) {
      setState(() {
        // 255 is dummy maximal size
        indextranscript.number++;
        // 2. filename.update
        indextranscript.fileName[1] = indextranscript.number.toString();
      });
      // 3. _init
      // _init();
    }
  }

  // void overwriteFile() async {
  //   var result = await _recorder.stop();
  //   File file = widget.localFileSystem.file(res)
  // }
  // Delete File
  // Future<String> get _localPath async {
  //   io.Directory directory;
  //   if (io.Platform.isIOS) {
  //     final directory = await getApplicationDocumentsDirectory();
  //   } else {
  //     final directory = await getExternalStorageDirectory();
  //   }
  //   return directory.path;
  // }

  // Future<File> get _localFile async {
  //   // final path = await _localPath;
  //   // print('path ${path}');
  //   print("localfile");
  //   return io.File(
  //       '/storage/emulated/0/Android/data/com.example.stt_win_record/files/jaler_f_20210111_audiobuku_jogja_hp/jaler_f_20210111_1_audiobuku_jogja_hp.wav');
  // }

  // Future<int> deleteFile() async {
  //   print("want deletefile");
  //   try {
  //     print("deletefile");
  //     final file = await _localFile;

  //     await file.delete();
  //   } catch (e) {
  //     return 0;
  //   }
  // }

  Future<void> deleteFile(String fileName) async {
    try {
      // var file = io.File(
      // '/storage/emulated/0/Android/data/com.example.stt_win_record/files/jaler_f_20210111_audiobuku_jogja_hp/jaler_f_20210111_1_audiobuku_jogja_hp.wav');
      var file = io.File(fileName);
      if (await file.exists()) {
        // file exists, it is safe to call delete on it
        await file.delete();
      }
    } catch (e) {
      // error in getting access to the file
    }
  }

  // Future<int>
}
