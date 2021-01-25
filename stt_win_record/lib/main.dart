import 'dart:async';
import 'dart:io' as io;

import 'package:flutter/cupertino.dart';
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
import 'package:flutter_archive/flutter_archive.dart';

void main() {
  // SystemChrome.setEnabledSystemUIOverlays([]);
  return runApp(new MyApp());
}

class User {
  const User(this.name);
  final String name;
}

class zipTranscript {
  zipTranscript({this.storeDir, this.zipDir, this.zipName, this.zipDateTime});
  String storeDir;
  String zipDir;
  String zipName;
  String zipDateTime;
}

class IndexTranscript {
  IndexTranscript(
      {this.number,
      this.dirName,
      this.fileName,
      this.transcriptTitle,
      this.userName});
  int number; // format number 001, 0001, 01, ...
  String dirName; // custom directory name
  // String fileName; // custom file name (dirName + increment index)
  List<String> fileName;
  String transcriptTitle;
  String userName;
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

  // Future<List<String>> loadAsset() async {
  //   var myData = await rootBundle.loadString("assets/quran2.csv");
  //   List<List<dynamic>> csvTable = CsvToListConverter().convert(myData);
  //   // print(csvTable[0]);
  //   // List<List<dynamic>> csvTable_data = CsvToListConverter(
  //   //   fieldDelimiter: ',',
  //   // ).convert(csvTable);
  //   //
  //   List<String> data = [];
  //   csvTable[0].forEach((value) {
  //     data.add(value.toString());
  //   });
  //   return data;
  // }

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
      transcriptTitle: 'audiobuku.csv',
      userName: 'user000'); // initiation

  // >> Form
  TextEditingController usernameField = TextEditingController();
  TextEditingController dialekField = TextEditingController();
  TextEditingController jenisKelaminField = TextEditingController();
  // String _jenisKelamin = "Perempuan";
  String _transcript = "audiobuku";
  String directory;
  List file;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _listFiles();
    // print(file.length);
  }

  // * listfiles
  void _listFiles() async {
    directory = (await getApplicationDocumentsDirectory()).path;
    print(directory);
    setState(() {
      file = io.Directory('$directory').listSync();
    });
    print(file);
  }

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new Padding(
        padding: new EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
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
                    // * ganti kode jenis kelamin
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
                      indextranscript.transcriptTitle = "$_transcript";
                      indextranscript.userName = "$_username";
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
  final IndexTranscript indextranscript;
  final initNumber;

  RecorderPage({localFileSystem, this.indextranscript, this.initNumber})
      : this.localFileSystem = localFileSystem ?? LocalFileSystem();

  @override
  RecorderPageState createState() => new RecorderPageState(indextranscript);
}

class RecorderPageState extends State<RecorderPage> {
  IndexTranscript indextranscript;
  RecorderPageState(this.indextranscript);
  FlutterAudioRecorder _recorder;
  Recording _current;
  RecordingStatus _currentStatus = RecordingStatus.Unset;
  // bool recordPressed = false;
  int transcript_length;

  String dirFile;
  List<io.FileSystemEntity> fileList;
  List<String> fileNameList = [];
  List<String> dirNameList = [];
  // TODO: get these code into _stop to count files every stopped
  //   String dirFile = ziptranscript.storeDir;
  // List fileList = io.Directory('$dirFile').listSync();
  // print(file.length);

  // * indikator record
  bool _isRecordMode;
  bool _isWaitMode;
  bool _isButtonDisabled;
  int _stateRecord;

  List colorIndicator = [
    Colors.grey,
    Colors.redAccent,
    Colors.greenAccent,
    Colors.redAccent
  ];

  final ziptranscript = zipTranscript(
    storeDir: "source_directory_zip",
    zipDir: "destination_directory_zip",
    zipName: "directory.zip",
    zipDateTime: "yyyyMMdd_HHmmss",
  );

  // RecorderPageState({Key key, @required this.dirName});

  // RecorderPageState({this.directoryName});
  Future<List<String>> loadAsset() async {
    var myData = await rootBundle
        .loadString("assets/${indextranscript.transcriptTitle}.csv");
    List<List<dynamic>> csvTable = CsvToListConverter().convert(myData);
    List<String> data = [];
    csvTable[0].forEach((value) {
      data.add(value.toString());
    });
    // print(data.length.toInt());
    transcript_length = (data.length.toInt() - 3) ~/ 2;
    // print(transcript_length.toInt());
    return data;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _zipFilename();
    print('test');
    _countDirs();
    // * record mode: state 1
    _isRecordMode = false;
    _isWaitMode = false;
    _isButtonDisabled = false;
    _stateRecord = 0;
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
                  // * Indikator bar
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width * 1,
                        height: MediaQuery.of(context).size.height * 0.02,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: colorIndicator[_stateRecord],
                          ),
                        )),
                  ),
                  // new SizedBox(child: c,olor: Colors.grey),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(0),
                        // * PREVIOUS BUTTON
                        child: new FlatButton(
                          onPressed: _stateRecord == 0
                              ? () {
                                  onPreviousTranscript();
                                }
                              : null, //
                          child: new Icon(Icons.navigate_before),
                          color: _stateRecord == 0
                              ? Colors.lightBlue
                              : Colors.blueGrey,
                        ),
                      ),
                      Padding(
                        // RECORD button
                        padding: const EdgeInsets.all(8.0),
                        child: new FlatButton(
                          onPressed: _isButtonDisabled
                              ? null
                              : () {
                                  switch (_currentStatus) {
                                    case RecordingStatus.Unset:
                                      {
                                        onRecordTranscript();
                                        // recordPressed = true;
                                        break;
                                      }
                                    case RecordingStatus.Recording:
                                      {
                                        _stop();
                                        // recordPressed = false;
                                        break;
                                      }
                                    case RecordingStatus.Stopped:
                                      {
                                        onRecordTranscript();
                                        // recordPressed = true;
                                        break;
                                      }
                                    default:
                                      break;
                                  }
                                },
                          // child: new Icon(Icons.fiber_manual_record_outlined),
                          // color: Colors.redAccent,
                          child: _stateRecord == 0
                              ? new Icon(
                                  Icons.stop_circle,
                                  color: Colors.redAccent,
                                  size: 50.0,
                                )
                              : new Icon(
                                  Icons.stop_outlined,
                                  size: 50.0,
                                ),
                          // child: recordPressed
                          //     ? new Icon(
                          //         Icons.stop_outlined,
                          //         size: 50.0,
                          //       )
                          //     : new Icon(
                          //         Icons.stop_circle,
                          //         color: Colors.redAccent,
                          //         size: 50.0,
                          //       ),
                          // color:
                          //     recordPressed ? Colors.white38 : Colors.white38,
                        ),
                      ), //
                      // * Next Transcript
                      new FlatButton(
                        onPressed: _stateRecord == 0
                            ? () {
                                onNextTranscript();
                              }
                            : null, //
                        child: new Icon(Icons.navigate_next),
                        color: _stateRecord == 0
                            ? Colors.lightBlue
                            : Colors.blueGrey,
                      ),
                    ],
                  ),
                  FutureBuilder(
                      future: _stateRecord == 0 ? _countFiles() : null,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.data == null) {
                          return Center(
                            child: Text('0 / $transcript_length'),
                          );
                        } else {
                          return Center(
                            child:
                                Text('${snapshot.data} / $transcript_length'),
                          );
                        }
                      }),
                  // new FlatButton(
                  //   onPressed: onCheckPlayAudio, //
                  //   child: new Text("Play",
                  //       style: TextStyle(color: Colors.black54)),
                  //   color: Colors.lightGreen[100],
                  // ),
                ]),
          ),
        ),
      ),
    );
    // return new Center(
    // );
  }

  _zipFilename() async {
    var nowTime = new DateTime.now();
    var formatterZip = new DateFormat('yyyyMMdd_HHmmss');
    String _formattedDate = formatterZip.format(nowTime);

    setState(() {
      ziptranscript.zipDateTime = _formattedDate;
    });
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
        String customDir =
            '/${indextranscript.dirName}_${ziptranscript.zipDateTime}/';
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

        setState(() {
          ziptranscript.storeDir = directory + customDir;
          ziptranscript.zipDir = directory;
          ziptranscript.zipName = customDir.substring(
              0, customDir.length - 1); // hilangin "/" di belakang
        });
        print('${ziptranscript.storeDir} good');
        // String dirFile = ziptranscript.storeDir;
        // List file = io.Directory('$dirFile').listSync();
        // print(file.length);

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

  _stopRecord() async {
    // ! timer stop
    var result = await _recorder.stop();
    print("Stop recording: ${result.path}");
    print("Stop recording: ${result.duration}");
    File file = widget.localFileSystem.file(result.path);
    print("File length: ${await file.length()}");
    setState(() {
      _current = result;
      _currentStatus = _current.status;
    });
    _zipping();
  }

  Future _countDirs() async {
    io.Directory appDocDirectory;
    if (io.Platform.isIOS) {
      appDocDirectory = await getApplicationDocumentsDirectory();
    } else {
      appDocDirectory = await getExternalStorageDirectory();
    }
    String directory = appDocDirectory.path;

    List<io.FileSystemEntity> dirList = io.Directory('$directory').listSync();
    // print('countDirs: $dirList');
    dirList.forEach((value) {
      String fileName = basename(value.path);
      List<String> filename = fileName.split('_');

      if (!(fileName.endsWith('.zip')) &&
          filename[0] == indextranscript.userName &&
          filename[3] == indextranscript.transcriptTitle) {
        // print("fileName: $fileName");
        dirNameList.add(fileName);
      }

      setState(() {
        ziptranscript.zipDir = directory;
      });
    });
  }

  Future<String> _countFiles() async {
    // _countDirs();
    for (String dirname in dirNameList) {
      dirFile = "${ziptranscript.zipDir}/$dirname";
      print("reading $dirFile");
      fileList = io.Directory('$dirFile').listSync();
      print('filelist(1): $fileList');
      fileList.forEach((value) {
        String fileName = basename(value.path);
        fileNameList.add(fileName);
      });
      print('filelist(2): $fileList');
    }

    fileNameList = fileNameList.toSet().toList();
    print(fileNameList);
    String data = fileNameList.length.toString();
    return data;
  }

  _stop() async {
    Timer _timer;
    int _start = 1;
    setState(() {
      _stateRecord = 3;
      _isButtonDisabled = true;
    });
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(oneSec, (Timer timer) {
      if (_start == 0) {
        // * times up here
        timer.cancel();
        _stopRecord();
        setState(() {
          // * 1->2 atau 3->0
          _stateRecord == 1 ? _stateRecord = 2 : _stateRecord = 0;
          _isButtonDisabled = false; // * button kembali aktif
        });
        _countDirs();
        onNextTranscript(); // * auto next after stop pressed

      } else {
        setState(() {
          _start--;
        });
      }
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
      // _stop();
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
    _stateRecord = 1;
    _isButtonDisabled = true;
    await _init();
    await _start();
    // ! use timer here
    countDownTimer_start(1);
    // print(_current?.duration.inMinutes.toString());
    // _current?.duration.inMilliseconds >= 3000 ? print("A") : print("B");
    // print(_current?.duration.toString());
  }

  countDownTimer_start(int _start) {
    Timer _timer;
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(oneSec, (Timer timer) {
      if (_start == 0) {
        // * times up here
        setState(() {
          timer.cancel();
          // * 1->2 atau 3->0
          _stateRecord == 1 ? _stateRecord = 2 : _stateRecord = 0;
          _isButtonDisabled = false; // * button kembali aktif
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  void onNextTranscript() async {
    print("next");
    // 1. if index < max(index) then index++
    if (indextranscript.number < transcript_length) {
      // _stop();
      setState(() {
        indextranscript.number++;
        // 2. filename.update
        indextranscript.fileName[1] = indextranscript.number.toString();
      });
      // 3. _init
      // _init();
    } else {
      // _stop();
      doneDialog();
      // showDialog(
      //     context: this.context,
      //     builder: (BuildContext context) {
      //       return AlertDialog(
      //         title: Text("Alert Dialog"),
      //         content: Text("Dialog Content"),
      //       );
      //     });
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

  Future<void> doneDialog() async {
    return showDialog<void>(
      context: this.context,
      barrierDismissible: false, //user must ap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('SELESAI!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Transcript ${indextranscript.transcriptTitle} telah selesai.'),
                Text('Klik "Ganti Transcript" untuk ganti transcript'),
                Text('atau "kembali" untuk menutup dialog ini'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('kembali'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Ganti Transcript'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pop(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          RecorderPage(indextranscript: indextranscript)),
                  // RecorderPage(
                  //     dir_name: new IndexTranscript(0, _dirname))),
                );
              },
            ),
          ],
        );
      },
    );
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

  Future _zipping() async {
    await _testZip();
  }

  io.File _createZipFile(String fileName) {
    final zipFilePath = ziptranscript.zipDir + "/" + fileName;
    final zipFile = io.File(zipFilePath);

    if (zipFile.existsSync()) {
      print("Deleting existing zip file: " + zipFile.path);
      zipFile.deleteSync();
    }
    return zipFile;
  }

  Future<io.File> _testZip() async {
    print("_appDataDir=" + ziptranscript.zipDir);
    final storeDir = io.Directory(ziptranscript.storeDir);

    final zipFile = _createZipFile("${ziptranscript.zipName}.zip");
    print("Writing to zip file: " + zipFile.path);

    try {
      await ZipFile.createFromDirectory(
          sourceDir: storeDir, zipFile: zipFile, recurseSubDirs: true);
    } on PlatformException catch (e) {
      print(e);
    }
    return zipFile;
  }
}

class zipPage extends StatefulWidget {
  final zipTranscript ziptranscript;
  zipPage({this.ziptranscript});
  @override
  _zipPageState createState() => new _zipPageState(ziptranscript);
}

class _zipPageState extends State<zipPage> {
  zipTranscript ziptranscript;
  _zipPageState(this.ziptranscript);
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
                new Text("Zipping"),
                new RaisedButton(child: Text("Test"), onPressed: () => _test()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future _test() async {
    await _testZip();
  }

  io.File _createZipFile(String fileName) {
    final zipFilePath = ziptranscript.zipDir + "/" + fileName;
    final zipFile = io.File(zipFilePath);

    if (zipFile.existsSync()) {
      print("Deleting existing zip file: " + zipFile.path);
      zipFile.deleteSync();
    }
    return zipFile;
  }

  Future<io.File> _testZip() async {
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyyMMdd_HHmmss');
    String _formattedDate = formatter.format(now);
    print("_appDataDir=" + ziptranscript.zipDir);
    final storeDir = io.Directory(ziptranscript.storeDir);

    final zipFile =
        _createZipFile("${ziptranscript.zipName}_$_formattedDate.zip");
    print("Writing to zip file: " + zipFile.path);

    try {
      await ZipFile.createFromDirectory(
          sourceDir: storeDir, zipFile: zipFile, recurseSubDirs: true);
    } on PlatformException catch (e) {
      print(e);
    }
    return zipFile;
  }

  // void zippingDir() async {
  //   final dataDir = Directory(indextranscript.dirName);
  //   try {
  //     final zipFile = File("zip_zap_zap");
  //     ZipFile.createFromDirectory(
  //         sourceDir: dataDir, zipFile: zipFile, recureSubDirs: true);
  //   } catch (e) {
  //     print(e);
  //   }
  // }
} // class-state
