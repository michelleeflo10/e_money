import 'dart:async';

import 'package:emoney/configuration.dart';
import 'package:emoney/sources/EMoneyAPI.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/EMoneyModel.dart';
import 'package:searchfield/searchfield.dart';
import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';


class InputRFID extends StatefulWidget {

  @override
  _InputRFIDState createState() => _InputRFIDState();
}

class _InputRFIDState extends State<InputRFID> {
  final _searchController = TextEditingController();
  final _NomorRFID = TextEditingController();

  @override
  void initState() {
    super.initState();
    FlutterNfcReader.onTagDiscovered().listen((onData) {
//                          print(onData.id);
//                          print(onData.content);
//                          print(onData.status);
      _showToast(context, onData.id);
    });
    // emoneys = data.map((e) => EMoney().fromMap(e)).toList();
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

  @override
  void didChangeDependencies() async {
    print('here');
    getRequestHistoryList();
  }

  List<EMoney> emoneys = [];

  @override
  Widget build(BuildContext context) {

    // List<String> emoneyList = showEMoneyList(config);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              child: SearchField(
                suggestions: emoneys.map((e) => e.NomorSeri).toList(),
                controller: _searchController,
                hint: 'Input nomor seri...',
                maxSuggestionsInViewPort: 4,
                itemHeight: 45,
                onTap: (x) {
                  print(x);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 30,
                left: 20,
                right: 20,
              ),
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: "Scan E-Money",
                ),
                controller: _NomorRFID,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 30,
                left: 20,
                right: 20,
              ),
              child: ElevatedButton(
                child: Text('Update'),
                onPressed: () => updateRFID(),
              ),
            )
          ],
        ),
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  // showEMoneyList(Configuration config) {
  //   List<String> tempWidgetList = [];
  //   print(tempWidgetList);
  //  for (int i = 0; i < emoneys.length; i++) {
  //    print(emoneys[i].NomorSeri);
  //    tempWidgetList.add(
  //       emoneys[i].NomorSeri
  //    );
  //  };
  //   return tempWidgetList;
  // }

  getRequestHistoryList() async {
    Configuration config = Configuration.of(context);

    emoneys = await EMoneyAPIs.getOrderList(context);
    print("ini list : ");
    print(emoneys[0].NomorSeri);

    setState(() {
      emoneys = emoneys;
    });
  }

  updateRFID() async{
    emoneys = await EMoneyAPIs.updateEMoney(context, _NomorRFID.text, _searchController.text);

    print("ini list : ");
    if(emoneys.length == 0){
      _NomorRFID.text = "";
      // _searchController.text = "";
      successToast(context);
    }

    // setState(() {
    //   emoneys = emoneys;
    // });
  }

  void _showToast(BuildContext context, String msg) {
//    msg=int.parse(msg, radix:16).toString();
    String hextodec='';
    String msg2=msg[8]+msg[9]+msg[6]+msg[7]+msg[4]+msg[5]+msg[2]+msg[3];
    hextodec=(int.parse(msg2, radix:16)).toString();

    final scaffold = Scaffold.of(context);
    _NomorRFID.text = hextodec;
    // scaffold.showSnackBar(
    //   SnackBar(
    //     content: Text(msg2+' - '+hextodec),
    //     action: SnackBarAction(
    //         label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
    //   ),
    // );
  }

  void successToast(BuildContext context){
    _NomorRFID.text = "";
    _searchController.text = "";
    final scaffold = Scaffold.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text('Berhasil diupdate'),
        action: SnackBarAction(
            label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

}