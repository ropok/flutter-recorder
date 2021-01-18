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

import 'package:csv/csv.dart';
import 'dart:async' show Future;
// import 'package:flutter/services.dart' show rootBundle;

void main() {
  // SystemChrome.setEnabledSystemUIOverlays([]);
  return runApp(new MyApp());
}

class User {
  const User(this.name);
  final String name;
}

class IndexTranscript {
  IndexTranscript(
      {this.number, this.dirName, this.fileName, this.transcriptTitle});
  int number; // format number 001, 0001, 01, ...
  String dirName; // custom directory name
  // String fileName; // custom file name (dirName + increment index)
  List<String> fileName;
  String transcriptTitle;
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
        appBar: AppBar(
            title: Text("STT WIN Recorder"),
            backgroundColor: Color.fromARGB(255, 39, 169, 225)),
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

  // // >> CSV Read
  // List<List<dynamic>> data = [];

  Future<List<String>> loadAsset() async {
    var myData = await rootBundle.loadString("assets/quran2.csv");
    List<List<dynamic>> csvTable = CsvToListConverter().convert(myData);
    // print(csvTable[0]);
    // List<List<dynamic>> csvTable_data = CsvToListConverter(
    //   fieldDelimiter: ',',
    // ).convert(csvTable);
    //
    List<String> data = [];
    csvTable[0].forEach((value) {
      data.add(value.toString());
    });
    return data;
  }

  // loadAsset() async {
  //   final myData = await rootBundle.loadString("assets/dongengwidya.csv");
  //   List<List<dynamic>> csvTable = CsvToListConverter().convert(myData);
  //   print(csvTable);
  //   data = csvTable;
  //   setState(() {});
  // }

  // IndexTranscript indextranscript;
  // var directoryName = new IndexTranscript(0, 'dirName');
  final indextranscript = IndexTranscript(
      // number: new NumberFormat("000"),
      number: 1,
      dirName: 'dirName',
      fileName: ['fileName1', 'index', 'fileName2'],
      transcriptTitle: 'audiobuku.csv'); // initiation
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
        padding: new EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FutureBuilder(
                    future: loadAsset(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      // this condition is important
                      if (snapshot.data == null) {
                        return Center(
                          child: Text('loading data'),
                        );
                      } else {
                        // ListView.builder(itemBuilder: itemBuilder)
                        print(snapshot.data.length);
                        return Center(child: Text(snapshot.data[98]));
                        // return ListView.builder(
                        //     itemCount: snapshot.data.length,
                        //     itemBuilder: (BuildContext context, int index) {
                        //       return Center(child: Text(snapshot.data[index]));
                        //     });
                      }
                    }),
                // Table(
                //   columnWidths: {
                //     0: FixedColumnWidth(100.0),
                //     1: FixedColumnWidth(200.0),
                //   },
                //   border: TableBorder.all(width: 1.0),
                //   children: data.map((item) {
                //     return TableRow(
                //         children: item.map((row) {
                //       return Container(
                //         color: row.toString().contains("NA")
                //             ? Colors.redAccent
                //             : Colors.greenAccent,
                //         child: Padding(
                //           padding: const EdgeInsets.all(8.0),
                //           child: Text(
                //             row.toString(),
                //             style: TextStyle(fontSize: 20.0),
                //           ),
                //         ),
                //       );
                //     }).toList());
                //   }).toList(),
                // ),

                // RaisedButton(onPressed: () async {
                //   await loadAsset();
                // }),
                SizedBox(height: 0.0),
                // Text Box Username
                SizedBox(height: 20.0),
                TextField(
                  controller: usernameField,
                  style: TextStyle(
                    fontSize: 18,
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
                      fontSize: 18,
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
                    fontSize: 18,
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
                SizedBox(height: 10.0),
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
                      fontSize: 18,
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
                    style: TextStyle(fontSize: 18),
                  ),
                  onPressed: () async {
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
                    setState(() {
                      indextranscript.number = 1;
                    });
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
                      indextranscript.transcriptTitle = "$_transcript.csv";
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
  bool recordPressed = false;
  double transcript_length;

  // RecorderPageState({Key key, @required this.dirName});

  // RecorderPageState({this.directoryName});
  Future<List<String>> loadAsset() async {
    var myData = await rootBundle
        .loadString("assets/${indextranscript.transcriptTitle}");
    List<List<dynamic>> csvTable = CsvToListConverter().convert(myData);
    List<String> data = [];
    csvTable[0].forEach((value) {
      data.add(value.toString());
    });
    // print(data.length.toInt());
    transcript_length = (data.length - 3) / 2;
    // print(transcript_length.toInt());
    return data;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // loadAsset();
    // _init();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        body: SafeArea(
          child: new Padding(
            padding: new EdgeInsets.all(1.0),
            child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // new Text("Status : $_currentStatus"),
                  FutureBuilder(
                      future: loadAsset(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        // this condition is important
                        if (snapshot.data == null) {
                          return Center(
                            child: Text('loading data'),
                          );
                        } else {
                          return Center(
                              // karena newline tidak terbaca sebagai split
                              child: Text(snapshot
                                  .data[(indextranscript.number * 2) + 1]));
                        }
                      }),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: new Text('${indextranscript.fileName.join()}'),
                      ),
                      // new Text(indextranscript.number.toString()),
                    ],
                  ),
                  // new Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: <Widget>[
                  //     Padding(
                  //       padding: const EdgeInsets.all(8.0),
                  //       child: new FlatButton(
                  //         onPressed: () {
                  //           switch (_currentStatus) {
                  //             case RecordingStatus.Initialized:
                  //               {
                  //                 _start();
                  //                 break;
                  //               }
                  //             case RecordingStatus.Recording:
                  //               {
                  //                 _pause();
                  //                 break;
                  //               }
                  //             case RecordingStatus.Paused:
                  //               {
                  //                 _resume();
                  //                 break;
                  //               }
                  //             case RecordingStatus.Stopped:
                  //               {
                  //                 _init();
                  //                 break;
                  //               }
                  //             default:
                  //               break;
                  //           }
                  //         },
                  //         child: _buildText(_currentStatus),
                  //         color: Colors.lightBlue,
                  //       ),
                  //     ),
                  //     new FlatButton(
                  //       onPressed: _currentStatus != RecordingStatus.Unset
                  //           ? _stop
                  //           : null,
                  //       child: new Text("Stop",
                  //           style: TextStyle(color: Colors.white)),
                  //       color: Colors.blueAccent.withOpacity(0.5),
                  //     ),
                  //     SizedBox(
                  //       width: 8,
                  //     ),
                  //     new FlatButton(
                  //       onPressed: onCheckPlayAudio,
                  //       child: new Text("Play",
                  //           style: TextStyle(color: Colors.white)),
                  //       color: Colors.blueAccent.withOpacity(0.5),
                  //     ),
                  //   ],
                  // ),
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
                        // RECORD button
                        padding: const EdgeInsets.all(8.0),
                        child: new FlatButton(
                          onPressed: () {
                            switch (_currentStatus) {
                              case RecordingStatus.Unset:
                                {
                                  onRecordTranscript();
                                  recordPressed = true;
                                  break;
                                }
                              case RecordingStatus.Recording:
                                {
                                  recordPressed = false;
                                  _stop();
                                  break;
                                }
                              case RecordingStatus.Stopped:
                                {
                                  onRecordTranscript();
                                  recordPressed = true;
                                  break;
                                }
                              default:
                                break;
                            }
                          },
                          // child: new Icon(Icons.fiber_manual_record_outlined),
                          // color: Colors.redAccent,
                          child: recordPressed
                              ? new Icon(
                                  Icons.stop_outlined,
                                  size: 50.0,
                                )
                              : new Icon(
                                  Icons.stop_circle,
                                  color: Colors.redAccent,
                                  size: 50.0,
                                ),
                          // color:
                          //     recordPressed ? Colors.white38 : Colors.white38,
                        ),
                      ),
                      new FlatButton(
                        onPressed: onNextTranscript, //
                        child: new Icon(Icons.navigate_next),
                        color: Colors.lightBlue,
                      ),
                    ],
                  ),
                  new FlatButton(
                    onPressed: onCheckPlayAudio, //
                    child: new Text("Play",
                        style: TextStyle(color: Colors.black54)),
                    color: Colors.lightGreen[100],
                  ),
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
        // print()
        // String customDir_wav;
        // if (customDir != null && customDir.length >= 5) {
        //   customDir_wav = customDir.substring(0, customDir.length - 5);
        // }
        // print(customDir);
        String fileName = '$customDir.wav';
        print('deleting $fileName');
        await deleteFile(fileName);

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
      _stop();
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
    await _init();
    await _start();
  }

  void onNextTranscript() async {
    print("next");
    // 1. if index < max(index) then index++
    if (indextranscript.number < transcript_length.toInt()) {
      _stop();
      setState(() {
        indextranscript.number++;
        // 2. filename.update
        indextranscript.fileName[1] = indextranscript.number.toString();
      });
      // 3. _init
      // _init();
    }
  }

  void onCheckPlayAudio() async {
    AudioPlayer audioPlayer = AudioPlayer();
    String customDir = '/${indextranscript.dirName}/';
    String customFileName = '${indextranscript.fileName.join()}';
    io.Directory appDocDirectory;
    if (io.Platform.isIOS) {
      appDocDirectory = await getApplicationDocumentsDirectory();
    } else {
      appDocDirectory = await getExternalStorageDirectory();
    }
    //create Variable
    String directory = appDocDirectory.path;

    customDir = directory + customDir + customFileName;

    try {
      // var file = io.File(
      // '/storage/emulated/0/Android/data/com.example.stt_win_record/files/jaler_f_20210111_audiobuku_jogja_hp/jaler_f_20210111_1_audiobuku_jogja_hp.wav');
      var file = io.File('$customDir.wav');
      String fileName = '$customDir.wav';
      if (await file.exists()) {
        // file exists, it is safe to call play on it
        await audioPlayer.play(fileName, isLocal: true);
      }
    } catch (e) {
      // error in getting access to the file
    }
  }

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
