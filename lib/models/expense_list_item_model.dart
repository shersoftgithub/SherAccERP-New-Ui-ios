
class ExpenseListItemModel {
  final int? id;
  final String eno, party, amount;

  ExpenseListItemModel({required this.id, required this.eno, required this.party, required this.amount});

  Map<String, dynamic> toJson() =>
      {"id": id, "Inv": eno, "Party": party, "Amount": amount};

  factory ExpenseListItemModel.fromJson(Map<String, dynamic> json) {
    return ExpenseListItemModel(
        id: int.tryParse(json['SlNo']),
        eno: json['SlNo'],
        party: json['LedName'].toString(),
        amount: json['Debit'].toString());
  }

  static ExpenseListItemModel emptyData() {
    return ExpenseListItemModel(
        id: 0,
        eno: '0',
        party: '',
        amount: '0');
  }
}
