class SalesDeliveryItem {
  final int itemId;
  final DateTime? dDate;
  final String entryNo;
  final String customer;
  final String itemname;
  final DateTime? deliveryDate;
  final double qty;
  final dynamic photo;
  final int? salesType;
  final String? remark;

  SalesDeliveryItem({
    required this.itemId,
    this.dDate,
    required this.entryNo,
    required this.customer,
    required this.itemname,
    this.deliveryDate,
    required this.qty,
    this.photo,
    this.salesType,
    this.remark,
  });

   factory SalesDeliveryItem.empty() {
    return SalesDeliveryItem(
      itemId: 0,
      entryNo: '',
      customer: '',
      itemname: '',
      qty: 0.0,
    );
  }

  factory SalesDeliveryItem.fromJson(Map<String, dynamic> json) {
    // Parse DDate
    DateTime? parseDDate() {
      if (json['DDate'] == null) return null;
      try {
        if (json['DDate'] is String) {
          return DateTime.tryParse(json['DDate']);
        } else if (json['DDate'] is DateTime) {
          return json['DDate'] as DateTime;
        }
      } catch (e) {
        return null;
      }
      return null;
    }

    // Parse DeliveryDate
    DateTime? parseDeliveryDate() {
      if (json['DeliveryDate'] == null) return null;
      try {
        if (json['DeliveryDate'] is String) {
          return DateTime.tryParse(json['DeliveryDate']);
        } else if (json['DeliveryDate'] is DateTime) {
          return json['DeliveryDate'] as DateTime;
        }
      } catch (e) {
        return null;
      }
      return null;
    }

    return SalesDeliveryItem(
      itemId: (json['ItemID'] as num).toInt(),
      dDate: parseDDate(),
      entryNo: json['EntryNo']?.toString() ?? '',
      customer: json['Customer']?.toString() ?? '',
      itemname: json['itemname']?.toString() ?? '',
      deliveryDate: parseDeliveryDate(),
      qty: (json['qty'] as num?)?.toDouble() ?? 0.0,
      photo: json['photo'],
      salesType: (json['SalesType'] as num?)?.toInt(),
      remark: json['Remark']?.toString() ?? '',
    );
  }
}