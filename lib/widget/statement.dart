import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_settings_screen_ex/flutter_settings_screen_ex.dart';

// import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:intl/intl.dart';
import 'package:sheraccerp/service/api_dio.dart';
import 'package:sheraccerp/shared/constants.dart';
import 'package:sheraccerp/models/statement_list_item_model.dart';
import 'package:sheraccerp/models/statement_item.dart';
import 'package:sheraccerp/service/com_service.dart';
import 'package:sheraccerp/util/res_color.dart';
import 'package:sheraccerp/widget/appbar_custom_widget.dart';
import 'package:sheraccerp/widget/statement_list_view.dart';

class Statement extends StatefulWidget {
  const Statement({Key? key}) : super(key: key);

  @override
  State<Statement> createState() => _StatementState();
}

class _StatementState extends State<Statement> {
  bool status = false;
  var dropDownBranchId;
  DioService dio = DioService();
  String heading = "";
  bool _status = false;
  DateTime now = DateTime.now();
  String? formattedDate;
  List<StatementItem> sItems = [
    StatementItem(
        id: 1, party: "Opening Balance", debit: "0.00 DR", credit: "0.00 CR"),
    StatementItem(
        id: 2, party: "Total Cash Sales", debit: "0.00 DR", credit: "0.00 CR"),
    StatementItem(
        id: 3,
        party: "Miscellaneous Income",
        debit: "0.00 DR",
        credit: "0.00 CR"),
    StatementItem(
        id: 4,
        party: "Total Cash Receipts",
        debit: "0.00 DR",
        credit: "0.00 CR"),
    StatementItem(
        id: 5,
        party: "Total Cash Payment",
        debit: "0.00 DR",
        credit: "0.00 CR"),
    StatementItem(
        id: 6, party: "Closing Balance", debit: "0.00 DR", credit: "0.00 CR")
  ];
  List<StatementListItemModel> lItems = [];

  @override
  void initState() {
    super.initState();
    formattedDate = DateFormat('yyyy-MM-dd').format(now);
    if (locationList.isNotEmpty) {
      var branchID = locationList
          .where((element) => element.value == defaultLocation)
          .map((e) => e.key)
          .first;
      dropDownBranchId = branchID;
      _fetchData(branchID);
    }
  }

  Future _fetchData(branch) async {
    dio.fetchDashStatement(formattedDate, branch).then((responseData) {
      List<dynamic> responseBody = responseData;

      setState(() {
        Map<dynamic, dynamic> responseBodyOfStatement = responseBody[0];
        if (responseBodyOfStatement != null) {
          sItems.clear();
          for (Map<String, dynamic> statement in responseBody) {
            sItems.add(StatementItem.fromJson(statement));
          }
        }
        if (responseBody.isNotEmpty) {
          _status = true;
        }
      });
      return _status;
    });
  }

  Future fetchData(String head, var branch) async {
    dio
        .fetchDashDailyStatement(formattedDate, head, branch)
        .then((responseData) {
      List<dynamic> responseBody = responseData;
      if (responseBody.isNotEmpty) {
        setState(() {
          Map<String, dynamic> responseBodyOfStatement = responseBody[0];
          if (responseBodyOfStatement != null) {
            lItems.clear();
            for (Map<String, dynamic> statement in responseBody) {
              lItems.add(StatementListItemModel.fromJson(statement));
            }
          }
        });
      } else {
        setState(() {
          lItems.clear();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bagroundColor,
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: AppbarWidgget(
            headTxt: 'Statement',
            onPressed: () {
              Navigator.pop(context);
            },
          )),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              DropDownSettingsTile<int>(
                title: 'Branch',
                settingKey: 'key-dropdown-default-location-view',
                values: locationList.isNotEmpty
                    ? {for (var e in locationList) e.key + 1: e.value}
                    : {
                        2: '',
                      },
                selected: 2,
                onChange: (value) {
                  debugPrint('key-dropdown-default-location-view: $value');
                  _fetchData(value - 1);
                },
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                  width: MediaQuery.sizeOf(context).width,
                  color: white,
                  child: TableController.createTable(sItems)),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        fetchData("SelectReceipt", dropDownBranchId);
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: const Color(0xff0008B3)),
                              // child: Image.asset(
                              //   gridImg[index],
                              // ),
                            ),
                            const Text(
                              'Cash Recipt',
                              style: TextStyle(
                                  fontFamily: 'poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  // ElevatedButton(
                  //   style: ElevatedButton.styleFrom(
                  //       backgroundColor: Colors.blue[100]),
                  //   onPressed: () {
                  //     fetchData("SelectReceipt", dropDownBranchId);
                  //   },
                  //   child: const Padding(
                  //     padding: EdgeInsets.all(4.0),
                  //     child: Row(
                  //       children: [
                  //         ImageIcon(
                  //             AssetImage(
                  //                 "assets/icons/ic_hand.png"),
                  //             color: Colors.blue),
                  //         Text('Cash Receipt',
                  //             style: TextStyle(
                  //               color: Colors.blue,
                  //             )),
                  //       ],
                  //     ), //Row
                  //   ), //Padding
                  // ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        fetchData('SelectPayment', dropDownBranchId);
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: const Color(0xff0008B3)),
                              // child: Image.asset(
                              //   gridImg[index],
                              // ),
                            ),
                            const Text(
                              'Cash Payment',
                              style: TextStyle(
                                  fontFamily: 'poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  // ElevatedButton(
                  //   style: ElevatedButton.styleFrom(
                  //       backgroundColor: Colors.lightGreen[100]),
                  //   onPressed: () {
                  //     fetchData('SelectPayment', dropDownBranchId);
                  //   },
                  //   child: const Padding(
                  //     padding: EdgeInsets.all(4.0),
                  //     child: Row(
                  //       children: [
                  //         ImageIcon(AssetImage("assets/icons/ic_money.png"),
                  //             color: Colors.lightGreen),
                  //         Text('Cash Payment',
                  //             style: TextStyle(
                  //               color: Colors.lightGreen,
                  //             )),
                  //       ],
                  //     ), //Row
                  //   ), //Padding
                  // ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        fetchData('BankRv', dropDownBranchId);
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: const Color(0xff0008B3)),
                              // child: Image.asset(
                              //   gridImg[index],
                              // ),
                            ),
                            const Text(
                              'Bank Recipt',
                              style: TextStyle(
                                  fontFamily: 'poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  // ElevatedButton(
                  //   style: ElevatedButton.styleFrom(
                  //       backgroundColor: Colors.pink[100]),
                  //   onPressed: () {
                  //     fetchData('BankRv', dropDownBranchId);
                  //   },
                  //   child: const Padding(
                  //     padding: EdgeInsets.all(4.0),
                  //     child: Row(
                  //       children: [
                  //         ImageIcon(AssetImage("assets/icons/ic_bank.png"),
                  //             color: Colors.pink),
                  //         Text('Bank Receipt',
                  //             style: TextStyle(
                  //               color: Colors.pink,
                  //             )),
                  //       ],
                  //     ), //Row
                  //   ), //Padding
                  // ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        fetchData('BankPv', dropDownBranchId);
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: const Color(0xff0008B3)),
                              // child: Image.asset(
                              //   gridImg[index],
                              // ),
                            ),
                            const Text(
                              'Bank Payment',
                              style: TextStyle(
                                  fontFamily: 'poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              lItems.isNotEmpty
                  ? Card(
                      color: Colors.blue[200],
                      child: Text(
                        heading + '  ' + currencySymbol + getTotal().toString(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Container(),
              lItems.isNotEmpty
                  ? const ColoredBox(
                      color: Colors.blue,
                      child: Row(children: [
                        Expanded(
                            child: Text('',
                                style: TextStyle(
                                  height: 1.0,
                                  fontSize: 15.2,
                                  fontWeight: FontWeight.bold,
                                ))),
                        // Expanded(
                        //     child: Text('', //id
                        //         style: TextStyle(
                        //           height: 1.0,
                        //           fontSize: 15.2,
                        //           fontWeight: FontWeight.bold,
                        //         ))),
                        Expanded(
                            child: Text('EntryNo Name(Status)',
                                style: TextStyle(
                                  height: 1.0,
                                  fontSize: 15.2,
                                  fontWeight: FontWeight.bold,
                                ))),
                        Expanded(
                            child: Text('',
                                style: TextStyle(
                                  height: 1.0,
                                  fontSize: 15.2,
                                  fontWeight: FontWeight.bold,
                                ))),
                        Expanded(
                            child: Text('Amount',
                                style: TextStyle(
                                  height: 1.0,
                                  fontSize: 15.2,
                                  fontWeight: FontWeight.bold,
                                ))),
                      ]),
                    )
                  : Container(),
              lItems.isNotEmpty ? StatementListView(lItems) : Container(),
            ],
          ),
        ),
      ),
    );
  }

  getTotal() {
    double total = 0;
    for (var element in lItems) {
      total += double.tryParse(element.amount)!;
    }
    return total;
  }
}

class TableController {
  static Widget createTable(List list) {
    List<TableRow> rows = [];
    rows.add(_createTableHeader(list[0].toJson().keys));
    for (var item in list) {
      rows.add(TableRow(
        children: _createTableBody(item.toJson().values),
      ));
    }
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Table(
          // defaultColumnWidth: FixedColumnWidth(100),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          border: TableBorder.all(
              width: 2.0, color: Color.fromARGB(255, 228, 228, 228)),
          children: rows),
    );
  }

  static TableRow _createTableHeader(Iterable<String> keys) {
    List<Widget> elements = [];
    for (String key in keys) {
      if (key.toString() != 'id') {
        elements.add(Padding(
          padding: const EdgeInsets.all(2.0),
          child: DecoratedBox(
            decoration: const BoxDecoration(color: kPrimaryColor),
            child: Text(
              key.toString(),
              // overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: white,
                  fontFamily: 'poppins',
                  fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ),
        ));
      }
    }
    return TableRow(
      children: elements,
    );
  }

  static List<Widget> _createTableBody(Iterable values) {
    List<Widget> elements = [];
    bool _id = false;
    for (var value in values) {
      if (_id) {
        elements.add(Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            value.toString(),
            // overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
                fontFamily: 'poppins'),
            textAlign: CommonService().isNumeric(
                    CommonService().getNumericFromDrCR(value.toString()))
                ? TextAlign.right
                : TextAlign.left,
          ),
        ));
      } else {
        _id = true;
      }
    }
    return elements;
  }
}
