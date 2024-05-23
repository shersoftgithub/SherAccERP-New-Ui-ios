class StockItem {
  int? id;
  String? name;
  String? code;
  double? quantity;
  bool? hasVariant;

  StockItem({required this.id, required this.name,required this.code, required this.quantity, required this.hasVariant});

  factory StockItem.fromJson(Map<String, dynamic> json) {
    return StockItem(
        id: json['itemId'],
        name: json['itemName'],
        code: json['itemcode'],
        quantity: double.tryParse(json['qty'].toString()),
        hasVariant: json['hasVariant'] == 1 ? true : false);
  }
}
