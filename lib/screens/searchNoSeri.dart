import 'package:emoney/configuration.dart';
import 'package:emoney/models/EMoneyModel.dart';
import 'package:emoney/sources/EMoneyAPI.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';
import 'package:flutter/services.dart';

class SearchNoSeri extends StatefulWidget {

  @override
  _SearchNoSeriState createState() => _SearchNoSeriState();
}

class _SearchNoSeriState extends State<SearchNoSeri> {
  final _NomorRFID = TextEditingController();
  final _NomorSeri = TextEditingController();

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
  List<EMoney> emoneys = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Padding(
            //   padding: const EdgeInsets.only(
            //     top: 50,
            //     left: 20,
            //     right: 20,
            //   ),
            // //   child: Text('Scan E-Money', style: size,),
            // ),

//            Text('Nomor RFID', textAlign: TextAlign.left),
            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              child: TextFormField(
                controller: _NomorRFID,
                decoration: InputDecoration(
                  hintText: "Scan E-Money..",
                  labelText: "Nomor RFID",
                  suffixIcon: IconButton(
                    onPressed: _NomorRFID.clear,
                    icon: Icon(Icons.clear),
                  ),
                ),
                onChanged: (value) async{
                  await getRequestHistoryList(value);
                },

              ),
            ),

            Padding(
              padding: const EdgeInsets.only(
                top: 40,
                left: 20,
                right: 20,
              ),
              child: TextFormField(
                controller: _NomorSeri,
                enabled: false,
                decoration: InputDecoration(
                  labelText: "Nomor Seri"
                ),
              ),
            ),

          ],
        ),
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _showToast(BuildContext context, String msg) {
//    msg=int.parse(msg, radix:16).toString();
    String hextodec='';
    String msg2=msg[8]+msg[9]+msg[6]+msg[7]+msg[4]+msg[5]+msg[2]+msg[3];
    hextodec=(int.parse(msg2, radix:16)).toString();

    final scaffold = Scaffold.of(context);
    _NomorRFID.text = hextodec;
    getRequestHistoryList(hextodec);
    // scaffold.showSnackBar(
    //   SnackBar(
    //     content: Text(msg2+' - '+hextodec),
    //     action: SnackBarAction(
    //         label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
    //   ),
    // );
  }

  getRequestHistoryList(String rfid) async {
    Configuration config = Configuration.of(context);

    emoneys = await EMoneyAPIs.searchNoSeri(context, rfid);
    print("ini orderlist : ");
    // print(emoneys[0].NomorSeri);
    if(rfid == ""){
      _NomorSeri.clear();
    }else{
      if(emoneys.length == 0){
        _NomorSeri.text = "Tidak ditemukan";
      }else{
        _NomorSeri.text = emoneys[0].NomorSeri;
      }
    }

    setState(() {
      emoneys = emoneys;
    });
  }

}