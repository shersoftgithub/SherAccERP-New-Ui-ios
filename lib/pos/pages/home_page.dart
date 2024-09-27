import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sheraccerp/models/company.dart';
import 'package:sheraccerp/models/product_register_model.dart';
import 'package:sheraccerp/models/sales_type.dart';
import 'package:sheraccerp/models/stock_item.dart';
import 'package:sheraccerp/models/stock_product.dart';
import 'package:sheraccerp/pos/controllers/cart_item_provider.dart';
import 'package:sheraccerp/pos/controllers/hold_item_provider.dart';
import 'package:sheraccerp/pos/models/pos_cart_model.dart';
import 'package:sheraccerp/pos/pages/payment_details_page.dart';
import 'package:sheraccerp/pos/pages/pos_settings_page.dart';
import 'package:sheraccerp/pos/pages/qr_view_page.dart';
import 'package:sheraccerp/pos/widgets/drawer_widget.dart';
import 'package:sheraccerp/scoped-models/main.dart';
import 'package:sheraccerp/service/api_dio.dart';
import 'package:sheraccerp/service/com_service.dart';
import 'package:sheraccerp/shared/constants.dart';
import 'package:sheraccerp/util/dateUtil.dart';
import 'package:sheraccerp/util/res_color.dart';

class PosHomePage extends StatefulHookConsumerWidget {
  final Map<String, int> selectedItems;
  const PosHomePage({super.key,required this.selectedItems});

  @override
  ConsumerState<PosHomePage> createState() => _PosHomePageState();
}

class _PosHomePageState extends ConsumerState<PosHomePage> {
  final TextEditingController quantityController = TextEditingController();
  List<PosCartModel> cartItem = [];
   DateTime now = DateTime.now();
  String? formattedDate;
  DioService api = DioService();
  List<StockItem>? fetchStockProducts;
   List<CartItem> cartItems = [];
  List<StockProduct>? fetchStockVariant;
  List<PosCartModel> posModel = [];
  StockProduct? productss;
  List<ProductPurchaseModel>? products;
   final TextEditingController _barcodeController = TextEditingController();
   final invoiceNoController = TextEditingController(); 
  Future<List<StockProduct>>? _productsFuture;
  List<StockProduct> _cart = [];
  CompanyInformation? companySettings;
  List<CompanySettings>? settings;
  String vehicleName = '', invoiceNo = '';
  bool _isLoading = false,
  enableKeralaFloodCess = false,
  cessOnNetAmount = false;
  String cashAc = '';
  int acId = 0,lId = 0;
  int decimal = 2,saleAccount = 0;
  var salesManId = 0;
  bool manualInvoiceNumberInSales = false,
         sType = false;
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
  //   double totalGrossValue = 0;
  // double totalDiscount = 0;
  // double totalNet = 0;
  // double totalCess = 0;
  // double totalIgST = 0;
  // double totalCgST = 0;
  // double totalSgST = 0;
  // double totalFCess = 0;
  // double totalAdCess = 0;
  // double totalRDiscount = 0;
  // double taxTotalCartValue = 0;
  // double totalCartValue = 0;
  // double totalProfit = 0;
//   String _toDay ='';
// String get getToDay => _toDay!;

   @override
   void initState(){
    super.initState();
    
    setToDay = DateFormat('dd-MM-yyyy').format(now);

     formattedDate =
        getToDay.isNotEmpty ? getToDay : DateFormat('dd-MM-yyyy').format(now);

      ComSettings().fetchOtherData();
      loadSettings();
      // saleAccount = mainAccount.firstWhere(
      //   (element) => element['LedName'] == 'GENERAL SALES A/C')['LedCode'];
      _fetchStockProducts();
      // _fetchStockVariant();
      
    
    load(); 
   }

   @override
   void dispose(){
    quantityController.clear();
    super.dispose();
   }

  // CompanyInformation companySettings = CompanyInformation.emptyData();
  

  loadSettings() {
    companySettings = ScopedModel.of<MainModel>(context).getCompanySettings();
    settings = ScopedModel.of<MainModel>(context).getSettings();

    companyTaxMode = ComSettings.getValue('PACKAGE', settings!);
    cessOnNetAmount = ComSettings.getStatus('CESS ON NET AMOUNT', settings!);
    enableKeralaFloodCess = false;

        salesManId = ComSettings.appSettings(
            'int', 'key-dropdown-default-salesman-view', 1) -
        1;
        lId = ComSettings.appSettings(
            'int', 'key-dropdown-default-location-view', 2) -
        1;    
        acId = 
         mainAccount.firstWhere((element) => element['LedName'] == cashAc,
            orElse: () => {'LedName': cashAc, 'LedCode': acId})['LedCode']
        ; 

   

      // for (var option in salesTypeList) {
      // if (option.type.toString() == 'SALES-POS') {
      //   salesTypeData = option;
      //   // status = true;
      //   break;
      // } else {
      //   // status = false;
      // }
      //  }
      //   if(salesTypeData == null) {
      //       var settingss  = ScopedModel.of<MainModel>(context).getSettings();
      //      sType = ComSettings.getValue('TOOLBAR SALES', settingss)
      //               .toString()
      //               .isNotEmpty
      //           ? ComSettings.selectSalesType(
      //               ComSettings.getValue('TOOLBAR SALES', settingss))
      //           : false;
      // }

        manualInvoiceNumberInSales =
        ComSettings.getStatus('MANNUAL INVOICE NUMBER IN SALES', settings!);
   companyTaxMode = ComSettings.getValue('PACKAGE', settings!);
   getEntryNo(12);

  }

      getEntryNo(saleFormId) {
    api.getSalesInvoiceNo(saleFormId,'SEntryNo').then((value) {
      setState(() {
        invoiceNo = (int.parse(value.toString()) + 1).toString();
        invoiceNoController.text = invoiceNo;
      });
    });
  }

    void _fetchProducts() {
    final barcode = _barcodeController.text;
    setState(() {
      _productsFuture = api.fetchStockProductByBarcode(barcode);
      
    });
    
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

  void _addToCart(StockProduct product) {
    setState(() {
      _cart.add(product);
    });
  }


  // Future<void> _fetchStockProducts() async {
  //   // products = await api.fetchAllProductPurchase();
  //   fetchStockProducts = await api.fetchStockProduct(DateUtil.dateDMY2YMD(formattedDate));
  // //  fetchStockVariant = fetchStockProducts!.where((element) => api.fetchStockVariant(element.id!),);
  //   setState(() {
  //     _isLoading = false;
  //   });
  // }
  
  Future<void> _fetchStockProducts() async {
  setState(() {
    _isLoading = true;
  });

  fetchStockProducts = await api.fetchStockProduct(DateUtil.dateDMY2YMD(formattedDate));

  fetchStockVariant = [];
  for (var product in fetchStockProducts!) {
    var variant = await api.fetchStockVariant(product.id!);
    
    if (variant != null) {
      fetchStockVariant!.addAll(variant);
      _cart = fetchStockVariant!;
    }
  }

  setState(() {
    _isLoading = false;
  });
}


  // Future<void> _fetchStockVariant() async {
  //   fetchStockVariant = await api.fetchStockVariant();
  //   setState(() {
  //     _isLoading = false;
  //   });
  // }

   Future<bool> showExitPopup() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App'),
            content: const Text('Do you want to exit an App?'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }
 
    var scaffoldKey = GlobalKey<ScaffoldState>();

    final animationDuration = const Duration(milliseconds: 400);

  @override
  Widget build(BuildContext context) {
    // getEntryNo(12);
    List<StockItem> itemList = fetchStockProducts ?? [];
    List<StockProduct> variantList = fetchStockVariant ?? [];
    // final List<ProductPurchaseModel> _itemList = products ?? [];
    final cartModel = ref.watch(cartItemProvider);
    final selectedRateType = ref.watch(rateTypeProvider);
    final isTax = ref.watch(isTaxProvider);
    //  taxP = isTax ? _variantList.tax! : 0;
      // cess = isTax ? _variantList.cess! : 0;
      // cessPer = isTax ? _variantList.cessPer! : 0;
      // adCessPer = isTax ? _variantList.adCessPer! : 0;

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
    //  debugPrint(iGST.toString()); 
    // total = CommonService.getRound(
    //     2, (subTotal + csGST + csGST + iGST + cess + kfc + adCess));
  // double totalAmount = cartModel.fold(0.0, (sum, item) => sum + item.realPrice * item.quantity!);
  
  // double totalTax = isTax
  //     ? cartModel.fold(0.0, (sum, item) => sum + (item.tax ?? 0) * item.quantity!)
  //     : 0.0;
  //     if (companyTaxMode == 'INDIA') {
  //       kfc = isKFC ? CommonService.getRound(4, ((subTotal * kfcP) / 100)) : 0;
  //       double csPer = taxP / 2;
  //       iGST = 0;
  //       csGST = CommonService.getRound(2, (totalTax / 2));
  //     }else if (companyTaxMode == 'GULF') {
  //     iGST = CommonService.getRound(2, (totalTax / 2));
  //     csGST = 0;
  //     kfc = 0;
  //   }
  double totalAmount = cartModel.fold(0.0, (sum, item) => sum + double.tryParse(item.realPrice.toStringAsFixed(4))! * item.quantity!);

double totalTax = isTax
    ? cartModel.fold(0.0, (sum, item) => sum + (double.tryParse(item.tax!.toStringAsFixed(4)) ?? 0) )
    : 0.0;

double kfc = 0;
double csGST = 0;
double iGST = 0;

if (companyTaxMode == 'INDIA') {
  kfc = isKFC ? CommonService.getRound(4, ((totalAmount * kfcP) / 100)) : 0;
  
  csGST = CommonService.getRound(2, (totalTax / 2)); // SGST + CGST
  iGST = 0; 
} else if (companyTaxMode == 'GULF') {
  iGST = CommonService.getRound(2, totalTax);
  
  csGST = 0;
  kfc = 0; 
}



      debugPrint('csGST${csGST.toString()}');
      debugPrint('igst${iGST.toString()}');


     double grandTotal = totalAmount + totalTax;
    // debugPrint(cartItem.length.toString()); 
         var _quantity = useState('');


    void _handleNumberPressed(String number) {
    quantityController.text =  _quantity.value += number;
    debugPrint(number);
      // widget.onQuantityChanged(_quantity.value);
    }

    void _handleClearPressed() {
      _quantity.value = '';
      // widget.onQuantityChanged('');
    }
     final isExpanded = useState<bool>(true);
    //  debugPrint(fetchStockVariant.toString());

    return  WillPopScope(
      onWillPop: showExitPopup,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: bagroundColor,
            key: scaffoldKey,
            drawer: const DrawerWidget(),
            appBar: AppBar(
              toolbarHeight: 80,
             leading: Align(
              alignment: Alignment.bottomRight,
               child: IconButton(onPressed: (){
                  scaffoldKey.currentState?.openDrawer();
               }, icon: Image.asset('assets/icons/ic_menu.png',scale: 2.6,)),
             ),
             actions: [
              Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  // crossAxisAlignment: CrossAxisAlignment.end,
                  // mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: (){
                    
                    }, icon: const Icon(Icons.arrow_back_ios)
                    ),
                    TextField(
                      readOnly: true,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: white,
                      ),
                      controller: invoiceNoController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none
                        ),
                        constraints: BoxConstraints(
                          maxHeight: 20,
                          maxWidth: 50
                        )
                      ),
                    ),
                    // Text(invoiceNo ?? '0',
                    // style: TextStyle(
                    //   color: white
                    // ),
                    // ),
                    IconButton(
                      onPressed: (){
                    
                    }, icon: const Icon(Icons.arrow_forward_ios)
                    ),
                    IconButton(
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(
                                builder: (context) => 
                                 PaymentPage(
                                  sGst: csGST,
                                  cGst: csGST,
                                  iGst: iGST,
                                  totalGrossValue: totalAmount,
                                  cartItems: cartModel,
                                  grandTotal: grandTotal ?? 0,
                                ),
                                ));
                    }, icon: const Icon(Icons.save_rounded)
                    ),
                  ],
                ),
              )
             ],
             backgroundColor: kPrimaryColor,
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 10
              ),
              child: Container(
               padding: const EdgeInsets.symmetric(
                 horizontal: 3,
                 vertical: 8
               ),
               decoration: BoxDecoration(
                 borderRadius: BorderRadius.circular(3),
                 color: white,
               ),
               height: MediaQuery.of(context).size.height,
               width: MediaQuery.of(context).size.width,
               child: ListView(
                // scrollDirection: Axis.vertical,
                // physics: BouncingScrollPhysics(),
                 children: [
                   SizedBox(
                     width: MediaQuery.of(context).size.width,
                     child: Row(
                       children: [
                         SizedBox(
                           width: MediaQuery.of(context).size.width/7,
                           child: const Text('Barcode',
                           overflow: TextOverflow.ellipsis,
                           // textScaler: TextScaler.linear(.9),
                                                 style: TextStyle(
                                                   fontFamily: 'poppins',
                                                   // fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color: grey
                                                 ),
                           ),
                         ),
                         const Spacer(),
                         SizedBox(
                           width: MediaQuery.of(context).size.width/4,
                           child: const Center(
                             child: Text('Item Name',
                             overflow: TextOverflow.ellipsis,
                             // textScaler: TextScaler.linear(.9),
                                                   style: TextStyle(
                                                     fontFamily: 'poppins',
                                                     // fontSize: 13,
                                                      fontWeight: FontWeight.w500,
                                                      color: grey
                                                   ),
                             ),
                           ),
                         ),
                         const Spacer(),
                         SizedBox(
                           width: MediaQuery.of(context).size.width/9,
                           child: const Center(
                             child: Text('Qty',
                             overflow: TextOverflow.ellipsis,
                             // textScaler: TextScaler.linear(.9),
                                                   style: TextStyle(
                                                     fontFamily: 'poppins',
                                                     // fontSize: 13,
                                                      fontWeight: FontWeight.w500,
                                                      color: grey
                                                   ),
                             ),
                           ),
                         ),
                         const Spacer(),
                         SizedBox(
                           width: MediaQuery.of(context).size.width/7,
                           child: const Center(
                             child: Text('Rate',
                             overflow: TextOverflow.ellipsis,
                             // textScaler: TextScaler.linear(.9),
                                                   style: TextStyle(
                                                     fontFamily: 'poppins',
                                                     // fontSize: 13,
                                                      fontWeight: FontWeight.w500,
                                                      color: grey
                                                   ),
                             ),
                           ),
                         ),
                         const Spacer(),
                         SizedBox(
                           width: MediaQuery.of(context).size.width/7,
                           child: const Center(
                             child: Text('Total',
                             overflow: TextOverflow.ellipsis,
                             // textScaler: TextScaler.linear(.9),
                                                   style: TextStyle(
                                                     fontFamily: 'poppins',
                                                     // fontSize: 13,
                                                      fontWeight: FontWeight.w500,
                                                      color: grey
                                                   ),
                             ),
                           ),
                         ),
                         SizedBox(
                           width: MediaQuery.of(context).size.width/15,
                           child: const Center(
                             child: Text(' ',
                             overflow: TextOverflow.ellipsis,
                             // textScaler: TextScaler.linear(.9),
                                                   style: TextStyle(
                                                     fontFamily: 'poppins',
                                                     // fontSize: 13,
                                                      fontWeight: FontWeight.w500,
                                                      color: grey
                                                   ),
                             ),
                           ),
                         ),
                       ],
                     ),
                   ),
                   const Divider(),
                   // items list
                   cartModel.isNotEmpty
                    ? Column(
                     mainAxisSize: MainAxisSize.min,
                      children: [
                        ListView.separated(
                          reverse: true,
                          // scrollDirection:Axis.vertical , 
                         physics: const BouncingScrollPhysics(),
                         shrinkWrap: true,
                         separatorBuilder: (context, index) => const Divider(),
                         itemCount: cartModel.length,
                         itemBuilder: (context, index) {
                          final item = cartModel[index];
                          double? quantity = double.tryParse(cartModel[index].quantity.toString() );
                          double? rate = double.tryParse(cartModel[index].rate.toString());
                           return InkWell(
                            onTap: () {
                          showDialog(
                            context: context, builder: (context) {
                                double quantity = cartModel[index].quantity!.toDouble();
                                double price = cartModel[index].rate.toDouble() * quantity;
                                TextEditingController quantityController = TextEditingController(text: quantity.toString());
                                TextEditingController priceController = TextEditingController(text: price.toStringAsFixed(2));

                              return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text('Edit Item'),
          titleTextStyle: const TextStyle(
            fontFamily: 'poppins',
            fontSize: 18,
            color: black,
          ),
          content: Container(
            height: MediaQuery.of(context).size.height / 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Item Name',
                  style: TextStyle(fontFamily: 'poppins', fontSize: 14),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: grey),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    cartModel[index].itemName!,
                    style: const TextStyle(fontFamily: 'poppins'),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Quantity',
                  style: TextStyle(fontFamily: 'poppins', fontSize: 14),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          if (quantity > 1) {
                            quantity--;
                            price = quantity * cartModel[index].rate.toDouble();
                            quantityController.text = quantity.toString();
                            priceController.text = price.toStringAsFixed(2);
                          }
                        });
                      },
                      icon: const Icon(Icons.remove),
                    ),
                    SizedBox(
                      width: 100, 
                      child: TextField(
                        controller: quantityController,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontFamily: 'poppins'),
                        decoration: const InputDecoration(
                           constraints: BoxConstraints(maxHeight: 40),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 5,
                    ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            quantity = double.tryParse(value) ?? quantity;
                            price = quantity * cartModel[index].rate.toDouble();

                            priceController.text = price.toStringAsFixed(2);
                          });
                        },

                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          quantity++;
                          price = quantity * cartModel[index].rate.toDouble();
                          quantityController.text = quantity.toString();
                          priceController.text = price.toStringAsFixed(2);
                        });
                      },
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Price',
                  style: TextStyle(fontFamily: 'poppins', fontSize: 14),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: priceController,
                  // textAlign: TextAlign.center,
                  // readOnly: true, 
                  style: const TextStyle(fontFamily: 'poppins'),
                  decoration: const InputDecoration(
                    constraints: BoxConstraints(maxHeight: 40),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 5,
                    ),
                  ),
                  onChanged: (value) {
                   
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref.read(cartItemProvider.notifier).updateItem(
                  cartModel[index].copyWith(
                    quantity: quantity,
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
                            },);
                            },
                             child: SizedBox(
                               width: MediaQuery.of(context).size.width,
                               // height: 40,
                               child: Row(
                                 children: [
                                    SizedBox(
                                 width: MediaQuery.of(context).size.width/7,
                                 child:  Text(cartModel[index].code?? '',
                                 maxLines: null,
                                 // textScaler: TextScaler.linear(.9),
                                 textAlign: TextAlign.center,
                                 overflow: TextOverflow.ellipsis,
                                                       style: TextStyle(
                                                         fontFamily: 'poppins',
                                                         // fontSize: 13,
                                                          fontWeight: FontWeight.w500,
                                                       ),
                                 ),
                               ),
                               const Spacer(),
                               SizedBox(
                                 width: MediaQuery.of(context).size.width/4,
                                 child:  Center(
                                   child: Text(cartModel[index].itemName ?? '',
                                   // textScaler: TextScaler.linear(.9),
                                   maxLines: null,
                                   textAlign: TextAlign.justify,
                                   overflow: TextOverflow.ellipsis,
                                                         style: const TextStyle(
                                                           fontFamily: 'poppins',
                                                           // color: grey,
                                                           // fontSize: 13,
                                                            fontWeight: FontWeight.w500,
                                                         ),
                                   ),
                                 ),
                               ),
                               const Spacer(),
                               SizedBox(
                                 width: MediaQuery.of(context).size.width/9,
                                 child: Center(
                                   child: Text(cartModel[index].quantity.toString(),
                                   // textScaler: TextScaler.linear(.9),
                                   overflow: TextOverflow.ellipsis,
                                                         style: const TextStyle(
                                                           fontFamily: 'poppins',
                                                           // color: grey,
                                                           // fontSize: 13,
                                                            fontWeight: FontWeight.w500,
                                                         ),
                                   ),
                                 ),
                                 ),
                               const Spacer(),
                               SizedBox(
                                 width: MediaQuery.of(context).size.width/7,
                                 child:  Center(
                                   child: Text(cartModel[index].rate.toString() ,
                                   // textScaler: TextScaler.linear(.9),
                                   overflow: TextOverflow.ellipsis,
                                                         style: const TextStyle(
                                                           fontFamily: 'poppins',
                                                           // fontSize: 13,
                                                            fontWeight: FontWeight.w500,
                                                         ),
                                   ),
                                 ),
                               ),
                               const Spacer(),
                               SizedBox(
                                 width: MediaQuery.of(context).size.width/7,
                                 child:  Center(
                                   child: Text(((quantity ?? 0) * (cartModel[index].rate ?? 0)).toString(),
                                   overflow: TextOverflow.ellipsis,
                                   // textScaler: TextScaler.linear(.9),
                                                         style: const TextStyle(
                                                           fontFamily: 'poppins',
                                                           // fontSize: 13,
                                                            fontWeight: FontWeight.w500,
                                                         ),
                                   ),
                                 ),
                               ),
                               SizedBox(
                                 width: MediaQuery.of(context).size.width/15,
                                 child:    InkWell(
                                 onTap: () { 
                                  setState(() {
                                    cartModel.removeAt(index);
                                    // ref.read(cartItemProvider.notifier).removeItem(item);
                                  });
                                 },
                                 
                                 child: const Icon(
                                   Icons.remove,color: red,
                                   size: 16,
                                   ),
                               )
                               ),
                                 ],
                               ),
                             ),
                           );
                         },
                         ),
                         const SizedBox(
                           height: 20,
                         ),
                          Row(
                           mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                               onTap: () {
                                    
                                      ref.read(holdItemProvider.notifier).addHoldList(cartModel);
                                     //  cartModel.clear();
                                      ref.read(cartItemProvider.notifier).clearAllCartItems();
                                      // final holdModel = ref.watch(holdItemProvider);
                                      // // Navigator.push(context, MaterialPageRoute(
                                      // //   builder: (context) => HoldList(),));
                                      // debugPrint('hold list =====  ${holdModel.toString()}');
                                  
                                    ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Items added to hold list')),
                                  );
                               },
                                child: Container(
                                                            padding: const EdgeInsets.symmetric(
                                                              horizontal: 6,
                                                              vertical: 4
                                                            ),
                                                             decoration: BoxDecoration(
                                                          color: kPrimaryColor,
                                                          borderRadius: BorderRadius.circular(3)
                                                        ),
                                                        child: const Center(child: Text('Hold',
                                                        style: TextStyle(
                                                         fontSize: 16,
                                                         fontFamily: 'poppins',
                                                         color: white
                                                        ),
                                                        )),
                                                          ),
                              ),
                            ],
                          ),
                          // const SizedBox(
                          //   height: 200,
                          // )
                      ],
                    ) 
                     : const SizedBox(),
                 ],
               ),
              ),
            ),
            // extendBody: true,
            bottomNavigationBar: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                !isExpanded.value?  Container(
                    height: 6,
                    color: bagroundColor,
                  ): const SizedBox(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5
                    ),
                     margin: const EdgeInsets.symmetric(
                      // vertical: 8,
                      horizontal: 8
                    ), 
                    width: MediaQuery.of(context).size.width,
                    // height: 28,
                    decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(3)
                        ),
                    child:  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              ref.read(cartItemProvider.notifier).removeAllCartItem(cartModel.length);
                            });
                          },
                          child: const Text('Clear all     ',
                          // textScaler: TextScaler.linear(.9),
                          style: TextStyle(
                            fontFamily: 'poppins',
                            // fontSize: 13,
                             fontWeight: FontWeight.w500,
                             decoration: TextDecoration.underline,
                             decorationColor: red,
                             color: red
                          ),
                          ),
                        ),
                        const Spacer(),
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: InkWell(
                              onTap: () {
                                isExpanded.value = !isExpanded.value;
                              },
                              child: Icon(!isExpanded.value ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,)),
                          ),
                        ),
                          const Spacer(),
                           Text('Total Item: ${cartModel.length}',
                          // textScaler: TextScaler.linear(.9),
                          style: const TextStyle(
                            fontFamily: 'poppins',
                            // fontSize: 13,
                            fontWeight: FontWeight.w500
                          ),)
                      ],
                    ),
                  ),
                  Container(
                    height: 6,
                    color: bagroundColor,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5
                    ),
                    width: MediaQuery.of(context).size.width,
                    height: 35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: white,
                    ),
                    child: const Row(
                      children: [
                        Text('Customer Card No',
                        //  textScaler: TextScaler.linear(.9),
                          style: TextStyle(
                            fontFamily: 'poppins',
                            // fontSize: 13,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Expanded(
                          child: TextField(
                            // autofocus: true,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 3
                              ),
                              constraints: BoxConstraints(
                                maxHeight: 28
                              ),
                              border: OutlineInputBorder(
                              )
                            ),
                          )
                        )
                      ],
                    ),
                  ),
                  Container(
                    color: bagroundColor,
                    height: 8,
                  ),
                  AnimatedContainer(
                    color: bagroundColor,
                    // margin: EdgeInsets.symmetric(
                    //   vertical: 10,
                    //   horizontal: 8
                    // ), 
                    duration: animationDuration,
                    // color: white,
                    // height: isExpanded.value
                    //     ? MediaQuery.of(context).size.height / 2
                    //     : 0,
                    child: Container(
                       margin: const EdgeInsets.symmetric(
                      // vertical: 16,
                      horizontal: 8
                    ), 
                      height: isExpanded.value
                        ? MediaQuery.of(context).size.height / 2
                        : 0,
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(3)
                        ),
                        child:  Align(
                          alignment: Alignment.topCenter,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TabBar(
                                dividerHeight: 0,
                                labelPadding: const EdgeInsets.symmetric(
                                  horizontal: 1
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 1
                                ),
                                indicatorSize: TabBarIndicatorSize.tab,
                                indicatorPadding: EdgeInsets.symmetric(
                                 vertical:isExpanded.value ?  10 : 0
                                ),
                                labelColor: kPrimaryColor,
                                indicatorColor: isExpanded.value? kPrimaryColor : bagroundColor,
                                unselectedLabelColor: black,
                                labelStyle: const TextStyle(
                                  fontFamily: 'poppins',
                                  fontWeight: FontWeight.w500,
                                  color: kPrimaryColor //Color(0xff0008B3),
                                  // fontSize: 13
                                ),
                                tabs: const[
                                Tab(text: 'Barcode',),
                                Tab(text: 'Quantity',),
                                Tab(text: 'Speed Item',),
                              ]),
                              Expanded(
                                child: TabBarView(children: [
                                 Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Barcode', style: TextStyle(fontFamily: 'poppins')),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: TextField(
                  controller: _barcodeController,
                  decoration: InputDecoration(
                    suffixIconConstraints: const BoxConstraints(maxHeight: 28),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: InkWell(
                        onTap: () {
                          _fetchProducts();
                        },
                        child: const Icon(Icons.search_off_outlined),
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                    constraints: const BoxConstraints(maxHeight: 35),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: () async {
                  final Barcode? scannedData = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QRViewPage(),
                    ),
                  );
                  debugPrint('Scanned Data: ${scannedData?.code}');
                },
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner_rounded,
                    size: 22,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FutureBuilder<List<StockProduct>>(
            future: _productsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return AlertDialog(
                  title: const Text(
                    'An Error Occurred!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  content: Text(
                    "${snapshot.error}",
                    style: const TextStyle(color: Colors.blueAccent),
                  ),
                );
              } 
              else if (snapshot.hasData) {
                if (snapshot.data!.isNotEmpty) {
                  return Column(
                    children: snapshot.data!.map((product) {
                         double? rate = selectedRateType == 'MRP' ? product.sellingPrice 
                                                     : selectedRateType == 'WHOLESALE' ? product.wholeSalePrice 
                                                       : selectedRateType == 'RETAIL' ? product.retailPrice 
                                                         : selectedRateType == 'SPRETAIL' ? product.spRetailPrice
                                                           : product.retailPrice ;
                              //                         Future.delayed(Duration(),() {
                              //                         },);
                              
                      return ListView.builder(
                        itemCount: 1,
                        shrinkWrap: true,
                        itemBuilder: (context , index) {
                           final item = itemList[index];
                                        final itemVariant = variantList[index];
                                        // double? rate = selectedRateType == 'MRP' ? itemVariant.sellingPrice 
                                        //              : selectedRateType == 'WHOLESALE' ? itemVariant.wholeSalePrice 
                                        //                : selectedRateType == 'RETAIL' ? itemVariant.retailPrice 
                                        //                  : selectedRateType == 'SPRETAIL' ? itemVariant.spRetailPrice
                                        //                    : itemVariant.retailPrice ;
                          return InkWell(
                          onTap: () {
  print('Item tapped: ${product.name}');
  print('Rate: $rate');

  setState(() {
    ref.read(cartItemProvider.notifier).addItem(
      PosCartModel(
        cess: cess,
        adCess: adCess,
        barcode: product.itemId,
        cDisc: cDisc,
        serialNo: product.serialNo,
        uniqueCode: product.productId,
        expDate: product.expDate,
        net: double.tryParse(rate!.toStringAsFixed(2))! * 1,
        fUnitId: 0,
        fUnitValue: 1,
        taxP: product.tax ?? 0,
        sGST: product.tax! > 0 ? double.tryParse(csGST.toStringAsFixed(2)) ?? 0 : 0,
        unitId: unitData.firstWhere((element) => element.name == 'NOS').id,
        unitValue: 1,
        cGST: product.tax! > 0 ? double.tryParse(csGST.toStringAsFixed(2)) ?? 0 : 0,
        cdPer: cdPer,
        discount: discount,
        discountPercent: discountPercent,
        gross: double.tryParse(rate.toStringAsFixed(2))! * 1,
        iGST: product.tax! > 0 ? double.tryParse(iGST.toStringAsFixed(2)) ?? 0 : 0,
        itemId: product.itemId,
        realPrice: rate,
        free: 0,
        fCess: 0,
        pRate: product.buyingPrice,
        rPRate: product.buyingPriceReal,
        total: double.tryParse(rate.toStringAsFixed(2))! * 1,
        profitPer: 0,
        rDiscount: 0,
        rRate: taxMethod == 'MINUS'
            ? cessOnNetAmount
                ? CommonService.getRound(
                    4, (100 * rate) / (100 + tax + kfcP + cessPer))
                : CommonService.getRound(4, (100 * rate) / (100 + tax + kfcP))
            : rate,
        tax: product.tax! > 0
            ? double.tryParse(product.tax!.toStringAsFixed(3))!
            : 0,
        code: product.productId.toString(),
        id: product.itemId!,
        itemName: product.name!,
        minimumRate: product.minimumRate,
        quantity: 1,
        stock: product.quantity,
        rate: double.tryParse(rate.toStringAsFixed(2))!,
      ),
    );
  });
},

                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 3
                              ),
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                              // boxShadow: [
                                              //   BoxShadow( 
                                              //     color: Colors.grey.shade400,
                                              //     blurRadius: 5,
                                              //     spreadRadius: .8,
                                              //   )
                                              // ],
                                              border: Border.all(
                                                  color: grey, width: .5),
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                              color:
                                                  Colors.grey.withOpacity(.1)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Name  : ${product.name!}',
                                  maxLines: null,
                                  style: const TextStyle(
                                    fontFamily: 'poppins'
                                  ),
                                  ),
                                    Text('Price     : \u{20B9} ${rate.toString()}',
                                        style: const TextStyle(
                                          // fontFamily: 'poppins'
                                        ),
                                        ),
                                  // SizedBox(
                                  //   width: MediaQuery.of(context).size.width/1.5,
                                  //   child: Row(
                                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  //     mainAxisSize: MainAxisSize.min,
                                  //     children: [
                                  //       Text('Price     : \u{20B9} ${rate.toString()}',
                                  //       style: const TextStyle(
                                  //         // fontFamily: 'poppins'
                                  //       ),
                                  //       ),
                                  //        Text('Quantity :  ${product.quantity.toString()}',
                                  // style: const TextStyle(
                                  //   // fontFamily: 'poppins'
                                  // ),
                                  // ),
                                  //     ],
                                  //   ),
                                  // ),
                                  // SizedBox(
                                  //   width: MediaQuery.of(context).size.width/1.5,
                                  //   child: Row(
                                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  //     mainAxisSize: MainAxisSize.min,
                                  //     children: [
                                  //       Text('Prate     : \u{20B9} ${product.buyingPriceReal.toString()}',
                                  //       style: const TextStyle(
                                  //         // fontFamily: 'poppins'
                                  //       ),
                                  //       ),
                                  //        Text('Tax :  ${product.tax.toString()}%',
                                  // style: const TextStyle(
                                  //   // fontFamily: 'poppins'
                                  // ),
                                  // ),
                                  //     ],
                                  //   ),
                                  // ),
                                 
                                ],
                              ),
                            ),
                          );
                        }
                      );
                    }).toList(),
                  );
                } else {
                  return Center(
                    child: const Text('Barcode not found...'),
                  );
                }
              } else {
                return const Text('');
              }
            },
          ),
        ],
      ),
    ),
                                  Container(
                                    // height: MediaQuery.of(context).size.height,
                                    // color: green,
                                    child: 
                                     Row(
                                      children: [
                                        Expanded(
                                          child: 
                                        Column(
                                          children: [
                                               GestureDetector(
                                               onTap: () => _handleNumberPressed('+1'),
                                                  child: Container(
                                                width: 80,
                                                height: 50,
                                               // padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 7),
                                                 decoration: BoxDecoration(
                                                   borderRadius: BorderRadius.circular(5),
                                                 color: const Color(0xffeeeff3),
                                             ),
                                             child: const Center(
                                              child: Text(
                                               '+1',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: black, fontSize: 22),
                                             ),
                                          ),
                                        ),
                                        ),
                                          const SizedBox(
                                          height: 8,
                                        ),
                                                                                       GestureDetector(
                                               onTap: () => _handleNumberPressed('7'),
                                                  child: Container(
                                                width: 80,
                                                height: 50,
                                               // padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 7),
                                                 decoration: BoxDecoration(
                                                   borderRadius: BorderRadius.circular(5),
                                                 color: const Color(0xffeeeff3),
                                             ),
                                             child: const Center(
                                              child: Text(
                                               '7',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: black, fontSize: 22),
                                             ),
                                          ),
                                        ),
                                        ),
                                          const SizedBox(
                                          height: 8,
                                        ),
                                                                                       GestureDetector(
                                               onTap: () => _handleNumberPressed('4'),
                                                  child: Container(
                                                width: 80,
                                                height: 50,
                                               // padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 7),
                                                 decoration: BoxDecoration(
                                                   borderRadius: BorderRadius.circular(5),
                                                 color: const Color(0xffeeeff3),
                                             ),
                                             child: const Center(
                                              child: Text(
                                               '4',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: black, fontSize: 22),
                                             ),
                                          ),
                                        ),
                                        ),
                                          const SizedBox(
                                          height: 8,
                                        ),
                                                                                       GestureDetector(
                                               onTap: () => _handleNumberPressed('1'),
                                                  child: Container(
                                                width: 80,
                                                height: 50,
                                               // padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 7),
                                                 decoration: BoxDecoration(
                                                   borderRadius: BorderRadius.circular(5),
                                                 color: const Color(0xffeeeff3),
                                             ),
                                             child: const Center(
                                              child: Text(
                                               '1',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: black, fontSize: 22),
                                             ),
                                          ),
                                        ),
                                        ),
                                        const SizedBox(
                                          height: 8,
                                        ),
                                                                                       GestureDetector(
                                               onTap: () => _handleNumberPressed('0'),
                                                  child: Container(
                                                width: 80,
                                                height: 50,
                                               // padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 7),
                                                 decoration: BoxDecoration(
                                                   borderRadius: BorderRadius.circular(5),
                                                 color: const Color(0xffeeeff3),
                                             ),
                                             child: const Center(
                                              child: Text(
                                               '0',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: black, fontSize: 22),
                                             ),
                                          ),
                                        ),
                                        ),
                                          ],
                                        )),
                                        Expanded(
                                          child: 
                                        Column(
                                          children: [
                                                                                          GestureDetector(
                                               onTap: () => _handleNumberPressed('-1'),
                                                  child: Container(
                                                width: 80,
                                                height: 50,
                                               // padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 7),
                                                 decoration: BoxDecoration(
                                                   borderRadius: BorderRadius.circular(5),
                                                 color: const Color(0xffeeeff3),
                                             ),
                                             child: const Center(
                                              child: Text(
                                               '-1',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: black, fontSize: 22),
                                             ),
                                          ),
                                        ),
                                        ),
                                        const SizedBox(
                                          height: 8,
                                        ),
                                                                                                                                  GestureDetector(
                                               onTap: () => _handleNumberPressed('8'),
                                                  child: Container(
                                                width: 80,
                                                height: 50,
                                               // padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 7),
                                                 decoration: BoxDecoration(
                                                   borderRadius: BorderRadius.circular(5),
                                                 color: const Color(0xffeeeff3),
                                             ),
                                             child: const Center(
                                              child: Text(
                                               '8',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: black, fontSize: 22),
                                             ),
                                          ),
                                        ),
                                        ),
                                        const SizedBox(
                                          height: 8,
                                        ),
                                                                                                                                  GestureDetector(
                                               onTap: () => _handleNumberPressed('5'),
                                                  child: Container(
                                                width: 80,
                                                height: 50,
                                               // padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 7),
                                                 decoration: BoxDecoration(
                                                   borderRadius: BorderRadius.circular(5),
                                                 color: const Color(0xffeeeff3),
                                             ),
                                             child: const Center(
                                              child: Text(
                                               '5',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: black, fontSize: 22),
                                             ),
                                          ),
                                        ),
                                        ),
                                        const SizedBox(
                                          height: 8,
                                        ),
                                                                                                                                  GestureDetector(
                                               onTap: () => _handleNumberPressed('2'),
                                                  child: Container(
                                                width: 80,
                                                height: 50,
                                               // padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 7),
                                                 decoration: BoxDecoration(
                                                   borderRadius: BorderRadius.circular(5),
                                                 color: const Color(0xffeeeff3),
                                             ),
                                             child: const Center(
                                              child: Text(
                                               '2',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: black, fontSize: 22),
                                             ),
                                          ),
                                        ),
                                        ),
                                        const SizedBox(
                                          height: 8,
                                        ),
                                                                                                                                  GestureDetector(
                                               onTap: () => _handleNumberPressed('00'),
                                                  child: Container(
                                                width: 80,
                                                height: 50,
                                               // padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 7),
                                                 decoration: BoxDecoration(
                                                   borderRadius: BorderRadius.circular(5),
                                                 color: const Color(0xffeeeff3),
                                             ),
                                             child: const Center(
                                              child: Text(
                                               '00',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: black, fontSize: 22),
                                             ),
                                          ),
                                        ),
                                        ),
                                          ],
                                        )),
                                        Expanded(
                                          child: 
                                        Column(
                                          children: [
                                                                                          GestureDetector(
                                               onTap: () => _handleNumberPressed('+5'),
                                                  child: Container(
                                                width: 80,
                                                height: 50,
                                               // padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 7),
                                                 decoration: BoxDecoration(
                                                   borderRadius: BorderRadius.circular(5),
                                                 color: const Color(0xffeeeff3),
                                             ),
                                             child: const Center(
                                              child: Text(
                                               '+5',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: black, fontSize: 22),
                                             ),
                                          ),
                                        ),
                                        ),
                                        const SizedBox(
                                          height: 8,
                                        ),
                                                                                                                                  GestureDetector(
                                               onTap: () => _handleNumberPressed('9'),
                                                  child: Container(
                                                width: 80,
                                                height: 50,
                                               // padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 7),
                                                 decoration: BoxDecoration(
                                                   borderRadius: BorderRadius.circular(5),
                                                 color: const Color(0xffeeeff3),
                                             ),
                                             child: const Center(
                                              child: Text(
                                               '9',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: black, fontSize: 22),
                                             ),
                                          ),
                                        ),
                                        ),
                                        const SizedBox(
                                          height: 8,
                                        ),
                                                                                                                                  GestureDetector(
                                               onTap: () => _handleNumberPressed('6'),
                                                  child: Container(
                                                width: 80,
                                                height: 50,
                                               // padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 7),
                                                 decoration: BoxDecoration(
                                                   borderRadius: BorderRadius.circular(5),
                                                 color: const Color(0xffeeeff3),
                                             ),
                                             child: const Center(
                                              child: Text(
                                               '6',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: black, fontSize: 22),
                                             ),
                                          ),
                                        ),
                                        ),
                                        const SizedBox(
                                          height: 8,
                                        ),
                                                                                                                                  GestureDetector(
                                               onTap: () => _handleNumberPressed('3'),
                                                  child: Container(
                                                width: 80,
                                                height: 50,
                                               // padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 7),
                                                 decoration: BoxDecoration(
                                                   borderRadius: BorderRadius.circular(5),
                                                 color: const Color(0xffeeeff3),
                                             ),
                                             child: const Center(
                                              child: Text(
                                               '3',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: black, fontSize: 22),
                                             ),
                                          ),
                                        ),
                                        ),
                                        const SizedBox(
                                          height: 8,
                                        ),
                                                                                                                                  GestureDetector(
                                               onTap: () => _handleNumberPressed('.'),
                                                  child: Container(
                                                width: 80,
                                                height: 50,
                                               // padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 7),
                                                 decoration: BoxDecoration(
                                                   borderRadius: BorderRadius.circular(5),
                                                 color: const Color(0xffeeeff3),
                                             ),
                                             child: const Center(
                                              child: Text(
                                               '.',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,color: black, fontSize: 22),
                                             ),
                                          ),
                                        ),
                                        ),
                                          ],
                                        )),
                                        Expanded(
                                          child: 
                                        Column(
                                          children: [
                                                                                          GestureDetector(
                                               onTap: () => _handleNumberPressed('+10'),
                                                  child: Container(
                                                width: 80,
                                                height: 50,
                                               // padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 7),
                                                 decoration: BoxDecoration(
                                                   borderRadius: BorderRadius.circular(5),
                                                 color: const Color(0xffeeeff3),
                                             ),
                                             child: const Center(
                                              child: Text(
                                               '+10',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: black, fontSize: 22),
                                             ),
                                          ),
                                        ),
                                        ),
                                        const SizedBox(
                                          height: 8,
                                        ),
                                                                                                                                  GestureDetector(
                                               onTap: () => _handleClearPressed(),
                                                  child: Container(
                                                width: 80,
                                                height: 50,
                                               // padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 7),
                                                 decoration: BoxDecoration(
                                                   borderRadius: BorderRadius.circular(5),
                                                 color: const Color(0xffeeeff3),
                                             ),
                                             child:  const Icon(
                                           Icons.close,
                                            color: black,
                                           ),
                                        ),
                                        ),
                                        const SizedBox(
                                          height: 8,
                                        ),
                                                   GestureDetector(
                                               onTap: () {
                                                 
                                               },
                                                  child: Container(
                                                width: 80,
                                                height: 50,
                                               // padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 7),
                                                 decoration: BoxDecoration(
                                                   borderRadius: BorderRadius.circular(5),
                                                 color: const Color(0xffeeeff3),
                                             ),
                                             child: const Icon(
                                           Icons.more_outlined,
                                            color: black,
                                           ),
                                        ),
                                        ),
                                        const SizedBox(
                                          height: 8,
                                        ),
                                                   GestureDetector(
                                               onTap: () {
                                                 
                                               },
                                                  child: Container(
                                                width: 80,
                                                height: 110,
                                               // padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 7),
                                                 decoration: BoxDecoration(
                                                   borderRadius: BorderRadius.circular(5),
                                                 color: const Color(0xffeeeff3),
                                             ),
                                             child: const Center(
                                              child: Text(
                                               'Add',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: kPrimaryColor, fontSize: 22),
                                             ),
                                          ),
                                        ),
                                        ),
                                          ],
                                        )),
                                      ],
                                    )

                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4
                                    ),
                                    // height: MediaQuery.of(context).size.height,
                                    // color: blue,  
                                    child: _isLoading ? const Center(child: CircularProgressIndicator())
                                                : GridView.builder(
                                      gridDelegate:
                                      const SliverGridDelegateWithMaxCrossAxisExtent(
                                        // mainAxisExtent: 120,
                                        mainAxisSpacing: 8,
                                        crossAxisSpacing: 8,
                                        maxCrossAxisExtent:140 ),
                                      // const 
                                      // SliverGridDelegateWithFixedCrossAxisCount(
                                      //   mainAxisExtent: 80,
                                      //   mainAxisSpacing: 8,
                                      // crossAxisCount: 3,crossAxisSpacing: 8),
                                      itemCount: itemList.length,
                                       itemBuilder: (context, index) {
                                        final item = itemList[index];
                                        final itemVariant = variantList[index];
                                        double? rate = selectedRateType == 'MRP' ? itemVariant.sellingPrice 
                                                     : selectedRateType == 'WHOLESALE' ? itemVariant.wholeSalePrice 
                                                       : selectedRateType == 'RETAIL' ? itemVariant.retailPrice 
                                                         : selectedRateType == 'SPRETAIL' ? itemVariant.spRetailPrice
                                                           : itemVariant.retailPrice ;
                                                           
                                          return  Container(
                                            constraints: const BoxConstraints(
                                              // maxHeight: 120
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                              vertical: 6
                                            ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            color: const Color(0xffeeeff3)
                                          ),
                                          child: IntrinsicHeight( 
                                            child: Column(
                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              Text(
                                                                                item.name ?? '',
                                                                                textAlign: TextAlign.center,
                                                                                style: const TextStyle(
                                                                                  fontFamily: 'poppins',
                                                                                  fontWeight: FontWeight.w500,
                                                                                ),
                                                                              ),
                                                                              Text(
                                                                                "Price \u{20B9} ${rate ?? 0}", 
                                                                                maxLines: null,
                                                                                style: const TextStyle(
                                                                                  fontWeight: FontWeight.w400,
                                                                                ),
                                                                              ),
                                                                              Text(
                                                                                "Tax ${itemVariant.tax!.toStringAsFixed(0) ?? ''}%", 
                                                                                maxLines: null,
                                                                                style: const TextStyle(
                                                                                  fontWeight: FontWeight.w400,
                                                                                ),
                                                                              ),
                                                                              InkWell(
                                                                                onTap: () {
                                                                                 setState(() {
                                                                                  
                                                                                  // var currentItem = cartModel[index];
                                                                                  // double price = cartModel[index].rate.toDouble() * quantity;
                                                                                  // double? quantity = double.tryParse(cartModel[index].quantity.toString() );
                                                                                  ref.read(cartItemProvider.notifier).addItem(
                                                                                    PosCartModel(
                                                                                      cess: cess,
                                                                                      adCess: adCess,
                                                                                      barcode: itemVariant.itemId,
                                                                                      cDisc: cDisc,
                                                                                      serialNo: itemVariant.serialNo,
                                                                                      uniqueCode: itemVariant.productId,
                                                                                      expDate: itemVariant.expDate,
                                                                                      net: double.tryParse(rate!.toStringAsFixed(2))! * 1,
                                                                                      fUnitId: 0,
                                                                                      fUnitValue: 1,
                                                                                      taxP: itemVariant.tax?? 0,
                                                                                      sGST: itemVariant.tax! > 0 ? double.tryParse(csGST.toStringAsFixed(2))?? 0 : 0,
                                                                                      unitId: unitData.firstWhere((element) => element.name == 'NOS',).id,
                                                                                      unitValue: 1,
                                                                                      cGST: itemVariant.tax! > 0 ? double.tryParse(csGST.toStringAsFixed(2))?? 0 : 0,
                                                                                      cdPer: cdPer,
                                                                                      discount: discount,
                                                                                      discountPercent: discountPercent,
                                                                                      gross: double.tryParse(rate.toStringAsFixed(2))! * 1,
                                                                                      iGST: itemVariant.tax! > 0 ? double.tryParse(iGST.toStringAsFixed(2))?? 0 : 0,
                                                                                      itemId: itemVariant.itemId,
                                                                                      realPrice: rate!,
                                                                                      free: 0,
                                                                                      fCess: 0,
                                                                                      pRate: itemVariant.buyingPrice,
                                                                                      rPRate: itemVariant.buyingPriceReal,
                                                                                      total: double.tryParse(rate.toStringAsFixed(2))! * 1,
                                                                                      profitPer: 0,
                                                                                      rDiscount: 0,
                                                                                      rRate: taxMethod == 'MINUS'
        ? cessOnNetAmount
            ? CommonService.getRound(
                4, (100 * rate) / (100 + tax + kfcP + cessPer))
            : CommonService.getRound(4, (100 * rate) / (100 + tax + kfcP))
        : rate,
                                                                                       tax: itemVariant.tax! > 0 ? double.tryParse(itemVariant.tax!.toStringAsFixed(3))!  : 0 ,
                                                                                       code: itemVariant.productId.toString(),
                                                                                       id: item.id,
                                                                                       itemName: item.name!,
                                                                                       minimumRate: itemVariant.minimumRate,
                                                                                       quantity: 1,
                                                                                       stock: itemVariant.quantity,
                                                                                       rate: double.tryParse(rate.toStringAsFixed(2))!)
                                                                                  );
                                                                                });
                                                                                },
                                                                                child: Container(
                                                                                  width: MediaQuery.of(context).size.width,
                                                                                  decoration: BoxDecoration(
                                                                                    color: kPrimaryColor,
                                                                                    borderRadius: BorderRadius.circular(3),
                                                                                  ),
                                                                                  child: const Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    mainAxisSize: MainAxisSize.min,
                                                                                    children: [
                                            Text('Add', style: TextStyle(color: white)),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                          ),
                                         );
                                       },)
                                  ),
                                ]),
                              )
                            ],
                          ),
                        ),
                    ),
                  ),
                   Container(
                    color: bagroundColor,
                    height: 8,
                  ),
                  Container(
                    color: kPrimaryColor,
                    width: MediaQuery.of(context).size.width,
                    // height: MediaQuery.of(context).size.height/6.5,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width/1.53,
                                child: const Text('Total',
                                style: TextStyle(
                                fontFamily: 'poppins',
                                fontWeight: FontWeight.w300,
                                color: white,
                                fontSize: 14
                                 ),
                                ),
                              ),
                              const Text(':',
                               style: TextStyle(
                                fontFamily: 'poppins',
                                fontWeight: FontWeight.w500,
                                color: white,
                                fontSize: 16
                                 ),
                              ),
                              const Spacer(),
                               Text(totalAmount.toStringAsFixed(2),
                               style: const TextStyle(
                                fontFamily: 'poppins',
                                fontWeight: FontWeight.w300,
                                color: white,
                                fontSize: 15
                                 ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width/1.53,
                                child: const Text('GST/VAT',
                                style: TextStyle(
                                fontFamily: 'poppins',
                                fontWeight: FontWeight.w300,
                                color: white,
                                fontSize: 14
                                 ),
                                ),
                              ),
                              const Text(':',
                               style: TextStyle(
                                fontFamily: 'poppins',
                                fontWeight: FontWeight.w500,
                                color: white,
                                fontSize: 16
                                 ),
                              ),
                              const Spacer(),
                               Text(totalTax.toStringAsFixed(2),
                               style: const TextStyle(
                                fontFamily: 'poppins',
                                fontWeight: FontWeight.w300,
                                color: white,
                                fontSize: 15
                                 ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          InkWell(
                            onTap: () {
                              debugPrint( ' cess === ${totalCess.toString()}');
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) => 
                                 PaymentPage(
                                  sGst: csGST,
                                  cGst: csGST,
                                  iGst: iGST,
                                  totalGrossValue: totalAmount,
                                  cartItems: cartModel,
                                  grandTotal: grandTotal ?? 0,
                                ),
                                ));
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5
                              ),
                              width: MediaQuery.of(context).size.width,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: white
                              ),
                             child:  Row(
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width/1.56,
                                  child: const Text('Grand Total',
                                  style: TextStyle(
                                  fontFamily: 'poppins',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16
                                   ),
                                  ),
                                ),
                                const Text(':',
                                 style: TextStyle(
                                  fontFamily: 'poppins',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18
                                   ),
                                ),
                                const Spacer(),
                                 Text(grandTotal.toStringAsFixed(2),
                                 style: const TextStyle(
                                  fontFamily: 'poppins',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15
                                   ),
                                )
                              ],
                            ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            resizeToAvoidBottomInset: true,
          ),
        ),
      ),
    );
    
  }
  //  fetchSale(context, data) {
    
  //   // selectedItemId = cartModel!.id;
  //    setState(() {
  //     isLoading = true;
  //   });
  //   double billTotal = 0, billCash = 0;

  //   api.fetchSalesInvoice(data['Id'], salesTypeData!.id).then((value) {
  //     if (value != null) {
  //       salesData = value;
  //       var information = value['Information'][0];
  //       var particulars = value['Particulars'];
  //       // var serialNO = value['SerialNO'];
  //       // var deliveryNoteDetails = value['DeliveryNote'];
  //       otherAmountList = value['otherAmount'];
  //       formattedDate = DateUtil.dateDMY(information['DDate']);
  //       rateTypeItem = rateTypeList.firstWhere((element) => 
  //       element.id.toString() ==
  //        information['Stype'].toString());
  //       dataDynamic = [
  //         {
  //           'RealEntryNo': information['RealEntryNo'],
  //           'EntryNo': information['EntryNo'],
  //           'InvoiceNo': information['InvoiceNo'],
  //           'Type': salesTypeData!.id
  //         }
  //       ];
        
  //       invoiceNo = information['InvoiceNo'];
  //       invoiceNoController.text = invoiceNo;
  //       billCash = double.tryParse(information['CashReceived'].toString())!;
  //       billTotal = double.tryParse(information['GrandTotal'].toString())!;
  //       returnAmount = double.tryParse(information['ReturnAmount'].toString())!;
  //       selectedItemId = information['itemId'];
  //       returnBillId = information['ReturnNo'];
  //       controllerNarration.text = information['Narration'];
     
       
  //       if (apiV != 'v19/') {
  //         Object _bankLedgerName = information['BankName'] != null
  //             ? information['BankName'].toString()
  //             : 0;
  //         double? _bankLedgerAmount = information['bankamount'] != null
  //             ? double.tryParse(information['bankamount'].toString())
  //             : 0;
  //         if (_bankLedgerAmount! > 0) {
  //           bankAmountController.text = _bankLedgerAmount.toString();
  //           bankLedgerData = cashBankACList.firstWhere((element) =>
  //               element.name.toLowerCase() ==
  //               _bankLedgerName.toString().toLowerCase());
  //           bankLedgerName = bankLedgerData.name;

  //         } else {
  //           bankAmountController.text = '';
  //           bankLedgerData = null;
  //           bankLedgerName = '';
  //         }
  //         int? _commissionLedgerAc = information['CareOff'] != null
  //             ? int.tryParse(information['CareOff'].toString())
  //             : 0;
  //         double? _commissionLedgerAmount = information['CareOffAmount'] != null
  //             ? double.tryParse(information['CareOffAmount'].toString())
  //             : 0;
  //         if (_commissionLedgerAmount! > 0) {
  //           commissionAmountController.text =
  //               _commissionLedgerAmount.toString();
  //           commissionAccount = _commissionLedgerAc!;
  //           api.getCustomerDetail(_commissionLedgerAc).then((ledgerData) =>
  //               commissionLedgerData = LedgerModel(
  //                   id: _commissionLedgerAc, name: ledgerData.name!));
  //         } else {
  //           commissionAmountController.text = '';
  //           commissionLedgerData = null;
  //           commissionAccount = 0;
  //         }
  //       }
  //       CustomerModel cModel = CustomerModel(
  //           id: information['Customer'],
  //           name: information['ToName'],
  //           address1: information['Add1'],
  //           address2: information['Add2'],
  //           address3: information['Add3'],
  //           address4: information['Add4'],
  //           balance: information['Balance'].toString(),
  //           city: '',
  //           email: '',
  //           phone: '',
  //           route: '',
  //           state: '',
  //           stateCode: '',
  //           taxNumber: information['gstno']);
  //       ledgerModel =  cModel;
  //       nameControl.text = cModel.id == acId ?  cashAc :cModel.name!;
  //       selectedCustomerId =  cModel.id;
  //       addressControl.text = cModel.address1!;
  //       siteNameControl.text = cModel.address2!;
        
  //       // api
  //       //     .getCustomerDetail(ledgerModel.id)
  //       //     .then((ledgerData) => accountModel = ledgerData);
  //       ScopedModel.of<MainModel>(context).addCustomer(cModel);
  // //       cartModel =
  // // cartItem.elementAt(position!);
  //       for (var product in particulars) {
  //         addProduct(  
  //             CartItem(
  //                 stock: 0,
  //                 minimumRate: 0,
  //                 id: totalItem + 1,
  //                 itemId: product['itemId'],
  //                 itemName: product['itemname'],
  //                 quantity: double.tryParse(product['Qty'].toString())!,
  //                 rate: double.tryParse(product['Rate'].toString())!,
  //                 rRate: double.tryParse(product['RealRate'].toString())!,
  //                 uniqueCode: product['UniqueCode'],
  //                 gross: double.tryParse(product['GrossValue'].toString())!,
  //                 discount: double.tryParse(product['Disc'].toString())!,
  //                 discountPercent:
  //                     double.tryParse(product['DiscPersent'].toString())!,
  //                 rDiscount: double.tryParse(product['RDisc'].toString())!,
  //                 fCess: double.tryParse(product['Fcess'].toString())!,
  //                 serialNo: product['serialno'].toString(),
  //                 tax: double.tryParse(product['CGST'].toString())! +
  //                     double.tryParse(product['SGST'].toString())! +
  //                     double.tryParse(product['IGST'].toString())!,
  //                 taxP: double.tryParse(product['igst'].toString())!,
  //                 unitId: product['Unit'],
  //                 unitValue: double.tryParse(product['UnitValue'].toString())!,
  //                 pRate: double.tryParse(product['Prate'].toString())!,
  //                 rPRate: double.tryParse(product['Rprate'].toString())!,
  //                 barcode: product['UniqueCode'],
  //                 expDate: '2020-01-01',
  //                 free: double.tryParse(product['freeQty'].toString())!,
  //                 fUnitId: int.tryParse(product['Funit'].toString())!,
  //                 cdPer: 0, //product['']cdPer,
  //                 cDisc: 0, //product['']cDisc,
  //                 net: double.tryParse(product['Net'].toString())!, //subTotal,
  //                 cess: double.tryParse(product['cess'].toString())!, //cess,
  //                 total: double.tryParse(product['Total'].toString())!, //total,
  //                 profitPer: 0, //product['']profitPer,
  //                 fUnitValue: double.tryParse(
  //                     product['FValue'].toString())!, //fUnitValue,
  //                 adCess:
  //                     double.tryParse(product['adcess'].toString())!, //adCess,
  //                 iGST: double.tryParse(product['IGST'].toString())!,
  //                 cGST: double.tryParse(product['CGST'].toString())!,
  //                 sGST: double.tryParse(product['SGST'].toString())!,
  //                 cessPer: double.tryParse(product['cessper'].toString())!,
  //                 adCessPer: double.tryParse(product['adcessper'].toString())!,
  //                 ),
                  
  //             -1);
  //       } 
  //       userDateCheck(information['DDate'].toString());
  //     }

  //     setState(() {
  //       widgetID = false;
  //       grandTotal = billTotal - returnAmount;
  //       if (billCash > 0) {
  //         controllerCashReceived.text = billCash.toString();
  //         _balance = controllerCashReceived.text.isNotEmpty
  //             ? grandTotal > 0
  //                 ? grandTotal - double.tryParse(controllerCashReceived.text)!
  //                 : ((totalCartValue) -
  //                     double.tryParse(controllerCashReceived.text)!)
  //             : grandTotal > 0
  //                 ? grandTotal
  //                 : totalCartValue;
  //       }
  //       if (returnAmount > 0) {
  //         returnAmountController.text = returnAmount.toString();
  //         returnEntryNoController.text = returnBillId.toString();
  //       }
  //       // nextWidget = 4;
        
  //       editItem = true;
  //       oldBill = true;
  //     });
  //     // Navigator.pushReplacementNamed(context, '/preview_show',
  //     // arguments: {'title': 'Sale'});
  //   });
  // }

  //   double totalGrossValue = 0;
  // double totalDiscount = 0;
  // double totalNet = 0;
  // double totalCess = 0;
  // double totalIgST = 0;
  // double totalCgST = 0;
  // double totalSgST = 0;
  // double totalFCess = 0;
  // double totalAdCess = 0;
  // double totalRDiscount = 0;
  // double taxTotalCartValue = 0;
  // double totalCartValue = 0;
  // double totalProfit = 0;
  // int get totalItem => cartItem.length;

  //   void calculateTotal() {
  //   totalGrossValue = 0;
  //   totalDiscount = 0;
  //   totalRDiscount = 0;
  //   totalNet = 0;
  //   totalCess = 0;
  //   totalIgST = 0;
  //   totalCgST = 0;
  //   totalSgST = 0;
  //   totalFCess = 0;
  //   totalAdCess = 0;
  //   taxTotalCartValue = 0;
  //   totalCartValue = 0;
  //   totalProfit = 0;
  //   grandTotal = 0;

  //   for (var f in cartItem) {
  //     totalGrossValue += f.!;
  //     totalDiscount += f.discount!;
  //     totalRDiscount += f.rDiscount!;
  //     totalNet += f.net!;
  //     totalCess += f.cess!;
  //     totalIgST += f.iGST!;
  //     totalCgST += f.cGST!;
  //     totalSgST += f.sGST!;
  //     totalFCess += f.fCess!;
  //     totalAdCess += f.adCess!;
  //     taxTotalCartValue += f.tax!;
  //     totalCartValue += f.total!;
  //     totalProfit += f.profitPer!;
  //   }
  //   grandTotal = (totalCartValue - returnAmount) +
  //       otherAmountList.fold(
  //           0.0,
  //           (t, e) =>
  //               t +
  //               double.parse(e['Symbol'] == '-'
  //                   ? (e['Amount'] * -1).toString()
  //                   : e['Amount'].toString()));
  // }
}
