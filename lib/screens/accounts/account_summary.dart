
import 'dart:typed_data';

// import 'package:esys_flutter_share_plus/esys_flutter_share_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:ui' as ui;
import 'package:pdf/pdf.dart' as pw;
import 'package:printing/printing.dart';
import 'package:sheraccerp/service/api_dio.dart';

class AccountSummery extends StatefulWidget {
  const AccountSummery({super.key});

  @override
  State<AccountSummery> createState() => _AccountSummeryState();
}

class _AccountSummeryState extends State<AccountSummery> {
  bool loading = true;
  var sDate = '2024-01-01';
  var eDate = '2024-01-08';

  DioService api = DioService();
  LedgerReports? ledgerReports;
  @override
  void initState() {
    super.initState();
    var dataJson = ''; //'[${json.encode({
    //   'statementType':
    //       widget.statement.isEmpty ? 'Ledger_Report' : widget.statement,
    //   'sDate': widget.sDate.isEmpty ? '' : widget.sDate,
    //   'eDate': widget.eDate.isEmpty ? '' : widget.eDate,
    //   'id': widget.id ?? '',
    //   'Check_openingbalance': widget.ob ?? 0,
    //   'location': jsonEncode(location),
    //   'project': jsonEncode(project),
    //   'salesMan': 0,
    //   'fyId': currentFinancialYear!.id,
    // })}]';
    api.accountSummery(dataJson).then((value) {
      setState(() {
        if (value.isNotEmpty) {
          ledgerReports = value[0];

          // print("list=${modelInvoiceToJson(ledgerReports!)}===");

          loading = false;
        } else {
          // Handle the case when the list is empty or invalid
          debugPrint("Empty or invalid data received from API");
        }
      });
    });
  }

  final GlobalKey _globalKey = GlobalKey();

  Future<void> _printPage(pw.PdfPageFormat paperFormat) async {
    final pdf = pw.Document();

    pdf.addPage(pw.MultiPage(
      maxPages: 50,
      pageFormat: pw.PdfPageFormat.a4,
      header: (pw.Context context) => _buildHeader(),
      footer: (pw.Context context) => _buildFooter(context),
      build: (pw.Context context) {
        List<pw.Widget> widgets = [
          pw.Table(
            columnWidths: const {
              0: pw.FixedColumnWidth(45),
              1: pw.FlexColumnWidth(20),
              2: pw.FlexColumnWidth(8),
              3: pw.FlexColumnWidth(8),
              4: pw.FlexColumnWidth(8),
            },
            children: [
              for (var i = 0;
                  i < ledgerReports!.recordset!.cast<Recordset>().length;
                  i++)
                pw.TableRow(children: [
                  pw.Center(
                      child: pw.Column(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(2.0),
                        child: pw.Text(
                          '${ledgerReports!.recordset!.cast<Recordset>()[i].date}',
                          style: pw.TextStyle(
                              fontSize: 7, fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ],
                  )),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(2.0),
                    child: pw.Text(
                      '${ledgerReports!.recordset!.cast<Recordset>()[i].particulars}',
                      style: pw.TextStyle(
                          fontSize: 8, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(2.0),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Text(
                          '${ledgerReports!.recordset!.cast<Recordset>()[i].debit}',
                          style: pw.TextStyle(
                              fontSize: 8, fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(2.0),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Text(
                          '${ledgerReports!.recordset!.cast<Recordset>()[i].credit}',
                          style: pw.TextStyle(
                              fontSize: 8, fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(2.0),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Text(
                          '${ledgerReports!.recordset!.cast<Recordset>()[i].balance}',
                          style: pw.TextStyle(
                              fontSize: 8,
                              color: const pw.PdfColor.fromInt(0xFF000000),
                              fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                ]),
            ],
            border: pw.TableBorder.all(
                width: 1, color: const pw.PdfColor.fromInt(0xFF0000FF)),
          ),
        ];

        return widgets;
      },
    ));

    await Printing.layoutPdf(
      onLayout: (pw.PdfPageFormat format) async => pdf.save(),
    );
  }

  _buildHeader() {
    return pw
        .Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.start,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            height: 60,
            width: 60,
            decoration: const pw.BoxDecoration(
                shape: pw.BoxShape.circle, color: PdfColor.fromInt(0xFFFF0000)),
          ),
          pw.SizedBox(
            width: 5,
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Container(
                height: 5,
                width: 20,
                color: const PdfColor.fromInt(0xFF0000FF),
              ),
              pw.Container(
                height: 60,
                width: 10,
                color: const PdfColor.fromInt(0xFF0000FF),
              ),
            ],
          ),
          pw.SizedBox(
            width: 2,
          ),
          pw.Container(
            height: 65,
            width: 3,
            color: const PdfColor.fromInt(0xFF0000FF),
          ),
          pw.SizedBox(
            width: 15,
          ),
          pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "ACCOUNT SUMMERY",
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(
                height: 12,
              ),
              pw.Text(
                "Mr.MALABAR SAND",
                style:
                    pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              ),
              pw.Row(
                children: [
                  pw.Text(
                    "From  $sDate",
                    style: pw.TextStyle(
                        fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(
                    width: 10,
                  ),
                  pw.Text(
                    "To  $eDate",
                    style: pw.TextStyle(
                        fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
      pw.SizedBox(
        height: 1,
      ),
      pw.Divider(
        color: const PdfColor.fromInt(0xFF336699), // Blue color
      ),
      pw.Container(
        width: double.infinity,
        height: 50,
        color: const PdfColor.fromInt(0xFF0000FF),
        child: pw.Table(
          columnWidths: {
            0: const pw.FixedColumnWidth(45),
            1: const pw.FlexColumnWidth(15),
            2: const pw.FlexColumnWidth(8),
            3: const pw.FlexColumnWidth(9),
            4: const pw.FlexColumnWidth(8),
          },
          children: [
            pw.TableRow(children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '  Date',
                    style: pw.TextStyle(
                        fontSize: 7,
                        color: const PdfColor.fromInt(0xFFFFFFFF),
                        fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '  Description',
                    style: pw.TextStyle(
                        fontSize: 7,
                        color: const PdfColor.fromInt(0xFFFFFFFF),
                        fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Center(
                    child: pw.Text(
                      '                             Debit',
                      style: pw.TextStyle(
                          fontSize: 7,
                          color: const PdfColor.fromInt(0xFFFFFFFF),
                          fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),
              pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    '               Credit',
                    style: pw.TextStyle(
                        fontSize: 7,
                        color: const PdfColor.fromInt(0xFFFFFFFF),
                        fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    "        Balanace",
                    style: pw.TextStyle(
                        fontSize: 7,
                        color: const PdfColor.fromInt(0xFFFFFFFF),
                        fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ]),
          ],
          border: pw.TableBorder.all(
              width: 1, color: const PdfColor.fromInt(0xFF0000FF)),
        ),
      ),
    ]);
  }

  _buildFooter(pw.Context context) {
    return pw.Footer(
      trailing: pw.Column(
        children: [
          pw.SizedBox(
            height: 15,
          ),
          pw.Text('Page ${context.pageNumber} /${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  Future<void> _shareInvoiceTo(
      BuildContext context, PdfPageFormat paperFormat) async {
    final pdf = pw.Document();
    final image = await _captureWidgetToImage();

    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Center(
          child: pw.Image(
            pw.MemoryImage(image),
            fit: pw.BoxFit.fill,
          ),
        );
      },
    ));

    // await Printing.layoutPdf(
    //   onLayout: (PdfPageFormat format) async => pdf.save(),

    // );

    final Uint8List pdfBytes = await pdf.save();

    // Share the PDF file via WhatsApp

    // await Share.file(
    //   'PDF Document',
    //   'Invoice.pdf',
    //   pdfBytes,
    //   'application/pdf',
    //   text:
    //       'Hi nabeel ahammed, Details of your Sale Invoice from My Company. Invoice Amount: 1160.0. Thank you for doing business with us. My Company - 7012374637. Manage your Business on your phone.',
    // );
  }

  Future<Uint8List> _captureWidgetToImage() async {
    RenderRepaintBoundary boundary =
        _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    List<Recordset>? recdset;
    if (loading) {
    } else {
      recdset = ledgerReports!.recordset!.cast<Recordset>();
    }
    return Scaffold(
        appBar: AppBar(
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                // Handle the selection of the dropdown menu item
                print('Selected: $value');
              },
              itemBuilder: (BuildContext context) {
                return <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    child: InkWell(
                        onTap: () {
                          _printPage(PdfPageFormat.a4);
                        },
                        child: const Row(
                          children: [
                            Icon(
                              Icons.print,
                              color: Colors.indigo,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text('Print Invoice'),
                          ],
                        )),
                  ),
                  PopupMenuItem<String>(
                    child: InkWell(
                        onTap: () {
                          _shareInvoiceTo(context, PdfPageFormat.a4);
                        },
                        child: const Row(
                          children: [
                            Icon(
                              Icons.share,
                              color: Colors.indigo,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text('Share Invoice'),
                          ],
                        )),
                  ),
                  // Add more PopupMenuItems as needed
                ];
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: RepaintBoundary(
            key: _globalKey,
            child: loading
                ? SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            strokeWidth: 5,
                            color: Colors.grey,
                            backgroundColor: Colors.red,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Loading",
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          )
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 60,
                              width: 60,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  height: 5,
                                  width: 20,
                                  color: Colors.blue,
                                ),
                                Container(
                                  height: 60,
                                  width: 10,
                                  color: Colors.blue,
                                ),
                              ],
                            ),
                            const SizedBox(
                              width: 2,
                            ),
                            Container(
                              height: 65,
                              width: 3,
                              color: Colors.blue,
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "ACCOUNT SUMMERY",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                const Text(
                                  "Mr.MALABAR SAND",
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "From  $sDate",
                                      style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    Text(
                                      "To  $eDate",
                                      style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 0,
                        ),
                        const Divider(
                          color: Colors.blue,
                        ),
                        Container(
                          height: 20,
                          color: Colors.blue,
                          child: Table(
                            columnWidths: const {
                              0: FixedColumnWidth(45),
                              1: FlexColumnWidth(15),
                              2: FlexColumnWidth(8),
                              3: FlexColumnWidth(9),
                              4: FlexColumnWidth(8),
                            },
                            children: const [
                              TableRow(children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      '  Date',
                                      style: TextStyle(
                                          fontSize: 7,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      '  Description',
                                      style: TextStyle(
                                          fontSize: 7,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      'Debit',
                                      style: TextStyle(
                                          fontSize: 7,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      'Credit',
                                      style: TextStyle(
                                          fontSize: 7,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "Balanace",
                                      style: TextStyle(
                                          fontSize: 7,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ]),
                            ],
                            border:
                                TableBorder.all(width: 1, color: Colors.blue),
                          ),
                        ),
                        Table(
                          columnWidths: const {
                            0: FixedColumnWidth(45),
                            1: FlexColumnWidth(15),
                            2: FlexColumnWidth(8),
                            3: FlexColumnWidth(9),
                            4: FlexColumnWidth(8),
                          },
                          children: [
                            for (var i = 0; i < recdset!.length; i++)
                              TableRow(children: [
                                Center(
                                    child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Text(
                                        // '10/20/2020',
                                        '${recdset[i].date}',

                                        style: const TextStyle(
                                            fontSize: 6,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                )),
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Text(
                                    '${recdset[i].particulars}',
                                    style: const TextStyle(
                                        fontSize: 6,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${recdset[i].debit}',
                                        style: const TextStyle(
                                            fontSize: 6,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${recdset[i].credit}',
                                        style: const TextStyle(
                                            fontSize: 6,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Text(
                                        "${recdset[i].balance}",
                                        style: const TextStyle(
                                            fontSize: 6,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ]),
                          ],
                          border: TableBorder.all(width: 1, color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
          ),
        ));
  }
}

class LedgerReports {
  List<List<Recordsets>>? recordsets;
  List<Recordset>? recordset;
  Output? output;
  List<dynamic>? rowsAffected;
  int? returnValue;

  LedgerReports(
      {this.recordsets,
      this.recordset,
      this.output,
      this.rowsAffected,
      this.returnValue});

  LedgerReports.fromJson(Map<String, dynamic> json) {
    recordsets = (json["recordsets"] == null
            ? null
            : (json["recordsets"] as List)
                .map((e) => e == null
                    ? []
                    : (e as List).map((e) => Recordsets.fromJson(e)).toList())
                .toList())!
        .cast<List<Recordsets>>();
    recordset = json["recordset"] == null
        ? null
        : (json["recordset"] as List)
            .map((e) => Recordset.fromJson(e))
            .toList();
    output = json["output"] == null ? null : Output.fromJson(json["output"]);
    rowsAffected = json["rowsAffected"] ?? [];
    returnValue = json["returnValue"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    if (recordsets != null) {
      _data["recordsets"] =
          recordsets?.map((e) => e.map((e) => e.toJson()).toList()).toList();
    }
    if (recordset != null) {
      _data["recordset"] = recordset?.map((e) => e.toJson()).toList();
    }
    if (output != null) {
      _data["output"] = output?.toJson();
    }
    if (rowsAffected != null) {
      _data["rowsAffected"] = rowsAffected;
    }
    _data["returnValue"] = returnValue;
    return _data;
  }
}

class Output {
  Output();

  Output.fromJson(Map<String, dynamic> json) {}

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};

    return _data;
  }
}

class Recordset {
  String? date;
  String? particulars;
  String? voucher;
  String? entryNo;
  String? debit;
  String? credit;
  String? balance;
  String? narration;
  String? supInvNo;
  String? bankStatus;
  String? isSelected;
  String? receipt;
  String? days;

  Recordset(
      {this.date,
      this.particulars,
      this.voucher,
      this.entryNo,
      this.debit,
      this.credit,
      this.balance,
      this.narration,
      this.supInvNo,
      this.bankStatus,
      this.isSelected,
      this.receipt,
      this.days});

  Recordset.fromJson(Map<String, dynamic> json) {
    date = json["Date"];
    particulars = json["Particulars"];
    voucher = json["Voucher"];
    entryNo = json["EntryNo"];
    debit = json["Debit"];
    credit = json["Credit"];
    balance = json["Balance"];
    narration = json["Narration"];
    supInvNo = json["SupInvNo"];
    bankStatus = json["BankStatus"];
    isSelected = json["IsSelected"];
    receipt = json["Receipt"];
    days = json["Days"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["Date"] = date;
    _data["Particulars"] = particulars;
    _data["Voucher"] = voucher;
    _data["EntryNo"] = entryNo;
    _data["Debit"] = debit;
    _data["Credit"] = credit;
    _data["Balance"] = balance;
    _data["Narration"] = narration;
    _data["SupInvNo"] = supInvNo;
    _data["BankStatus"] = bankStatus;
    _data["IsSelected"] = isSelected;
    _data["Receipt"] = receipt;
    _data["Days"] = days;
    return _data;
  }
}

class Recordsets {
  String? date;
  String? particulars;
  String? voucher;
  String? entryNo;
  String? debit;
  String? credit;
  String? balance;
  String? narration;
  String? supInvNo;
  String? bankStatus;
  String? isSelected;
  String? receipt;
  String? days;

  Recordsets(
      {this.date,
      this.particulars,
      this.voucher,
      this.entryNo,
      this.debit,
      this.credit,
      this.balance,
      this.narration,
      this.supInvNo,
      this.bankStatus,
      this.isSelected,
      this.receipt,
      this.days});

  Recordsets.fromJson(Map<String, dynamic> json) {
    date = json["Date"];
    particulars = json["Particulars"];
    voucher = json["Voucher"];
    entryNo = json["EntryNo"];
    debit = json["Debit"];
    credit = json["Credit"];
    balance = json["Balance"];
    narration = json["Narration"];
    supInvNo = json["SupInvNo"];
    bankStatus = json["BankStatus"];
    isSelected = json["IsSelected"];
    receipt = json["Receipt"];
    days = json["Days"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["Date"] = date;
    _data["Particulars"] = particulars;
    _data["Voucher"] = voucher;
    _data["EntryNo"] = entryNo;
    _data["Debit"] = debit;
    _data["Credit"] = credit;
    _data["Balance"] = balance;
    _data["Narration"] = narration;
    _data["SupInvNo"] = supInvNo;
    _data["BankStatus"] = bankStatus;
    _data["IsSelected"] = isSelected;
    _data["Receipt"] = receipt;
    _data["Days"] = days;
    return _data;
  }
}