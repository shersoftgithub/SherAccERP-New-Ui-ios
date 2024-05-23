class StatementItem {
  int? id;
  String? party;
  String? debit;
  String? credit;

  StatementItem({required this.id, required this.party, required this.debit, required this.credit});

  Map<String, dynamic> toJson() =>
      {"id": id, "PARTY": party, "DEBIT": debit, "CREDIT": credit};

  StatementItem.fromJson(Map<String, dynamic> json) {
    id = 0; //id
    party = json['Party'].toString();
    debit = json['Debit'].toString();
    credit = json['Credit'].toString();
  }
}
