import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'EMoneyModel.g.dart';

@JsonSerializable()
class EMoney {
  String NomorSeri;
  String NomorRFID;
  String KodeCabang;

  EMoney({
    this.NomorSeri,
    this.NomorRFID,
    this.KodeCabang
  });

  factory EMoney.fromJson(Map<String, dynamic> parsedJson) =>
      _$EMoneyFromJson(parsedJson);

  Map<String, dynamic> toJson() => _$EMoneyToJson(this);
}
