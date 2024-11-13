class WarrantyCustomerModel {
  int? auto;
  int? entryNo;
  String? wDate;
  int? customer;
  int? location;
  String? mobile;
  int? userId;
  int? warrantyLocation;
  int? salesman;
  int? fyId;
  int? transferStatus;
  String? customerName;

  WarrantyCustomerModel({
    this.auto,
    this.entryNo,
    this.wDate,
    this.customer,
    this.location,
    this.mobile,
    this.userId,
    this.warrantyLocation,
    this.salesman,
    this.fyId,
    this.transferStatus,
    this.customerName,
  });

  Map<String, dynamic> toMap() {
    return {
      'auto': auto,
      'entryNo': entryNo,
      'wDate': wDate,
      'customer': customer,
      'location': location,
      'mobile': mobile,
      'userId': userId,
      'warrantyLocation': warrantyLocation,
      'salesman': salesman,
      'fyId': fyId,
      'transferStatus': transferStatus,
      'customerName': customerName,
    };
  }
}
