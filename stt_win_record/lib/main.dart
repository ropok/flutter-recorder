import 'dart:async';
import 'dart:io' as io;
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter_countdown_timer/countdown_controller.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:csv/csv.dart';
import 'dart:async' show Future;
import 'package:flutter_archive/flutter_archive.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'util/validators.dart';

void main() {
  return runApp(new MyApp());
}

class User {
  const User(this.name);
  final String name;
}

class ZipTranscript {
  ZipTranscript(
      {this.storeDir,
      this.zipDir,
      this.zipName,
      this.zipDateTime,
      this.zipSize});
  String storeDir;
  String zipDir;
  String zipName;
  String zipDateTime;
  String zipSize;
}

class IndexTranscript {
  IndexTranscript(
      {this.number,
      this.dirName,
      this.fileName,
      this.transcriptTitle,
      this.userName,
      this.dateTime,
      this.dialek});
  int number; // format number 001, 0001, 01, ...
  String dirName; // custom directory name
  List<String> fileName;
  String transcriptTitle;
  String userName;
  String dateTime;
  String dialek;
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
  final _formKey = GlobalKey<FormState>();
  User jenisKelaminUser;
  List<User> users = <User>[User('Perempuan'), User('Laki-laki')];

  final indextranscript = IndexTranscript(
      number: 1,
      dirName: 'dirName',
      fileName: ['fileName1', 'index', 'fileName2'],
      transcriptTitle: 'audiobuku.csv',
      userName: 'user000',
      dateTime: 'YYYYMMDD',
      dialek: 'dialek'); // * initiation

  // * Form
  TextEditingController usernameField = TextEditingController();
  TextEditingController dialekField = TextEditingController();
  TextEditingController jenisKelaminField = TextEditingController();
  String _transcript = "audiobuku";
  String directory;
  List file;

  @override
  void initState() {
    super.initState();
    _listFiles();
  }

  // * read directory's content
  void _listFiles() async {
    directory = (await getApplicationDocumentsDirectory()).path;
    setState(() {
      file = io.Directory('$directory').listSync();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      // return new Center(
      child: new Padding(
        padding: new EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 0.0),
                SizedBox(height: 20.0),
                // * Text Box Username
                TextFormField(
                  controller: usernameField,
                  maxLength: 6,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: 'username',
                    icon: Icon(Icons.supervisor_account),
                    hintText: '6 digit huruf kecil. contoh: jal098',
                    hintStyle: TextStyle(fontSize: 14.0),
                    helperText: '6 digit, contoh: jal098',
                    border: const OutlineInputBorder(),
                  ),
                  validator: validateUsername,
                ),
                // * Dropdown Jenis Kelamin
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
                // * Text Box Dialek
                SizedBox(height: 20.0),
                TextFormField(
                  controller: dialekField,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: 'dialek',
                    icon: Icon(Icons.record_voice_over),
                    hintText: 'asal daerah atau dialek',
                    hintStyle: TextStyle(fontSize: 14.0),
                    helperText: 'contoh: jogja, batak, lampung, dll',
                    border: const OutlineInputBorder(),
                  ),
                  validator: validateDialek,
                ),
                // * Dropdown transcript
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
                // * Dropdown Jenis Kelamin
                SizedBox(height: 10.0),
                RaisedButton(
                  child: Text(
                    'SUBMIT',
                    style: TextStyle(fontSize: 18),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      var now = new DateTime.now();
                      var formatter = new DateFormat('yyyyMMdd');
                      String _formattedDate = formatter.format(now);
                      String _jenisKelamin;
                      // * ganti kode jenis kelamin
                      jenisKelaminUser.name == "Perempuan"
                          ? _jenisKelamin = "f"
                          : _jenisKelamin = "m";
                      String _username = usernameField.text.toLowerCase();
                      String _dialek = dialekField.text.toLowerCase();
                      // * hilangin spasi dari inputan dialek
                      _dialek = _dialek.replaceAll(new RegExp(r'\s+'), "");
                      setState(() {
                        indextranscript.number = 1;
                      });
                      int _index = indextranscript.number;
                      String _dirname =
                          "$_username\_$_jenisKelamin\_$_formattedDate\_$_transcript\_$_dialek\_hp";
                      String _filename1 =
                          "$_username\_$_jenisKelamin\_$_formattedDate\_";
                      String _filename2 = "\_$_transcript\_$_dialek\_hp";

                      // * example: rut122_f_20201216_001_audiobuku_yogyakarta_hp
                      setState(() {
                        indextranscript.dirName = _dirname;
                        indextranscript.fileName = [
                          _filename1,
                          _index.toString(),
                          _filename2
                        ];
                        indextranscript.transcriptTitle = "$_transcript";
                        indextranscript.userName = "$_username";
                        indextranscript.dateTime = "$_formattedDate";
                        indextranscript.dialek = "${dialekField.text}";
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                RecorderPage(indextranscript: indextranscript)),
                      );
                    }
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

class RecorderPage extends StatefulWidget {
  final LocalFileSystem localFileSystem;
  final IndexTranscript indextranscript;
  final initNumber;
  final ScrollController controller;

  RecorderPage(
      {localFileSystem, this.indextranscript, this.initNumber, this.controller})
      : this.localFileSystem = localFileSystem ?? LocalFileSystem();

  @override
  RecorderPageState createState() => new RecorderPageState(indextranscript);
}

class RecorderPageState extends State<RecorderPage> {
  int endTime = DateTime.now().millisecondsSinceEpoch + 0 * 3;
  CountdownController countdownController;
  CountdownTimerController countdownTimerController;
  IndexTranscript indextranscript;
  RecorderPageState(this.indextranscript);
  ScrollController controller;
  FlutterAudioRecorder _recorder;
  Recording _current;
  RecordingStatus _currentStatus = RecordingStatus.Unset;
  // bool recordPressed = false;
  int transcriptLength;

  TextEditingController jumpTranscriptController = TextEditingController();

  String dirFile;
  List<io.FileSystemEntity> fileList;
  List<String> fileNameList = [];
  List<String> dirNameList = [];

  // * indikator record
  bool _isButtonDisabled;
  int _stateRecord;

  // * warna dari bar indikator, berdasarkan _stateRecord
  List colorIndicator = [
    Colors.grey,
    Colors.redAccent,
    Colors.greenAccent,
    Colors.redAccent
  ];

  // * isi text dari bar indikator, berdasarkan _stateRecord
  List<String> textIndicator = [
    "Harap diam saat warna merah.\nMulai baca saat warna hijau muncul!",
    "",
    "",
    ""
  ];

  final ziptranscript = ZipTranscript(
    storeDir: "source_directory_zip",
    zipDir: "destination_directory_zip",
    zipName: "directory.zip",
    zipDateTime: "yyyyMMdd_HHmmss",
    zipSize: "0",
  );

  Future<List<String>> loadAsset() async {
    var myData = await rootBundle
        .loadString("assets/${indextranscript.transcriptTitle}.csv");
    List<List<dynamic>> csvTable = CsvToListConverter().convert(myData);
    List<String> data = [];
    csvTable[0].forEach((value) {
      data.add(value.toString());
    });
    transcriptLength = (data.length.toInt() - 3) ~/ 2;
    return data;
  }

  @override
  void initState() {
    super.initState();
    _zipFilename();
    _countDirs();
    // * record mode: state 1
    _isButtonDisabled = false;
    _stateRecord = 0;
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
              "${indextranscript.transcriptTitle}\n${indextranscript.number}/$transcriptLength",
              textAlign: TextAlign.center),
          backgroundColor: Color.fromARGB(255, 39, 169, 225),
        ),
        body: SafeArea(
          child: new Padding(
            padding: new EdgeInsets.all(1.0),
            child: Wrap(
              children: [
                new Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      // * Indikator bar
                      new Container(
                        child: SizedBox(
                            width: MediaQuery.of(context).size.width * 1,
                            height: MediaQuery.of(context).size.height * 0.02,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: colorIndicator[_stateRecord],
                              ),
                            )),
                      ),
                      // ),
                      // * TEXT TRANSCRIPT
                      new Container(
                        width: MediaQuery.of(context).size.width * 0.85,
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: FutureBuilder(
                            future: loadAsset(),
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              // this condition is important
                              if (snapshot.data == null) {
                                return Center(
                                  child: Text('loading data'),
                                );
                              } else {
                                return Center(
                                    // * karena newline tidak terbaca sebagai split
                                    child: Text(
                                  snapshot
                                      .data[(indextranscript.number * 2) + 1],
                                  style: TextStyle(height: 1.25, fontSize: 32),
                                ));
                              }
                            }),
                      ),
                      // * Indikator bar
                      new Container(
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 1,
                              height: MediaQuery.of(context).size.height * 0.08,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: colorIndicator[_stateRecord],
                                ),
                              ),
                              // new Text("A"),
                            ),
                            new Text("${textIndicator[_stateRecord]}"),
                          ],
                        ),
                      ),
                      // * record button
                      new Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          new Container(
                            child: new FlatButton(
                              minWidth: MediaQuery.of(context).size.width * 0.2,
                              height: MediaQuery.of(context).size.height * 0.2,
                              onPressed: _isButtonDisabled
                                  ? null
                                  : () {
                                      switch (_currentStatus) {
                                        case RecordingStatus.Unset:
                                          {
                                            onRecordTranscript();
                                            break;
                                          }
                                        case RecordingStatus.Recording:
                                          {
                                            _stop();
                                            break;
                                          }
                                        case RecordingStatus.Stopped:
                                          {
                                            onRecordTranscript();
                                            break;
                                          }
                                        default:
                                          break;
                                      }
                                    },
                              child: _stateRecord == 0
                                  ? Stack(
                                      alignment: Alignment.center,
                                      children: <Widget>[
                                        new Icon(
                                          Icons.stop_circle,
                                          color: Colors.redAccent,
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.25,
                                        ),
                                        new Text(
                                          "record",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Stack(
                                      alignment: Alignment.center,
                                      children: <Widget>[
                                        new Icon(
                                          Icons.stop_rounded,
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.3,
                                        ),
                                        new Text(
                                          "stop",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              // * PREVIOUS BUTTON
                              new FlatButton(
                                minWidth:
                                    MediaQuery.of(context).size.width * 0.1,
                                height:
                                    MediaQuery.of(context).size.height * 0.05,
                                onPressed: _stateRecord == 0
                                    ? () {
                                        onPreviousTranscript();
                                      }
                                    : null, //
                                child: new Icon(
                                  Icons.navigate_before,
                                  size:
                                      MediaQuery.of(context).size.width * 0.15,
                                ),
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              // * Next Transcript
                              new FlatButton(
                                minWidth:
                                    MediaQuery.of(context).size.width * 0.1,
                                height:
                                    MediaQuery.of(context).size.height * 0.05,
                                onPressed: _stateRecord == 0
                                    ? () {
                                        onNextTranscript();
                                      }
                                    : null, //
                                child: new Icon(
                                  Icons.navigate_next,
                                  size:
                                      MediaQuery.of(context).size.width * 0.15,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      new SizedBox(
                        height: 15.0,
                      ),
                    ]),
              ],
            ),
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Text(
                  'STATUS - ${indextranscript.dateTime}\n\nusername: ${indextranscript.userName}\ndialek: ${indextranscript.dialek}\njudul transcript: ${indextranscript.transcriptTitle}',
                  style: TextStyle(color: Colors.white),
                ),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 39, 169, 225),
                ),
              ),

              new FlatButton(
                onPressed: () {
                  _countDirs();
                  dirStatSync(ziptranscript.zipDir);
                },
                child: new Icon(Icons.refresh),
                color: Colors.black12,
              ),
              FutureBuilder(
                  future: _stateRecord == 0 ? _countFiles() : null,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.data == null) {
                      return Center(
                        child: Text('jumlah terbaca: 0 / $transcriptLength'),
                      );
                    } else {
                      return Center(
                        child: Text(
                            'jumlah terbaca: ${snapshot.data} / $transcriptLength'),
                      );
                    }
                  }),
              SizedBox(
                height: 10.0,
              ),
              new Text("file size: ${ziptranscript.zipSize}",
                  textAlign: TextAlign.center),
              SizedBox(
                height: 20.0,
              ),
              // * jump to number transcript
              new Container(
                padding: EdgeInsets.symmetric(horizontal: 90.0),
                child: TextField(
                  controller: jumpTranscriptController,
                  onSubmitted: (value) {
                    1 <= int.parse(value) &&
                            int.parse(value) <= transcriptLength
                        ? () {
                            setState(() {
                              indextranscript.number = int.parse(value);
                              indextranscript.fileName[1] =
                                  indextranscript.number.toString();
                            });
                            Fluttertoast.showToast(
                              msg:
                                  "no. $value ${indextranscript.transcriptTitle}",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.greenAccent,
                              textColor: Colors.white,
                              fontSize: 12.0,
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RecorderPage(
                                      indextranscript: indextranscript)),
                            );
                          }()
                        : Fluttertoast.showToast(
                            msg: "nomor melebihi batas",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.redAccent,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                  },
                  decoration: new InputDecoration(
                    labelText: "pilih nomor transcript",
                    hintText: "1 - $transcriptLength",
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
        String customDir =
            '/${indextranscript.dirName}_${ziptranscript.zipDateTime}/';
        String customFileName = '${indextranscript.fileName.join()}';

        io.Directory appDocDirectory;
        if (io.Platform.isIOS) {
          appDocDirectory = await getApplicationDocumentsDirectory();
        } else {
          appDocDirectory = await getExternalStorageDirectory();
        }

        // * create Variable
        String directory = appDocDirectory.path;

        // * create directory and its subdirectory
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
              0, customDir.length - 1); // * hilangin "/" di belakang
        });

        customDir = directory + customDir + customFileName;
        String fileName = '$customDir.wav';
        await deleteFile(fileName);
        _recorder = FlutterAudioRecorder(customDir,
            audioFormat: AudioFormat.WAV, sampleRate: 16000);
        await _recorder.initialized;
        var current = await _recorder.current(channel: 0);
        // * should be "Initialized", if all working fine
        setState(() {
          _current = current;
          _currentStatus = current.status;
        });
      }
    } catch (e) {
      print(e);
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
        setState(() {
          _current = current;
          _currentStatus = _current.status;
        });
      });
    } catch (e) {
      print(e);
    }
  }

  _stopRecord() async {
    // ! timer stop
    var result = await _recorder.stop();
    setState(() {
      _current = result;
      _currentStatus = _current.status;
    });
    await _zipping();
    String zipSize = await dirStatSync(ziptranscript.zipDir);
    setState(() {
      ziptranscript.zipSize = zipSize;
    });
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
    dirList.forEach((io.FileSystemEntity value) {
      String fileName = basename(value.path);
      List<String> filename = fileName.split('_');

      if (!(fileName.endsWith('.zip')) &&
          filename[0] == indextranscript.userName &&
          filename[3] == indextranscript.transcriptTitle) {
        dirNameList.add(fileName);
      }
      setState(() {
        ziptranscript.zipDir = directory;
      });
    });
  }

  Future<String> dirStatSync(String dirPath) async {
    int fileNum = 0;
    int totalSize = 0;
    var dir = io.Directory(dirPath);
    try {
      if (dir.existsSync()) {
        dir
            .listSync(recursive: false, followLinks: false)
            .forEach((io.FileSystemEntity entity) {
          if (entity is io.File && (entity.toString().endsWith('.zip\''))) {
            // ! count only on username and transcript.
            String fileName = basename(entity.toString());
            List<String> filename = fileName.split('_');
            if (filename[0] == indextranscript.userName &&
                filename[3] == indextranscript.transcriptTitle) {
              print(basename(entity.toString()));
              fileNum++;
              totalSize += entity.lengthSync();
            }
          }
        });
      }
    } catch (e) {
      print(e.toString());
    }
    setState(() {
      ziptranscript.zipSize = "${formatBytes(totalSize, 0)}";
    });
    return "${formatBytes(totalSize, 0)}";
  }

  static String formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) +
        ' ' +
        suffixes[i];
  }

  Future<String> _countFiles() async {
    for (String dirname in dirNameList) {
      dirFile = "${ziptranscript.zipDir}/$dirname";
      fileList = io.Directory('$dirFile').listSync();
      fileList.forEach((value) {
        String fileName = basename(value.path);
        fileNameList.add(fileName);
      });
    }

    fileNameList = fileNameList.toSet().toList();
    String data = fileNameList.length.toString();
    return data;
  }

  _stop() async {
    setState(() {
      _stateRecord = 3;
      _isButtonDisabled = true;
    });
    Timer(Duration(seconds: 1), () {
      _stopRecord();
      setState(() {
        // * 1->2 atau 3->0
        _stateRecord == 1 ? _stateRecord = 2 : _stateRecord = 0;
        _isButtonDisabled = false; // * button kembali aktif
      });
      _countDirs();
      onNextTranscript(); // * auto next after stop pressed
    });
  }

  void onPlayAudio() async {
    AudioPlayer audioPlayer = AudioPlayer();
    await audioPlayer.play(_current.path, isLocal: true);
  }

  void onPreviousTranscript() async {
    // * 1. if index > 1 then index--
    if (indextranscript.number > 1) {
      setState(() {
        indextranscript.number--;
        // * 2. filename.update
        indextranscript.fileName[1] = indextranscript.number.toString();
      });
    }
  }

  void onRecordTranscript() async {
    _stateRecord = 1;
    _isButtonDisabled = true;
    await _init();
    await _start();
    // ! use timer here
    countDownTimerstart(1);
  }

  countDownTimerstart(int _start) {
    Timer(Duration(seconds: _start), () {
      // * times up here
      setState(() {
        // * 1->2 atau 3->0
        _stateRecord == 1 ? _stateRecord = 2 : _stateRecord = 0;
        _isButtonDisabled = false; // * button kembali aktif
      });
    });
  }

  void onNextTranscript() async {
    // * 1. if index < max(index) then index++
    if (indextranscript.number < transcriptLength) {
      setState(() {
        indextranscript.number++;
        // * 2. filename.update
        indextranscript.fileName[1] = indextranscript.number.toString();
      });
    } else {
      doneDialog();
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
    // * create Variable
    String directory = appDocDirectory.path;
    customDir = directory + customDir + customFileName;

    try {
      var file = io.File('$customDir.wav');
      String fileName = '$customDir.wav';
      if (await file.exists()) {
        await audioPlayer.play(fileName, isLocal: true);
      }
    } catch (e) {}
  }

  Future<void> doneDialog() async {
    return showDialog<void>(
      context: this.context,
      barrierDismissible: false, // ! user must tap button!
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
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteFile(String fileName) async {
    try {
      var file = io.File(fileName);
      if (await file.exists()) {
        // * file exists, it is safe to call delete on it
        await file.delete();
      }
    } catch (e) {
      // * error in getting access to the file
    }
  }

  Future _zipping() async {
    await _testZip();
  }

  io.File _createZipFile(String fileName) {
    final zipFilePath = ziptranscript.zipDir + "/" + fileName;
    final zipFile = io.File(zipFilePath);
    // * Deleting existing zip file
    if (zipFile.existsSync()) {
      zipFile.deleteSync();
    }
    return zipFile;
  }

  Future<io.File> _testZip() async {
    // * _appDataDir
    final storeDir = io.Directory(ziptranscript.storeDir);

    // * Writing to zip file
    final zipFile = _createZipFile("${ziptranscript.zipName}.zip");

    try {
      await ZipFile.createFromDirectory(
          sourceDir: storeDir, zipFile: zipFile, recurseSubDirs: true);
    } on PlatformException catch (e) {
      print(e);
    }
    return zipFile;
  }
}
