import 'dart:convert';

class SalesType {
  int id;
  String name, type, rateType, sColor;
  int location;
  bool stock, accounts, tax, eInvoice;

  SalesType(
      {required this.id,
      required this.name,
      required this.type,
      required this.rateType,
      required this.stock,
      required this.accounts,
      required this.location,
      required this.sColor,
      required this.tax,
      required this.eInvoice});

  factory SalesType.fromJson(Map<String, dynamic> json) {
    return SalesType(
        id: json['iD'],
        name: json['Name'],
        type: json['Type'],
        rateType: json['RateType'],
        stock: json['Stock'] == 1 ? true : false,
        accounts: json['Accounts'] == 1 ? true : false,
        location: json['Location'],
        sColor: json['Scolor'],
        tax: json['Tax'] == 1 ? true : false,
        eInvoice: json['EInvoice'] == 1 ? true : false);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sType': type,
      'rateType': rateType,
      'stock': stock,
      'accounts': accounts,
      'location': location,
      'sColor': sColor,
      'tax': tax,
      'eInvoice': eInvoice
    };
  }

  String toJson() => json.encode(toMap());
}

SalesType? salesTypeData;
bool taxable = false;
