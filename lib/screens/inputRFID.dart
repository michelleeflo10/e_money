import 'dart:async';
import 'dart:typed_data';

import 'package:emoney/configuration.dart';
import 'package:emoney/sources/EMoneyAPI.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:usb_serial/usb_serial.dart';
import '../models/EMoneyModel.dart';
import 'package:searchfield/searchfield.dart';
import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';
import 'package:textfield_search/textfield_search.dart';


class InputRFID extends StatefulWidget {

  @override
  _InputRFIDState createState() => _InputRFIDState();
}

class _InputRFIDState extends State<InputRFID> {
  final FocusNode FocusNomorRFID = FocusNode();
  final _searchController = TextEditingController();
  final _NomorRFID = TextEditingController();

  String tesEvent = "";
  @override
  void initState() {
    super.initState();
//    _searchController.addListener(_printLatestValue);
  }
  _requestFocusRFID() {
    FocusNomorRFID.requestFocus();
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

    List<UsbDevice> devices = await UsbSerial.listDevices();
    print(devices);

    UsbPort port;
    if (devices.length == 0) {
      return;
    }
    port = await devices[0].create();

    bool openResult = await port.open();
    if ( !openResult ) {
      print("Failed to open");
      return;
    }

    await port.setDTR(true);
    await port.setRTS(true);

    port.setPortParameters(115200, UsbPort.DATABITS_8,
        UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

    // print first result and close port.
    port.inputStream.listen((Uint8List event) {
      print(event);
      setState(() {
        tesEvent = event.toString();
        FocusNomorRFID.requestFocus();
      });


        _NomorRFID.clear();
        _NomorRFID.value = TextEditingValue(
          text: event.toString()+' input rfid',
          selection: TextSelection.fromPosition(
            TextPosition(offset: event.toString().length),
          ),
        );

      port.close();
    });

    await port.write(Uint8List.fromList([0x10, 0x00]));


  }

  List<EMoney> emoneys = [];

  // mocking a future that returns List of Objects
  Future<List> fetchComplexData() async {
//    await Future.delayed(Duration(milliseconds: 1000));
    List _list = new List();
    List _jsonList = [];
    for(int i =0; i < emoneys.length; i++){
      print(emoneys[i].NomorSeri);
      _jsonList.add(
        {'label' : emoneys[i].NomorSeri.toString(), 'value': i}
      );
    }
    for(int i = 0; i < _jsonList.length; i++){
      _list.add(new TestItem.fromJson(_jsonList[i]));
    }

//    List _jsonList = [
//      {'label': 'Text' + ' Item 1', 'value': 30},
//      {'label': 'Text' + ' Item 2', 'value': 31},
//      {'label': 'Text' + ' Item 3', 'value': 32},
//    ];
//    _list.add(new TestItem.fromJson(_jsonList[0]));
//    _list.add(new TestItem.fromJson(_jsonList[1]));
//    _list.add(new TestItem.fromJson(_jsonList[2]));

    return _list;
  }

  @override
  Widget build(BuildContext context) {
    // List<String> emoneyList = showEMoneyList(config);
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Form(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
//              SizedBox(height: 16),
//              TextFieldSearch(
//                label: 'Nomor Seri',
//                controller: _searchController,
//                future: () {
//                  return fetchComplexData();
//                },
//                initialList: emoneys.map((e) => e.NomorSeri).toList(),
//                getSelectedValue: (item) {
//                  _requestFocusRFID;
//                  print("item");
//
//                },
//              ),
              TextFieldSearch(
                initialList: emoneys.map((e) => e.NomorSeri).toList(),
                label: "Nomor Seri",
                controller: _searchController,
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(
                  top: 20,
                ),
                child: TextFormField(
                  focusNode: FocusNomorRFID,
                  decoration: InputDecoration(
                    labelText: "Scan E-Money"
                  ),
                  controller: _NomorRFID,
    //                onChanged: (value) {
    ////                  await
    //                  setState(() {
    //                    _NomorRFID.clear();
    //                    _NomorRFID.value = TextEditingValue(
    //                      text: value,
    //                      selection: TextSelection.fromPosition(
    //                        TextPosition(offset: value.toString().length),
    //                      ),
    //                    );
    //                  });
    //                },
                ),
              ),
//               Padding(
//                padding: const EdgeInsets.only(
//                  top: 30,
//                  left: 40,
//                  right: 40,
//                ),
//                child: ElevatedButton(
//                  child: Text('Update'),
//                  onPressed: () => updateRFID(),
//                ),
//              ),
            ],
          ),
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
    if(_NomorRFID.text != "" && _searchController.text != ""){
      if(_NomorRFID.text.length > 10){
        failedToast(context);
      }
      else{
        emoneys = await EMoneyAPIs.updateEMoney(context, _NomorRFID.text, _searchController.text);
        print("ini list : ");
        if(emoneys.length == 0){
          _NomorRFID.text = "";
          // _searchController.text = "";
          successToast(context);
        }
      }
    }
    else{
      failedToast(context);
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
    setState(() {
      FocusNomorRFID.requestFocus();
    });

    if(_NomorRFID.text.length > 0){
      _NomorRFID.clear();
      _NomorRFID.value = TextEditingValue(
        text: hextodec+' input rfid mmm',
        selection: TextSelection.fromPosition(
          TextPosition(offset: hextodec.toString().length),
        ),
      );
    }
    else{
      _NomorRFID.value = TextEditingValue(
        text: hextodec+' input rfid mmm',
        selection: TextSelection.fromPosition(
          TextPosition(offset: hextodec.toString().length),
        ),
      );
    }

//    _NomorRFID.text = hextodec+' input rfid';

//    _NomorRFID.value = TextEditingValue(
//      text: hextodec+' input rfid mmm',
//      selection: TextSelection.fromPosition(
//        TextPosition(offset: hextodec.toString().length),
//      ),
//    );
//     scaffold.showSnackBar(
//       SnackBar(
//         content: Text(msg2+' - '+hextodec+' input rfid'),
//         action: SnackBarAction(
//             label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
//       ),
//     );
  }

  void successToast(BuildContext context){
    _NomorRFID.text = "";
    _searchController.text = "";
    final scaffold = Scaffold.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text('Berhasil Diupdate'),
        action: SnackBarAction(
            label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }
  void failedToast(BuildContext context){
    _NomorRFID.text = "";
//    _searchController.text = "";
    final scaffold = Scaffold.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text('Update Gagal'),
        action: SnackBarAction(
            label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

}

class TestItem {
  String label;
  dynamic value;

  TestItem({this.label, this.value});

  factory TestItem.fromJson(Map<String, dynamic> json) {
    return TestItem(label: json['label'], value: json['value']);
  }
}