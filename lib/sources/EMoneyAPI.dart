import 'dart:convert';

import 'package:emoney/configuration.dart';
import 'package:emoney/models/EMoneyModel.dart';
import 'package:emoney/models/result.dart';
import 'package:http/http.dart' show Client;

class EMoneyAPI {
  Client client = Client( );
  Future<List<EMoney>> getOrderList(final context) async {
    Result result;
    List<EMoney> emoneys = [];
    EMoney emoney;
    String url_address;

    url_address = config.baseUrl + "/" + "getNoSeri.php";

    String getLimitRequestHistorySuccess = "";
//    String url = "";

    if(url_address != ""){
      try {
        final response = await client.get(url_address);

        print("status code "+response.statusCode.toString());
        print("cek body "+response.body);

        var parsedJson = jsonDecode(response.body);

        if(response.body.toString() != "false") {
          print("masuk sini 1");

          result = new Result(success: 1, message: "OK", data: parsedJson);

          result.data.map((item) {
            emoneys.add(EMoney.fromJson(item));
          }).toList();

          print("cek list length "+ emoneys.length.toString());

        } else {
          getLimitRequestHistorySuccess = "Data tidak ditemukan";
          result = new Result(success: 0, message: "Data tidak ditemukan");
        }

      } catch (e) {
        getLimitRequestHistorySuccess = "Gagal terhubung dengan server";
        result = new Result(success: -1, message: "Gagal terhubung dengan server");
        print(e);
      }

    } else {
      getLimitRequestHistorySuccess = "Gagal terhubung dengan server";
      result = new Result(success: -1, message: "Gagal terhubung dengan server");
    }

    return emoneys;
  }


  Future<List<EMoney>> updateEMoney(final context, String rfid, String seri) async {
    Result result;
    List<EMoney> emoneys = [];
    String status;
    EMoney emoney;
    String url_address, seri2, rfid2;
    seri2 = Uri.encodeComponent(seri);
    rfid2 = Uri.encodeQueryComponent(rfid);
    url_address = config.baseUrl + "/" + "updateRFID.php/?NomorSeri="+seri2+"&NomorRFID="+rfid2+"";
    print(url_address);

    String getLimitRequestHistorySuccess = "";
//    String url = "";

    if(url_address != ""){
      try {
        final response = await client.get(url_address);

        print("status code "+response.statusCode.toString());
        print("cek body "+response.body);

        // var parsedJson = jsonDecode(response.body.toString().replaceAll("\n",""));
        // print(parsedJson);

        if(response.body.toString() != "false") {
          print("masuk sini");


          // result = new Result(success: 1, message: "OK", data: parsedJson);

          // result.data.map((item) {
          //   emoneys.add(EMoney.fromJson(item));
          // }).toList();

          // print("cek list length "+ emoneys.length.toString());

        } else {
          getLimitRequestHistorySuccess = "Data tidak ditemukan";
          result = new Result(success: 0, message: "Data tidak ditemukan");
        }

      } catch (e) {
        getLimitRequestHistorySuccess = "Gagal terhubung dengan server";
        result = new Result(success: -1, message: "Gagal terhubung dengan server");
        print(e);
      }

    } else {
      getLimitRequestHistorySuccess = "Gagal terhubung dengan server";
      result = new Result(success: -1, message: "Gagal terhubung dengan server");
    }

    return emoneys;
  }

  Future<List<EMoney>> searchNoSeri(final context, String rfid) async {
    Result result;
    List<EMoney> emoneys = [];
    EMoney emoney;
    String url_address;

    url_address = config.baseUrl + "/" + "searchNoSeri.php/?&NomorRFID="+rfid+"";

    String getLimitRequestHistorySuccess = "";
//    String url = "";

    if(url_address != ""){
      try {
        final response = await client.get(url_address);

        print("status code "+response.statusCode.toString());
        print("cek body "+response.body);

        var parsedJson = jsonDecode(response.body);

        if(response.body.toString() != "false") {
          print("masuk sini 1");

          result = new Result(success: 1, message: "OK", data: parsedJson);

          result.data.map((item) {
            emoneys.add(EMoney.fromJson(item));
          }).toList();

          print("cek list length "+ emoneys.length.toString());

        } else {
          getLimitRequestHistorySuccess = "Data tidak ditemukan";
          result = new Result(success: 0, message: "Data tidak ditemukan");
        }

      } catch (e) {
        getLimitRequestHistorySuccess = "Gagal terhubung dengan server";
        result = new Result(success: -1, message: "Gagal terhubung dengan server");
        print(e);
      }

    } else {
      getLimitRequestHistorySuccess = "Gagal terhubung dengan server";
      result = new Result(success: -1, message: "Gagal terhubung dengan server");
    }

    return emoneys;
  }
}

final EMoneyAPIs = EMoneyAPI();