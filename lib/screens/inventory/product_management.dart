
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sheraccerp/models/company.dart';
import 'package:sheraccerp/models/product_manage_model.dart';
import 'package:sheraccerp/scoped-models/mains.dart';
import 'package:sheraccerp/service/api_dio.dart';
import 'package:sheraccerp/shared/constants.dart';
import 'package:intl/intl.dart';
import 'package:sheraccerp/util/dateUtil.dart';
import 'package:sheraccerp/util/res_color.dart';
import 'package:sheraccerp/widget/progress_hud.dart';

class ProductManagement extends StatefulWidget {
  ProductManagement({Key? key}) : super(key: key);

  @override
  State<ProductManagement> createState() => _ProductManagementState();
}

class _ProductManagementState extends State<ProductManagement> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  DioService api = DioService();
  DataJson ?productModel;
  Size ?deviceSize;
  String productId = '';
  List<DataJson> productList = [];
  bool _isLoading = false, isExist = false, buttonEvent = false;
  bool taxGroupUpdate = false;
  String ?_result;

  @override
  void initState() {
    CompanyInformation companySettings =
        ScopedModel.of<MainModel>(context).getCompanySettings();
    List<CompanySettings> settings =
        ScopedModel.of<MainModel>(context).getSettings();
    taxGroupUpdate = 
        ComSettings.getStatus('KEY TAXGROUP UPDATE', settings!);     
    
    api.fetchAllProductPurchase(taxGroupUpdate).then((value) {
      setState(() {
        for (var data in value) {
          productList.add(DataJson(id: data.slNo, name: data.itemName));
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    deviceSize = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: bagroundColor,
          key: _scaffoldKey,
          appBar: AppBar(
            title: const Text('Product Management'),
            titleTextStyle: const TextStyle(
              fontFamily: 'poppins',
              color: white
            ),
            actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () async {
                var result = await showSearch<List<DataJson>>(
                  context: context,
                  delegate: CustomDelegateProduct(productList),
                );
                setState(() {
                  _result = result![0].name;
                  productId = result[0].id.toString();
                  if (productId.isNotEmpty) {
                    findProductDetails(productId);
                  }
                });
              },
            ),
          ]),
          body: ProgressHUD(
              inAsyncCall: _isLoading, opacity: 0.0, child: formWidget())),
    );
  }

  int nextWidget = 0;
  List<ProductManageModel> productData = [];
  ProductManageModel ?productSingle;
  DateTime now = DateTime.now();

  TextEditingController controllerOBarcode = TextEditingController();
  TextEditingController controllerMrp = TextEditingController();
  TextEditingController controllerRetail = TextEditingController();
  TextEditingController controllerSPRetail = TextEditingController();
  TextEditingController controllerWholeSale = TextEditingController();
  TextEditingController controllerBranch = TextEditingController();

  String oBarcode = '';
  double quantity = 0,
      mrp = 0,
      retail = 0,
      spRetail = 0,
      wholeSale = 0,
      branch = 0;
  int _index = 0,
      rackId = 0;

  formWidget() {
    return nextWidget == 0
        ? const Center(
            child: Text('Select Product',
            style: TextStyle(
              fontFamily: 'poppins'
            ),
            ),
          )
        : nextWidget == 1
            ? productData.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    // shrinkWrap: true,
                    itemCount: productData.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8
                          ),
                          decoration: BoxDecoration(
                            boxShadow: const[
                              BoxShadow(
                                blurRadius: .2,
                                spreadRadius: .2,
                                color: grey
                              )
                            ],
                            color: white,
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(
                            color: grey
                          )),
                          child: ListTile(
                              title: Text(
                                  '${productData[index].uniquecode} $_result')),
                        ),
                        onTap: () {
                          setState(() {
                            _index = index;
                            productSingle = productData[index];
                            controllerMrp.text =
                                productSingle!.mrp.toStringAsFixed(2);
                            controllerRetail.text =
                                productSingle!.retail.toStringAsFixed(2);
                            controllerSPRetail.text =
                                productSingle!.spretail.toStringAsFixed(2);
                            controllerWholeSale.text =
                                productSingle!.wSrate.toStringAsFixed(2);
                            controllerBranch.text =
                                productSingle!.branch.toStringAsFixed(2);
                            controllerOBarcode.text = productSingle!.obarcode;
                            rackId = productSingle!.rackId;
                            nextWidget = 2;
                          });
                        },
                      );
                    })
            : nextWidget == 2
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Text('Item : $_result',
                              style: const TextStyle(
                                fontFamily: 'poppins',
                                fontSize: 15,
                                fontWeight: FontWeight.w500
                              ),
                              )),
                          Row(
                            children: [
                              Expanded(
                                  child: MaterialButton(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(3)
                                    ),
                                onPressed: () {
                                  setState(() {
                                    nextWidget = 1;
                                    clearValue();
                                  });
                                },
                                color: kPrimaryColor,
                                child: const Text("Back",
                                style: TextStyle(
                                  fontFamily: 'poppins',
                                  color: white
                                ),
                                ),
                              )),
                              const SizedBox(
                                width: 4,
                              ),
                              Expanded(
                                  child: MaterialButton(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(3)
                                    ),
                                onPressed: () {
                                  setState(() {
                                    nextWidget = 0;
                                  });
                                },
                                child: const Text("Cancel",
                                style: TextStyle(
                                  fontFamily: 'poppins',
                                  color: white
                                ),
                                ),
                                color: kPrimaryColor,
                              )),
                              const SizedBox(
                                width: 4,
                              ),
                              Expanded(
                                  child: MaterialButton(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(3)
                                    ),
                                onPressed: () {
                                  setState(() {
                                    oBarcode =
                                        controllerOBarcode.text.isNotEmpty
                                            ? controllerOBarcode.text
                                            : '';
                                    mrp = (controllerMrp.text.isNotEmpty
                                        ? double.tryParse(controllerMrp.text)
                                        : mrp)!;
                                    retail = (controllerRetail.text.isNotEmpty
                                        ? double.tryParse(controllerRetail.text)
                                        : retail)!;
                                    wholeSale =
                                        (controllerWholeSale.text.isNotEmpty
                                            ? double.tryParse(
                                                controllerWholeSale.text)
                                            : wholeSale)!;
                                    spRetail =
                                        (controllerSPRetail.text.isNotEmpty
                                            ? double.tryParse(
                                                controllerSPRetail.text)
                                            : spRetail)!;
                                    branch = (controllerBranch.text.isNotEmpty
                                        ? double.tryParse(controllerBranch.text)
                                        : branch)!;
                                    if (productSingle!.uniquecode
                                        .toString()
                                        .isNotEmpty) {
                                      productSingle!.obarcode = oBarcode;
                                      productSingle!.mrp = mrp;
                                      productSingle!.retail = retail;
                                      productSingle!.spretail = spRetail;
                                      productSingle!.wSrate = wholeSale;
                                      productSingle!.branch = branch;
                                      productSingle!.rackId = rackId;
                                      productData.removeAt(_index);
                                      productData.insert(_index, productSingle!);
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      updateData();
                                      //   clearValue();
                                      //   editItem = false;
                                    }
                                  });
                                },
                                color: kPrimaryColor,
                                child: const Text("Add",
                                style: TextStyle(
                                  fontFamily: 'poppins',
                                  color: white
                                ),
                                ),
                              )),
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          TextField(
                            controller: controllerOBarcode,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 8
                              ),
                                border: OutlineInputBorder(),
                                labelStyle: TextStyle(
                                  fontFamily: 'poppins',
                                ),
                                label: Text('Old Barcode')),
                            onChanged: (value) {
                              setState(() {
                                // editableRate = true;
                                oBarcode = value;
                              });
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  width: MediaQuery.sizeOf(context).width,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                        const Text('Mrp',
                                  style: TextStyle(
                                    fontFamily: 'poppins',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500
                                  ),
                                  ),
                                SizedBox(
                                  height: 30,
                                  width: 100,
                                  child: TextField(
                                    controller: controllerMrp,
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 5
                                      ),
                                        border: OutlineInputBorder(),),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter(
                                          RegExp(r'[0-9]'),
                                          allow: true,
                                          replacementString: '.')
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        // editableMrp = true;
                                        mrp = double.tryParse(value)?? 0.0;
                                      });
                                    },
                                  ),
                                ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              Expanded(child: 
                               Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Retail',
                               style: TextStyle(
                                    fontFamily: 'poppins',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500
                                  ),
                              ),
                              SizedBox(
                                height: 30,
                                width: 100,
                                child: TextField(
                                  controller: controllerRetail,
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                       contentPadding: EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 5
                                      ),),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter(
                                        RegExp(r'[0-9]'),
                                        allow: true,
                                        replacementString: '.')
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      // editableRetail = true;
                                      retail = double.tryParse(value)?? 0.0;
                                      // calculateRate();
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                              )
                            ],
                          ),
                         
                          const SizedBox(
                            height: 4,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  width: MediaQuery.sizeOf(context).width,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                       const Text('WholeSale',
                                          style: TextStyle(
                                    fontFamily: 'poppins',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500
                                  ),
                                       ),
                              SizedBox(
                                height: 30,
                                width: 100,
                                child: TextField(
                                  controller: controllerWholeSale,
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                       contentPadding: EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 5
                                      ),),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter(
                                        RegExp(r'[0-9]'),
                                        allow: true,
                                        replacementString: '.')
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      // editableWSale = true;
                                      wholeSale = double.tryParse(value)?? 0.0;
                                      // calculateRate();
                                    });
                                  },
                                ),
                              ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              Expanded(child: 
                              SizedBox(
                                width: MediaQuery.sizeOf(context).width,
                                child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Branch',
                                 style: TextStyle(
                                    fontFamily: 'poppins',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500
                                  ),
                              ),
                              SizedBox(
                                height: 30,
                                width: 100,
                                child: TextField(
                                  controller: controllerBranch,
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                       contentPadding: EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 5
                                      ),),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter(
                                        RegExp(r'[0-9]'),
                                        allow: true,
                                        replacementString: '.')
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      // editableBranch = true;
                                      branch = double.tryParse(value)?? 0.0;
                                      // calculateRate();
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                              )
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                           Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            // mainAxisAlignment: MainAxisAlignment.end,
                             children: [
                               SizedBox(
                                 width: MediaQuery.sizeOf(context).width/2.2,
                                 child: Row(
                                  // crossAxisAlignment: CrossAxisAlignment.start,
                                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                           children: [
                               const Text('SpRetail',
                                  style: TextStyle(
                                     fontFamily: 'poppins',
                                     fontSize: 14,
                                     fontWeight: FontWeight.w500
                                   ),
                               ),
                               SizedBox(
                                 height: 30,
                                 width: 100,
                                 child: TextField(
                                   controller: controllerSPRetail,
                                   decoration: const InputDecoration(
                                       border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                         horizontal: 5,
                                         vertical: 5
                                       ),),
                                   keyboardType:
                                       const TextInputType.numberWithOptions(
                                           decimal: true),
                                   inputFormatters: [
                                     FilteringTextInputFormatter(
                                         RegExp(r'[0-9]'),
                                         allow: true,
                                         replacementString: '.')
                                   ],
                                   onChanged: (value) {
                                     setState(() {
                                       // editableBranch = true;
                                       spRetail = double.tryParse(value) ?? 0.0;
                                       // calculateRate();
                                     });
                                   },
                                 ),
                               ),
                                                           ],
                                                      ),
                               ),
                             ],
                           )
                        ],
                      ),
                    ),
                  )
                : nextWidget == 3
                    ? const Center(
                        child: Text('Product Updated'),
                      )
                    : nextWidget == 4
                        ? const Center(
                            child: Text('Update Error'),
                          )
                        : const Center(
                            child: Text('No widget'),
                          );
  }

  void findProductDetails(String productId) {
    productData = [];
    var date =
        getToDay.isNotEmpty ? getToDay : DateFormat('dd-MM-yyyy').format(now);
    api.fetchProductDetails(productId, DateUtil.dateYMD(date)).then((data) {
      productData.addAll(data);
      setState(() {
        nextWidget = 1;
      });
    });
  }

  void clearValue() {
    controllerOBarcode.text = '';
    controllerMrp.text = '';
    controllerRetail.text = '';
    controllerSPRetail.text = '';
    controllerWholeSale.text = '';
    controllerBranch.text = '';
    productSingle = null;
    _index = 0;
  }

  void updateData() {
    debugPrint(json.encode(productData));
    api.updateProductDetails(productData).then((value) {
      setState(() {
        value ? nextWidget = 3 : nextWidget = 4;
        _isLoading = false;
      });
    });
  }
}

class CustomDelegateProduct extends SearchDelegate<List<DataJson>> {
  List<DataJson> data;
  CustomDelegateProduct(this.data);

  @override
  List<Widget> buildActions(BuildContext context) =>
      [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
      icon: const Icon(Icons.chevron_left),
      onPressed: () => close(context, []));

  @override
  Widget buildResults(BuildContext context) => Container();

  @override
  Widget buildSuggestions(BuildContext context) {
    List<DataJson> listToShow;
    if (query.isNotEmpty) {
      listToShow = data
          .where((e) =>
              e.name!.toLowerCase().contains(query.toLowerCase()) &&
              e.name!.toLowerCase().startsWith(query.toLowerCase()))
          .toList();
    } else {
      listToShow = data;
    }
    return ListView.builder(
      itemCount: listToShow.length,
      itemBuilder: (_, i) {
        var noun = listToShow[i];
        return ListTile(
          title: Text(noun.name!),
          onTap: () => close(context, [noun]),
        );
      },
    );
  }
}
