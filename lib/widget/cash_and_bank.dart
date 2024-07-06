import 'package:flutter/material.dart';
import 'package:sheraccerp/service/api_dio.dart';
import 'package:sheraccerp/util/res_color.dart';
import 'package:sheraccerp/widget/appbar_custom_widget.dart';
import 'package:sheraccerp/widget/loading.dart';

class CashAndBank extends StatelessWidget {
  DioService api = DioService();
  var dropDownBranchId;
  DateTime now = DateTime.now();

  CashAndBank({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String dated = now.year.toString() +
        '-' +
        now.month.toString() +
        '-' +
        now.day.toString();
    return Scaffold(
      backgroundColor: bagroundColor,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: AppbarWidgget(
            headTxt: 'Cash & Bank',
            onPressed: () {
              Navigator.pop(context);
            },
          )),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Expanded(
            //   flex: 1,
            //   child: Card(
            //     elevation: 2,
            //     child: Container(
            //         alignment: Alignment.center,
            //         child: const Text(
            //           'Cash & Bank',
            //           style:
            //               TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            //         )),
            //   ),
            // ),
            Expanded(
              // flex: 9,
              child: FutureBuilder(
                  future: api.fetchCashBankLedger(dated, dated),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Loading();
                    } else {
                      return snapshot.hasData
                          ? Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                ListView.separated(
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(
                                          height: 8,
                                        ),
                                    shrinkWrap: true,
                                    itemCount: snapshot.data[0].length,
                                    padding: const EdgeInsets.all(0),
                                    itemBuilder:
                                        (BuildContext context, int position) {
                                      return createViewItem(
                                          snapshot.data[0][position],
                                          context);
                                    }),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                Text(
                                  'Total : ${snapshot.data[1][0]['total']}',
                                  style: const TextStyle(
                                    fontFamily: 'poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500),
                                ),
                              ],
                            )
                          : Text("${snapshot.error}");
                    }
                  }),
            )
          ],
        ),
      ),
    );
  }

  Widget createViewItem(Map<String, dynamic> data, BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: grey,width: .1),
        borderRadius: BorderRadius.circular(5),color: white,),
      width: MediaQuery.of(context).size.width,
      child: ListTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              Visibility(
                visible: false,
                child: Padding(
                    child: Text(
                      data['slno'].toString(),
                      style: const TextStyle(),
                      textAlign: TextAlign.right,
                    ),
                    padding: const EdgeInsets.all(2.0)),
              ),
              Padding(
                  child: Text(
                    data['name'],
                    textAlign: TextAlign.justify,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w500
                    ),
                    maxLines: 2,
                  ),
                  padding: const EdgeInsets.all(1.0)),
            ],
          ),
          Padding(
              padding: const EdgeInsets.all(1.0),
              child: Text(
                '${data['amount']}',
                style: const TextStyle(
                  fontFamily: 'poppins',
                      fontSize: 15,
                      color: grey,
                      fontWeight: FontWeight.w500
                ),
                textAlign: TextAlign.right,
              )),
        ]),
        // onTap: () => _onTapItem(context, listItemModel),
      ),
    );
  }
}
