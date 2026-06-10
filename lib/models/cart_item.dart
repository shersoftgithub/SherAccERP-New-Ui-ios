import 'package:sheraccerp/models/stock_product.dart';

class CartItem {
  String itemName, serialNo, expDate;
  double quantity,
      stock,
      rate,
      rRate,
      gross,
      fCess,
      discount,
      discountPercent,
      rDiscount,
      tax,
      taxP,
      pRate,
      rPRate,
      unitValue,
      free,
      cdPer,
      cDisc,
      net,
      cess,
      total,
      profitPer,
      fUnitValue,
      adCess,
      iGST,
      cGST,
      sGST,
      minimumRate,
      cessPer,
      adCessPer;
  int id, itemId, fUnitId, unitId, barcode, uniqueCode;
  String? remark,scBarcode;
  List<String>? colorN;

  // Fields added from StockProduct
  String? hsnCode, taxType, oBarcode, locked;
  double? buyingPrice,
      sellingPrice,
      buyingPriceReal,
      retailPrice,
      wholeSalePrice,
      spRetailPrice;
  int? branch, size, supplierId, locationId, categoryId, mfrId, subcategoryId, rackId, brand, company, color;

  CartItem(
      {required this.id,
      required this.itemId,
      required this.itemName,
      required this.serialNo,
      required this.uniqueCode,
      required this.fCess,
      required this.unitId,
      required this.quantity,
      required this.rate,
      required this.rRate,
      required this.gross,
      required this.discount,
      required this.discountPercent,
      required this.rDiscount,
      required this.tax,
      required this.taxP,
      required this.unitValue,
      required this.pRate,
      required this.rPRate,
      required this.barcode,
      required this.expDate,
      required this.free,
      required this.fUnitId,
      required this.cdPer,
      required this.cDisc,
      required this.net,
      required this.cess,
      required this.total,
      required this.profitPer,
      required this.fUnitValue,
      required this.adCess,
      required this.iGST,
      required this.cGST,
      required this.sGST,
      required this.stock,
      required this.minimumRate,
      required this.cessPer,
      required this.adCessPer,
      this.hsnCode,
      this.taxType,
      this.oBarcode,
      this.locked,
      this.buyingPrice,
      this.sellingPrice,
      this.buyingPriceReal,
      this.retailPrice,
      this.wholeSalePrice,
      this.spRetailPrice,
      this.branch,
      this.size,
      this.supplierId,
      this.locationId,
      this.categoryId,
      this.mfrId,
      this.subcategoryId,
      this.rackId,
      this.brand,
      this.company,
      this.color,
      this.remark,
      this.scBarcode,
      this.colorN,
      });

  Map<String, dynamic> toCartJson() {
    return {
      'id': id,
      'itemId': itemId,
      'itemName': itemName,
      'serialNo': serialNo,
      'uniqueCode': uniqueCode,
      'fCess': fCess,
      'unit': unitId,
      'quantity': quantity,
      'rate': rate,
      'rRate': rRate,
      'gross': gross,
      'discount': discount,
      'discountPercent': discountPercent,
      'rDiscount': rDiscount,
      'tax': tax,
      'taxP': taxP,
      'unitValue': unitValue,
      'pRate': pRate,
      'rPRate': rPRate,
      'barcode': barcode,
      'expDate': expDate,
      'free': free,
      'fUnitId': fUnitId,
      'cdPer': cdPer,
      'cDisc': cDisc,
      'net': net,
      'cess': cess,
      'total': total,
      'profitPer': profitPer,
      'fUnitValue': fUnitValue,
      'adCess': adCess,
      'iGST': iGST,
      'cGST': cGST,
      'sGST': sGST,
      'stock': stock,
      'minimumRate': minimumRate,
      'cessPer': cessPer,
      'adCessPer': adCessPer,
      'hsnCode': hsnCode,
      'taxType': taxType,
      'oBarcode': oBarcode,
      'locked': locked,
      'buyingPrice': buyingPrice,
      'sellingPrice': sellingPrice,
      'buyingPriceReal': buyingPriceReal,
      'retailPrice': retailPrice,
      'wholeSalePrice': wholeSalePrice,
      'spRetailPrice': spRetailPrice,
      'branch': branch,
      'size': size,
      'supplierId': supplierId,
      'locationId': locationId,
      'categoryId': categoryId,
      'mfrId': mfrId,
      'subcategoryId': subcategoryId,
      'rackId': rackId,
      'brand': brand,
      'company': company,
      'color': color,
      'remark': remark,
      'scBarcode':scBarcode
    };
  }

  static List encodeCartToJson(List<CartItem> list) {
    List jsonList = [];
    list.map((item) => jsonList.add(item.toCartJson())).toList();
    return jsonList;
  }

  Map toCartMap() {
    var map = {};
    map["id"] = id;
    map['itemId'] = itemId;
    map["itemName"] = itemName;
    map["serialNo"] = serialNo;
    map["uniqueCode"] = uniqueCode;
    map["fCess"] = fCess;
    map["unit"] = unitId;
    map["quantity"] = quantity;
    map["rate"] = rate;
    map['rRate'] = rRate;
    map["gross"] = gross;
    map["discount"] = discount;
    map["discountPercent"] = discountPercent;
    map["rDiscount"] = rDiscount;
    map["tax"] = tax;
    map["taxP"] = taxP;
    map["unitValue"] = unitValue;
    map["pRate"] = pRate;
    map['rPRate'] = rPRate;
    map['barcode'] = barcode;
    map['expDate'] = expDate;
    map['free'] = free;
    map['fUnitId'] = fUnitId;
    map['cdPer'] = cdPer;
    map['cDisc'] = cDisc;
    map['net'] = net;
    map['cess'] = cess;
    map['total'] = total;
    map['profitPer'] = profitPer;
    map['fUnitValue'] = fUnitValue;
    map['adCess'] = adCess;
    map['iGST'] = iGST;
    map['cGST'] = cGST;
    map['sGST'] = sGST;
    map['stock'] = stock;
    map['minimumRate'] = minimumRate;
    map['cessPer'] = cessPer;
    map['adCessPer'] = adCessPer;
    map['hsnCode'] = hsnCode;
    map['taxType'] = taxType;
    map['oBarcode'] = oBarcode;
    map['locked'] = locked;
    map['buyingPrice'] = buyingPrice;
    map['sellingPrice'] = sellingPrice;
    map['buyingPriceReal'] = buyingPriceReal;
    map['retailPrice'] = retailPrice;
    map['wholeSalePrice'] = wholeSalePrice;
    map['spRetailPrice'] = spRetailPrice;
    map['branch'] = branch;
    map['size'] = size;
    map['supplierId'] = supplierId;
    map['locationId'] = locationId;
    map['categoryId'] = categoryId;
    map['mfrId'] = mfrId;
    map['subcategoryId'] = subcategoryId;
    map['rackId'] = rackId;
    map['brand'] = brand;
    map['company'] = company;
    map['color'] = color;
    map['remark'] = remark;
    map['scBarcode'] = scBarcode;
    return map;
  }
   CartItem copyWith({
   String? itemName,
    serialNo, expDate,
  double? quantity,
      stock,
      rate,
      rRate,
      gross,
      fCess,
      discount,
      discountPercent,
      rDiscount,
      tax,
      taxP,
      pRate,
      rPRate,
      unitValue,
      free,
      cdPer,
      cDisc,
      net,
      cess,
      total,
      profitPer,
      fUnitValue,
      adCess,
      iGST,
      cGST,
      sGST,
      minimumRate,
      cessPer,
      adCessPer,
  int? id, itemId, fUnitId, unitId, barcode, uniqueCode,color,
  String? remark,scBarcode,
  List<String>?  colorN,

  }) {
    return CartItem(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      rate: rate ?? this.rate,
      uniqueCode: uniqueCode ?? this.uniqueCode,
      serialNo: serialNo ?? this.serialNo,
      fCess: fCess ?? this.fCess,
      unitId: unitId ?? this.unitId,
      rRate: rRate ?? this.rRate,
      gross: gross ?? this.gross,
      discount: discount ?? this.discount,
      discountPercent: discountPercent ?? this.discountPercent,
      rDiscount: rDiscount ?? this.rDiscount,
      tax: tax ?? this.tax,
      taxP: taxP ?? this.taxP,
      unitValue: unitValue ?? this.unitValue,
      pRate: profitPer ?? this.pRate,
      rPRate: rPRate ?? this.rPRate,
      barcode: barcode ?? this.barcode,
      expDate: expDate ?? this.expDate,
      free: free ?? this.free,
      fUnitId: fUnitId ?? this.fUnitId,
      cdPer: cdPer ?? this.cdPer,
      cDisc: cDisc ?? this.cDisc,
      net: net ?? this.net,
      cess: cess ?? this.cess,
      total: total ?? this.total,
      profitPer: profitPer ?? this.profitPer,
      fUnitValue: fUnitValue ?? this.fUnitValue,
      adCess: adCess ?? this.adCess,
      iGST: iGST ?? this.iGST,
      cGST: cGST ?? this.cGST,
      sGST: sGST ?? this.sGST,
      stock: stock ?? this.stock,
      minimumRate: minimumRate ?? this.minimumRate,
      cessPer: cessPer ?? this.cessPer,
      adCessPer: adCessPer ?? this.adCessPer,
      color: color ?? this.color,
      colorN: colorN ?? this.colorN
    );
  }

    StockProduct toStockProduct() {
    return StockProduct(
      name: itemName,
      itemId: itemId,
      productId: uniqueCode,
      quantity: quantity,
      buyingPrice: buyingPrice,
      buyingPriceReal: buyingPriceReal,
      sellingPrice: sellingPrice,
      retailPrice: retailPrice,
      wholeSalePrice: wholeSalePrice,
      hsnCode: hsnCode,
      stockValuation: null, 
      tax: tax,
      cess: cess,
      cessPer: cessPer,
      adCessPer: adCessPer,
      spRetailPrice: spRetailPrice,
      branch: branch?.toDouble(),
      minimumRate: minimumRate,
      serialNo: serialNo,
      oBarcode: oBarcode,
      supplierId: supplierId,
      locationId: locationId,
      categoryId: categoryId,
      unitId: unitId,
      mfrId: mfrId,
      subcategoryId: subcategoryId,
      rackId: rackId,
      free: free,
      taxType: taxType,
      estUniqueCode: uniqueCode,
      expDate: expDate,
      locked: locked,
      brand: brand,
      company: company,
      size: size?.toDouble(),
      color: color,
    );
  }
}


class CartItemP {
  String itemName, serialNo, expDate, unitName;
  double quantity,
      rate,
      rRate,
      gross,
      fCess,
      discount,
      discountPercent,
      mrp,
      tax,
      taxP,
      retail,
      spRetail,
      unitValue,
      free,
      cdPer,
      cDisc,
      net,
      cess,
      total,
      wholesale,
      fUnitValue,
      adCess,
      iGST,
      cGST,
      sGST,
      branch,
      profitPer,
      expense,
      mrpPer,
      wholesalePer,
      retailPer,
      spRetailPer,
      branchPer;
  int id,
      itemId,
      unitId,
      fUnitId,
      barcode,
      uniqueCode,
      location,
      estUniqueCode,
      brand,
      company,
      size,
      color,
      expenseQty;
  CartItemP(
      {required this.id,
      required this.itemId,
      required this.itemName,
      required this.serialNo,
      required this.uniqueCode,
      required this.fCess,
      required this.unitId,
      required this.quantity,
      required this.rate,
      required this.rRate,
      required this.gross,
      required this.discount,
      required this.discountPercent,
      required this.mrp,
      required this.tax,
      required this.taxP,
      required this.unitValue,
      required this.retail,
      required this.spRetail,
      required this.barcode,
      required this.expDate,
      required this.free,
      required this.fUnitId,
      required this.cdPer,
      required this.cDisc,
      required this.net,
      required this.cess,
      required this.total,
      required this.wholesale,
      required this.fUnitValue,
      required this.adCess,
      required this.iGST,
      required this.cGST,
      required this.sGST,
      required this.branch,
      required this.profitPer,
      required this.location,
      required this.expense,
      required this.mrpPer,
      required this.wholesalePer,
      required this.retailPer,
      required this.spRetailPer,
      required this.branchPer,
      required this.unitName,
      required this.estUniqueCode,
      required this.brand,
      required this.company,
      required this.size,
      required this.color,
      required this.expenseQty});

  Map<String, dynamic> toCartJson() {
    return {
      'id': id,
      'itemId': itemId,
      'itemName': itemName,
      'serialNo': serialNo,
      'uniqueCode': uniqueCode,
      'fCess': fCess,
      'unit': unitId,
      'quantity': quantity,
      'rate': rate,
      'rRate': rRate,
      'gross': gross,
      'discount': discount,
      'discountPercent': discountPercent,
      'mrp': mrp,
      'tax': tax,
      'taxP': taxP,
      'unitValue': unitValue,
      'retail': retail,
      'spRetail': spRetail,
      'barcode': barcode,
      'expDate': expDate,
      'free': free,
      'fUnitId': fUnitId,
      'cdPer': cdPer,
      'cDisc': cDisc,
      'net': net,
      'cess': cess,
      'total': total,
      'wholesale': wholesale,
      'fUnitValue': fUnitValue,
      'adCess': adCess,
      'iGST': iGST,
      'cGST': cGST,
      'sGST': sGST,
      'branch': branch,
      'profitPer': profitPer,
      'location': location,
      'expense': expense,
      'mrpPer': mrpPer,
      'wholesalePer': wholesalePer,
      'retailPer': retailPer,
      'spRetailPer': spRetailPer,
      'branchPer': branchPer,
      'unitName': unitName,
      'estUniqueCode': estUniqueCode,
      'brand': brand,
      'company': company,
      'size': size,
      'color': color,
      'expenseQty': expenseQty
    };
  }

  static List encodeCartToJson(List<CartItemP> list) {
    List jsonList = [];
    list.map((item) => jsonList.add(item.toCartJson())).toList();
    return jsonList;
  }

  Map toCartMap() {
    var map = {};
    map["id"] = id;
    map['itemId'] = itemId;
    map["itemName"] = itemName;
    map["serialNo"] = serialNo;
    map["uniqueCode"] = uniqueCode;
    map["fCess"] = fCess;
    map["unit"] = unitId;
    map["quantity"] = quantity;
    map["rate"] = rate;
    map['rRate'] = rRate;
    map["gross"] = gross;
    map["discount"] = discount;
    map["discountPercent"] = discountPercent;
    map["mrp"] = mrp;
    map["tax"] = tax;
    map["taxP"] = taxP;
    map["unitValue"] = unitValue;
    map["retail"] = retail;
    map['spRetail'] = spRetail;
    map['barcode'] = barcode;
    map['expDate'] = expDate;
    map['free'] = free;
    map['fUnitId'] = fUnitId;
    map['cdPer'] = cdPer;
    map['cDisc'] = cDisc;
    map['net'] = net;
    map['cess'] = cess;
    map['total'] = total;
    map['wholesale'] = wholesale;
    map['fUnitValue'] = fUnitValue;
    map['adCess'] = adCess;
    map['iGST'] = iGST;
    map['cGST'] = cGST;
    map['sGST'] = sGST;
    map['branch'] = branch;
    map['profitPer'] = profitPer;
    map['location'] = location;
    map['expense'] = expense;
    map['mrpPer'] = mrpPer;
    map['wholesalePer'] = wholesalePer;
    map['retailPer'] = retailPer;
    map['spRetailPer'] = spRetailPer;
    map['branchPer'] = branchPer;
    map['unitName'] = unitName;
    map['estUniqueCode'] = estUniqueCode;
    map['brand'] = brand;
    map['company'] = company;
    map['size'] = size;
    map['color'] = color;
    map['expenseQty'] = expenseQty;
    return map;
  }
}

class CartItemOP {
  String itemName, serialNo, expDate, unitName, supplier;
  double quantity,
      rate,
      rRate,
      gross,
      fCess,
      discount,
      discountPercent,
      mrp,
      tax,
      taxP,
      retail,
      spRetail,
      unitValue,
      free,
      cdPer,
      cDisc,
      net,
      cess,
      total,
      wholesale,
      fUnitValue,
      adCess,
      iGST,
      cGST,
      sGST,
      branch,
      profitPer,
      expense,
      mrpPer,
      wholesalePer,
      retailPer,
      spRetailPer,
      branchPer;
  int id, itemId, unitId, fUnitId, barcode, uniqueCode, location, supplierId;
  CartItemOP(
      {required this.id,
      required this.itemId,
      required this.itemName,
      required this.serialNo,
      required this.uniqueCode,
      required this.fCess,
      required this.unitId,
      required this.quantity,
      required this.rate,
      required this.rRate,
      required this.gross,
      required this.discount,
      required this.discountPercent,
      required this.mrp,
      required this.tax,
      required this.taxP,
      required this.unitValue,
      required this.retail,
      required this.spRetail,
      required this.barcode,
      required this.expDate,
      required this.free,
      required this.fUnitId,
      required this.cdPer,
      required this.cDisc,
      required this.net,
      required this.cess,
      required this.total,
      required this.wholesale,
      required this.fUnitValue,
      required this.adCess,
      required this.iGST,
      required this.cGST,
      required this.sGST,
      required this.branch,
      required this.profitPer,
      required this.location,
      required this.expense,
      required this.mrpPer,
      required this.wholesalePer,
      required this.retailPer,
      required this.spRetailPer,
      required this.branchPer,
      required this.unitName,
      required this.supplierId,
      required this.supplier});

  Map<String, dynamic> toCartJson() {
    return {
      'id': id,
      'itemId': itemId,
      'itemName': itemName,
      'serialNo': serialNo,
      'uniqueCode': uniqueCode,
      'fCess': fCess,
      'unit': unitId,
      'quantity': quantity,
      'rate': rate,
      'rRate': rRate,
      'gross': gross,
      'discount': discount,
      'discountPercent': discountPercent,
      'mrp': mrp,
      'tax': tax,
      'taxP': taxP,
      'unitValue': unitValue,
      'retail': retail,
      'spRetail': spRetail,
      'barcode': barcode,
      'expDate': expDate,
      'free': free,
      'fUnitId': fUnitId,
      'cdPer': cdPer,
      'cDisc': cDisc,
      'net': net,
      'cess': cess,
      'total': total,
      'wholesale': wholesale,
      'fUnitValue': fUnitValue,
      'adCess': adCess,
      'iGST': iGST,
      'cGST': cGST,
      'sGST': sGST,
      'branch': branch,
      'profitPer': profitPer,
      'location': location,
      'expense': expense,
      'mrpPer': mrpPer,
      'wholesalePer': wholesalePer,
      'retailPer': retailPer,
      'spRetailPer': spRetailPer,
      'branchPer': branchPer,
      'unitName': unitName,
      'supplierId': supplierId,
      'supplier': supplier
    };
  }

  static List encodeCartToJson(List<CartItemOP> list) {
    List jsonList = [];
    list.map((item) => jsonList.add(item.toCartJson())).toList();
    return jsonList;
  }

  Map toCartMap() {
    var map = {};
    map["id"] = id;
    map['itemId'] = itemId;
    map["itemName"] = itemName;
    map["serialNo"] = serialNo;
    map["uniqueCode"] = uniqueCode;
    map["fCess"] = fCess;
    map["unit"] = unitId;
    map["quantity"] = quantity;
    map["rate"] = rate;
    map['rRate'] = rRate;
    map["gross"] = gross;
    map["discount"] = discount;
    map["discountPercent"] = discountPercent;
    map["mrp"] = mrp;
    map["tax"] = tax;
    map["taxP"] = taxP;
    map["unitValue"] = unitValue;
    map["retail"] = retail;
    map['spRetail'] = spRetail;
    map['barcode'] = barcode;
    map['expDate'] = expDate;
    map['free'] = free;
    map['fUnitId'] = fUnitId;
    map['cdPer'] = cdPer;
    map['cDisc'] = cDisc;
    map['net'] = net;
    map['cess'] = cess;
    map['total'] = total;
    map['wholesale'] = wholesale;
    map['fUnitValue'] = fUnitValue;
    map['adCess'] = adCess;
    map['iGST'] = iGST;
    map['cGST'] = cGST;
    map['sGST'] = sGST;
    map['branch'] = branch;
    map['profitPer'] = profitPer;
    map['location'] = location;
    map['expense'] = expense;
    map['mrpPer'] = mrpPer;
    map['wholesalePer'] = wholesalePer;
    map['retailPer'] = retailPer;
    map['spRetailPer'] = spRetailPer;
    map['branchPer'] = branchPer;
    map['unitName'] = unitName;
    map['supplierId'] = supplierId;
    map['supplier'] = supplier;
    return map;
  }
}

class CartItemST {
  String itemName, serialNo, unitName,cBarcode;
  double quantity,
      rate,
      rRate,
      gross,
      mrp,
      retail,
      spRetail,
      unitValue,
      wholesale,
      branch,
      stock;
  int id, itemId, unitId, barcode, uniqueCode, stUniqueCode;
  CartItemST(
      {required this.id,
      required this.itemId,
      required this.itemName,
      required this.serialNo,
      required this.uniqueCode,
      required this.unitId,
      required this.quantity,
      required this.rate,
      required this.rRate,
      required this.gross,
      required this.mrp,
      required this.unitValue,
      required this.retail,
      required this.spRetail,
      required this.barcode,
      required this.wholesale,
      required this.branch,
      required this.unitName,
      required this.stUniqueCode,
      required this.stock,
      required this.cBarcode});

  Map<String, dynamic> toCartJson() {
    return {
      'id': id,
      'itemId': itemId,
      'itemName': itemName,
      'serialNo': serialNo,
      'uniqueCode': uniqueCode,
      'unit': unitId,
      'quantity': quantity,
      'rate': rate,
      'rRate': rRate,
      'gross': gross,
      'mrp': mrp,
      'unitValue': unitValue,
      'retail': retail,
      'spRetail': spRetail,
      'barcode': barcode,
      'wholesale': wholesale,
      'branch': branch,
      'unitName': unitName,
      'stUniqueCode': stUniqueCode,
      'stock': stock,
      'cBarcode': cBarcode
    };
  }

  static List encodeCartToJson(List<CartItemST> list) {
    List jsonList = [];
    list.map((item) => jsonList.add(item.toCartJson())).toList();
    return jsonList;
  }

  Map toCartMap() {
    var map = {};
    map["id"] = id;
    map['itemId'] = itemId;
    map["itemName"] = itemName;
    map["serialNo"] = serialNo;
    map["uniqueCode"] = uniqueCode;
    map["unit"] = unitId;
    map["quantity"] = quantity;
    map["rate"] = rate;
    map['rRate'] = rRate;
    map["gross"] = gross;
    map["mrp"] = mrp;
    map["unitValue"] = unitValue;
    map["retail"] = retail;
    map['spRetail'] = spRetail;
    map['barcode'] = barcode;
    map['wholesale'] = wholesale;
    map['branch'] = branch;
    map['unitName'] = unitName;
    map['stock'] = unitName;
    map['stUniqueCode'] = stUniqueCode;
    map['cBarcode'] = cBarcode;
    return map;
  }
}

class CartJobCartItem {
  int id;
  int itemid;
  String itemName;
  double qty;
  String model;
  String date;
  String uniqueCode;
  CartJobCartItem(
      {required this.id,
      required this.itemid,
      required this.itemName,
      required this.qty,
      required this.model,
      required this.date,
      required this.uniqueCode});

  Map<String, dynamic> tomap() {
    return {
      'id': id,
      'itemId': itemid,
      'ItemName': itemName,
      'qty': qty,
      'model': model,
      'date': date,
      'uniqueCode': uniqueCode
    };
  }
}