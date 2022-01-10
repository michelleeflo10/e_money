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
//    FlutterNfcReader.onTagDiscovered().listen((onData) {
////                          print(onData.id);
////                          print(onData.content);
////                          print(onData.status);
//      _showToast(context, onData.id);
//    });
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
          text: event.toString()+' input rfid mmm',
          selection: TextSelection.fromPosition(
            TextPosition(offset: event.toString().length),
          ),
        );

      port.close();
    });

    await port.write(Uint8List.fromList([0x10, 0x00]));


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
//                searchStyle: TextStyle(
//                  fontSize: 18,
//                  color: Colors.black.withOpacity(0.8),
//                ),
//                searchInputDecoration:
//                InputDecoration(
//                  focusedBorder: OutlineInputBorder(
//                    borderSide: BorderSide(
//                      color: Colors.black.withOpacity(0.8),
//                    ),
//                  ),
//                  border: OutlineInputBorder(
//                    borderSide: BorderSide(color: Colors.red),
//                  ),
//                ),
                suggestions: emoneys.map((e) => e.NomorSeri).toList(),
                controller: _searchController,
                hint: 'Input nomor seri...',
                maxSuggestionsInViewPort: 4,
                itemHeight: 45,
                onTap: (x) {
                  print(x);
                  _NomorRFID.clear();
                  FocusNomorRFID.requestFocus();
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
                focusNode: FocusNomorRFID,
                decoration: InputDecoration(
                  hintText: "Scan E-Money",
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
            ),
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