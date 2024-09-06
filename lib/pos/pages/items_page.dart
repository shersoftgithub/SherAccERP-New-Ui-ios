import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sheraccerp/models/company.dart';
import 'package:sheraccerp/models/stock_item.dart';
import 'package:sheraccerp/models/stock_product.dart';
import 'package:sheraccerp/pos/controllers/cart_item_provider.dart';
import 'package:sheraccerp/pos/models/pos_cart_model.dart';
import 'package:sheraccerp/pos/pages/pos_settings_page.dart';
import 'package:sheraccerp/scoped-models/main.dart';
import 'package:sheraccerp/service/api_dio.dart';
import 'package:sheraccerp/service/com_service.dart';
import 'package:sheraccerp/shared/constants.dart';
import 'package:sheraccerp/util/dateUtil.dart';
import 'package:sheraccerp/util/res_color.dart';

class ItemsPage extends StatefulHookConsumerWidget {
  const ItemsPage({super.key});

  @override
  ConsumerState<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends ConsumerState<ItemsPage> {
  final TextEditingController searchController = TextEditingController();
  List<DataJson> categoryDataList = [];
  List<String> categoryList = [];
  List<PosCartModel> cartItem = [];
  bool _showCategoryList = false;
  Map<String, int> selectedItems = {};
  List<StockItem>? products;
  List<StockItem>? filteredProducts;
  List<StockProduct>? fetchStockVariant;
  DioService api = DioService();
  String _selectedCategory = "All";
  // String _toDay = '';
  // String get getToDay => _toDay!;
  DateTime now = DateTime.now();
  String? formattedDate;
  bool _isLoading = false,
  enableKeralaFloodCess = false,
  cessOnNetAmount = false;
   double taxP = 0,
      tax = 0,
      gross = 0,
      subTotal = 0,
      total = 0,
      quantity = 0,
      rate = 0,
      saleRate = 0,
      currentRate = 0,
      discount = 0,
      discountPercent = 0,
      rDisc = 0,
      rRate = 0,
      rateOff = 0,
      kfcP = 0,
      kfc = 0,
      unitValue = 1,
      _conversion = 0,
      freeQty = 0,
      fUnitValue = 0,
      cdPer = 0,
      cDisc = 0,
      cess = 0,
      cessPer = 0,
      adCessPer = 0,
      profitPer = 0,
      adCess = 0,
      iGST = 0,
      csGST = 0,
      pRate = 0,
      rPRate = 0;

  final Map<String, List<StockItem>> _categoryItems = {
    "All": [],
  };

  @override
  void initState() {
    super.initState();
    formattedDate =
        getToDay.isNotEmpty ? getToDay : DateFormat('dd-MM-yyyy').format(now);
    _fetchProducts();
    categoryDataList
        .addAll(DataJson.fromJsonListX(otherRegistrationList[0]['category']));

    categoryList.addAll(categoryDataList
        .map((item) => item.name)
        .where((name) => name != null)
        .cast<String>()
        .toList());

    for (String category in categoryList) {
      _categoryItems[category] = [];
    }
    loadSettings();
    load(); 
  }

    CompanyInformation companySettings = CompanyInformation.emptyData();
  List<CompanySettings> settings = [];
   loadSettings() {
    companySettings = ScopedModel.of<MainModel>(context).getCompanySettings();
    settings = ScopedModel.of<MainModel>(context).getSettings();
    companyTaxMode = ComSettings.getValue('PACKAGE', settings!);
    cessOnNetAmount = ComSettings.getStatus('CESS ON NET AMOUNT', settings!);
    enableKeralaFloodCess = false;
  }
  
      String _regId = "", firm = "", firmCode = "", fId = "";
  load() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      _regId = (pref.getString('regId') ?? "");
      firm = (pref.getString('CompanyName') ?? "");
      firmCode = (pref.getString('CustomerCode') ?? "");
      fId = (pref.getString('fId') ?? "");
    });
  }
  
  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
    });

    products = await api.fetchStockProduct(DateUtil.dateDMY2YMD(formattedDate));
    filteredProducts = products;
    fetchStockVariant = [];
    for (var product in products!) {
      var variants = await api.fetchStockVariant(product.id!);
      if (variants != null) {
        fetchStockVariant!.addAll(variants);
      }
    }

    _categorizeProducts();
    setState(() {
      _isLoading = false;
    });
  }

  void _categorizeProducts() {
    _categoryItems["All"] = products ?? [];
  }

  void filterProducts(String query) {
    if (query.isEmpty) {
      filteredProducts = _categoryItems[_selectedCategory];
    } else {
      filteredProducts = _categoryItems[_selectedCategory]
          !.where((product) =>
              product.name?.toLowerCase().contains(query.toLowerCase()) ??
              false)
          .toList();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // debugPrint(cartItem.length.toString());
    final isExpanded = useState<bool>(false);
    final cartModel = ref.watch(cartItemProvider);
    final selectedRateType = ref.watch(rateTypeProvider);
    final List<StockItem> itemList = filteredProducts ?? [];
    List<StockProduct> variantList = fetchStockVariant ?? [];
    final isTax = ref.watch(isTaxProvider);
        double totalGrossValue = 0;
  double totalDiscount = 0;
  double totalNet = 0;
  double totalCess = 0;
  double totalIgST = 0;
  double totalCgST = 0;
  double totalSgST = 0;
  double totalFCess = 0;
  double totalAdCess = 0;
  double totalRDiscount = 0;
  double taxTotalCartValue = 0;
  double totalCartValue = 0;
  double totalProfit = 0;
  double csPer = 0;
    if(fetchStockVariant != null )
     for(var totals in fetchStockVariant!){
      // totalGrossValue += totals.gross!;
      // totalDiscount += totals.discount!;
      // totalRDiscount += totals.rDiscount!;
      // totalNet += totals.net!;
      cessPer = totals.cessPer!;
      totalCess += totals.cess!;
      totalAdCess += totals.adCessPer!;
      taxTotalCartValue += totals.tax!;
      //  totalIgST += totals.;
      //  totalCess += totals.cess!;
     }
     kfcP = isTax
          ? enableKeralaFloodCess
              ? kfcPer
              : 0
          : 0;
     csPer = taxP / 2;
     debugPrint("cessPer == ${totalCess.toString()}");
     debugPrint("tax == ${taxP.toString()}");
   
     debugPrint('cess = ${cess.toString()}'); 
     debugPrint(iGST.toString()); 
    // total = CommonService.getRound(
    //     2, (subTotal + csGST + csGST + iGST + cess + kfc + adCess));
  double totalAmount = cartModel.fold(0.0, (sum, item) => sum + item.rate * item.quantity!);

  double totalTax = isTax
      ? cartModel.fold(0.0, (sum, item) => sum + (item.tax ?? 0) * item.quantity!)
      : 0.0;
      if (companyTaxMode == 'INDIA') {
        kfc = isKFC ? CommonService.getRound(4, ((subTotal * kfcP) / 100)) : 0;
        double csPer = taxP / 2;
        iGST = 0;
        csGST = CommonService.getRound(2, (totalTax / 2));
      }else if (companyTaxMode == 'GULF') {
      iGST = CommonService.getRound(2, (totalTax / 2));
      csGST = 0;
      kfc = 0;
    }
      debugPrint('csGST${csGST.toString()}');
      debugPrint('igst${iGST.toString()}');


     double grandTotal = totalAmount + totalTax;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        centerTitle: true,
        title: const Text(
          'Items',
          style: TextStyle(
            fontFamily: 'poppins',
            color: white,
          ),
        ),
        bottom: isExpanded.value
            ? PreferredSize(
                preferredSize: const Size.fromHeight(40),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: TextField(
                    style: const TextStyle(color: white),
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search..',
                      hintStyle: TextStyle(color: white, fontFamily: 'poppins'),
                      constraints: BoxConstraints(maxHeight: 45),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      filterProducts(value);
                    },
                  ),
                ),
              )
            : null,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _showCategoryList = !_showCategoryList;
              });
            },
            icon: const Icon(Icons.menu, color: white),
          ),
          IconButton(
            onPressed: () {
              isExpanded.value = !isExpanded.value;
            },
            icon: const Icon(Icons.search, color: white),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                if (_showCategoryList)
                  Container(
                    color: bagroundColor,
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width / 2.9,
                    child: ListView.builder(
                      itemCount: _categoryItems.keys.length,
                      itemBuilder: (context, index) {
                        String category = _categoryItems.keys.elementAt(index);
                        return ListTile(
                          title: Text(category),
                          tileColor: _selectedCategory == category
                              ? kPrimaryColor
                              : null,
                          textColor: _selectedCategory == category
                              ? kPrimaryColor
                              : null,
                          trailing: category == 'All'
                              ? InkWell(
                                  onTap: () {
                                    setState(() {
                                      _showCategoryList = false;
                                    });
                                  },
                                  child: const Icon(
                                      Icons.keyboard_double_arrow_left))
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                              filterProducts(searchController.text);
                            });
                          },
                        );
                      },
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Align(
                      alignment: Alignment.center,
                      child: Wrap(
                        children: itemList.map((item) {
                          // Find the variant for the current item
                          StockProduct? variant = variantList.firstWhere(
                              (variant) => variant.itemId == item.id,
                              orElse: () => StockProduct());

                              double? rate = selectedRateType == 'MRP' ? variant.sellingPrice 
                                                     : selectedRateType == 'WHOLESALE' ? variant.wholeSalePrice 
                                                       : selectedRateType == 'RETAIL' ? variant.retailPrice 
                                                         : selectedRateType == 'SPRETAIL' ? variant.spRetailPrice
                                                           : variant.retailPrice ;

                          return Container(
                            padding: const EdgeInsets.all(4),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 4),
                            width: MediaQuery.of(context).size.width / 3.5,
                            constraints: const BoxConstraints(
                                minHeight: 120, maxHeight: 150),
                            decoration: BoxDecoration(
                              border: Border.all(color: grey),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: IntrinsicHeight(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.name ?? '',
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    style: const TextStyle(
                                      fontFamily: 'poppins',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    "Price \u{20B9} ${rate ?? 0}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    "Tax ${variant.tax!.toStringAsFixed(0) ?? 0}%",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        ref
                                            .read(cartItemProvider.notifier)
                                            .addItem(
                                            PosCartModel(
                                                                                      cess: cess,
                                                                                      adCess: adCess,
                                                                                      barcode: variant.itemId,
                                                                                      cDisc: cDisc,
                                                                                      serialNo: variant.serialNo,
                                                                                      uniqueCode: variant.productId,
                                                                                      expDate: variant.expDate,
                                                                                      net: rate,
                                                                                      fUnitId: 0,
                                                                                      fUnitValue: 1,
                                                                                      taxP: tax,
                                                                                      sGST: csGST?? 0,
                                                                                      unitId: unitData.firstWhere((element) => element.name == 'NOS',).id,
                                                                                      unitValue: 1,
                                                                                      cGST: csGST?? 0,
                                                                                      cdPer: cdPer,
                                                                                      discount: discount,
                                                                                      discountPercent: discountPercent,
                                                                                      gross: gross,
                                                                                      iGST: iGST?? 0,
                                                                                      itemId: variant.itemId,
                                                                                      realPrice: rate!,
                                                                                      free: 0,
                                                                                      fCess: 0,
                                                                                      pRate: variant.buyingPrice,
                                                                                      rPRate: variant.buyingPriceReal,
                                                                                      total: rate * quantity ,
                                                                                      profitPer: 0,
                                                                                      rDiscount: 0,
                                                                                      rRate: taxMethod == 'MINUS'
        ? cessOnNetAmount
            ? CommonService.getRound(
                4, (100 * rate) / (100 + tax + kfcP + cessPer))
            : CommonService.getRound(4, (100 * rate) / (100 + tax + kfcP))
        : rate,
                                                                                       tax: variant.tax?? 0,
                                                                                       code: variant.productId.toString(),
                                                                                       id: item.id,
                                                                                       itemName: item.name!,
                                                                                       minimumRate: variant.minimumRate,
                                                                                       quantity: 1,
                                                                                       stock: 1,
                                                                                       rate: rate!)
                                                );
                                      });
                                      // Navigator.of(context)
                                      //     .pushReplacement(
                                      //         MaterialPageRoute(
                                      //             builder: (context) =>
                                      //                 PosHomePage(
                                      //                     selectedItems:
                                      //                         selectedItems)));
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                        color: kPrimaryColor,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text('Add',
                                              style: TextStyle(color: white)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
