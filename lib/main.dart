import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:emoney/screens/inputRFID.dart';
import 'package:emoney/screens/searchNoSeri.dart';
import 'package:emoney/example/tesdropdown.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:emoney/models/EMoneyModel.dart';
import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';
// Database db;

Future<List<EMoney>> fetchCabang(http.Client client) async {
  final response =
//  await client.get('http://192.168.10.213:80/stockopnamegadgetDEV/list_tbCabang_f.php');
  await client.get('http://203.142.77.243:80/EMoney/getNoSeri.php');

  List<EMoney> cbgs=await compute(parseCabang, response.body) as List<EMoney>;

}

List<EMoney> parseCabang(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<EMoney>((json) => EMoney.fromJson(json)).toList();
}

void ReadNFC(){
  FlutterNfcReader.onTagDiscovered().listen((onData) {
    print(onData.id);
    print(onData.content);
  });
}


void main() => runApp(MyApp());

class MyApp extends StatelessWidget  {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Tes Form Flutter';
    return MaterialApp(
      title: appTitle,
      home: MyHomePage(title: appTitle),
      theme: ThemeData(
        primarySwatch: Colors.red,
        accentColor: Colors.amber,
        canvasColor: Color.fromRGBO(255, 254, 229, 1),
        textTheme: ThemeData.light().textTheme.copyWith(
          bodyText1: TextStyle(
            color: Color.fromRGBO(20, 51, 51, 1),
          ),
          bodyText2: TextStyle(
            color: Color.fromRGBO(20, 51, 51, 1),
          ),
          headline6: TextStyle(
            fontSize: 20,
            fontFamily: 'RobotoCondensed',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<EMoney> EMoneyList = [];
  Future<List<EMoney>> cabangs;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    cabangs = fetchCabang(http.Client());
    FlutterNfcReader.onTagDiscovered().listen((onData) {
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

  int _currentIndex = 0;

  final _pageOptions = [
    InputRFID(),
    SearchNoSeri()
  ];

  void onTabTapped(int index) {
    // print(index);
    // if(index == 1){
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(builder: (context) => InputRFID()),
    //   );
    // }
    setState(() {
      _currentIndex = index;
    });
  }

  Widget build(BuildContext context) {
    void rfidBoarding(dynamic rfidId) {
      print(rfidId);
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pageOptions[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.red,
        fixedColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.pending),
            title: new Text('INPUT'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.done),
            title: new Text('SEARCH'),
          )
        ],
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
  final List<EMoney> photos;

  PhotosList({Key key, this.photos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: photos.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text((index+1<10?'0'+(index+1).toString():(index+1).toString())+'. ${photos[index].NomorSeri}'),
        );
      },
    );
  }
}

