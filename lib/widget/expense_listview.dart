
// import 'package:flutter/material.dart';
// import 'package:sheraccerp/models/expense_list_item_model.dart';

// class ExpenseListView extends StatelessWidget {
//   final List<ExpenseListItemModel> ?listViewModels;
//   var branchId;
//   ExpenseListView({Key ?key, this.listViewModels, this.branchId})
//       : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return ListView.separated(
//         separatorBuilder: (context, index) => const Divider(
//               color: Colors.black,
//             ),
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         itemCount: listViewModels!.length,
//         padding: const EdgeInsets.all(15.0),
//         itemBuilder: (context, position) {
//           return createViewItem(listViewModels![position], context);
//         });
//   }
//   Widget createViewItem(
//       ExpenseListItemModel listItemModel, BuildContext context) {
//     return ListTile(
//       title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Visibility(
//             visible: false,
//             child: Padding(
//                 padding: const EdgeInsets.all(1.0),
//                 child: Text(
//                   listItemModel.eno,
//                   style: const TextStyle(
//                       fontWeight: FontWeight.bold, fontSize: 20),
//                   textAlign: TextAlign.right,
//                 ))),
//         Row(
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(right: 5.0),
//               child: Text(
//                 listItemModel.id.toString(),
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.right,
//               ),
//             ),
//             Text(
//               listItemModel.party,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(fontWeight: FontWeight.bold),
//               maxLines: 2,
//             ),
//             const Spacer(),
//             Text(
//               listItemModel.amount,
//               style: const TextStyle(fontWeight: FontWeight.bold),
//               textAlign: TextAlign.right,
//             ),
//           ],
//         ),
//       ]),
//       // onTap: () => _onTapItem(context, listItemModel),
//     );
//   }

//   // void _onTapItem(BuildContext context, ExpenseListItemModel expenseItem) {
//   //   Navigator.of(context).push(
//   //       MaterialPageRoute(builder: (_) => ExpenseList(expenseItem, branchId)));
//   // }
// }

import 'package:flutter/material.dart';
import 'package:sheraccerp/models/expense_list_item_model.dart';
import 'package:sheraccerp/util/res_color.dart';

class ExpenseListView extends StatelessWidget {
  final List<ExpenseListItemModel>? listViewModels;
  final int branchId;

  ExpenseListView({Key? key, this.listViewModels, required this.branchId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    return listViewModels != null && listViewModels!.isNotEmpty
        ? SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: MediaQuery.sizeOf(context).width,
                child: DataTable(
                  // horizontalMargin: 10,
                  // columnSpacing: 5,
                  dividerThickness: .5,
                  headingRowHeight: 25,
                  dataRowMaxHeight: 25,
                  dataRowMinHeight: 8,
                  headingTextStyle: const TextStyle(fontFamily: 'poppins',color: white),
                  headingRowColor: const MaterialStatePropertyAll(kPrimaryColor),
                  decoration: BoxDecoration(
                    color: white,border: Border.all(color: grey,width: .5)),
                  border: TableBorder(borderRadius: BorderRadius.circular(3),
                  verticalInside: const BorderSide(color: grey,width: .5)),
                  columns: const [
                    // DataColumn(label: Text('ID')),
                    DataColumn(label: Text('NAME')),
                    DataColumn(label: Text('AMOUNT')),
                  ],
                  rows: listViewModels!
                      .map(
                        (item) => DataRow(
                          cells: [
                            // DataCell(Text(item.id.toString())),
                            DataCell(
                              Text(
                                item.party,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                            DataCell(

                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(item.amount,
                                                            textAlign: TextAlign.right,
                                                            ),
                              )),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          )
        : const Center(child: CircularProgressIndicator());
  }
}

