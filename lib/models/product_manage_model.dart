import 'dart:convert';

class ProductManageModel {
  ProductManageModel({
    required this.itemId,
    required this.prate,
    required this.realPrate,
    required this.mrp,
    required this.retail,
    required this.spretail,
    required this.wSrate,
    required this.branch,
    required this.location,
    required this.uniquecode,
    required this.obarcode,
    required this.rackId,
  });

  int itemId;
  double prate;
  double realPrate;
  double mrp;
  double retail;
  double spretail;
  double wSrate;
  double branch;
  int location;
  int uniquecode;
  String obarcode;
  int rackId ;

  factory ProductManageModel.fromJson(String str) =>
      ProductManageModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ProductManageModel.fromMap(Map<String, dynamic> json) =>
      ProductManageModel(
        itemId: json["ItemId"],
        prate: json["prate"]?.toDouble(),
        realPrate: json["RealPrate"]?.toDouble(),
        mrp: json["mrp"]?.toDouble(),
        retail: json["retail"]?.toDouble(),
        spretail: json["Spretail"]?.toDouble(),
        wSrate: json["WSrate"]?.toDouble(),
        branch: json["Branch"]?.toDouble(),
        location: json["location"],
        uniquecode: json["uniquecode"],
        obarcode: json["obarcode"],
        rackId: json["rack_id"]?? 0,
      );

  Map<String, dynamic> toMap() => {
        "ItemId": itemId,
        "prate": prate,
        "RealPrate": realPrate,
        "mrp": mrp,
        "retail": retail,
        "Spretail": spretail,
        "WSrate": wSrate,
        "Branch": branch,
        "location": location,
        "uniquecode": uniquecode,
        "obarcode": obarcode,
        "rack_id": rackId,
      };
}
