class SalesModel {
  bool ?success;
  List<ParticularsModel> ?particulars;
  List<InformationModel>? information;
  List<SerialNOModel>? serialNo;
  List<DeliveryNoteModel>? deliveryNote;
  String? footerMessage;

  SalesModel(
      {required this.success,
      required this.information,
      required this.particulars,
      required this.serialNo,
      required this.deliveryNote,
      required this.footerMessage});

  SalesModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (success!) {
      information = <InformationModel>[];
      json['Information'].forEach((v) {
        information!.add(InformationModel.fromJson(v));
      });
      particulars = <ParticularsModel>[];
      json['Particulars'].forEach((v) {
        particulars!.add(ParticularsModel.fromJson(v));
      });
      serialNo = <SerialNOModel>[];
      json['SerialNO'].forEach((v) {
        serialNo!.add(SerialNOModel.fromJson(v));
      });
      deliveryNote = <DeliveryNoteModel>[];
      json['DeliveryNote'].forEach((v) {
        deliveryNote!.add(DeliveryNoteModel.fromJson(v));
      });
    }
    footerMessage = json['message'];
  }
}

class InformationModel {
  int ?RealEntryNo;
  var EntryNo;
  var InvoiceNo;
  var DDate;
  var BTime;
  var Customer;
  var Add1;
  var Add2;
  var Toname;
  var TaxType;
  var GrossValue;
  var Discount;
  var NetAmount;
  var cess;
  var Total;
  var loadingcharge;
  var OtherCharges;
  var OtherDiscount;
  var Roundoff;
  var GrandTotal;
  var SalesAccount;
  var SalesMan;
  var Location;
  var Narration;
  var Profit;
  var CashReceived;
  var BalanceAmount;
  var Ecommision;
  var labourCharge;
  var OtherAmount;
  var Type;
  var PrintStatus;
  var CNo;
  var CreditPeriod;
  var DiscPercent;
  var SType;
  var VatEntryNo;
  var tcommision;
  var commisiontype;
  var cardno;
  var takeuser;
  var PurchaseOrderNo;
  var ddate1;
  var deliverNoteNo;
  var despatchno;
  var despatchdate;
  var Transport;
  var Destination;
  var Transfer_Status;
  var TenderCash;
  var TenderBalance;
  var returnno;
  var returnamt;
  var vatentryname;
  var otherdisc1;
  var salesorderno;
  var systemno;
  var deliverydate;
  var QtyDiscount;
  var ScheemDiscount;
  var Add3;
  var Add4;
  var BankName;
  var CCardNo;
  var SMInvoice;
  var Bankcharges;
  var CGST;
  var SGST;
  var IGST;
  var mrptotal;
  var adcess;
  var BillType;
  var discuntamount;
  var unitprice;
  var lrno;
  var evehicleno;
  var ewaybillno;
  var RDisc;
  var subsidy;
  var kms;
  var todevice;
  var Fcess;
  var spercent;
  var bankamount;
  var FcessType;
  var receiptAmount;
  var receiptDate;
  var JobCardno;

  InformationModel(
      {required this.RealEntryNo,
      this.EntryNo,
      this.InvoiceNo,
      this.DDate,
      this.BTime,
      this.Customer,
      this.Add1,
      this.Add2,
      this.Toname,
      this.TaxType,
      this.GrossValue,
      this.Discount,
      this.NetAmount,
      this.cess,
      this.Total,
      this.loadingcharge,
      this.OtherCharges,
      this.OtherDiscount,
      this.Roundoff,
      this.GrandTotal,
      this.SalesAccount,
      this.SalesMan,
      this.Location,
      this.Narration,
      this.Profit,
      this.CashReceived,
      this.BalanceAmount,
      this.Ecommision,
      this.labourCharge,
      this.OtherAmount,
      this.Type,
      this.PrintStatus,
      this.CNo,
      this.CreditPeriod,
      this.DiscPercent,
      this.SType,
      this.VatEntryNo,
      this.tcommision,
      this.commisiontype,
      this.cardno,
      this.takeuser,
      this.PurchaseOrderNo,
      this.ddate1,
      this.deliverNoteNo,
      this.despatchno,
      this.despatchdate,
      this.Transport,
      this.Destination,
      this.Transfer_Status,
      this.TenderCash,
      this.TenderBalance,
      this.returnno,
      this.returnamt,
      this.vatentryname,
      this.otherdisc1,
      this.salesorderno,
      this.systemno,
      this.deliverydate,
      this.QtyDiscount,
      this.ScheemDiscount,
      this.Add3,
      this.Add4,
      this.BankName,
      this.CCardNo,
      this.SMInvoice,
      this.Bankcharges,
      this.CGST,
      this.SGST,
      this.IGST,
      this.mrptotal,
      this.adcess,
      this.BillType,
      this.discuntamount,
      this.unitprice,
      this.lrno,
      this.evehicleno,
      this.ewaybillno,
      this.RDisc,
      this.subsidy,
      this.kms,
      this.todevice,
      this.Fcess,
      this.spercent,
      this.bankamount,
      this.FcessType,
      this.receiptAmount,
      this.receiptDate,
      this.JobCardno});
  InformationModel.fromJson(Map<String, dynamic> json);
}

class ParticularsModel {
  // ParticularsModel(
  // {var dDate,
  // var entryNo,
  // var uniqueCode,
  // var itemID,
  // var serialno,
  // var rate,
  // var realRate,
  // var qty,
  // var freeQty,
  // var grossValue,
  // var discPersent,
  // var disc,
  // var rDisc,
  // var net,
  // var vat,
  // var freeVat,
  // var cess,
  // var total,
  // var profit,
  //  int auto,
  // var unit,
  // var unitValue,
  // var funit,
  // var fValue,
  // var commision,
  // var gridID,
  // var takeprintstatus,
  // var qtyDiscPercent,
  // var qtyDiscount,
  // var scheemDiscPercent,
  // var scheemDiscount,
  // var cGST,
  // var sGST,
  // var iGST,
  // var adCess,
  // var netDisc,
  // var taxRate,
  // var salesmanId,
  // var fCess,
  // var prate,
  // var rPrate,
  // var location,
  // var sType});
  /*Particulars": [
    {
      "slno": "1",
      "itemname": "product 1",
      "itemId": 6,
      "UniqueCode": 6,
      "RealRate": 8.05,
      "Qty": 2,
      "Rate": 9.5,
      "Net": 16.1,
      "igst": 18,
      "CGST": 1.45,
      "SGST": 1.45,
      "IGST": 0,
      "Total": 19,
      "Unit": -1,
      "unitName": "",
      "freeQty": 0,
      "Funit": -1,
      "GrossValue": 16.1,
      "cess": 0,
      "FValue": 0,
      "adcess": 0,
      "Disc": 0,
      "RDisc": 0,
      "Fcess": 0,
      "serialno": "",
      "DiscPersent": 0,
      "UnitValue": 1,
      "Prate": 7.76,
      "Rprate": 0
    }
  ],*/

  int slno;
  String itemname;
  int itemId;
  int uniqueCode;
  double realRate;
  double qty;
  double rate;
  double net;
  double taxP;
  double cGST;
  double sGST;
  double iGST;
  double total;
  int unit;
  String unitName;
  double freeQty;
  int funit;
  double grossValue;
  double cess;
  double fValue;
  double adcess;
  double disc;
  double rDisc;
  double fcess;
  String serialno;
  double discPersent;
  double unitValue;
  double pRate;
  double rPrate;
  ParticularsModel({
    required this.slno,
    required this.itemname,
    required this.itemId,
    required this.uniqueCode,
    required this.realRate,
    required this.qty,
    required this.rate,
    required this.net,
    required this.taxP,
    required this.cGST,
    required this.sGST,
    required this.iGST,
    required this.total,
    required this.unit,
    required this.unitName,
    required this.freeQty,
    required this.funit,
    required this.grossValue,
    required this.cess,
    required this.fValue,
    required this.adcess,
    required this.disc,
    required this.rDisc,
    required this.fcess,
    required this.serialno,
    required this.discPersent,
    required this.unitValue,
    required this.pRate,
    required this.rPrate,
  });

  factory ParticularsModel.fromJson(Map<String, dynamic> json) =>
      ParticularsModel(
          slno: int.tryParse(json['slno'].toString()) ?? 0,
          itemname: json['itemname'] ?? '',
          itemId: json['itemId'] ?? 0,
          uniqueCode: json['UniqueCode'] ?? 0,
          realRate: double.tryParse(json['RealRate'].toString()) ?? 0,
          qty: double.tryParse(json['Qty'].toString()) ?? 0,
          rate: double.tryParse(json['Rate'].toString()) ?? 0,
          net: double.tryParse(json['Net'].toString()) ?? 0,
          taxP: double.tryParse(json['igst'].toString()) ?? 0,
          cGST: double.tryParse(json['CGST'].toString()) ?? 0,
          sGST: double.tryParse(json['SGST'].toString()) ?? 0,
          iGST: double.tryParse(json['IGST'].toString()) ?? 0,
          total: double.tryParse(json['Total'].toString()) ?? 0,
          unit: json['Unit'] ?? 0,
          unitName: json['unitName'] ?? '',
          freeQty: double.tryParse(json['freeQty'].toString()) ?? 0,
          funit: json['Funit'] ?? 0,
          grossValue: double.tryParse(json['GrossValue'].toString()) ?? 0,
          cess: double.tryParse(json['cess'].toString()) ?? 0,
          fValue: double.tryParse(json['FValue'].toString()) ?? 0,
          adcess: double.tryParse(json['adcess'].toString()) ?? 0,
          disc: double.tryParse(json['Disc'].toString()) ?? 0,
          rDisc: double.tryParse(json['RDisc'].toString()) ?? 0,
          fcess: double.tryParse(json['Fcess'].toString()) ?? 0,
          serialno: json['serialno'] ?? '',
          discPersent: double.tryParse(json['DiscPersent'].toString()) ?? 0,
          unitValue: double.tryParse(json['UnitValue'].toString()) ?? 0,
          pRate: double.tryParse(json['Prate'].toString()) ?? 0,
          rPrate: double.tryParse(json['Rprate'].toString()) ?? 0);

  static List<ParticularsModel> fromJsonList(List list) {
    return list.map((item) => ParticularsModel.fromJson(item)).toList();
  }
}

class SerialNOModel {
  int? slNo;
  int ?entryNo;
  int? itemName;
  String ?serialNo;
  int? gId;
  String ?tType;
  int ?uniqueCode;

  SerialNOModel(
      {required this.slNo,
      required this.entryNo,
      required this.itemName,
      required this.serialNo,
      required this.gId,
      required this.tType,
      required this.uniqueCode});

  SerialNOModel.fromJson(Map<String, dynamic> json) {
    slNo = json['slno'];
    entryNo = json['EntryNo'];
    itemName = json['itemname'];
    serialNo = json['SerialNO'];
    gId = json['Gid'];
    tType = json['Type'];
    uniqueCode = json['Uniquecode'];
  }

  factory SerialNOModel.fromMap(Map<String, dynamic> json) => SerialNOModel(
        slNo: json['slno'],
        entryNo: json['EntryNo'],
        itemName: json['itemname'],
        serialNo: json['SerialNo'],
        gId: json['Gid'],
        tType: json['Type'],
        uniqueCode: json['UniqueCode'],
      );

  Map<String, dynamic> toMap() => {
        "slNo": slNo,
        "entryNo": entryNo,
        "itemName": itemName,
        "serialNo": serialNo,
        "gId": gId,
        "tType": tType,
        "uniqueCode": uniqueCode
      };

  static List encodedToJson(List<SerialNOModel> list) {
    List jsonList = [];
    list.map((item) => jsonList.add(item.toMap())).toList();
    return jsonList;
  }

  static List<SerialNOModel> fromJsonList(List list) {
    return list.map((item) => SerialNOModel.fromJson(item)).toList();
  }

  static List<SerialNOModel> fromJsonListDynamic(List<dynamic> list) {
    return list.map((item) => SerialNOModel.fromJsonMap(item)).toList();
  }

  factory SerialNOModel.fromJsonMap(Map<String, dynamic> map) =>
      SerialNOModel.fromMap(map);

  static emptyData() {
    return SerialNOModel(
        entryNo: 0,
        gId: 0,
        itemName: 0,
        serialNo: '',
        slNo: 0,
        tType: '',
        uniqueCode: 0);
  }
}

class DeliveryNoteModel {
  int? auto;
  var EntryNo;
  var name;
  var address;
  var add1;
  var add2;
  var gstno;
  var state;
  var statecode;
  var stype;
  DeliveryNoteModel({
    required this.auto,
    required this.EntryNo,
    required this.name,
    required this.address,
    required this.add1,
    required this.add2,
    required this.gstno,
    required this.state,
    required this.statecode,
    required this.stype,
  });

  DeliveryNoteModel.fromJson(Map<String, dynamic> json) {
    auto = json['auto'];
    EntryNo = json['EntryNo'];
    name = json['name'];
    address = json['address'];
    add1 = json['add1'];
    add2 = json['add2'];
    gstno = json['gstno'];
    state = json['state'];
    statecode = json['statecode'];
    stype = json['stype'];
  }

  factory DeliveryNoteModel.fromMap(Map<String, dynamic> json) =>
      DeliveryNoteModel(
        auto: json['auto'],
        EntryNo: json['EntryNo'],
        name: json['name'],
        address: json['address'],
        add1: json['add1'],
        add2: json['add2'],
        gstno: json['gstno'],
        state: json['state'],
        statecode: json['statecode'],
        stype: json['stype'],
      );

  Map<String, dynamic> toMap() => {
        "auto": auto,
        "EntryNo": EntryNo,
        "name": name,
        "address": address,
        "add1": add1,
        "add2": add2,
        "gstno": gstno,
        "state": state,
        "statecode": statecode,
        "stype": stype,
      };

  static List<DeliveryNoteModel> fromJsonList(List list) {
    return list.map((item) => DeliveryNoteModel.fromJson(item)).toList();
  }

  static List<DeliveryNoteModel> fromJsonListDynamic(List<dynamic> list) {
    return list.map((item) => DeliveryNoteModel.fromJsonMap(item)).toList();
  }

  factory DeliveryNoteModel.fromJsonMap(Map<String, dynamic> map) =>
      DeliveryNoteModel.fromMap(map);
}

class OtherAmount {
  int ledCode;
  String symbol;
  double percentage;
  double amount;
  String ledName;

  OtherAmount({
    required this.ledCode,
    required this.symbol,
    required this.percentage,
    required this.amount,
    required this.ledName,
  });

  factory OtherAmount.fromJson(Map<String, dynamic> json) => OtherAmount(
      ledCode: json["LedCode"] ?? 0,
      symbol: json["Symbol"] ?? '',
      percentage: double.tryParse(json["Percentage"].toString()) ?? 0,
      amount: double.tryParse(json["Amount"].toString()) ?? 0,
      ledName: json["LedName"] ?? '');

  factory OtherAmount.fromMap(Map<String, dynamic> json) => OtherAmount(
        ledCode: json["LedCode"],
        symbol: json["Symbol"],
        ledName: json["LedName"],
        amount: json["Amount"],
        percentage: json["Percentage"],
      );

  Map<String, dynamic> toMap() => {
        "LedCode": ledCode,
        "Symbol": symbol,
        "LedName": ledName,
        "Amount": amount,
        "Percentage": percentage,
      };

  static List<OtherAmount> fromJsonList(List list) {
    return list.map((item) => OtherAmount.fromJson(item)).toList();
  }

  static List<OtherAmount> fromJsonListDynamic(List<dynamic> list) {
    return list.map((item) => OtherAmount.fromJson(item)).toList();
  }

  factory OtherAmount.fromJsonMap(Map<String, dynamic> map) =>
      OtherAmount.fromMap(map);
}
