class WarrantyRepalceModel{
  int? entryNo;
  String? wDate;
  int? auto;
  int? barcode;
  int? itemId;
  String? serialNo;
  int? qty;
  int? sRate;
  int? total;
  String? narration;
  String? eType;
  String? status;
  int? gid;
  int? location;
  String? warrantyDate;
  int? fyId;
  int? transferStatus;
  String? productName;
    
    WarrantyRepalceModel({
      this.entryNo,
      this.wDate,
      this.auto,
      this.barcode,
      this.itemId,
      this.serialNo,
      this.qty,
      this.sRate,
      this.total,
      this.narration,
      this.eType,
      this.status,
      this.gid,
      this.location,
      this.warrantyDate,
      this.fyId,
      this.transferStatus,
      this.productName
    });
     Map<String, dynamic> toMap() {
    return {
      'entryNo': entryNo,
      'wDate': wDate,
      'auto':auto,
      'barcode':barcode,
      'itemId':itemId,
      'serialNo':serialNo,
      'qty':qty,
      'sRate':sRate,
      'total':total,
      'narration':narration,
      'eType':eType,
      'status':status,
      'gid':gid,
      'location':location,
      'warrantyDate':warrantyDate,
      'fyId':fyId,
      'transferStatus':transferStatus,
      'productName':productName
    };
  }
}