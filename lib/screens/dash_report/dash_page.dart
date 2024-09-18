import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:flutter_settings_screen_ex/flutter_settings_screen_ex.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sheraccerp/models/company.dart';
import 'package:sheraccerp/scoped-models/main.dart';
import 'package:sheraccerp/service/api_dio.dart';
import 'package:sheraccerp/shared/constants.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:sheraccerp/util/dateUtil.dart';
import 'package:sheraccerp/util/res_color.dart';
import 'package:sheraccerp/widget/simple_barchart.dart';

class DashPage extends StatefulWidget {
  const DashPage({Key? key}) : super(key: key);

  @override
  State<DashPage> createState() => _DashPageState();
}

class _DashPageState extends State<DashPage> {
  String totalSales = '0';
  String totalNoSales = '0';
  String totalCashSales = '0';
  String totalNoCashSales = '0';
  String totalCreditSales = '0';
  String totalNoCreditSales = '0';
  String totalNoCustomers = '0';
  String totalNoOfRepeatCustomers = '0';
  String totalExpenses = '0';
  bool _status = false,
      _statusSalesSummary = false,
      _statusPurchaseSummary = false;
  Map<dynamic, dynamic>? responseBodyOfTotal;
  Map<dynamic, dynamic>? responseBodyOfSalesSummary;
  Map<dynamic, dynamic>? responseBodyOfPurchaseSummary;
  Map<dynamic, dynamic>? responseBodyOfTopProducts;
  Map<dynamic, dynamic>? responseBodyOfTopExpenses;
  final List<ChartSales> _salesData = [];
  final List<ChartPurchase> _purchaseData = [];
  DateTime now = DateTime.now();
  String? formattedDate, startDate, endDate;
  var dropdownBranchId = 1;
  DioService dio = DioService();

  static List<charts.Series<ChartSales, String>> _createSampleData() {
    final data = [
      ChartSales(ddate: '2014', amount: 5),
      ChartSales(ddate: '2015', amount: 25),
      ChartSales(ddate: '2016', amount: 100),
      ChartSales(ddate: '2017', amount: 75),
    ];

    return [
      charts.Series<ChartSales, String>(
        id: 'Sales',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(kPrimaryColor),
        // charts.MaterialPalette.blue.shadeDefault,
        domainFn: (ChartSales sales, _) => sales.ddate!,
        measureFn: (ChartSales sales, _) => sales.amount,
        data: data,
      )
    ];
  }

  CompanyInformation company = CompanyInformation.emptyData();
  @override
  void initState() {
    super.initState();
    formattedDate = DateFormat('yyyy-MM-dd').format(now);
    setToDay = DateFormat('dd-MM-yyyy').format(now);
    startDate = DateUtil.dateDMY(currentFinancialYear == null
        ? '2000-01-01'
        : currentFinancialYear!.startDate);
    endDate = DateUtil.dateDMY(currentFinancialYear == null
        ? '2000-01-01'
        : currentFinancialYear!.endDate);

    company = ScopedModel.of<MainModel>(context).getCompanySettings();

    Future<String>.delayed(
            const Duration(seconds: 2), () => '["123", "456", "789"]')
        .then((String value) {
      setState(() {
        setState(() {
          _status = true;
          _statusSalesSummary = true;
          _statusPurchaseSummary = true;
        });
      });
    });
    if (locationList.isNotEmpty) {
      dropdownBranchId = locationList
          .where((element) => element.value == defaultLocation)
          .map((e) => e.key)
          .first;
      _fetchTotalData(dropdownBranchId);
      _fetchSalesSummary(dropdownBranchId);
      _fetchPurchaseSummary(dropdownBranchId);
    } else {
      _fetchDataAll();
    }
  }

  Future _fetchDataAll() async {
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (locationList.isNotEmpty) {
        dropdownBranchId = locationList
            .where((element) => element.value == defaultLocation)
            .map((e) => e.key)
            .first;
        _fetchTotalData(dropdownBranchId);
        _fetchSalesSummary(dropdownBranchId);
        _fetchPurchaseSummary(dropdownBranchId);
      } else {
        _fetchTotalData(dropdownBranchId);
        _fetchSalesSummary(dropdownBranchId);
        _fetchPurchaseSummary(dropdownBranchId);
      }
    });
  }

  Future _fetchTotalData(var branch) async {
    dio.fetchDashTotalData(formattedDate, branch).then((responseBodyOfTotal) {
      if (responseBodyOfTotal != null && responseBodyOfTotal.isNotEmpty) {
        totalSales = responseBodyOfTotal['Total Sales'].toString();
        totalNoSales = responseBodyOfTotal['Total No Sales'].toString();
        totalCashSales = responseBodyOfTotal['Total Cash Sales'].toString();
        totalNoCashSales =
            responseBodyOfTotal['Total No Cash Sales'].toString();
        totalCreditSales = responseBodyOfTotal['Total Credit Sales'].toString();
        totalNoCreditSales =
            responseBodyOfTotal['Total No Credit Sales'].toString();
        totalNoCustomers = responseBodyOfTotal['No Customers'].toString();
        totalNoOfRepeatCustomers =
            responseBodyOfTotal['No of Repeat Customers'].toString();
        totalExpenses = responseBodyOfTotal['Total Expenses'].abs().toString();
        setState(() {
          _status = true;
        });
      }
      return _status;
    });
  }

  Future _fetchSalesSummary(var branch) async {
    var fromDate = now.subtract(const Duration(days: 4));
    String sDate = DateFormat('yyyy-MM-dd').format(fromDate);
    dio
        .fetchDashSalesSummary(formattedDate, sDate, branch)
        .then((responseData) {
      if (responseData != null) {
        List<dynamic> salesSummary =
            responseData.length > 0 ? responseData : [];

        if (mounted) {
          setState(() {
            _statusSalesSummary = true;
            if (salesSummary.isNotEmpty) {
              _salesData.clear();
              for (Map sales in salesSummary) {
                _salesData.add(ChartSales.fromJson(sales));
              }
            }
          });
        }
      }
      return _statusSalesSummary;
    });
  }

  Future _fetchPurchaseSummary(var branch) async {
    var fromDate = now.subtract(const Duration(days: 4));
    String sDate = DateFormat('yyyy-MM-dd').format(fromDate);
    dio
        .fetchDashPurchaseSummary(formattedDate, sDate, branch)
        .then((responseData) {
      if (responseData != null) {
        List<dynamic> purchaseSummary =
            responseData.length > 0 ? responseData : [];

        if (mounted) {
          setState(() {
            _statusPurchaseSummary = true;
            if (purchaseSummary.isNotEmpty) {
              _purchaseData.clear();
              for (Map purchase in purchaseSummary) {
                _purchaseData.add(ChartPurchase.fromJson(purchase));
              }
            }
          });
        }
      }
      return _statusPurchaseSummary;
    });
  }

  // final kPrimaryColor = Color(0xff0008B3);
  _getSalesSeriesData() {
    List<charts.Series<ChartSales, String>> series = [
      charts.Series<ChartSales, String>(
        id: 'Sales',
        colorFn: (_, __) =>
            charts.ColorUtil.fromDartColor(kPrimaryColor),
            // charts.MaterialPalette.blue.shadeDefault,
        domainFn: (ChartSales sales, _) => sales.ddate!,
        measureFn: (ChartSales sales, _) => sales.amount,
        data: _salesData,
      )
    ];
    return series;
  }

  _getPurchaseSeriesData() {
    List<charts.Series<ChartPurchase, String>> series = [
      charts.Series<ChartPurchase, String>(
        id: 'Purchase',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(kPrimaryColor),
        // charts.MaterialPalette.blue.shadeDefault,
        domainFn: (ChartPurchase sales, _) => sales.date!,
        measureFn: (ChartPurchase sales, _) => sales.amount,
        data: _purchaseData,
      )
    ];
    return series;
  }

  @override
  Widget build(BuildContext context) {
    List summaryTxt = [
      'Total Sales',
      'Total No Sales',
      'Total Cash Sales',
      'Total No Cash Sales',
      'Total Credit Sales',
      'No of Credit Sales',
      'No. Customers',
      'Repeat Customers No.'
    ];
    List imageList = [
      'assets/icons/ic_total_sales.png',
      'assets/icons/ic_total_no_sales.png',
      'assets/icons/ic_total_cash_sales.png',
      'assets/icons/ic_total_no_cash_sales.png',
      'assets/icons/ic_total_credit_sales.png',
      'assets/icons/ic_no_of_credit_sales.png',
      'assets/icons/ic_customer.png',
      'assets/icons/ic_repeat customers_no.png'
    ];
    List<String> summuryValues = [
      totalSales,
      totalNoSales,
      totalCashSales.toCurrencyString(
          thousandSeparator: ThousandSeparator.Comma),
      totalNoCashSales,
      totalCreditSales.toCurrencyString(
          thousandSeparator: ThousandSeparator.Comma),
      totalNoCreditSales,
      totalNoCustomers,
      totalNoOfRepeatCustomers,
    ];
    return Scaffold(
        backgroundColor: bagroundColor,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              children: [
                Container(
                  width: MediaQuery.sizeOf(context).width,
                  height: 40,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8), color: white),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Row(
                      children: [
                        const Text(
                          'Financial Year',
                          style: TextStyle(
                              fontFamily: 'poppins',
                              fontWeight: FontWeight.w500,
                              fontSize: 15),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () => _showFinancialList(),
                          child: Container(
                            width: 100,
                            height: 20,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(color: grey)),
                            child: Center(child: Text('$startDate')),
                          ),
                        ),
                        Container(
                          width: 3,
                          height: 1,
                          color: grey,
                        ),
                        Container(
                          width: 100,
                          height: 20,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(color: grey)),
                          child: Center(child: Text('$endDate')),
                        ),
                      ],
                    ),
                  ),
                ),
                locationList.isNotEmpty
                    ? DropdownButtonHideUnderline(
                        child: DropDownSettingsTile<int>(
                          title: 'Branch',
                          titleTextStyle: const TextStyle(
                            fontFamily: 'poppins',
                            fontWeight: FontWeight.w500,
                            fontSize: 15
                          ),
                          settingKey: 'key-dropdown-default-location-view',
                          values: locationList.isNotEmpty
                              ? {for (var e in locationList) e.key + 1: e.value}
                              : {
                                  2: '',
                                },
                          selected: 2,
                          onChange: (value) {
                            debugPrint(
                                'key-dropdown-default-location-view: $value');
                            dropdownBranchId = value - 1;
                            _fetchTotalData(dropdownBranchId);
                            _fetchSalesSummary(dropdownBranchId);
                            _fetchPurchaseSummary(dropdownBranchId);
                          },
                        ),
                      )
                    : const Text(''),
                const SizedBox(
                  height: 10,
                ),
                GridView.builder(
                  physics: const ClampingScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      mainAxisExtent: 85,
                      mainAxisSpacing: 5,
                      crossAxisSpacing: 5,
                      crossAxisCount: 2),
                  itemCount: 8,
                  itemBuilder: (context, index) {
                    return Container(
                      clipBehavior: Clip.antiAlias,
                      height: 82,
                      // width: 173,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white,
                      ),
                      child: Stack(
                        children: [
                          
                           Positioned(
                              right: -30,
                              top: -31,
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(imageList[index]),
                                    scale: 3.1,
                                    alignment: Alignment.lerp(Alignment.bottomLeft, Alignment.center, .5)?? Alignment.center
                                    ),
                                  color: kPrimaryColor,
                                  borderRadius: BorderRadius.circular(50)),
                                // backgroundImage: AssetImage(imageList[index]),
                                // radius: 50,
                                // backgroundColor: Color(0xff0008B3),
                              )),
                          // Positioned(
                          //     top: 8,
                          //     right: 9,
                          //     child: Image.asset(
                          //       summaryIcons[index],
                          //       fit: BoxFit.fill,
                          //     )
                          //     ),
                          Positioned(
                              top: 6,
                              left: 3,
                              child: Text(
                                summaryTxt[index],
                                textAlign: TextAlign.justify,
                                textScaler: const TextScaler.linear(.9),
                                style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13),
                              )),
                          Positioned(
                              top: 30,
                              left: 10,
                              child: Text(
                                summuryValues[index],
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'poppins',
                                    fontWeight: FontWeight.w500),
                              ))
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                StaggeredGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  children: [
                    // StaggeredGridTile.extent(
                    //   mainAxisExtent: 80,
                    //   crossAxisCellCount: 2,
                    //   child: _buildTile(
                    //     Padding(
                    //       padding: const EdgeInsets.all(1),
                    //       child: Column(
                    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //         children: [
                    //           Row(
                    //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //               crossAxisAlignment: CrossAxisAlignment.center,
                    //               children: [
                    //                 Column(
                    //                   children: [
                    //                     // InkWell(
                    //                     //   hoverColor: orange,
                    //                     //   splashColor: red,
                    //                     //   focusColor: yellowAccent,
                    //                     //   highlightColor: purple,
                    //                     //   child: Container(
                    //                     //     height: 25,
                    //                     //     alignment: Alignment.center,
                    //                     //     child: Text('${company.name}',
                    //                     //         style: const TextStyle(
                    //                     //             color: kPrimaryColor,
                    //                     //             fontWeight: FontWeight.w700,
                    //                     //             fontSize: 18.0)),
                    //                     //   ),
                    //                     //   onTap: () => changeCompany(),
                    //                     // ),
                    //                     InkWell(
                    //                         child: Text(
                    //                             'Financial Year $startDate  $endDate',
                    //                             style: const TextStyle(
                    //                                 color: black,
                    //                                 fontWeight: FontWeight.w700,
                    //                                 fontSize: 16.0)),
                    //                         onTap: () => _showFinancialList()),
                    //                   ],
                    //                 )
                    //               ]),
                    //           Row(
                    //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //             crossAxisAlignment: CrossAxisAlignment.center,
                    //             children: [
                    //               const Text('Date',
                    //                   style: TextStyle(
                    //                       color: black,
                    //                       fontWeight: FontWeight.w700,
                    //                       fontSize: 16.0)),
                    //               InkWell(
                    //                 child: Text(getToDay,
                    //                     style: const TextStyle(
                    //                         color: black,
                    //                         fontWeight: FontWeight.w700,
                    //                         fontSize: 16.0)),
                    //                 onTap: () => _selectDate(),
                    //               ),
                    //             ],
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                    // ),

                    // StaggeredGridTile.extent(
                    //   mainAxisExtent: 80,
                    //   crossAxisCellCount: 2,
                    //   child: _buildTile(
                    //     Padding(
                    //       padding: const EdgeInsets.all(5.0),
                    //       child: locationList.isNotEmpty
                    //           ? DropDownSettingsTile<int>(
                    //               title: 'Branch',
                    //               settingKey:
                    //                   'key-dropdown-default-location-view',
                    //               values: locationList.isNotEmpty
                    //                   ? {
                    //                       for (var e in locationList)
                    //                         e.key + 1: e.value
                    //                     }
                    //                   : {
                    //                       2: '',
                    //                     },
                    //               selected: 2,
                    //               onChange: (value) {
                    //                 debugPrint(
                    //                     'key-dropdown-default-location-view: $value');
                    //                 dropdownBranchId = value - 1;
                    //                 _fetchTotalData(dropdownBranchId);
                    //                 _fetchSalesSummary(dropdownBranchId);
                    //                 _fetchPurchaseSummary(dropdownBranchId);
                    //               },
                    //             )
                    //           : const Text(''),
                    //     ),
                    //     onTap: () => Navigator.of(context)
                    //         .push(MaterialPageRoute(builder: (_) => NewPage())),

                    //   ),
                    // ),
                    // StaggeredGridTile.extent(
                    //   mainAxisExtent: 80,
                    //   crossAxisCellCount: 1,
                    //   child: _buildTile(
                    //     Padding(
                    //       padding: const EdgeInsets.all(14.0),
                    //       child: Row(
                    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //           crossAxisAlignment: CrossAxisAlignment.center,
                    //           children: <Widget>[
                    //             Column(
                    //               mainAxisAlignment: MainAxisAlignment.center,
                    //               crossAxisAlignment: CrossAxisAlignment.start,
                    //               children: <Widget>[
                    //                 const Text('Total Sales',
                    //                     style: TextStyle(color: blueAccent)),
                    //                 Text(totalSales,
                    //                     style: const TextStyle(
                    //                         color: black,
                    //                         fontWeight: FontWeight.w700,
                    //                         fontSize: 20.0))
                    //               ],
                    //             ),
                    //             // Material(
                    //             //     color: blue,
                    //             //     borderRadius: BorderRadius.circular(24.0),
                    //             //     child: Center(
                    //             //         child: Padding(
                    //             //       padding: const EdgeInsets.all(16.0),
                    //             //       child: Icon(Icons.timeline,
                    //             //           color: white, size: 30.0),
                    //             //     )))
                    //           ]),
                    //     ),
                    //   ),
                    // ),
                    // StaggeredGridTile.extent(
                    //   mainAxisExtent: 80,
                    //   crossAxisCellCount: 1,
                    //   child: _buildTile(
                    //     Padding(
                    //       padding: const EdgeInsets.all(14.0),
                    //       child: Column(
                    //           mainAxisAlignment: MainAxisAlignment.start,
                    //           crossAxisAlignment: CrossAxisAlignment.start,
                    //           children: <Widget>[
                    //             // Material(
                    //             //     color: teal,
                    //             //     shape: CircleBorder(),
                    //             //     child: Padding(
                    //             //       padding: const EdgeInsets.all(16.0),
                    //             //       child: Icon(Icons.settings_applications,
                    //             //           color: white, size: 30.0),
                    //             //     )),
                    //             // Padding(padding: EdgeInsets.only(bottom: 16.0)),
                    //             const Text('Total No Sales',
                    //                 style: TextStyle(color: blueAccent)),
                    //             Text(totalNoSales,
                    //                 style: const TextStyle(
                    //                     color: black,
                    //                     fontWeight: FontWeight.w700,
                    //                     fontSize: 20.0))
                    //           ]),
                    //     ),
                    //   ),
                    // ),
                    // StaggeredGridTile.extent(
                    //   mainAxisExtent: 80,
                    //   crossAxisCellCount: 1,
                    //   child: _buildTile(
                    //     Padding(
                    //       padding: const EdgeInsets.all(14.0),
                    //       child: Row(
                    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //           crossAxisAlignment: CrossAxisAlignment.center,
                    //           children: <Widget>[
                    //             Column(
                    //               mainAxisAlignment: MainAxisAlignment.center,
                    //               crossAxisAlignment: CrossAxisAlignment.start,
                    //               children: <Widget>[
                    //                 const Text('Total Cash Sales',
                    //                     style: TextStyle(color: blueAccent)),
                    //                 Text(
                    //                     totalCashSales.toCurrencyString(
                    //                         thousandSeparator:
                    //                             ThousandSeparator.Comma),
                    //                     style: const TextStyle(
                    //                         color: black,
                    //                         fontWeight: FontWeight.w700,
                    //                         fontSize: 20.0))
                    //               ],
                    //             ),
                    //           ]),
                    //     ),
                    //   ),
                    // ),
                    // StaggeredGridTile.extent(
                    //   mainAxisExtent: 80,
                    //   crossAxisCellCount: 1,
                    //   child: _buildTile(
                    //     Padding(
                    //       padding: const EdgeInsets.all(14.0),
                    //       child: Row(
                    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //           crossAxisAlignment: CrossAxisAlignment.center,
                    //           children: <Widget>[
                    //             Column(
                    //               mainAxisAlignment: MainAxisAlignment.center,
                    //               crossAxisAlignment: CrossAxisAlignment.start,
                    //               children: <Widget>[
                    //                 const Text('Total No Cash Sales',
                    //                     style: TextStyle(color: blueAccent)),
                    //                 Text(totalNoCashSales,
                    //                     style: const TextStyle(
                    //                         color: black,
                    //                         fontWeight: FontWeight.w700,
                    //                         fontSize: 20.0))
                    //               ],
                    //             ),
                    //           ]),
                    //     ),
                    //   ),
                    // ),
                    // StaggeredGridTile.extent(
                    //   mainAxisExtent: 80,
                    //   crossAxisCellCount: 1,
                    //   child: _buildTile(
                    //     Padding(
                    //       padding: const EdgeInsets.all(14.0),
                    //       child: Row(
                    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //           crossAxisAlignment: CrossAxisAlignment.center,
                    //           children: <Widget>[
                    //             Column(
                    //               mainAxisAlignment: MainAxisAlignment.center,
                    //               crossAxisAlignment: CrossAxisAlignment.start,
                    //               children: <Widget>[
                    //                 const Text('Total Credit Sales',
                    //                     style: TextStyle(color: blueAccent)),
                    //                 Text(
                    //                     totalCreditSales.toCurrencyString(
                    //                         thousandSeparator:
                    //                             ThousandSeparator.Comma),
                    //                     style: const TextStyle(
                    //                         color: black,
                    //                         fontWeight: FontWeight.w700,
                    //                         fontSize: 20.0))
                    //               ],
                    //             ),
                    //           ]),
                    //     ),
                    //   ),
                    // ),
                    // StaggeredGridTile.extent(
                    //   mainAxisExtent: 80,
                    //   crossAxisCellCount: 1,
                    //   child: _buildTile(
                    //     Padding(
                    //       padding: const EdgeInsets.all(14.0),
                    //       child: Row(
                    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //           crossAxisAlignment: CrossAxisAlignment.center,
                    //           children: <Widget>[
                    //             Column(
                    //               mainAxisAlignment: MainAxisAlignment.center,
                    //               crossAxisAlignment: CrossAxisAlignment.start,
                    //               children: <Widget>[
                    //                 const Text('No Of Credit Sales',
                    //                     style: TextStyle(color: blueAccent)),
                    //                 Text(totalNoCreditSales,
                    //                     style: const TextStyle(
                    //                         color: black,
                    //                         fontWeight: FontWeight.w700,
                    //                         fontSize: 20.0))
                    //               ],
                    //             ),
                    //           ]),
                    //     ),
                    //   ),
                    // ),
                    // StaggeredGridTile.extent(
                    //   mainAxisExtent: 80,
                    //   crossAxisCellCount: 1,
                    //   child: _buildTile(
                    //     Padding(
                    //       padding: const EdgeInsets.all(14.0),
                    //       child: Row(
                    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //           crossAxisAlignment: CrossAxisAlignment.center,
                    //           children: <Widget>[
                    //             Column(
                    //               mainAxisAlignment: MainAxisAlignment.center,
                    //               crossAxisAlignment: CrossAxisAlignment.start,
                    //               children: <Widget>[
                    //                 const Text('No Customers',
                    //                     style: TextStyle(color: blueAccent)),
                    //                 Text(totalNoCustomers,
                    //                     style: const TextStyle(
                    //                         color: black,
                    //                         fontWeight: FontWeight.w700,
                    //                         fontSize: 20.0))
                    //               ],
                    //             ),
                    //           ]),
                    //     ),
                    //   ),
                    // ),
                    // StaggeredGridTile.extent(
                    //   mainAxisExtent: 80,
                    //   crossAxisCellCount: 1,
                    //   child: _buildTile(
                    //     Padding(
                    //       padding: const EdgeInsets.all(10.0),
                    //       child: Row(
                    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //           crossAxisAlignment: CrossAxisAlignment.center,
                    //           children: <Widget>[
                    //             Column(
                    //               mainAxisAlignment: MainAxisAlignment.center,
                    //               crossAxisAlignment: CrossAxisAlignment.start,
                    //               children: <Widget>[
                    //                 const Text('Repeat Customers No',
                    //                     style: TextStyle(color: blueAccent)),
                    //                 Text(totalNoOfRepeatCustomers,
                    //                     style: const TextStyle(
                    //                         color: black,
                    //                         fontWeight: FontWeight.w700,
                    //                         fontSize: 20.0))
                    //               ],
                    //             ),
                    //           ]),
                    //     ),
                    //   ),
                    // ),
                    // StaggeredGridTile.extent(
                    //   mainAxisExtent: 80,
                    //   crossAxisCellCount: 2,
                    //   child: _buildTile(
                    //     Padding(
                    //       padding: const EdgeInsets.all(14.0),
                    //       child: Row(
                    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //           crossAxisAlignment: CrossAxisAlignment.center,
                    //           children: <Widget>[
                    //             Column(
                    //               mainAxisAlignment: MainAxisAlignment.center,
                    //               crossAxisAlignment: CrossAxisAlignment.start,
                    //               children: <Widget>[
                    //                 const Text('Total Expenses',
                    //                     style: TextStyle(color: blueAccent)),
                    //                 Text(totalExpenses,
                    //                     style: const TextStyle(
                    //                         color: black,
                    //                         fontWeight: FontWeight.w700,
                    //                         fontSize: 20.0))
                    //               ],
                    //             ),
                    //           ]),
                    //     ),
                    //   ),
                    // ),
                    StaggeredGridTile.extent(
                      mainAxisExtent: 250,
                      crossAxisCellCount: 2,
                      child: _buildTile(
                        Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Builder(builder: (context) {
                                          return const Text('Sales Summary',
                                              style: TextStyle(color: green));
                                        }),
                                      ],
                                    ),
                                  ],
                                ),
                                const Padding(
                                    padding: EdgeInsets.only(bottom: 4.0)),
                                Expanded(
                                    child: _salesData.isNotEmpty
                                        ? SimpleBarChart(_getSalesSeriesData())
                                        : SimpleBarChart(_createSampleData())),
                              ],
                            )),
                      ),
                    ),
                    StaggeredGridTile.extent(
                      mainAxisExtent: 250,
                      crossAxisCellCount: 2,
                      child: _buildTile(
                        Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Builder(builder: (context) {
                                          return const Text('Purchase Summary',
                                              style: TextStyle(color: green));
                                        }),
                                      ],
                                    ),
                                  ],
                                ),
                                const Padding(
                                    padding: EdgeInsets.only(bottom: 4.0)),
                                Expanded(
                                    child: _purchaseData.isNotEmpty
                                        ? SimpleBarChart(
                                            _getPurchaseSeriesData())
                                        : SimpleBarChart(_createSampleData())),
                              ],
                            )),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ));
  }

  Future _selectDate() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (picked != null) {
      setState(() {
        setToDay = DateFormat('dd-MM-yyyy').format(picked);
        formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Widget _buildTile(Widget child, {Function()? onTap}) {
    return Material(
        elevation: 14.0,
        borderRadius: BorderRadius.circular(12.0),
        shadowColor: const Color(0x802196F3),
        child: InkWell(
            // Do onTap() if it isn't null, otherwise do print()
            onTap: onTap != null
                ? () => onTap()
                : () {
                    // print('Not set yet');
                  },
            child: child));
  }

  _showFinancialList() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Container(
              color: Colors.blueAccent,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Financial Year',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            content: setFinancialList(context),
          );
        });
  }

  setFinancialList(context) {
    List<FinancialYear> data =
        ScopedModel.of<MainModel>(context).getFinancialYear();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 300.0,
          width: 300.0,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: data.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: InkWell(
                  child: Card(
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            "${DateUtil.dateDMY(data[index].startDate)} - ${DateUtil.dateDMY(data[index].endDate)}"),
                      )),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      currentFinancialYear = data[index];
                      startDate =
                          DateUtil.dateDMY(currentFinancialYear!.startDate);
                      endDate = DateUtil.dateDMY(currentFinancialYear!.endDate);
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  changeCompany() {}
}
