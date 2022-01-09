// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'EMoneyModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EMoney _$EMoneyFromJson(Map<String, dynamic> json) {
  return EMoney(
    NomorSeri: json['NomorSeri'] as String,
    NomorRFID: json['NomorRFID'] as String,
    KodeCabang: json['KodeCabang'] as String,
  );
}

Map<String, dynamic> _$EMoneyToJson(EMoney instance) => <String, dynamic>{
      'NomorSeri': instance.NomorSeri,
      'NomorRFID': instance.NomorRFID,
      'KodeCabang': instance.KodeCabang,
    };
