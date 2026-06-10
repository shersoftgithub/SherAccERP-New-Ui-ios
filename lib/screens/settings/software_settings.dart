import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sheraccerp/models/company.dart';
import 'package:sheraccerp/models/sales_type.dart';
import 'package:sheraccerp/scoped-models/mains.dart';
import 'package:sheraccerp/screens/inventory/sales/sales_form_register.dart';
import 'package:sheraccerp/screens/inventory/sales/sales_other_detail_register.dart';
import 'package:sheraccerp/screens/settings/sms_settings.dart';
import 'package:sheraccerp/service/api_dio.dart';
import 'package:sheraccerp/shared/constants.dart';
import 'package:sheraccerp/util/res_color.dart';
import 'package:sheraccerp/widget/appbar_custom_widget.dart';
import 'package:sheraccerp/widget/container_textfield_widget.dart';
import 'package:sheraccerp/widget/loading.dart';

class SoftwareSettings extends StatefulWidget {
  const SoftwareSettings({Key? key}) : super(key: key);

  @override
  State<SoftwareSettings> createState() => _SoftwareSettingsState();
}

class _SoftwareSettingsState extends State<SoftwareSettings> {
  List<CompanySettings> _settingsList = [];
  List<CompanySettings> settingsData = [];
  List<CompanySettings> settingsDisplayList = [];
  DioService dio = DioService();
  late CompanyInformation _companySettings;
  List<CompanySettings> _settings = [];
  String toolBarSale = '',
      toolBarSaleId = '0',
      cashAC = '',
      stockValue = '',
      defaultLocation = '',
      decimalPoint = '',
      boxColor = '',
      toolBarColor = '',
      backhand = '',
      keySerialNoTitle = '',
      keyEWayApi = '',
      keyItemSPTitle = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    settingsDisplayList = [];
    _settingsList = [];

    _companySettings = ScopedModel.of<MainModel>(context).getCompanySettings();
    _settings = ScopedModel.of<MainModel>(context).getSettings();

    toolBarSaleId =
        ComSettings.getValue('TOOLBAR SALES', _settings).toString().trim() ??
            '1';
    toolBarSaleId = ComSettings.oKNumeric(toolBarSaleId) ? toolBarSaleId : '1';
    cashAC =
        ComSettings.getValue('CASH A/C', _settings).toString().trim() ?? 'CASH';
    controllerCashAc.text = cashAC;
    decimalPoint =
        ComSettings.getValue('DECIMAL', _settings).toString().trim() ?? '2';
    controllerDecimalPoint.text = decimalPoint;
    boxColor = ComSettings.getValue('BOXCOLOR', _settings).toString().trim() ??
        '-8323200';
    stockValue =
        ComSettings.getValue('STOCK METHODE', _settings).toString().trim() ??
            'AVERAGE VALUE';
    controllerStockValuation.text = stockValue;
    defaultLocation =
        ComSettings.getValue('DEFAULT LOCATION', _settings).toString().trim() ??
            'SHOP';
    controllerDefaultLocation.text = defaultLocation;
    toolBarColor =
        ComSettings.getValue('TOOLBARCOLOR', _settings).toString().trim() ??
            '16777215';
    toolBarColor = toolBarColor.isEmpty ? '16777215' : toolBarColor;
    keySerialNoTitle = ComSettings.getValue('KEY ITEM SERIAL NO', _settings)
            .toString()
            .trim() ??
        '';
    keyEWayApi = ComSettings.getValue('KEY EWAYBILLAPI OWNER', _settings)
            .toString()
            .trim() ??
        'SHERSOFT';
    keyItemSPTitle = ComSettings.getValue('KEY ITEM SP RATE TITLE', _settings)
            .toString()
            .trim() ??
        '';

    load();
  }

  List<String> cashListDisplay = [];
  List<String> locationListDisplay = [];
  List<String> saleTypeListDisplay = [];
  FocusNode focusNodeKeySerialNoTitle = FocusNode();
  FocusNode focusNodeKeyEWayApi = FocusNode();
  FocusNode focusNodeKeyItemSPTitle = FocusNode();
  SalesType? currentType;

  @override
  void dispose() {
    focusNodeKeyEWayApi.dispose();
    focusNodeKeyItemSPTitle.dispose();
    focusNodeKeySerialNoTitle.dispose();
    controllerKeyEWayApi.removeListener(controllerKeyEWayApiListener);
    controllerKeyItemSPTitle.removeListener(controllerKeyItemSPTitleListener);
    controllerKeySerialNoTitle
        .removeListener(controllerKeySerialNoTitleListener);
    super.dispose();
  }

  load() {
    if (_settings.isNotEmpty && _settings.first.id! > 0) {
      setState(() {
        _settingsList.addAll(_settings);
        settingsData = _settingsList;
        settingsDisplayList = _settingsList;
      });
    } else {
      dio.getSoftwareSettings().then((value) {
        setState(() {
          _settingsList.addAll(value);
          settingsData = _settingsList;
          settingsDisplayList = _settingsList;
        });
      });
    }
    if (cashAccount.isNotEmpty) {
      List<dynamic> listData = cashAccount;
      setState(() {
        cashListDisplay.addAll(List<String>.from(listData
            .map((item) => (item.value))
            .toList()
            .map((s) => s)
            .toList()));
        cashListDisplay.remove("");
      });
    }
    if (salesTypeList.isNotEmpty) {
      toolBarSale = salesTypeList
          .firstWhere((element) => element.id.toString() == toolBarSaleId)
          .type;
      controllerToolBarSales.text = toolBarSale;
      currentType = salesTypeList
          .firstWhere((element) => element.id.toString() == toolBarSaleId);
      setState(() {
        saleTypeListDisplay.addAll(List<String>.from(salesTypeList
            .map((item) => (item.type))
            .toList()
            .map((s) => s)
            .toList()));
      });
    }
    if (locationList.isNotEmpty) {
      List<dynamic> listData = locationList;
      setState(() {
        locationListDisplay.addAll(List<String>.from(listData
            .map((item) => (item.value))
            .toList()
            .map((s) => s)
            .toList()));
        locationListDisplay.remove("");
      });
    }

    controllerKeyEWayApi.addListener(controllerKeyEWayApiListener);
    controllerKeyItemSPTitle.addListener(controllerKeyItemSPTitleListener);
    controllerKeySerialNoTitle.addListener(controllerKeySerialNoTitleListener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(100),
            child: AppbarWidgget(
              headTxt: 'General',
              onPressed: () {
                Navigator.pop(context);
              },
              iconFirst: Image.asset('assets/icons/ic_filter.png',scale: 3.3,),
              onTapFirst: () {
                setState(() {
                  settingsDisplayList = _settingsList;
                });
              },
              iconSecondPath: isLoading ? SizedBox(
                width: 25,
                height: 25,
                child: const FittedBox(
                  fit: BoxFit.fitHeight,
                  child: CircularProgressIndicator(
                    backgroundColor: white,
                  ),
                ),
              )
              :Image.asset('assets/icons/Save instagram@2x.png',
              scale: 1.6,
              ),
              onTapSecond: () {
                setState(() {
                  isLoading = true;
                  saveData();
                });
              },
            )),
        // AppBar(actions: [
        //   IconButton(
        //       onPressed: () {
        //         setState(() {
        //           settingsDisplayList = _settingsList;
        //         });
        //       },
        //       icon: const Icon(Icons.filter_alt)),
        //   IconButton(
        //       onPressed: () {
        //         setState(() {
        //           isLoading = true;
        //           saveData();
        //         });
        //       },
        //       icon: const Icon(Icons.save)),
        // ], title: const Text('General')),
        body: _settingsList.isEmpty ? const Loading() : loadData());
  }

  TextEditingController controllerCashAc = TextEditingController();
  TextEditingController controllerToolBarSales = TextEditingController();
  TextEditingController controllerStockValuation = TextEditingController();
  TextEditingController controllerDefaultLocation = TextEditingController();
  TextEditingController controllerDecimalPoint = TextEditingController();
  TextEditingController controllerKeyItemSPTitle = TextEditingController();
  TextEditingController controllerKeyEWayApi =
      TextEditingController(text: 'SHERSOFT');
  TextEditingController controllerKeySerialNoTitle = TextEditingController();
  TextEditingController controllerHeadOfficeDB = TextEditingController();
  TextEditingController controllerDecimalPointOnReports =
      TextEditingController(text: "2");

  GlobalKey<AutoCompleteTextFieldState<String>> keyCashAc = GlobalKey();
  GlobalKey<AutoCompleteTextFieldState<String>> keySalesType = GlobalKey();
  GlobalKey<AutoCompleteTextFieldState<String>> keyStockType = GlobalKey();
  GlobalKey<AutoCompleteTextFieldState<String>> keyLocationType = GlobalKey();

  loadData() {
    return DefaultTabController(
        length: 2,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
              backgroundColor: bagroundColor,
              // appBar: AppBar(
              //   backgroundColor: blue,
              //   automaticallyImplyLeading: false,
              //   flexibleSpace:
              // ),
              body: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    Container(
                      color: const Color(0xff1B22BA),
                      child: TabBar(
                        dividerColor: white,
                        indicator: const BoxDecoration(color: kPrimaryColor),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerHeight: 0,
                        // indicatorWeight: 5,
                        tabs: [
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset('assets/icons/options_icon.png'),
                                const SizedBox(width: 10),
                                const Text('Option'),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset('assets/icons/value_icon.png'),
                                const SizedBox(width: 10),
                                const Text('Value'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(
                        flex: 1,
                        child: TabBarView(children: [
                          Padding(
      padding: const EdgeInsets.all(1.0),
      child: Column(
        children: [
          _searchBar(),
          Expanded(
            child: ListView.builder(
              itemCount: settingsDisplayList.length,
              itemBuilder: (BuildContext context, int index) {
                return _listItem(index);
              },
            ),
          ),
        ],
      ),
    ),
                          // Padding(
                          //   padding: const EdgeInsets.all(1.0),
                          //   child: ListView.builder(
                          //       itemCount: settingsDisplayList.length,
                          //       itemBuilder: (BuildContext context, int index) {
                          //         return index == 0
                          //             ? _searchBar()
                          //             : _listItem(index - 1);
                          //       }),
                          // ),
                          ListView(children: [
                            const SizedBox(
                              height: 10,
                            ),
                            // SizedBox(
                            //   height: 40,
                            //   child: Card(
                            //     elevation: 5,
                            //     child: Row(
                            //       mainAxisAlignment:
                            //           MainAxisAlignment.spaceEvenly,
                            //       children: [
                            //         const Text('Select Color '),
                            //         Text(boxColor),
                            //       ],
                            //     ),
                            //   ),
                            // ),
                            ContainerFieldWidget(
                                widget: EasyAutocomplete(
                                  // key: keyCashAc,
                                  controller: controllerCashAc,
                                  // clearOnSubmit: false,
                                  suggestions: cashListDisplay,
                                  decoration: const InputDecoration(
                                    hintText: 'Select Cash A/C',
                                    hintStyle: TextStyle(
                                        fontFamily: 'poppins', color: grey),
                                    border: OutlineInputBorder(),
                                  ),
                                  onSubmitted: (data) {
                                    setState(() {
                                      cashAC = data;
                                    });
                                  },
                                ),
                                headTxt: 'Company Cash A/C'),
                            // Card(
                            //   elevation: 5,
                            //   child: Row(
                            //     mainAxisAlignment:
                            //         MainAxisAlignment.spaceEvenly,
                            //     children: [
                            //       const Text('Company Cash A/C        '),
                            //       Expanded(
                            //           child: SizedBox(
                            //         height: 40,
                            //         child:
                            //       )),
                            //     ],
                            //   ),
                            // ),
                            const SizedBox(
                              height: 10,
                            ),
                            ContainerFieldWidget(
                                widget: EasyAutocomplete(
                                  // key: keySalesType,
                                  controller: controllerToolBarSales,
                                  // clearOnSubmit: false,
                                  suggestions:
                                      salesTypeList.map((e) => e.type).toList(),
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintStyle: TextStyle(
                                          fontFamily: 'poppins', color: grey),
                                      hintText: 'Select Sale'),
                                  onSubmitted: (data) {
                                    setState(() {
                                      toolBarSale = data;
                                      toolBarSaleId = salesTypeList
                                          .firstWhere(
                                              (element) =>
                                                  element.type.toString() ==
                                                  toolBarSale,
                                              orElse: () => currentType!)
                                          .id
                                          .toString();
                                    });
                                  },
                                ),
                                headTxt: 'ToolBar Sale'),
                            const SizedBox(
                              height: 10,
                            ),
                            ContainerFieldWidget(
                                widget: EasyAutocomplete(
                                  // key: keyStockType,
                                  controller: controllerStockValuation,
                                  // clearOnSubmit: false,
                                  suggestions: stockValuationData,
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintStyle: TextStyle(
                                          fontFamily: 'poppins', color: grey),
                                      hintText: 'Select Stock Value'),
                                  onSubmitted: (data) {
                                    setState(() {
                                      stockValue = data;
                                    });
                                  },
                                ),
                                headTxt: 'Select Stock Value'),
                            const SizedBox(
                              height: 10,
                            ),
                            ContainerFieldWidget(
                                widget: EasyAutocomplete(
                                  // key: keyLocationType,
                                  controller: controllerDefaultLocation,
                                  // clearOnSubmit: false,
                                  suggestions: locationListDisplay,
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintStyle: TextStyle(
                                          fontFamily: 'poppins', color: grey),
                                      hintText: 'Select Location'),
                                  onSubmitted: (data) {
                                    setState(() {
                                      defaultLocation = data;
                                    });
                                  },
                                ),
                                headTxt: 'Default Location'),
                            const SizedBox(
                              height: 10,
                            ),
                            ContainerFieldWidget(
                                widget: TextField(
                                  controller: controllerDecimalPoint,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(),
                                  decoration: const InputDecoration(
                                      hintText: 'Select Decimal',
                                      hintStyle: TextStyle(
                                          fontFamily: 'poppins', color: grey),
                                      border: OutlineInputBorder()),
                                ),
                                headTxt: 'Decimal Point'),
                            const SizedBox(
                              height: 10,
                            ),
                            ContainerFieldWidget(
                                widget: TextField(
                                  focusNode: focusNodeKeySerialNoTitle,
                                  controller: controllerKeySerialNoTitle,
                                  decoration: const InputDecoration(
                                      hintText: 'SerialNo Title',
                                      hintStyle: TextStyle(
                                          fontFamily: 'poppins', color: grey),
                                      border: OutlineInputBorder()),
                                ),
                                headTxt: 'Serial No Title'),
                            const SizedBox(
                              height: 10,
                            ),
                            ContainerFieldWidget(
                                widget: TextField(
                                  focusNode: focusNodeKeyEWayApi,
                                  controller: controllerKeyEWayApi,
                                  decoration: const InputDecoration(
                                      hintText: 'API Owner',
                                      hintStyle: TextStyle(
                                          fontFamily: 'poppins', color: grey),
                                      border: OutlineInputBorder()),
                                ),
                                headTxt: 'EWay Api Owner'),
                            const SizedBox(
                              height: 10,
                            ),
                            ContainerFieldWidget(
                                widget: TextField(
                                  focusNode: focusNodeKeyItemSPTitle,
                                  controller: controllerKeyItemSPTitle,
                                  decoration: const InputDecoration(
                                      hintText: 'SpecialRateTitle',
                                      hintStyle: TextStyle(
                                          fontFamily: 'poppins', color: grey),
                                      border: OutlineInputBorder()),
                                ),
                                headTxt: 'Item Special Rate Title'),
                            const SizedBox(
                              height: 10,
                            ),
                            ContainerFieldWidget(
                                widget: TextField(
                                  controller: controllerHeadOfficeDB,
                                  decoration: const InputDecoration(
                                      hintText: 'Select DB',
                                      hintStyle: TextStyle(
                                          fontFamily: 'poppins', color: grey),
                                      border: OutlineInputBorder()),
                                ),
                                headTxt: 'Head Of DB'),
                            const SizedBox(
                              height: 10,
                            ),
                            ContainerFieldWidget(
                                widget: TextField(
                                  keyboardType:
                                      const TextInputType.numberWithOptions(),
                                  controller: controllerDecimalPointOnReports,
                                  decoration: const InputDecoration(
                                      hintText: 'Select Decimal',
                                      hintStyle: TextStyle(
                                          fontFamily: 'poppins', color: grey),
                                      border: OutlineInputBorder()),
                                ),
                                headTxt: 'Decimal Point On Rate'),
                            const SizedBox(
                              height: 10,
                            ),
                            // SizedBox(
                            //   height: 40,
                            //   child: Card(
                            //     elevation: 5,
                            //     child: Row(
                            //       mainAxisAlignment:
                            //           MainAxisAlignment.spaceEvenly,
                            //       children: [
                            //         const Text('Toolbar Color '),
                            //         Text(toolBarColor),
                            //       ],
                            //     ),
                            //   ),
                            // ),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5)),
                                    backgroundColor: kPrimaryColor),
                                onPressed: () {
                                  var _pass = '';
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(
                                                20.0,
                                              ),
                                            ),
                                          ),
                                          contentPadding: const EdgeInsets.only(
                                            top: 10.0,
                                          ),
                                          title: const Text(
                                            "Enter Password",
                                            style: TextStyle(
                                                fontSize: 24.0,
                                                fontFamily: 'poppins'),
                                          ),
                                          content: SizedBox(
                                            height: 400,
                                            child: SingleChildScrollView(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  const Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: Text(
                                                      "Enter Your Password",
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'poppins'),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: TextField(
                                                      decoration:
                                                          const InputDecoration(
                                                              border:
                                                                  OutlineInputBorder(),
                                                              hintText:
                                                                  'Enter password',
                                                              labelText:
                                                                  'password'),
                                                      obscureText: true,
                                                      onChanged: (value) =>
                                                          _pass = value,
                                                    ),
                                                  ),
                                                  Container(
                                                    width: double.infinity,
                                                    height: 60,
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        if (_pass ==
                                                            softwarePassword) {
                                                          Navigator.of(context)
                                                              .pop();
                                                          Navigator.of(context).push(
                                                              MaterialPageRoute(
                                                                  builder: (BuildContext
                                                                          context) =>
                                                                      const SalesFormRegister()));
                                                        } else {
                                                          Fluttertoast.showToast(
                                                              msg:
                                                                  'incorrect password');
                                                          Navigator.of(context)
                                                              .pop();
                                                        }
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5)),
                                                        backgroundColor:
                                                            kPrimaryColor,
                                                        // fixedSize: Size(250, 50),
                                                      ),
                                                      child: const Text(
                                                        "Submit",
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'poppins',
                                                            color: white),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      });
                                },
                                child: const Text(
                                  'Sales Forms Register',
                                  style: TextStyle(
                                      fontFamily: 'poppins', color: white),
                                )),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5)),
                                    backgroundColor: kPrimaryColor),
                                onPressed: () {
                                  var _pass = '';
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(
                                                20.0,
                                              ),
                                            ),
                                          ),
                                          contentPadding: const EdgeInsets.only(
                                            top: 10.0,
                                          ),
                                          title: const Text(
                                            "Enter Password",
                                            style: TextStyle(
                                                fontSize: 24.0,
                                                fontFamily: 'poppins'),
                                          ),
                                          content: SizedBox(
                                            height: 400,
                                            child: SingleChildScrollView(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  const Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: Text(
                                                      "Enter Your Password",
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'poppins'),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: TextField(
                                                      decoration:
                                                          const InputDecoration(
                                                              border:
                                                                  OutlineInputBorder(),
                                                              hintText:
                                                                  'Enter password',
                                                              labelText:
                                                                  'password'),
                                                      obscureText: true,
                                                      onChanged: (value) =>
                                                          _pass = value,
                                                    ),
                                                  ),
                                                  Container(
                                                    width: double.infinity,
                                                    height: 60,
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        if (_pass ==
                                                            softwarePassword) {
                                                          Navigator.of(context)
                                                              .pop();
                                                          Navigator.of(context).push(
                                                              MaterialPageRoute(
                                                                  builder: (BuildContext
                                                                          context) =>
                                                                      const SalesOtherDetailRegister()));
                                                        } else {
                                                          Fluttertoast.showToast(
                                                              msg:
                                                                  'incorrect password');
                                                          Navigator.of(context)
                                                              .pop();
                                                        }
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5)),
                                                        backgroundColor:
                                                            kPrimaryColor,

                                                        // fixedSize: Size(250, 50),
                                                      ),
                                                      child: const Text(
                                                        "Submit",
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'poppins',
                                                            color: white),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      });
                                },
                                child: const Text(
                                  'Sales OtherDetails Register',
                                  style: TextStyle(
                                      fontFamily: 'poppins', color: white),
                                )),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5)),
                                    backgroundColor: kPrimaryColor),
                                onPressed: () {
                                  var _pass = '';
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(
                                                20.0,
                                              ),
                                            ),
                                          ),
                                          contentPadding: const EdgeInsets.only(
                                            top: 10.0,
                                          ),
                                          title: const Text(
                                            "Enter Password",
                                            style: TextStyle(fontSize: 24.0),
                                          ),
                                          content: SizedBox(
                                            height: 400,
                                            child: SingleChildScrollView(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  const Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: Text(
                                                      "Enter Your Password",
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: TextField(
                                                      decoration:
                                                          const InputDecoration(
                                                              border:
                                                                  OutlineInputBorder(),
                                                              hintText:
                                                                  'Enter password',
                                                              labelText:
                                                                  'password'),
                                                      obscureText: true,
                                                      onChanged: (value) =>
                                                          _pass = value,
                                                    ),
                                                  ),
                                                  Container(
                                                    width: double.infinity,
                                                    height: 60,
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        if (_pass ==
                                                            softwarePassword) {
                                                          Navigator.of(context)
                                                              .pop();
                                                          Navigator.of(context).push(
                                                              MaterialPageRoute(
                                                                  builder: (BuildContext
                                                                          context) =>
                                                                      const SmsSettings()));
                                                        } else {
                                                          Fluttertoast.showToast(
                                                              msg:
                                                                  'incorrect password');
                                                          Navigator.of(context)
                                                              .pop();
                                                        }
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5)),
                                                        backgroundColor:
                                                            kPrimaryColor,

                                                        // fixedSize: Size(250, 50),
                                                      ),
                                                      child: const Text(
                                                        "Submit",
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'poppins',
                                                            color: white),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      });
                                },
                                child: const Text(
                                  'SMS Settings',
                                  style: TextStyle(
                                      fontFamily: 'poppins', color: white),
                                )),
                          ]),
                        ])),
                  ],
                ),
              )),
        ));
  }

  _searchBar() {
    return TextField(
      decoration: const InputDecoration(
          border: OutlineInputBorder(), label: Text('Search...')),
      onChanged: (text) {
        text = text.toLowerCase();
        setState(() {
          settingsDisplayList = _settingsList.where((item) {
            var itemName = item.name.toString().toLowerCase();
            return itemName.contains(text);
          }).toList();
        });
      },
    );
  }

  _listItem(int index) {
    CompanySettings item = settingsDisplayList[index];
    // debugPrint(item.toJson());
    return item.name == 'ALLOW NEGETIVE STOCK'
    ? Container()
    : Card(
      shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(3)),
      elevation: 0,
      color: white,
      child: Column(children: [
        const SizedBox(
          height: 10,
        ),
        CheckboxListTile(
          activeColor: kPrimaryColor,
          title: Text(item.name!),
          value: item.status == 1 ? true : false,
          onChanged: (bool? val) {
            setState(() => item.status = val != null
                ? val
                    ? 1
                    : 0
                : 0);
            updateItem(item);
          },
        ),
      ]),
    );
  }

  updateItem(CompanySettings item) {
    int index = settingsData.indexWhere((element) => element.name == item.name);
    settingsData[index] = item;
  }

  saveData() {
    final body = {
      'toolBarSale': toolBarSaleId,
      'cashAC': cashAC,
      'stockValue': stockValue,
      'defaultLocation': defaultLocation,
      'decimalPoint': decimalPoint,
      'boxColor': boxColor,
      'toolBarColor': toolBarColor,
      'backhand': backhand,
      'data': settingsData
    };
    dio.updateGeneralSetting(body).then((value) {
      if (value) {
        ScopedModel.of<MainModel>(context).setSettings(settingsData);
        showInSnackBar('Settings Saved');
      } else {
        showInSnackBar('Error');
      }
    });
    dio.updateGeneralSettingMobile({
      "keySerialNo": controllerKeySerialNoTitle.text,
      "keyEWayApi": controllerKeyEWayApi.text.toString().toUpperCase(),
      "keyItemSP": controllerKeyItemSPTitle.text
    });
  }

  void showInSnackBar(String value) {
    setState(() {
      isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  void controllerKeyEWayApiListener() {
    if (controllerKeyEWayApi.text.isNotEmpty) {
      var key = 'KEY EWAYBILLAPI OWNER';
      var value = controllerKeyEWayApi.text.toString();
      var itemExist =
          settingsData.where((element) => element.name!.toUpperCase() == key);

      CompanySettings item = settingsData.firstWhere(
          (element) => element.name!.toUpperCase() == key,
          orElse: () =>
              CompanySettings(id: 0, name: key, status: 0, value: ''));
      item.value = value;
      if (item.id! > 0) {
        updateItem(item);
      } else {
        if (itemExist.isNotEmpty) {
          updateItem(item);
        } else {
          settingsData.add(item);
        }
      }
    }
  }

  void controllerKeyItemSPTitleListener() {
    if (controllerKeyItemSPTitle.text.isNotEmpty) {
      var key = 'KEY ITEM SP RATE TITLE';
      var value = controllerKeyEWayApi.text.toString();
      var itemExist =
          settingsData.where((element) => element.name!.toUpperCase() == key);

      CompanySettings item = settingsData.firstWhere(
          (element) => element.name!.toUpperCase() == key,
          orElse: () =>
              CompanySettings(id: 0, name: key, status: 0, value: ''));
      item.value = value;
      if (item.id! > 0) {
        updateItem(item);
      } else {
        if (itemExist.isNotEmpty) {
          updateItem(item);
        } else {
          settingsData.add(item);
        }
      }
    }
  }

  void controllerKeySerialNoTitleListener() {
    if (controllerKeySerialNoTitle.text.isNotEmpty) {
      var key = 'KEY ITEM SERIAL NO';
      var value = controllerKeySerialNoTitle.text.toString();
      var itemExist =
          settingsData.where((element) => element.name!.toUpperCase() == key);

      CompanySettings item = settingsData.firstWhere(
          (element) => element.name!.toUpperCase() == key,
          orElse: () =>
              CompanySettings(id: 0, name: key, status: 0, value: ''));
      item.value = value;
      if (item.id! > 0) {
        updateItem(item);
      } else {
        if (itemExist.isNotEmpty) {
          updateItem(item);
        } else {
          settingsData.add(item);
        }
      }
    }
  }
}
