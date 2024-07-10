import 'package:flutter/material.dart';
import 'package:sheraccerp/service/api_dio.dart';
import 'package:sheraccerp/shared/constants.dart';
import 'package:sheraccerp/util/res_color.dart';
import 'package:sheraccerp/widget/appbar_custom_widget.dart';
import 'package:sheraccerp/widget/simple_piediagram_pay_rec.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:sheraccerp/widget/loading.dart';
import 'package:easy_pie_chart/easy_pie_chart.dart';
import 'package:intl/intl.dart';
class ReceivablesAndPayables extends StatelessWidget {
  DioService api = DioService();
  var dropDownBranchId;

  ReceivablesAndPayables({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (locationList.isNotEmpty) {
      dropDownBranchId = locationList
          .where((element) => element.value == defaultLocation)
          .map((e) => e.key)
          .first;
    }
    return Scaffold(
      backgroundColor: bagroundColor,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: AppbarWidgget(
            headTxt: 'Recivable & Payable',
            onPressed: () {
              Navigator.pop(context);
            },
          )),
      body:
      FutureBuilder(
    future: api.fetchReceivableAndPayable('2000-01-01', '2000-01-01', dropDownBranchId),
    builder: (BuildContext context, AsyncSnapshot snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Loading();
      } else {
        if (snapshot.hasData) {
          
           final List<PieData> pies = [
    PieData(value: 0.65, color: Color(0xff1434A4)),
    PieData(value: 0.25, color: Color(0xff0047AB)),
  ];
          final List<ChartPayRec> chartData = snapshot.data;
          final recv = chartData.map((e) => e.amount).first;
          final payv = chartData.map((e) => e.amount).last;
          final List<PieData> pieData = _convertToPieData(chartData);
          
          return Column(
            children: [
              const SizedBox(
                height: 80,
              ),
              Center(
                child: EasyPieChart(
                  key: const Key('pie 1'),
                  children: pies,
                  borderEdge: StrokeCap.butt,
                  pieType: PieType.crust,
                  // showValue: false,
                  shouldAnimate: false,
                  borderWidth: 45,
                  // onTap: (index) {
                  //   print("Tapped on index $index");
                  // },
                  style: const TextStyle(color: white, fontSize: 10),
                  gap: 0.002,
                  start: 0,
                  size: 220,
                ),
              ),
              const SizedBox(
                height: 60,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 10,
                    backgroundColor: Color(0xff1434A4),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(recv.toString(),style: const TextStyle(
                    fontFamily: 'poppins',
                    color:Color(0xff1434A4),
                    fontSize: 12,
                    fontWeight: FontWeight.w600
                    ),),
                    const SizedBox(
                    width: 8,
                  ),
                    const CircleAvatar(
                    radius: 10,
                    backgroundColor: Color(0xff0047AB),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(payv.toString(),style: const TextStyle(
                    fontFamily: 'poppins',
                    color:Color(0xff0047AB),
                    fontSize: 12,
                    fontWeight: FontWeight.w600
                    ),),
                ],
              )
            ],
          );
        } else {
          return const Loading();
        }
      }
    },
  )
      //  FutureBuilder(
      //     future: api.fetchReceivableAndPayable(
      //         '2000-01-01', '2000-01-01', dropDownBranchId),
      //     builder: (BuildContext context, AsyncSnapshot snapshot) {
      //       if (snapshot.connectionState != ConnectionState.done) {
      //         return const Loading();
      //       } else {
      //         return snapshot.hasData
      //             ? SimplePieDiagramPayRec(_getExpenseSeriesData(snapshot.data),
      //                 animate: true)
      //             : const Loading();
      //       }
      //     }),
    );
  }
  String formatNumber(int number) {
  NumberFormat formatter = NumberFormat('#,##0.00', 'en_US');
  return formatter.format(number);
}
List<PieData> _convertToPieData(List<ChartPayRec> data) {
  return data.map((expense) {
    return PieData(
      value: double.parse(expense.amount!.split(' ').last),
      color: Color(int.parse(expense.colorVal!)),
    );
  }).toList();
}

  // _getExpenseSeriesData(var _data) {
  //   List<charts.Series<ChartPayRec, String>> series = [
  //     charts.Series<ChartPayRec, String>(
  //       id: 'PayRec',
  //       colorFn: (ChartPayRec expense, _) =>
  //           charts.ColorUtil.fromDartColor(Color(int.parse(expense.colorVal!))),
  //       domainFn: (ChartPayRec expense, _) => expense.amount!,
  //       measureFn: (ChartPayRec expense, _) =>
  //           double.tryParse((expense.amount)!.split(" ")[1]),
  //       data: _data,
  //       labelAccessorFn: (ChartPayRec expense, _) => expense.amount!,
  //     )
  //   ];
  //   return series;
  // }
}
