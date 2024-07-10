import 'package:flutter/material.dart';
import 'package:flutter_settings_screen_ex/flutter_settings_screen_ex.dart';

// import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:intl/intl.dart';
import 'package:sheraccerp/models/expense_list_item_model.dart';
import 'package:sheraccerp/service/api_dio.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:sheraccerp/shared/constants.dart';
import 'package:sheraccerp/util/res_color.dart';
import 'package:sheraccerp/widget/appbar_custom_widget.dart';
import 'package:sheraccerp/widget/expense_listview.dart';
import 'package:sheraccerp/widget/loading.dart';
import 'package:sheraccerp/widget/simple_piediagram.dart';


class Expense extends StatefulWidget {
  const Expense({Key? key}) : super(key: key);

  @override
  State<Expense> createState() => _ExpenseState();
}

class _ExpenseState extends State<Expense> {
  String heading = "";
  final List<ChartExpense> _expenseData = [];
  
  // final List<ChartExpense> _expenseData = [
  //     ChartExpense(name: 'Shop', amount: '0.53', id: 1, colorVal: '0xff00008B'),
  //   ChartExpense(name: 'General Purchase A/c', amount: '2', id: 2, colorVal: '0xff0047AB'),
  //   ChartExpense(name: 'Service Charge', amount: '2', id: 3, colorVal: '0xff0096FF'),
  //   ChartExpense(name: 'Samsung Service Charge', amount: '2', id: 4, colorVal: '0xff1434A4'),
  //   ChartExpense(name: 'Salary', amount: '2', id: 5, colorVal: '0xFF0000FF'),
  // ];
  DateTime now = DateTime.now();
  String? formattedDate;
  DioService api = DioService();
  final colorValues = [
    // '0xffE33335',
    '0xff0008B3',
    '0xff0047AB',
    '0xff0096FF',
    '0xff1434A4',
    '0xFF0000FF',
    '0xffE33335',
    '0xffEED44C',
    '0xff109618',
    '0xFF0000FF'
  ];

  List<ExpenseListItemModel> lItems = [];
  var dropDownBranchId;

  @override
  void initState() {
    super.initState();
    formattedDate = DateFormat('yyyy-MM-dd').format(now);
    if (locationList.isNotEmpty) {
      dropDownBranchId = locationList
          .where((element) => element.value == defaultLocation)
          .map((e) => e.key)
          .first;
      _fetchData(dropDownBranchId);
    }
  }

  Future _fetchData(var branchID) async {
    api
        .fetchExpenseData(
            formattedDate!, formattedDate!, 'All Expense', branchID)
        .then((value) {
      setState(() {
        for (var data in value) {
          lItems.add(ExpenseListItemModel.fromJson(data));
        }
        int n = 0;
        for (var json in value) {
          if (n < 5) {
            _expenseData.add(ChartExpense(
                id: int.tryParse(json['SlNo'])!,
                name: json['LedName'],
                amount: json['Debit'].toString(),
                colorVal: colorValues[n]));
          }
          n++;
        }
        if (_expenseData.isEmpty) {
          _expenseData.add(
            ChartExpense(
                name: 'expense', amount: '0', id: 1, colorVal: '0xff990099'),
          );
          lItems.add(ExpenseListItemModel(
              id: 1, amount: '0', eno: '0', party: 'expense'));
        }
      });
    });
  }

  _getExpenseSeriesData() {
    List<charts.Series<ChartExpense, String>> series = [
      charts.Series<ChartExpense, String>(
        id: 'Expense',
        colorFn: (ChartExpense expense, _) =>
            charts.ColorUtil.fromDartColor(Color(int.parse(expense.colorVal!))),
        domainFn: (ChartExpense expense, _) => expense.name!,
        measureFn: (ChartExpense expense, _) => double.parse(expense.amount!),
        data: _expenseData,
        labelAccessorFn: (ChartExpense expense, _) => expense.amount!,
      )
    ];
    return series;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bagroundColor,
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(100),
            child: AppbarWidgget(
              headTxt: 'Expenses',
              onPressed: () {
                Navigator.pop(context);
              },
            )),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 8),
            child: Column(
              children: [
                DropDownSettingsTile<int>(
                  
                  titleTextStyle: const TextStyle(
                    fontFamily: 'poppins',fontSize: 15,fontWeight: FontWeight.w500),
                  title: 'Branch',
                  settingKey: 'key-dropdown-default-location-view',
                  values: locationList.isNotEmpty
                      ? Map.fromIterable(locationList,
                          key: (e) => e.key + 1, value: (e) => e.value)
                      : {
                          2: '',
                        },
                  selected: 2,
                  onChange: (value) {
                    debugPrint('key-dropdown-default-location-view: $value');
                    dropDownBranchId = value - 1;
                    _fetchData(dropDownBranchId);
                  },
                ),
                // const Center(
                //   child: Text(
                //     'All Expenses',
                //     style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                //   ),
                // ),
                const SizedBox(
                  height: 30.0,
                ),
                SizedBox(
          height: 200.0,
          width: 200.0,
          child: _expenseData.isNotEmpty
              ? SimplePieDiagram(_expenseData, animate: true)
              : const CircularProgressIndicator(),
        ),
                // SizedBox(
                //     height: 320.0,
                //     width: 320.0,
                //     child: _expenseData.isNotEmpty
                //         ? SimplePieDiagram(
                          
                //           _getExpenseSeriesData(), animate: true)
                //         : const Loading()),
               
                const SizedBox(
                  height: 40.0,
                ),
               const Row(
                 children: [
                   Expanded(
                     child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Row(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             CircleAvatar(
                               radius: 10,
                               backgroundColor: Color(0xff0008B3),
                             ),
                             SizedBox(
                               width: 4,
                             ),
                             Text('General Purchase A/C',
                             style: TextStyle(
                               fontFamily: 'poppins',
                               fontSize: 12,
                               fontWeight: FontWeight.w500),),
                             // Spacer(),
                           
                           ],
                         ),
                       SizedBox(
                        height: 8,
                      ),
                       Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           CircleAvatar(
                             radius: 10,
                             backgroundColor: Color(0xff0008B3),
                           ),
                           SizedBox(
                             width: 4,
                           ),
                           Text('Allowance Paid',
                           style: TextStyle(
                             fontFamily: 'poppins',
                             fontSize: 12,
                             fontWeight: FontWeight.w500),),
                          
                         ],
                       ),
                       SizedBox(
                        height: 8.0,
                      ),
                       Row(
                         children: [
                           CircleAvatar(
                             radius: 10,
                             backgroundColor: Color(0xff0008B3),
                           ),
                           SizedBox(
                             width: 4,
                           ),
                           Text('Wages',
                           style: TextStyle(
                             fontFamily: 'poppins',
                             fontSize: 12,
                             fontWeight: FontWeight.w500),),
                          
                         ],
                       ),
                      SizedBox(
                        height: 10,
                      ),
                         Row(
                           children: [
                             CircleAvatar(
                               radius: 10,
                               backgroundColor: Color(0xff0008B3),
                             ),
                             SizedBox(
                               width: 4,
                             ),
                             Text('O.T Wages',
                             style: TextStyle(
                               fontFamily: 'poppins',
                               fontSize: 12,
                               fontWeight: FontWeight.w500),),
                             
                           ],
                         ),
                      ],
                     ),
                   ),
                   Expanded(child: Column(
                    children: [
                      Row(
                        children: [
                            CircleAvatar(
                               radius: 10,
                               backgroundColor: Color(0xff0008B3),
                             ),
                             SizedBox(
                               width: 4,
                             ),
                             Text('General Purchase A/C',
                             style: TextStyle(
                               fontFamily: 'poppins',
                               fontSize: 12,
                               fontWeight: FontWeight.w500))
                        ],
                      ),
                       SizedBox(
                        height: 8.0,
                      ),
                      Row(
                        children: [
                            CircleAvatar(
                               radius: 10,
                               backgroundColor: Color(0xff0008B3),
                             ),
                             SizedBox(
                               width: 4,
                             ),
                             Text('Discount Allowed',
                             style: TextStyle(
                               fontFamily: 'poppins',
                               fontSize: 12,
                               fontWeight: FontWeight.w500))
                        ],
                      ),
                       SizedBox(
                        height: 8.0,
                      ),
                      Row(
                        children: [
                            CircleAvatar(
                               radius: 10,
                               backgroundColor: Color(0xff0008B3),
                             ),
                             SizedBox(
                               width: 4,
                             ),
                             Text('Damaged Goods',
                             style: TextStyle(
                               fontFamily: 'poppins',
                               fontSize: 12,
                               fontWeight: FontWeight.w500))
                        ],
                      ),
                       SizedBox(
                        height: 8.0,
                      ),
                      Row(
                        children: [
                            CircleAvatar(
                               radius: 10,
                               backgroundColor: Color(0xff0008B3),
                             ),
                             SizedBox(
                               width: 4,
                             ),
                             Text('Round of Difference',
                             style: TextStyle(
                               fontFamily: 'poppins',
                               fontSize: 12,
                               fontWeight: FontWeight.w500))
                        ],
                      ),
                    ],
                   ))
                 ],
               ),
                const SizedBox(
                  height: 10,
                ),
                lItems.isNotEmpty
                    ? ExpenseListView(
                        listViewModels: lItems, branchId: dropDownBranchId)
                    : const Loading(),
              ],
            ),
          ),
        ));
  }
}
