import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

//import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';
import './input_form.dart';
import './intent_parameter.dart';
//import 'package:tesformflutter/main_ori.dart';
//import 'package:nfc_in_flutter/nfc_in_flutter.dart';
//import 'package:fluttertoast/fluttertoast.dart';

//Future<List<Photo>> fetchPhotos(http.Client client) async {
//  final response =
//  await client.get('https://jsonplaceholder.typicode.com/photos');
//
//  // Use the compute function to run parsePhotos in a separate isolate.
//  return compute(parsePhotos, response.body);
//}
//import 'package:intent/intent.dart' as android_intent;
//import 'package:intent/extra.dart' as android_extra;
//import 'package:intent/typedExtra.dart' as android_typedExtra;
//import 'package:intent/action.dart' as android_action;
//
//import 'package:android_intent/android_intent.dart';
//import 'package:android_intent/flag.dart';
//import 'package:flutter/material.dart';
//import 'package:platform/platform.dart';

//import 'package:nfc_in_flutter/nfc_in_flutter.dart';
//import 'package:alps_rfid_n6737/alps_rfid_n6737.dart';
Database db;

Future<List<Cabang>> fetchCabang(http.Client client) async {
  final response =
//  await client.get('http://192.168.10.213:80/stockopnamegadgetDEV/list_tbCabang_f.php');
  await client.get('http://203.142.77.243:80/stockopnamegadgetDEV/list_tbCabang_f.php');
//
  db= await initDb();
  // ignore: unnecessary_cast
  List<Cabang> cbgs=await compute(parseCabang, response.body) as List<Cabang>;

  if (cbgs.length>0){
    db.rawDelete('delete from cabang');
  }
  for (int i=0;i<cbgs.length;i++){
    db.rawInsert('insert into cabang (szname) values(?)', [cbgs[i].szName]);
  }

  db.rawDelete('delete from employee');
  db.rawInsert('insert into employee (szIdCard,szName) values(?,?)', ['0x218ce079','Hendra Kurniawan']);
  db.rawInsert('insert into employee (szIdCard,szName) values(?,?)', ['0x218ce080','Timoti Handy Wibawa']);

  final List<Map<String, dynamic>> maps = await db.query('cabang');

  // Convert the List<Map<String, dynamic> into a List<Dog>.
  return List.generate(maps.length, (i) {
    return Cabang(
      szName: maps[i]['szname'],
    );
  });

//  final List<Map<String, dynamic>> maps = await db.query('Cabang');
//
//  // Convert the List<Map<String, dynamic> into a List<Dog>.
//  return List.generate(maps.length, (i) {
//    return Cabang(
//      szName: maps[i]['szname'],
//    );
//  });

  // Use the compute function to run parsePhotos in a separate isolate.
//  final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
//  final parsed = jsonDecode(response.body).cast<String, dynamic>();
//
//  return parsed<Cabang>((json) => Cabang.fromJson(json)).toList();
//  -- return compute(parseCabang, response.body);
//  return Cabang.fromJson(json.decode(response.body));
}

// A function that converts a response body into a List<Photo>.
//List<Photo> parsePhotos(String responseBody) {
//  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
//
//  return parsed.map<Photo>((json) => Photo.fromJson(json)).toList();
//}
List<Cabang> parseCabang(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

//  var ListOfCabang = parsed.map<Cabang>((json) => Cabang.fromJson(json)).toList();
  return parsed.map<Cabang>((json) => Cabang.fromJson(json)).toList();
}

class Cabang {
  final String szName;
  Cabang ({this.szName});

  factory Cabang.fromJson(Map<String, dynamic> json) {
    return Cabang(
      szName: json['szname'],
    );
  }
}

class Employee {
  final String szIdCard;
  final String szName;
  Employee ({this.szIdCard, this.szName});

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      szIdCard: json['szidcard'],
      szName: json['szname'],
    );
  }
}
//
//class Photo {
//  final int albumId;
//  final int id;
//  final String title;
//  final String url;
//  final String thumbnailUrl;
//
//  Photo({this.albumId, this.id, this.title, this.url, this.thumbnailUrl});
//
//  factory Photo.fromJson(Map<String, dynamic> json) {
//    return Photo(
//      albumId: json['albumId'] as int,
//      id: json['id'] as int,
//      title: json['title'] as String,
//      url: json['url'] as String,
//      thumbnailUrl: json['thumbnailUrl'] as String,
//    );
//  }
//}

// ignore: non_constant_identifier_names
void ReadNFC(){
//  FlutterNfcReader.read().then((response) {
//    print(response.content);
//  });

  FlutterNfcReader.onTagDiscovered().listen((onData) {
    print(onData.id);
    print(onData.content);
  });
}

Future<Database> initDb() async {
//  Directory directory = await getApplicationDocumentsDirectory();
  Directory directory = await getExternalStorageDirectory();
  String path = directory.path + '/tesflutter';
  var todoDatabase = openDatabase(path, version: 1, onCreate: _createDb);
  // ignore: unnecessary_statements
//  _recreateDb;
  return todoDatabase;
}

void _createDb(Database db, int version) async {
  await db.execute('''
      CREATE TABLE IF NOT EXISTS Cabang (
        szname TEXT PRIMARY KEY 
      )
    ''');
//  await db.execute('''
//      CREATE TABLE IF NOT EXISTS Employee (
//        szidcard TEXT PRIMARY KEY,
//        szname TEXT
//      )
//    ''');
}
void _recreateDb() async {
  await db.execute('''
      CREATE TABLE IF NOT EXISTS Cabang (
        szname TEXT PRIMARY KEY 
      )
    ''');
  await db.execute('''
      CREATE TABLE IF NOT EXISTS Employee (
        szidcard TEXT PRIMARY KEY, 
        szname TEXT
      )
    ''');
}




void main() => runApp(MyApp());

class MyApp extends StatelessWidget  {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Tes Form Flutter';

    return MaterialApp(
      title: appTitle,
      home: MyHomePage(title: appTitle),
    );
  }



//  State<StatefulWidget> createState() {
//    // TODO: implement createState
//    throw UnimplementedError();
//  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
//  final String title;
  Future<List<Cabang>> cabangs;
//  BuildContext fContext;

//  MyHomePage({Key key, this.title}) : super(key: key);
//  MyHomePage({Key key, this.title});
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    cabangs = fetchCabang(http.Client());
    FlutterNfcReader.onTagDiscovered().listen((onData) {
//                          print(onData.id);
//                          print(onData.content);
//                          print(onData.status);
      _showToast(context, onData.id);
    });
  }

  Future<void> startNFC() async {
    NfcData response;
    var _nfcData;

    setState(() {
      _nfcData = NfcData();
      _nfcData.status = NFCStatus.reading;
    });

    print('NFC: Scan started');

    try {
      print('NFC: Scan readed NFC tag');
      response = (await FlutterNfcReader.read) as NfcData;
    } on PlatformException {
      print('NFC: Scan stopped exception');
    }
    setState(() {
      _nfcData = response;
      print(_nfcData.toString());
    });
  }


  Widget build(BuildContext context) {
//    fContext=context;

//    void rdfidDataListener(dynamic event) {
//      print('dart $event');
//      setState(() {
//        tags.add(event);
//        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
//            duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
//      });
//    }
    void rfidBoarding(dynamic rfidId) {
      print(rfidId);
    }

    return Scaffold(
//      appBar: AppBar(
////        title: Text('Tes Form Flutter'),
//      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
//            FlatButton.icon(
//                onPressed: (){
//                  _showToast(context);
//                },
//                icon: Icon (Icons.refresh),
//                label: Text('Refresh'),
//              color: Colors.cyan,
//            ),
//            RaisedButton.icon(
//                onPressed: (){
//                  _showToast(context);
//                },
//                icon: Icon (Icons.refresh),
//                label: Text('Refresh'),
////              color: Colors.lightGreen,
//            ),
//            ListView(),
            SizedBox(height: 50.0),
            Wrap(
              direction: Axis.horizontal,
              spacing: 10,
              children: <Widget>[
//                ConstrainedBox(
//                  constraints: const BoxConstraints(minWidth: double.maxFinite),
//                  child:
//                ),
                Builder(
                  builder: (ctx) => RaisedButton.icon(
//                  textColor: Colors.red,
                      icon: Icon (Icons.refresh),
                      label: Text('Refresh'),
                      color: Colors.lightGreen,
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                      onPressed: () {
                        setState(()  {
//                      isLoading=true;
                          // ignore: missing_return
                          cabangs = fetchCabang(http.Client());
//                      cabangs = fetchCabang(http.Client()).then((void nothing) {
//                        setState(() {
//                          isLoading=false;
//                        });
//                      });
//                      isLoading=false;
                        });
//                    _showToast(ctx);
//                    Scaffold.of(ctx).showSnackBar(SnackBar(content: Text('Profile Save'),),);
                      }
                  ),
                ),
                Builder(
                  builder: (ctx) => RaisedButton.icon(
//                  textColor: Colors.red,
                      icon: Icon (Icons.nfc),
                      label: Text('Start Reading NFC'),
                      color: Colors.yellowAccent,
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                      onPressed: () {
//                        AlpsRfidN6737.startRead();
//                        AlpsRfidN6737.setPowerLevel(level: 60);
////                        AlpsRfidN6737.continuousRead();
//                        AlpsRfidN6737.dataStream.receiveBroadcastStream().listen(rfidBoarding);

                        // NFC.readNDEF returns a stream of NDEFMessage
//                        Stream<NDEFMessage> stream = NFC.readNDEF();
//
//                        stream.listen((NDEFMessage message) {
//                          print("records: ${message.records.length}");
//                          print("records: ${message.records}");
//                        });

                        FlutterNfcReader.onTagDiscovered().listen((onData) async {
//                          print(onData.id);
//                          print(onData.content);
//                          print(onData.status);
                          _showToast(ctx, onData.id);
//                          List<Map> result = await db.rawQuery('SELECT * FROM employee WHERE szidcard=?', [onData.id]);
//                          // print the results
//                          String strNama='';
//                          if (result.length>0){
//                            for (int i=0;i<result.length;i++){
//                              strNama=result[i]['szname'];
//                            }
//                          }
//
//                          final intentParam= IntentParam(
//                            id: onData.id,
//                            text: strNama,
//                          );
//                          Navigator.push(
//                            context,
//                            MaterialPageRoute(builder: (context) => InputForm(
//                              intentParam: intentParam,
//                            )),
//                          );
                        });

//                    // NFC.readNDEF returns a stream of NDEFMessage
//                    Stream<NDEFMessage> stream = NFC.readNDEF();
//
//                    stream.listen((NDEFMessage message) {
////                      print("records: $message");
//                      print("records id: ${message.id}");
//                      print("records: ${message.records}");
//                    });
                      }
                  ),

                ),
                Builder(
                  builder: (ctx) => RaisedButton.icon(
//                  textColor: Colors.red,
                      icon: Icon (Icons.navigate_next),
                      label: Text('Go to form'),
                      color: Colors.lightBlue,
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                      onPressed: () {
                        final intentParam= IntentParam(
                          text: 'Hendra Kurniawan',
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => InputForm(
                            intentParam: intentParam,
                          )),
                        );

                      }
                  ),

                ),
              ],
            ),
//            Wrap(
//              direction: Axis.horizontal,
//              spacing: 10,
//              children: <Widget>[
////                ConstrainedBox(
////                  constraints: const BoxConstraints(minWidth: double.maxFinite),
////                  child:
////                ),
//                Builder(
//                  builder: (ctx) => RaisedButton.icon(
////                  textColor: Colors.red,
//                      icon: Icon (Icons.refresh),
//                      label: Text('SFA Tools'),
//                      color: Colors.pinkAccent,
//                      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
//                      onPressed: () {
////                        if (platform.isAndroid) {
//                          AndroidIntent intent = AndroidIntent(
//                              action: 'action_view',
////                              data: Uri.encodeFull('https://flutter.io'),
//                              package: 'com.sfa.tesreplacedb3.MainActivity'
//                          );
//                           intent.launch();
////                        }
////                        android_intent.Intent()
//////                          ..setPackage("com.sfa.tools")
////                          ..setAction("com.sfa.tools.MainActivity")
//////                          ..putExtra(android_extra.Extra.EXTRA_PACKAGE_NAME, "com.sfa.tools", type: android_typedExtra.TypedExtra.stringExtra)
////                          ..putExtra(android_extra.Extra.EXTRA_TITLE, "SfaCallingPage")
////                          ..putExtra(android_extra.Extra.EXTRA_TEXT, "Pengaturan")
//////                          ..setData(Uri(scheme: 'SfaCallingPage', path: 'Pengaturan'))
////                          ..startActivity().catchError((e) => print(e));
////                    _showToast(ctx);
////                    Scaffold.of(ctx).showSnackBar(SnackBar(content: Text('Profile Save'),),);
//                      }
//                  ),
//                ),
//              ],
//            ),

            SizedBox(height: 10.0),
            Expanded(
              child : isLoading ?
              Center(child: CircularProgressIndicator(),) :
              FutureBuilder<List<Cabang>>(
                future: cabangs,
                builder: (context, AsyncSnapshot<List<Cabang>> snapshot) {
                  if (snapshot.hasError) print(snapshot.error);

                  return snapshot.hasData
                      ? PhotosList(photos: snapshot.data)
                      : Center(child: CircularProgressIndicator());
                },
              ),
            ),

          ]
      ),
    );
  }

  void _showToast(BuildContext context, String msg) {
//    msg=int.parse(msg, radix:16).toString();
    String hextodec='';
    String msg2=msg[8]+msg[9]+msg[6]+msg[7]+msg[4]+msg[5]+msg[2]+msg[3];
    hextodec=(int.parse(msg2, radix:16)).toString();

    final scaffold = Scaffold.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(msg2+' - '+hextodec),
        action: SnackBarAction(
            label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}


class PhotosList extends StatelessWidget {
  final List<Cabang> photos;

  PhotosList({Key key, this.photos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: photos.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text((index+1<10?'0'+(index+1).toString():(index+1).toString())+'. ${photos[index].szName}'),
//          title: Text('${photos[index].szName}'),
        );
      },
    );
//    return GridView.builder(
//      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//        crossAxisCount: 2,
//      ),
//      itemCount: photos.length,
//      itemBuilder: (context, index) {
////        return Image.network(photos[index].thumbnailUrl);
//        return ListTile(
//          title: Text('${photos[index]}'),
//        );
//      },
//    );
  }
}
