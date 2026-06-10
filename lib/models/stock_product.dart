class StockProduct {
   String? name;
   int? productId, itemId;
   double? quantity;
   double? buyingPrice;
   double? buyingPriceReal;
   double? sellingPrice;
   double? retailPrice;
   double? wholeSalePrice;
   String? hsnCode;
   String? stockValuation;
   double? tax;
   double? cess;
   double? cessPer;
   double? adCessPer;
   double? spRetailPrice;
   double? branch;
   double? minimumRate;
   String? serialNo;
   String? oBarcode;
   int? supplierId;
   int? locationId;
   int? categoryId;
   int? unitId;
   int? mfrId;
   int? subcategoryId;
   int? rackId;
   double? free;
   String? taxType;
   int? estUniqueCode;
   String? expDate;
   String? locked;
   int? brand;
   int? company;
   double? size;
   int? color;
   String? cBarcode;

   StockProduct({
    this.name,
    this.itemId,
    this.buyingPrice,
    this.sellingPrice,
    this.buyingPriceReal,
    this.retailPrice,
    this.wholeSalePrice,
    this.quantity,
    this.productId,
    this.hsnCode,
    this.stockValuation,
    this.tax,
    this.cess,
    this.cessPer,
    this.adCessPer,
    this.spRetailPrice,
    this.branch,
    this.minimumRate,
    this.serialNo,
    this.oBarcode,
    this.supplierId,
    this.locationId,
    this.categoryId,
    this.unitId,
    this.mfrId,
    this.subcategoryId,
    this.rackId,
    this.free,
    this.taxType,
    this.estUniqueCode,
    this.expDate,
    this.locked,
    this.brand,
    this.company,
    this.size,
    this.color,
    this.cBarcode,
  });

  factory StockProduct.fromJson(Map<String, dynamic> json) {
    return StockProduct(
      name: json['itemname'],
      itemId: json['ItemId'],
      productId: json['uniquecode'],
      quantity: double.tryParse(json['Qty'].toString()),
      buyingPrice: double.tryParse(json['prate'].toString()),
      buyingPriceReal: double.tryParse(json['RealPrate'].toString()),
      sellingPrice: double.tryParse(json['mrp'].toString()),
      retailPrice: double.tryParse(json['retail'].toString()),
      wholeSalePrice: double.tryParse(json['WSrate'].toString()),
      hsnCode: json['hsncode'],
      stockValuation: json['stockvaluation'],
      tax: double.tryParse(json['tax'].toString()),
      cess: double.tryParse(json['cess'].toString()),
      cessPer: double.tryParse(json['cessper'].toString()),
      adCessPer: double.tryParse(json['adcessper'].toString()),
      spRetailPrice: double.tryParse(json['Spretail'].toString()),
      branch: double.tryParse(json['Branch'].toString()),
      minimumRate: double.tryParse(json['minimumRate'].toString()),
      serialNo: json['serialno'] ?? '',
      oBarcode: json['obarcode'] ?? '',
      supplierId: json['supplier'] ?? 0,
      locationId: json['location'] ?? 0,
      categoryId: json['Catagory_id'] ?? 0,
      unitId: json['unit_id'] ?? 0,
      mfrId: json['Mfr_id'] ?? 0,
      subcategoryId: json['subcatagory_id'] ?? 0,
      rackId: json['rack_id'] ?? 0,
      free: double.tryParse(
        json['Free'].toString(),
      ),
      taxType: json['TaxType'].toString(),
      estUniqueCode: json['EstUniQueCode'] ?? 0,
      expDate: json['expdate'] ?? '2023-08-01T00:00:00.000Z',
      locked: json['Locked'] ?? 'N',
      brand: json['Brand'] ?? 0,
      company: json['company'] ?? 0,
      size: double.tryParse(json['Size'].toString()),
      color: json['color'] ?? 0,
      cBarcode: json.containsKey('Cbarcode') ? json['Cbarcode'] : '' ?? '',
    );
  }
  factory StockProduct.fromJsonB(Map<String, dynamic> json) {
    return StockProduct(
      name: json['ProductName'],
      itemId: json['ItemId'] ?? 0,
      productId: json['uniquecode'],
      quantity: double.tryParse(json['qty'].toString()),
      buyingPrice: double.tryParse(json['prate'].toString()),
      buyingPriceReal: double.tryParse(json['RealPrate'].toString()),
      sellingPrice: double.tryParse(json['MRP'].toString()),
      retailPrice: double.tryParse(json['retail'].toString()),
      wholeSalePrice: double.tryParse(json['Wsale'].toString()),
      hsnCode: json['hsncode'],
      stockValuation: json['stockvaluation'],
      tax: double.tryParse(json['tax'].toString()),
      cess: double.tryParse(json['cess'].toString()),
      cessPer: double.tryParse(json['cessper'].toString()),
      adCessPer: double.tryParse(json['adcessper'].toString()),
      spRetailPrice: double.tryParse(json['SpRetail'].toString()),
      branch: double.tryParse(json['Branch'].toString()),
      minimumRate: double.tryParse(json['minimumRate'].toString()),
      serialNo: json['serialno'] ?? '',
      oBarcode: json['Obarcode'] ?? '',
      supplierId: json['Supplier'] ?? 0,
      locationId: int.tryParse('Location') ?? 0,
      categoryId: json['Catagory_id'] ?? 0,
      unitId: int.tryParse(json['Unit']) ?? 0,
      mfrId: json['Mfr_id'] ?? 0,
      subcategoryId: json['subcatagory_id'] ?? 0,
      rackId: json['rack_id'] ?? 0,
      free: double.tryParse(
        json['Free'].toString(),
      ),
      taxType: json['TaxType'].toString(),
      estUniqueCode: json['EstUniQueCode'] ?? 0,
      expDate: json['expdate'] ?? '2023-08-01T00:00:00.000Z',
      locked: json['Locked'] ?? 'N',
      brand: json['Brand'] ?? 0,
      company: json['Company'] ?? 0,
      size: double.tryParse(json['Size'].toString()),
      color: json['Color'] ?? 0,
    );
  }
  // StockProduct.fromCartItem(){}

  static StockProduct empty() {
    return  StockProduct(
        adCessPer: 0,
        branch: 0,
        brand: 0,
        buyingPrice: 0,
        buyingPriceReal: 0,
        categoryId: 0,
        cess: 0,
        cessPer: 0,
        color: 0,
        company: 0,
        estUniqueCode: 0,
        expDate: '',
        free: 0,
        hsnCode: '',
        itemId: 0,
        locationId: 0,
        locked: '',
        mfrId: 0,
        minimumRate: 0,
        name: '',
        oBarcode: '',
        productId: 0,
        quantity: 0,
        rackId: 0,
        retailPrice: 0,
        sellingPrice: 0,
        serialNo: '',
        size: 0,
        spRetailPrice: 0,
        stockValuation: '',
        subcategoryId: 0,
        supplierId: 0,
        tax: 0,
        taxType: '',
        unitId: 0,
        wholeSalePrice: 0);
  }
}
