class UpiModel {
  String upiName;
  String upiId;
  String businessName;

  UpiModel({
    required this.upiName,
    required this.upiId,
    required this.businessName,
  });

  factory UpiModel.fromMap(Map<String, dynamic> json) => UpiModel(
        upiName: json["upiname"],
        upiId: json["upi_id"],
        businessName: json["businessname"],
      );

  Map<String, dynamic> toMap() => {
        "upiname": upiName,
        "upi_id": upiId,
        "businessName": businessName,
      };

  static emptyData() {
    return UpiModel(upiName: '', upiId: '', businessName: '');
  }
}
