
import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'pos_cart_model.g.dart';
part 'pos_cart_model.freezed.dart';


Future<List<Map<String, dynamic>>> posCartModelFromJson(List<PosCartModel> list) async {
  return list.map((item) => item.toJson()).toList();
}

List<dynamic> posCartModelToJsonList(List<PosCartModel> data) {
  return data.map((item) => item.toJson()).toList();
}


@freezed
class PosCartModel  with _$PosCartModel{
  factory PosCartModel({
    String? itemName,
    String? serialNo,
    String? expDate,
    required double realPrice,
    required double rate,
    int? id,
    int? itemId,
    int? fUnitId,
  required  int? unitId,
    int? barcode,
    int? uniqueCode,
    String? code,
    double? stock,
    double? rRate,
    double? gross,
    double? quantity,
    double? fCess,
    double? discount,
     double? discountPercent,
     double? rDiscount,
     double? tax,
     double? taxP,
     double? pRate,
     double? rPRate,
     double? unitValue,
     double? free,
     double? cdPer,
     double? cDisc,
     double? net,
     double? cess,
     double? total,
     double? profitPer,
     double? fUnitValue,
     double? adCess,
     double? iGST,
     double? cGST,
     double? sGST,
     double? minimumRate,
  }) = _PosCartModel;

  factory PosCartModel.fromJson(Map<String, Object?> json) =>
      _$PosCartModelFromJson(json);
}