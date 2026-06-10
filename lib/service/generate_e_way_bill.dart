import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:sheraccerp/models/company.dart';
import 'package:sheraccerp/models/gst_auth_model.dart';
import 'package:sheraccerp/models/print_settings_model.dart';
import 'package:sheraccerp/scoped-models/mains.dart';
import 'package:sheraccerp/service/api_dio.dart';
import 'package:sheraccerp/shared/constants.dart';
import 'package:sheraccerp/util/dateUtil.dart';
import 'package:sheraccerp/util/res_color.dart';
import 'package:sheraccerp/widget/loading.dart';
import 'package:sheraccerp/widget/progress_hud.dart';

class GenerateEWaybill extends StatefulWidget {
  final data;
  final type;
  GenerateEWaybill({
    Key ?key,
    this.data,
    this.type,
  }) : super(key: key);

  @override
  State<GenerateEWaybill> createState() => _GenerateEWaybillState();
}

class _GenerateEWaybillState extends State<GenerateEWaybill> {
  dynamic data;
  var information, particulars, particularData, serialNO, deliveryNoteDetails;
  List? otherAmountList;
  String ?formattedDate, eWayBillClient = '';
  DateTime now = DateTime.now();
  CompanyInformation? companySettings;
  List<CompanySettings>? settings;
  PrintSettingsModel? printSettingsModel;
  bool _isLoading = false;

  List<String> supplyType = ["Outward", "Inward"];
  List<String> subSupplyType = [
    "Supply",
    "Import",
    "Export",
    "Job Work",
    "For Own Use",
    "Job work Returns",
    "Sales Return",
    "SKD/CKD",
    "Line Sales",
    "Recipient Not Known",
    "Exhibition or Fairs",
    "Others"
  ];
  List<String> doctype = [
    "Tax Invoice",
    "Bill of Supply",
    "Bill of Entry",
    "Delivery Challan",
    "Credit Note",
    "Others"
  ];
  List<String> transMode = ["Road", "Rail", "Air", "Ship"];
  List<String> vehicleType = ["Regular", "ODC"];
  List<String> transactionType = [
    "Regular",
    "Bill To-Ship To",
    "Bill From-Dispatch From",
    "Combination of 2 and 3"
  ];
  String ipAddress = '127.0.0.1';
  DioService api = DioService();
  String invoiceId = '',
      invoiceNo = '',
      invoiceDate = '',
      entryType = '',
      eWaybillNo = '';
  TextEditingController fromGstNoControl = TextEditingController();
  TextEditingController fromNameControl = TextEditingController();
  TextEditingController fromAddress1Control = TextEditingController();
  TextEditingController fromAddress2Control = TextEditingController();
  TextEditingController fromAddress3Control = TextEditingController();
  TextEditingController fromAddress4Control = TextEditingController();
  TextEditingController fromStateControl = TextEditingController();
  TextEditingController fromStateCodeControl = TextEditingController();
  TextEditingController fromActualStateCodeControl = TextEditingController();
  TextEditingController fromPinCodeControl = TextEditingController();
  TextEditingController fromEmailControl = TextEditingController();
  TextEditingController fromPhoneControl = TextEditingController();

  TextEditingController toGstNoControl = TextEditingController();
  TextEditingController toNameControl = TextEditingController();
  TextEditingController toAddress1Control = TextEditingController();
  TextEditingController toAddress2Control = TextEditingController();
  TextEditingController toAddress3Control = TextEditingController();
  TextEditingController toAddress4Control = TextEditingController();
  TextEditingController toPinCodeControl = TextEditingController();
  TextEditingController toStateCodeControl1 = TextEditingController();
  TextEditingController toStateCodeControl2 = TextEditingController();

  TextEditingController transporterControl = TextEditingController(text: "OWN");
  TextEditingController transporterIdControl = TextEditingController();
  TextEditingController transDocNoControl = TextEditingController();
  TextEditingController transDocDateControl = TextEditingController();
  TextEditingController invoiceNoControl = TextEditingController();
  TextEditingController invoiceDateControl = TextEditingController();
  TextEditingController distanceControl = TextEditingController();
  TextEditingController totalValueControl = TextEditingController();
  TextEditingController cGSTControl = TextEditingController();
  TextEditingController sGSTControl = TextEditingController();
  TextEditingController iGSTControl = TextEditingController();
  TextEditingController cessControl = TextEditingController();
  TextEditingController totalControl = TextEditingController();
  TextEditingController mainHSNControl = TextEditingController();
  TextEditingController otherChargeControl = TextEditingController();
  TextEditingController refNoControl = TextEditingController();
  TextEditingController eWayBillNoControl = TextEditingController();
  TextEditingController vehicleControl = TextEditingController();

  String supplyTypeValue = 'Outward',
      subSupplyTypeValue = 'Supply',
      doctypeValue = 'Tax Invoice',
      transModeValue = 'Road',
      vehicleTypeValue = 'Regular',
      transactionTypeValue = 'Regular';
  bool isKmLoading = false;
  String transactionId = '';

  List colHeader = [
    "SlNo",
    "ItemName",
    "HSN",
    "Qty",
    "Unit",
    "Net",
    "CGST",
    "SGST",
    "IGST",
    "CESS"
  ];
  var _username = '';
  var _password = '';
  var _clientId = '';
  var _clientSecret = '';

  @override
  void initState() {
    super.initState();
    entryType = widget.type ?? '';
    formattedDate = DateFormat('dd/MM/yyyy').format(now);
    data = widget.data;
    information = data['Information'][0];
    particularData = data['Particulars'];
    serialNO = data['SerialNO'];
    deliveryNoteDetails = data['DeliveryNote'];
    otherAmountList = data['otherAmount'];
    invoiceId = information['EntryNo'].toString();
    invoiceNo = information['InvoiceNo'].toString();
    invoiceDate = DateUtil.dateDMY1(information['DDate'].toString());
    invoiceNoControl.text = invoiceNo;
    invoiceDateControl.text = invoiceDate;
    transDocNoControl.text = invoiceNo;
    transDocDateControl.text =
        DateUtil.dateDMmmY(information['DDate'].toString());
    particulars = partBData(particularData);

    companySettings = ScopedModel.of<MainModel>(context).getCompanySettings();
    settings = ScopedModel.of<MainModel>(context).getSettings();
    totalValueControl.text = information['NetAmount'].toString();
    cGSTControl.text = information['CGST'].toString();
    sGSTControl.text = information['SGST'].toString();
    iGSTControl.text = information['IGST'].toString();
    cessControl.text = information['cess'].toString();
    totalControl.text = information['Total'].toString();
    otherChargeControl.text = information['OtherCharges'].toString();
    refNoControl.text = invoiceNo;
    eWayBillNoControl.text = information['EWayBillNo'].toString().trim();
    eWaybillNo = eWayBillNoControl.text;
    vehicleControl.text = information['EVehicleNo'].toString().trim();

    // manualInvoiceNumberInSales =
    //     ComSettings.getStatus('MANNUAL INVOICE NUMBER IN SALES', settings);
    eWayBillClient = ComSettings.getValue('EWAYBILLAPI OWNER', settings!);
    fromGstNoControl.text = ComSettings.getValue('GST-NO', settings!);
    fromStateControl.text = ComSettings.getValue('COMP-STATE', settings!);
    var cStateCode = ComSettings.getValue('COMP-STATECODE', settings!);
    fromStateCodeControl.text = cStateCode;
    fromActualStateCodeControl.text = cStateCode;
    fromAddress1Control.text = companySettings!.add1!;
    fromAddress2Control.text = companySettings!.add2!;
    fromAddress3Control.text = companySettings!.add3!;
    fromAddress4Control.text = companySettings!.add4!;
    var cAddress5 = companySettings!.add5!;
    fromEmailControl.text = companySettings!.email!;
    fromNameControl.text = companySettings!.name!;
    fromPhoneControl.text = companySettings!.mobile!;
    fromPinCodeControl.text = companySettings!.pin!;
    var sName = companySettings!.sName;
    var tel = companySettings!.telephone;

    if (printSettingsList != null) {
      if (printSettingsList.isNotEmpty) {
        printSettingsModel = printSettingsList.firstWhere(
            (element) =>
                element.model == 'INVOICE DESIGNER' &&
                element.dTransaction == widget.type &&
                element.fyId == currentFinancialYear!.id,
            orElse: () => printSettingsList.isNotEmpty
                ? printSettingsList[0]
                : PrintSettingsModel.empty());
      }
    }
    entryType = widget.type ?? '';
    // salestype = salestype;
    // this._salesno = entryno;
    // this.TxtEwayBillNo.Text = ewb;
    if (eWaybillNo.isNotEmpty) {
      // DataSet ds = this.dbSelectData2("Find", ewb);
      // if (ds != null && ds.Tables[0].Rows.Count > 0)
      // {
      //     this.cmbsupplytype.SelectedIndex = Convert.ToInt32(ds.Tables[0].Rows[0]["SupplyType"].ToString());
      //     this.txtinvoiceno.Text = ds.Tables[0].Rows[0]["InvoiceNo"].ToString();
      //     this.cmbtransmode.SelectedIndex = Convert.ToInt32(ds.Tables[0].Rows[0]["TransMode"].ToString());
      //     this.cmbvehicletype.SelectedIndex = Convert.ToInt32(ds.Tables[0].Rows[0]["VehicleType"].ToString());
      //     this.cmbdoctype.SelectedIndex = Convert.ToInt32(ds.Tables[0].Rows[0]["DocType"].ToString());
      //     this.txttransporter.Text = ds.Tables[0].Rows[0]["TransporterName"].ToString();
      //     this.txtdocno.Text = ds.Tables[0].Rows[0]["TransDocNo"].ToString();
      //     this.cmbsubsupplytype.SelectedIndex = Convert.ToInt32(ds.Tables[0].Rows[0]["SubSupplyType"].ToString());
      //     this.TxtOthers.Text = ds.Tables[0].Rows[0]["SupplyTypeOthers"].ToString();
      //     this.txtdocdate.Text = ds.Tables[0].Rows[0]["InvoiceDate"].ToString();
      //     this.txtdistance.Text = ds.Tables[0].Rows[0]["Distance"].ToString();
      //     this.txtvehicleno.Text = ds.Tables[0].Rows[0]["VehicleNo"].ToString();
      //     this.cmbTransactiontype.SelectedIndex = Convert.ToInt32(ds.Tables[0].Rows[0]["TransactionType"].ToString());
      //     this.txtid.Text = ds.Tables[0].Rows[0]["TransactionId"].ToString();
      //     this.txtdocdate1.Text = ds.Tables[0].Rows[0]["TransDocDate"].ToString();
      //     this.TxtEwayBillNo.Text = ds.Tables[0].Rows[0]["EwayBillNo"].ToString();
      //     this.TxtEwayBillDateTime.Text = ds.Tables[0].Rows[0]["EwayBillDate"].ToString();
      //     this.TxtValidUpto.Text = ds.Tables[0].Rows[0]["ValidUpto"].ToString();
      //     this.label38.Text = ds.Tables[0].Rows[0]["EwayStatus"].ToString();
      //     if (this.label38.Text == "Generated")
      //     {
      //         this.BtnSave.Enabled = false;
      //     }
      // }
    }
    if (entryType == "SALES") {
      // this.FnFindData(entryno.ToString(), salestype, "SALES");
      // return;
    }
    if (entryType == "DELIVERY NOTE") {
      // this.FnFindData(entryno.ToString(), salestype, "DELIVERY NOTE");
      // return;
    }
    if (entryType == "STOCK TRANSFER") {
      // this.FnFindStktr(entryno.ToString());
    }
    fetchPublicIp();
    api.eInvoiceDetails().then((value) {
      var data = value[0];
      _username = data['username'];
      _password = data['password'];
      // if (eWayBillClient != "SHERSOFT") {
      //   _clientId = data['ClientId'];
      //   _clientSecret = data['Clientscreate'];
      // } else {
      //   var cId = "2d9193c4-d528-42a0-b7bc-a01ac3d3827b";
      //   var cSecret = "bb60872c-e8f7-4056-a34a-e9157c4110ca";
      //   _clientId = cId;
      //   _clientSecret = cSecret;
      // }
    });
    var cId = "2d9193c4-d528-42a0-b7bc-a01ac3d3827b";
    var cSecret = "bb60872c-e8f7-4056-a34a-e9157c4110ca";
    _clientId = cId;
    _clientSecret = cSecret;
    api.getCustomerDetail(information['Customer']).then((value) {
      var data = value;
      toAddress1Control.text = data.address1!;
      toAddress2Control.text = data.address2!;
      toAddress3Control.text = data.address3!;
      toAddress4Control.text = data.address4!;
      // emailControl.text = data.email;
      toGstNoControl.text = data.taxNumber!;
      // phoneControl.text = data.phone;
      toPinCodeControl.text = data.pinNo!;
      var stateCode1 = data.stateCode;
      var stateCode2 = data.stateCode;
      toStateCodeControl1.text = stateCode1!;
      toStateCodeControl2.text = stateCode2!;
      toNameControl.text = data.name!;
      if (toPinCodeControl.text.isNotEmpty &&
          fromPinCodeControl.text.isNotEmpty) {
        calculateDistance();
      }
    });
  }


  fetchPublicIp() {
    api.getPublicIp().then((value) => ipAddress = value);
  }

  Future printIps() async {
    for (var interface in await NetworkInterface.list()) {
      // debugPrint('== Interface: ${interface.name} ==');
      for (var addr in interface.addresses) {
        ipAddress = addr.address;
        // debugPrint(
        //     '${addr.address} ${addr.host} ${addr.isLoopback} ${addr.rawAddress} ${addr.type.name}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> particularsList = 
    particulars is List ? List<Map<String, dynamic>>.from(particulars) : [];
    if (eWayBillNoControl.text.trim().isNotEmpty) {
      //
    }
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('E-Way Bill', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: kPrimaryColor,
          elevation: 0,
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.print_outlined),
              tooltip: 'Print',
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  printEWayBill();
                });
              },
            ),
          ],
        ),
        body: ProgressHUD(
          inAsyncCall: _isLoading,
          opacity: 0.0,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildSection(
                    title: "Your Details",
                    icon: Icons.person_outline,
                    child: _buildAddressForm(
                      gstController: fromGstNoControl,
                      nameController: fromNameControl,
                      address1Controller: fromAddress1Control,
                      address2Controller: fromAddress2Control,
                      placeController: fromAddress3Control,
                      pinCodeController: fromPinCodeControl,
                      stateCodeController: fromStateCodeControl,
                      actualStateCodeController: fromActualStateCodeControl,
                    ),
                  ),
                  const SizedBox(height: 20),   
                  _buildSection(
                    title: "Party Details",
                    icon: Icons.business_outlined,
                    child: _buildAddressForm(
                      gstController: toGstNoControl,
                      nameController: toNameControl,
                      address1Controller: toAddress1Control,
                      address2Controller: toAddress2Control,
                      placeController: toAddress3Control,
                      pinCodeController: toPinCodeControl,
                      stateCodeController: toStateCodeControl1,
                      actualStateCodeController: toStateCodeControl2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    title: "Transport Details",
                    icon: Icons.local_shipping_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _buildDropdown(
                              label: 'Supply Type',
                              value: supplyTypeValue,
                              items: supplyType,
                              onChanged: (value) => setState(() => supplyTypeValue = value!),
                            ),
                            _buildDropdown(
                              label: 'Sub Supply Type',
                              value: subSupplyTypeValue,
                              items: subSupplyType,
                              onChanged: (value) => setState(() => subSupplyTypeValue = value!),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: invoiceNoControl,
                                label: 'Invoice No',
                                onChanged: (value) => invoiceNo = value,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                controller: invoiceDateControl,
                                label: 'Invoice Date',
                                onChanged: (value) => invoiceDate = value,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildDropdown(
                                  label: 'Transport Mode',
                                  value: transModeValue,
                                  items: transMode,
                                  onChanged: (value) => setState(() => transModeValue = value!),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  children: [
                                    const SizedBox(height: 16),
                                    _buildTextField(
                                      controller: distanceControl,
                                      label: 'Distance (KM)',
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              isKmLoading
                                  ? const Loading()
                                  : IconButton(
                                      onPressed: () {
                                        setState(() => isKmLoading = true);
                                        calculateDistance();
                                      },
                                      icon: const Icon(Icons.calculate_outlined, color: black),
                                      tooltip: 'Calculate Distance',
                                    ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildDropdown(
                                  label: 'Vehicle Type',
                                  value: vehicleTypeValue,
                                  items: vehicleType,
                                  onChanged: (value) => setState(() => vehicleTypeValue = value!),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  children: [
                                    const SizedBox(height: 16),
                                    _buildTextField(
                                      controller: vehicleControl,
                                      label: 'Vehicle No',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Doc Type & Transaction Type
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildDropdown(
                                  label: 'Doc Type',
                                  value: doctypeValue,
                                  items: doctype,
                                  onChanged: (value) => setState(() => doctypeValue = value!),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildDropdown(
                                  label: 'Transaction Type',
                                  value: transactionTypeValue,
                                  items: transactionType,
                                  onChanged: (value) => setState(() => transactionTypeValue = value!),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Transporter Details
                        const Text(
                          'Transporter Details',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blue),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: transporterControl,
                                label: 'Transporter Name',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                controller: fromGstNoControl,
                                label: 'Transporter ID',
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: transDocNoControl,
                                label: 'Trans Doc No',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                controller: transDocDateControl,
                                label: 'Trans Doc Date',
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Tax Details
                        const Text(
                          'Tax Details',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blue),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            SizedBox(
                              width: 180,
                              child: _buildTextField(
                                controller: totalValueControl,
                                label: 'Total Value',
                              ),
                            ),
                            SizedBox(
                              width: 180,
                              child: _buildTextField(
                                controller: sGSTControl,
                                label: 'SGST',
                              ),
                            ),
                            SizedBox(
                              width: 180,
                              child: _buildTextField(
                                controller: cGSTControl,
                                label: 'CGST',
                              ),
                            ),
                            SizedBox(
                              width: 180,
                              child: _buildTextField(
                                controller: iGSTControl,
                                label: 'IGST',
                              ),
                            ),
                            SizedBox(
                              width: 180,
                              child: _buildTextField(
                                controller: cessControl,
                                label: 'CESS',
                              ),
                            ),
                            SizedBox(
                              width: 180,
                              child: _buildTextField(
                                controller: totalControl,
                                label: 'Total',
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        const Text(
                          'Additional Details',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blue),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: mainHSNControl,
                                label: 'Main HSN',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                controller: otherChargeControl,
                                label: 'Other Charges',
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: refNoControl,
                                label: 'Ref No',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                controller: eWayBillNoControl,
                                label: 'E-Way Bill No',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTable(
                    title: "Item Details",
                    icon: Icons.list_alt_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!, width: 1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: DataTable(
                              headingRowColor: MaterialStateColor.resolveWith(
                                (states) => Colors.blue[50]!,
                              ),
                              border: TableBorder(
                                horizontalInside: BorderSide(color: Colors.grey[300]!),
                                verticalInside: BorderSide(color: Colors.grey[300]!),
                              ),
                              columnSpacing: 24,
                              dataRowHeight: 36,
                              headingRowHeight: 40,
                              horizontalMargin: 12,
                              columns: colHeader.map((header) {
                                return DataColumn(
                                  label: Text(
                                    header,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }).toList(),
                              rows: particularsList.map<DataRow>((values) {
                                return DataRow(
                                  cells: [
                                    _buildDataCell(values['no']?.toString() ?? ''),
                                    _buildDataCell(values['name']?.toString() ?? ''),
                                    _buildDataCell(values['hsn']?.toString() ?? ''),
                                    _buildDataCell(values['qty']?.toString() ?? ''),
                                    _buildDataCell(values['unit']?.toString() ?? ''),
                                    _buildDataCell(values['net']?.toString() ?? ''),
                                    _buildDataCell(values['cGst']?.toString() ?? ''),
                                    _buildDataCell(values['cGst']?.toString() ?? ''),
                                    _buildDataCell(values['iGst']?.toString() ?? ''),
                                    _buildDataCell(values['cess']?.toString() ?? ''),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Container(
          height: 60,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Container(
                   decoration: const BoxDecoration(
                    color: white,
                    borderRadius: BorderRadiusDirectional.only(
                      bottomStart: Radius.circular(30),
                      topStart: Radius.circular(30),
                    ),
                  ),
                  child: _buildActionButton(
                    icon: Icons.cancel_outlined,
                    label: 'Cancel',
                    color: black,
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        cancelEWayBill();
                      });
                    },
                  ),
                ),
              ),
               Container(
                width: 1,
                height: 30,
                color: Colors.grey[300],
              ),
              Expanded(
                child: Container(
                   decoration: const BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadiusDirectional.only(
                      bottomEnd: Radius.circular(30),
                      topEnd: Radius.circular(30),
                    ),
                  ),
                  child: _buildActionButton(
                    icon: CupertinoIcons.add_circled,
                    label: 'Generate',
                    color: white,
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        generateEWayBill();
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    // return Scaffold(
    //     appBar: AppBar(
    //       title: const Text('E-Way Bill'),
    //       actions: [
    //         IconButton(
    //             icon: const Icon(Icons.save),
    //             onPressed: () {
    //               setState(
    //                 () {
    //                   _isLoading = true;
    //                   generateEWayBill();
    //                 },
    //               );
    //             }),
    //         IconButton(
    //             icon: const Icon(Icons.cancel),
    //             onPressed: () {
    //               setState(
    //                 () {
    //                   _isLoading = true;
    //                   cancelEWayBill();
    //                 },
    //               );
    //             }),
    //         IconButton(
    //             icon: const Icon(Icons.print),
    //             onPressed: () {
    //               setState(
    //                 () {
    //                   _isLoading = true;
    //                   printEWayBill();
    //                 },
    //               );
    //             }),
    //       ],
    //     ),
    //     body: ProgressHUD(
    //       inAsyncCall: _isLoading,
    //       opacity: 0.0,
    //       child: SingleChildScrollView(
    //         child: Padding(
    //           padding: const EdgeInsets.symmetric(horizontal: 2.0),
    //           child: Column(
    //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //             children: [
    //               // Row(
    //               //   mainAxisAlignment: MainAxisAlignment.center,
    //               //   children: [
    //               //     const Text(
    //               //       'Date : ',
    //               //       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
    //               //     ),
    //               //     InkWell(
    //               //       child: Text(
    //               //         formattedDate,
    //               //         style: const TextStyle(
    //               //             fontWeight: FontWeight.bold, fontSize: 18),
    //               //       ),
    //               //       onTap: () => _selectDate(),
    //               //     ),
    //               //   ],
    //               // ),
    //               ExpansionTile(
    //                   title: const Text(
    //                     "Your Details",
    //                     style: TextStyle(
    //                         fontSize: 18.0, fontWeight: FontWeight.bold),
    //                   ),
    //                   children: [
    //                     const SizedBox(
    //                       height: 1,
    //                     ),
    //                     Card(
    //                       elevation: 5,
    //                       color: blue[50],
    //                       child: Column(
    //                         mainAxisAlignment: MainAxisAlignment.center,
    //                         crossAxisAlignment: CrossAxisAlignment.center,
    //                         children: [
    //                           TextField(
    //                             controller: fromGstNoControl,
    //                             decoration: const InputDecoration(
    //                               labelText: 'GST No.',
    //                               border: OutlineInputBorder(),
    //                             ),
    //                           ),
    //                           const SizedBox(
    //                             height: 5,
    //                           ),
    //                           TextField(
    //                             controller: fromNameControl,
    //                             decoration: const InputDecoration(
    //                               labelText: 'Name',
    //                               border: OutlineInputBorder(),
    //                             ),
    //                           ),
    //                           const SizedBox(
    //                             height: 5,
    //                           ),
    //                           TextField(
    //                             controller: fromAddress1Control,
    //                             decoration: const InputDecoration(
    //                               labelText: 'Address1',
    //                               border: OutlineInputBorder(),
    //                             ),
    //                           ),
    //                           const SizedBox(
    //                             height: 5,
    //                           ),
    //                           TextField(
    //                             controller: fromAddress2Control,
    //                             decoration: const InputDecoration(
    //                               labelText: 'Address2',
    //                               border: OutlineInputBorder(),
    //                             ),
    //                           ),
    //                           const SizedBox(
    //                             height: 5,
    //                           ),
    //                           TextField(
    //                             controller: fromAddress3Control,
    //                             decoration: const InputDecoration(
    //                               labelText: 'Place',
    //                               border: OutlineInputBorder(),
    //                             ),
    //                           ),
    //                           const SizedBox(
    //                             height: 5,
    //                           ),
    //                           TextField(
    //                             controller: fromPinCodeControl,
    //                             decoration: const InputDecoration(
    //                               labelText: 'PinCode',
    //                               border: OutlineInputBorder(),
    //                             ),
    //                           ),
    //                           const SizedBox(
    //                             height: 5,
    //                           ),
    //                           Row(
    //                             mainAxisAlignment:
    //                                 MainAxisAlignment.spaceAround,
    //                             children: [
    //                               Expanded(
    //                                 child: TextField(
    //                                   controller: fromStateCodeControl,
    //                                   decoration: const InputDecoration(
    //                                     labelText: 'StateCode',
    //                                     border: OutlineInputBorder(),
    //                                   ),
    //                                 ),
    //                               ),
    //                               const SizedBox(
    //                                 width: 5,
    //                               ),
    //                               Expanded(
    //                                 child: TextField(
    //                                   controller: fromActualStateCodeControl,
    //                                   decoration: const InputDecoration(
    //                                     labelText: 'Actual StateCode',
    //                                     border: OutlineInputBorder(),
    //                                   ),
    //                                 ),
    //                               ),
    //                             ],
    //                           ),
    //                         ],
    //                       ),
    //                     ),
    //                   ]),
    //               ExpansionTile(
    //                 title: const Text(
    //                   "Party Details",
    //                   style: TextStyle(
    //                       fontSize: 18.0, fontWeight: FontWeight.bold),
    //                 ),
    //                 children: [
    //                   const SizedBox(
    //                     height: 1,
    //                   ),
    //                   Card(
    //                       elevation: 5,
    //                       color: blue[50],
    //                       child: Column(
    //                         mainAxisAlignment: MainAxisAlignment.center,
    //                         crossAxisAlignment: CrossAxisAlignment.center,
    //                         children: [
    //                           TextField(
    //                             controller: toGstNoControl,
    //                             decoration: const InputDecoration(
    //                               labelText: 'GST No.',
    //                               border: OutlineInputBorder(),
    //                             ),
    //                           ),
    //                           const SizedBox(
    //                             height: 5,
    //                           ),
    //                           TextField(
    //                             controller: toNameControl,
    //                             decoration: const InputDecoration(
    //                               labelText: 'Name',
    //                               border: OutlineInputBorder(),
    //                             ),
    //                           ),
    //                           const SizedBox(
    //                             height: 5,
    //                           ),
    //                           TextField(
    //                             controller: toAddress1Control,
    //                             decoration: const InputDecoration(
    //                               labelText: 'Address1',
    //                               border: OutlineInputBorder(),
    //                             ),
    //                           ),
    //                           const SizedBox(
    //                             height: 5,
    //                           ),
    //                           TextField(
    //                             controller: toAddress2Control,
    //                             decoration: const InputDecoration(
    //                               labelText: 'Address2',
    //                               border: OutlineInputBorder(),
    //                             ),
    //                           ),
    //                           const SizedBox(
    //                             height: 5,
    //                           ),
    //                           TextField(
    //                             controller: toAddress3Control,
    //                             decoration: const InputDecoration(
    //                               labelText: 'Place',
    //                               border: OutlineInputBorder(),
    //                             ),
    //                           ),
    //                           const SizedBox(
    //                             height: 5,
    //                           ),
    //                           TextField(
    //                             controller: toPinCodeControl,
    //                             decoration: const InputDecoration(
    //                               labelText: 'PinCode',
    //                               border: OutlineInputBorder(),
    //                             ),
    //                           ),
    //                           const SizedBox(
    //                             height: 5,
    //                           ),
    //                           Row(
    //                             mainAxisAlignment:
    //                                 MainAxisAlignment.spaceAround,
    //                             children: [
    //                               Expanded(
    //                                 child: TextField(
    //                                   controller: toStateCodeControl1,
    //                                   decoration: const InputDecoration(
    //                                     labelText: 'StateCode',
    //                                     border: OutlineInputBorder(),
    //                                   ),
    //                                 ),
    //                               ),
    //                               const SizedBox(
    //                                 width: 5,
    //                               ),
    //                               Expanded(
    //                                 child: TextField(
    //                                   controller: toStateCodeControl2,
    //                                   decoration: const InputDecoration(
    //                                     labelText: 'Actual StateCode',
    //                                     border: OutlineInputBorder(),
    //                                   ),
    //                                 ),
    //                               ),
    //                             ],
    //                           ),
    //                         ],
    //                       )),
    //                 ],
    //               ),
    //               const Text(
    //                 "Transport Details",
    //                 style:
    //                     TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
    //               ),
    //               Card(
    //                 elevation: 5,
    //                 child: Row(
    //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //                   children: [
    //                     const Text(
    //                       'Supply Type',
    //                       style: TextStyle(fontSize: 13),
    //                     ),
    //                     SizedBox(
    //                       width: 80,
    //                       child: DropdownButton(
    //                         items: supplyType
    //                             .map<DropdownMenuItem<String>>((item) {
    //                           return DropdownMenuItem<String>(
    //                             value: item,
    //                             child: Text(item),
    //                           );
    //                         }).toList(),
    //                         value: supplyTypeValue,
    //                         onChanged: (value) {
    //                           setState(() {
    //                             supplyTypeValue = value!;
    //                           });
    //                         },
    //                       ),
    //                     ),
    //                     const SizedBox(
    //                       width: 8,
    //                     ),
    //                     const Text(
    //                       'Sub Supply Type',
    //                       style: TextStyle(fontSize: 13),
    //                     ),
    //                     SizedBox(
    //                       width: 80,
    //                       child: DropdownButton(
    //                         items: subSupplyType
    //                             .map<DropdownMenuItem<String>>((item) {
    //                           return DropdownMenuItem<String>(
    //                             value: item,
    //                             child: Text(item),
    //                           );
    //                         }).toList(),
    //                         value: subSupplyTypeValue,
    //                         onChanged: (value) {
    //                           setState(() {
    //                             subSupplyTypeValue = value!;
    //                           });
    //                         },
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //               const Divider(),
    //               Row(
    //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                 children: [
    //                   Expanded(
    //                     child: TextField(
    //                       controller: invoiceNoControl,
    //                       decoration: const InputDecoration(
    //                         labelText: 'InvoiceNo',
    //                         border: OutlineInputBorder(),
    //                       ),
    //                       style: const TextStyle(fontSize: 13),
    //                       onChanged: (value) {
    //                         invoiceNo = value;
    //                       },
    //                     ),
    //                   ),
    //                   const SizedBox(
    //                     width: 5,
    //                   ),
    //                   Expanded(
    //                     child: TextField(
    //                       controller: invoiceDateControl,
    //                       decoration: const InputDecoration(
    //                         labelText: 'Invoice Date',
    //                         border: OutlineInputBorder(),
    //                       ),
    //                       style: const TextStyle(fontSize: 13),
    //                       onChanged: (value) {
    //                         invoiceDate = value;
    //                       },
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //               const Divider(),
    //               Card(
    //                 elevation: 3,
    //                 child: Row(
    //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //                   children: [
    //                     const Text(
    //                       'Trans Mode',
    //                       // style: TextStyle(fontSize: 13),
    //                     ),
    //                     const SizedBox(width: 1),
    //                     DropdownButton(
    //                       items:
    //                           transMode.map<DropdownMenuItem<String>>((item) {
    //                         return DropdownMenuItem<String>(
    //                           value: item,
    //                           child: Text(item),
    //                         );
    //                       }).toList(),
    //                       value: transModeValue,
    //                       onChanged: (value) {
    //                         setState(() {
    //                           transModeValue = value!;
    //                         });
    //                       },
    //                     ),
    //                     SizedBox(
    //                       width: 90,
    //                       child: Expanded(
    //                         child: TextField(
    //                           controller: distanceControl,
    //                           decoration: const InputDecoration(
    //                             labelText: 'Distance',
    //                             border: OutlineInputBorder(),
    //                           ),
    //                           style: const TextStyle(fontSize: 13),
    //                         ),
    //                       ),
    //                     ),
    //                     isKmLoading
    //                         ? const Loading()
    //                         : ElevatedButton(
    //                             onPressed: () {
    //                               setState(() {
    //                                 isKmLoading = true;
    //                               });
    //                               calculateDistance();
    //                             },
    //                             child: const Text('KM'))
    //                   ],
    //                 ),
    //               ),
    //               Card(
    //                 elevation: 5,
    //                 child: Row(
    //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //                   children: [
    //                     const Text(
    //                       'Vehicle Type',
    //                       // style: TextStyle(fontSize: 10),
    //                     ),
    //                     DropdownButton(
    //                       items:
    //                           vehicleType.map<DropdownMenuItem<String>>((item) {
    //                         return DropdownMenuItem<String>(
    //                           value: item,
    //                           child: Text(item),
    //                         );
    //                       }).toList(),
    //                       value: vehicleTypeValue,
    //                       onChanged: (value) {
    //                         setState(() {
    //                           vehicleTypeValue = value!;
    //                         });
    //                       },
    //                     ),
    //                     SizedBox(
    //                       width: 120,
    //                       child: Expanded(
    //                         child: TextField(
    //                           controller: vehicleControl,
    //                           decoration: const InputDecoration(
    //                             labelText: 'Vehicle No',
    //                             border: OutlineInputBorder(),
    //                           ),
    //                           style: const TextStyle(fontSize: 13),
    //                         ),
    //                       ),
    //                     )
    //                   ],
    //                 ),
    //               ),
    //               Card(
    //                 elevation: 5,
    //                 child: Row(
    //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //                   children: [
    //                     const Text(
    //                       'Doc Type',
    //                       style: TextStyle(fontSize: 13),
    //                     ),
    //                     const SizedBox(width: 2),
    //                     SizedBox(
    //                       width: 100,
    //                       child: DropdownButton(
    //                         items:
    //                             doctype.map<DropdownMenuItem<String>>((item) {
    //                           return DropdownMenuItem<String>(
    //                             value: item,
    //                             child:
    //                                 Text(item, style: TextStyle(fontSize: 13)),
    //                           );
    //                         }).toList(),
    //                         value: doctypeValue,
    //                         onChanged: (value) {
    //                           setState(() {
    //                             doctypeValue = value!;
    //                           });
    //                         },
    //                       ),
    //                     ),
    //                     const SizedBox(width: 8),
    //                     const Text(
    //                       'Transaction Type',
    //                       style: TextStyle(fontSize: 13),
    //                     ),
    //                     const SizedBox(width: 2),
    //                     SizedBox(
    //                       width: 120,
    //                       child: DropdownButton(
    //                         items: transactionType
    //                             .map<DropdownMenuItem<String>>((item) {
    //                           return DropdownMenuItem<String>(
    //                             value: item,
    //                             child:
    //                                 Text(item, style: TextStyle(fontSize: 13)),
    //                           );
    //                         }).toList(),
    //                         value: transactionTypeValue,
    //                         onChanged: (value) {
    //                           setState(() {
    //                             transactionTypeValue = value!;
    //                           });
    //                         },
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //               const Divider(),
    //               Row(
    //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                 children: [
    //                   Expanded(
    //                     child: TextField(
    //                       controller: transporterControl,
    //                       decoration: const InputDecoration(
    //                         labelText: 'Transporter Name',
    //                         border: OutlineInputBorder(),
    //                       ),
    //                     ),
    //                   ),
    //                   const SizedBox(width: 5),
    //                   Expanded(
    //                     child: TextField(
    //                       controller: fromGstNoControl,
    //                       decoration: const InputDecoration(
    //                         labelText: 'Id',
    //                         border: OutlineInputBorder(),
    //                       ),
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //               const Divider(),
    //               Row(
    //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                 children: [
    //                   Expanded(
    //                     child: TextField(
    //                       controller: transDocNoControl,
    //                       decoration: const InputDecoration(
    //                         labelText: 'Trans Doc No',
    //                         border: OutlineInputBorder(),
    //                       ),
    //                       onChanged: (value) {
    //                         // invoiceNo = value;
    //                       },
    //                     ),
    //                   ),
    //                   const SizedBox(
    //                     width: 5,
    //                   ),
    //                   Expanded(
    //                     child: TextField(
    //                       controller: transDocDateControl,
    //                       decoration: const InputDecoration(
    //                         labelText: 'Trans Doc Date',
    //                         border: OutlineInputBorder(),
    //                       ),
    //                       onChanged: (value) {
    //                         // invoiceDate = value;
    //                       },
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //               const Divider(),
    //               Row(
    //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                 children: [
    //                   Expanded(
    //                     child: TextField(
    //                       controller: totalValueControl,
    //                       decoration: const InputDecoration(
    //                         labelText: 'Total Value',
    //                         border: OutlineInputBorder(),
    //                       ),
    //                     ),
    //                   ),
    //                   const SizedBox(width: 2),
    //                   Expanded(
    //                     child: TextField(
    //                       controller: sGSTControl,
    //                       decoration: const InputDecoration(
    //                         labelText: 'SGST',
    //                         border: OutlineInputBorder(),
    //                       ),
    //                     ),
    //                   ),
    //                   const SizedBox(width: 2),
    //                   Expanded(
    //                     child: TextField(
    //                       controller: cGSTControl,
    //                       decoration: const InputDecoration(
    //                         labelText: 'CGST',
    //                         border: OutlineInputBorder(),
    //                       ),
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //               const Divider(),
    //               Row(
    //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                 children: [
    //                   Expanded(
    //                     child: TextField(
    //                       controller: iGSTControl,
    //                       decoration: const InputDecoration(
    //                         labelText: 'IGST',
    //                         border: OutlineInputBorder(),
    //                       ),
    //                     ),
    //                   ),
    //                   const SizedBox(width: 2),
    //                   Expanded(
    //                     child: TextField(
    //                       controller: cessControl,
    //                       decoration: const InputDecoration(
    //                         labelText: 'CESS',
    //                         border: OutlineInputBorder(),
    //                       ),
    //                     ),
    //                   ),
    //                   const SizedBox(width: 2),
    //                   Expanded(
    //                     child: TextField(
    //                       controller: totalControl,
    //                       decoration: const InputDecoration(
    //                         labelText: 'Total',
    //                         border: OutlineInputBorder(),
    //                       ),
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //               const Divider(),
    //               Row(
    //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                 children: [
    //                   Expanded(
    //                     child: TextField(
    //                       controller: mainHSNControl,
    //                       decoration: const InputDecoration(
    //                         labelText: 'Main HSN',
    //                         border: OutlineInputBorder(),
    //                       ),
    //                     ),
    //                   ),
    //                   const SizedBox(width: 5),
    //                   Expanded(
    //                     child: TextField(
    //                       controller: otherChargeControl,
    //                       decoration: const InputDecoration(
    //                         labelText: 'Other Charges',
    //                         border: OutlineInputBorder(),
    //                       ),
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //               const Divider(),
    //               Row(
    //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                 children: [
    //                   Expanded(
    //                     child: TextField(
    //                       controller: refNoControl,
    //                       decoration: const InputDecoration(
    //                         labelText: 'Ref No',
    //                         border: OutlineInputBorder(),
    //                       ),
    //                     ),
    //                   ),
    //                   const SizedBox(width: 5),
    //                   Expanded(
    //                     child: TextField(
    //                       controller: eWayBillNoControl,
    //                       decoration: const InputDecoration(
    //                         labelText: 'E-Way Bill No',
    //                         border: OutlineInputBorder(),
    //                       ),
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //               const Divider(),
    //               SingleChildScrollView(
    //                 scrollDirection: Axis.horizontal,
    //                 child: DataTable(
    //                     headingRowColor: MaterialStateColor.resolveWith(
    //                         (states) => Colors.grey.shade200),
    //                     border:
    //                         TableBorder.all(width: 1.0, color: Colors.black),
    //                     columnSpacing: 12,
    //                     dataRowHeight: 20,
    //                     headingRowHeight: 30,
    //                     columns: [
    //                       for (int i = 0; i < colHeader.length; i++)
    //                         DataColumn(
    //                           label: Align(
    //                             alignment: Alignment.center,
    //                             child: Text(
    //                               colHeader[i],
    //                               style: const TextStyle(
    //                                   fontWeight: FontWeight.bold),
    //                               textAlign: TextAlign.center,
    //                             ),
    //                           ),
    //                         ),
    //                     ],
    //                     rows: [
    //                       for (var values in particulars)
    //                         DataRow(cells: [
    //                           DataCell(
    //                             Align(
    //                               alignment: ComSettings.oKNumeric(
    //                                 values['no'].toString(),
    //                               )
    //                                   ? Alignment.centerRight
    //                                   : Alignment.centerLeft,
    //                               child: Text(
    //                                 values['no'].toString(),
    //                                 softWrap: true,
    //                                 overflow: TextOverflow.ellipsis,
    //                                 // style: TextStyle(fontSize: 6),
    //                               ),
    //                             ),
    //                           ),
    //                           DataCell(
    //                             Align(
    //                               alignment: ComSettings.oKNumeric(
    //                                 values['name'].toString(),
    //                               )
    //                                   ? Alignment.centerRight
    //                                   : Alignment.centerLeft,
    //                               child: Text(
    //                                 values['name'].toString(),
    //                                 softWrap: true,
    //                                 overflow: TextOverflow.ellipsis,
    //                                 // style: TextStyle(fontSize: 6),
    //                               ),
    //                             ),
    //                           ),
    //                           DataCell(
    //                             Align(
    //                               alignment: ComSettings.oKNumeric(
    //                                 values['hsn'].toString(),
    //                               )
    //                                   ? Alignment.centerRight
    //                                   : Alignment.centerLeft,
    //                               child: Text(
    //                                 values['hsn'] != null
    //                                     ? values['hsn'].toString()
    //                                     : '',
    //                                 softWrap: true,
    //                                 overflow: TextOverflow.ellipsis,
    //                                 // style: TextStyle(fontSize: 6),
    //                               ),
    //                             ),
    //                           ),
    //                           DataCell(
    //                             Align(
    //                               alignment: ComSettings.oKNumeric(
    //                                 values['qty'].toString(),
    //                               )
    //                                   ? Alignment.centerRight
    //                                   : Alignment.centerLeft,
    //                               child: Text(
    //                                 values['qty'].toString(),
    //                                 softWrap: true,
    //                                 overflow: TextOverflow.ellipsis,
    //                                 // style: TextStyle(fontSize: 6),
    //                               ),
    //                             ),
    //                           ),
    //                           DataCell(
    //                             Align(
    //                               alignment: ComSettings.oKNumeric(
    //                                 values['unit'].toString(),
    //                               )
    //                                   ? Alignment.centerRight
    //                                   : Alignment.centerLeft,
    //                               child: Text(
    //                                 values['unit'].toString(),
    //                                 softWrap: true,
    //                                 overflow: TextOverflow.ellipsis,
    //                                 // style: TextStyle(fontSize: 6),
    //                               ),
    //                             ),
    //                           ),
    //                           DataCell(
    //                             Align(
    //                               alignment: ComSettings.oKNumeric(
    //                                 values['net'].toString(),
    //                               )
    //                                   ? Alignment.centerRight
    //                                   : Alignment.centerLeft,
    //                               child: Text(
    //                                 values['net'].toString(),
    //                                 softWrap: true,
    //                                 overflow: TextOverflow.ellipsis,
    //                                 // style: TextStyle(fontSize: 6),
    //                               ),
    //                             ),
    //                           ),
    //                           DataCell(
    //                             Align(
    //                               alignment: ComSettings.oKNumeric(
    //                                 values['cGst'].toString(),
    //                               )
    //                                   ? Alignment.centerRight
    //                                   : Alignment.centerLeft,
    //                               child: Text(
    //                                 values['cGst'].toString(),
    //                                 softWrap: true,
    //                                 overflow: TextOverflow.ellipsis,
    //                                 // style: TextStyle(fontSize: 6),
    //                               ),
    //                             ),
    //                           ),
    //                           DataCell(
    //                             Align(
    //                               alignment: ComSettings.oKNumeric(
    //                                 values['cGst'].toString(),
    //                               )
    //                                   ? Alignment.centerRight
    //                                   : Alignment.centerLeft,
    //                               child: Text(
    //                                 values['cGst'].toString(),
    //                                 softWrap: true,
    //                                 overflow: TextOverflow.ellipsis,
    //                                 // style: TextStyle(fontSize: 6),
    //                               ),
    //                             ),
    //                           ),
    //                           DataCell(
    //                             Align(
    //                               alignment: ComSettings.oKNumeric(
    //                                 values['iGst'].toString(),
    //                               )
    //                                   ? Alignment.centerRight
    //                                   : Alignment.centerLeft,
    //                               child: Text(
    //                                 values['iGst'].toString(),
    //                                 softWrap: true,
    //                                 overflow: TextOverflow.ellipsis,
    //                                 // style: TextStyle(fontSize: 6),
    //                               ),
    //                             ),
    //                           ),
    //                           DataCell(
    //                             Align(
    //                               alignment: ComSettings.oKNumeric(
    //                                 values['cess'].toString(),
    //                               )
    //                                   ? Alignment.centerRight
    //                                   : Alignment.centerLeft,
    //                               child: Text(
    //                                 values['cess'].toString(),
    //                                 softWrap: true,
    //                                 overflow: TextOverflow.ellipsis,
    //                                 // style: TextStyle(fontSize: 6),
    //                               ),
    //                             ),
    //                           ),
    //                         ]),
    //                     ]),
    //               ),
    //               const Divider(),
    //             ],
    //           ),
    //         ),
    //       ),
    //     ));
  
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: black),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: black,
                fontFamily: 'poppins'
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildSectionTable({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: black),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: black,
                fontFamily: 'poppins'
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          // padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildAddressForm({
    required TextEditingController gstController,
    required TextEditingController nameController,
    required TextEditingController address1Controller,
    required TextEditingController address2Controller,
    required TextEditingController placeController,
    required TextEditingController pinCodeController,
    required TextEditingController stateCodeController,
    required TextEditingController actualStateCodeController,
  }) {
    return Column(
      children: [
        _buildTextField(controller: gstController, label: 'GST No'),
        const SizedBox(height: 8),
        _buildTextField(controller: nameController, label: 'Name'),
        const SizedBox(height: 8),
        _buildTextField(controller: address1Controller, label: 'Address 1'),
        const SizedBox(height: 8),
        _buildTextField(controller: address2Controller, label: 'Address 2'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildTextField(controller: placeController, label: 'Place'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTextField(controller: pinCodeController, label: 'Pin Code'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildTextField(controller: stateCodeController, label: 'State Code'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTextField(controller: actualStateCodeController, label: 'Actual State Code'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        floatingLabelStyle: const TextStyle(color: Colors.blue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        isDense: true,
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            borderRadius: BorderRadius.circular(8),
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: color),
      label: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20,),
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(20),
        // ),
      ),
    );
  }

  DataCell _buildDataCell(String value) {
    final isNumeric = ComSettings.oKNumeric(value);
    return DataCell(
      Container(
        alignment: isNumeric ? Alignment.centerRight : Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          value,
          style: const TextStyle(fontSize: 11),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
  
  void generateEWayBill() {
    if (fromPinCodeControl.text.isNotEmpty &&
        fromPinCodeControl.text.isNotEmpty &&
        distanceControl.text.isNotEmpty &&
        transporterControl.text.isNotEmpty &&
        transDocNoControl.text.isNotEmpty &&
        transactionId.isNotEmpty) {
      String docType = doctypeValue == 'Tax Invoice'
          ? 'INV'
          : doctypeValue == 'Bill of Supply'
              ? 'BIL'
              : doctypeValue == 'Bill of Entry'
                  ? 'BOE'
                  : doctypeValue == 'Delivery Challan'
                      ? 'CHL'
                      : doctypeValue == 'Others'
                          ? 'OTH'
                          : '';
      String supplyType = supplyTypeValue == 'Inward'
          ? 'I'
          : supplyTypeValue == 'Outward'
              ? 'O'
              : '';
      String subSupplyType = subSupplyTypeValue == 'Supply'
          ? '1'
          : subSupplyTypeValue == 'Import'
              ? '2'
              : subSupplyTypeValue == 'Export'
                  ? '3'
                  : subSupplyTypeValue == 'Job Work'
                      ? '4'
                      : subSupplyTypeValue == 'For Own Use'
                          ? '5'
                          : subSupplyTypeValue == 'Job work Returns'
                              ? '6'
                              : subSupplyTypeValue == 'Sales Return'
                                  ? '7'
                                  : subSupplyTypeValue == 'SKD/CKD'
                                      ? '8'
                                      : subSupplyTypeValue == 'Line Sales'
                                          ? '9'
                                          : subSupplyTypeValue ==
                                                  'Recipient Not Known'
                                              ? '10'
                                              : subSupplyTypeValue ==
                                                      'Exhibition or Fairs'
                                                  ? '11'
                                                  : subSupplyTypeValue ==
                                                          'Others'
                                                      ? '12'
                                                      : '0';
      String transMode = transModeValue == "Road"
          ? "1"
          : transModeValue == "Rail"
              ? "2"
              : transModeValue == "Air"
                  ? "3"
                  : transModeValue == "Ship"
                      ? "4"
                      : '0';
      String vehicleType = vehicleTypeValue != "Regular" ? "O" : "R";
      int transactionType = vehicleTypeValue == "Regular"
          ? 1
          : vehicleTypeValue == "Bill To-Ship To"
              ? 2
              : vehicleTypeValue == "Bill From-Dispatch From"
                  ? 3
                  : vehicleTypeValue == "Combination of 2 and 3"
                      ? 4
                      : 0;
      List<EwayItemListModel> itemList = [];
      for (var item in particulars) {
        if (item['name'] == null) {
          continue;
        }
        itemList.add(EwayItemListModel(
            cessNonadvol: 0,
            cessRate: int.parse(item['cess'].toString()),
            cgstRate: double.parse(item['cGst'].toString()),
            hsnCode: int.parse(item['hsn'].toString()),
            igstRate: double.parse(item['iGst'].toString()),
            productDesc: item['name'].toString(),
            productName: item['name'].toString(),
            qtyUnit: item['unit'].toString(),
            quantity: double.parse(item['qty'].toString()),
            sgstRate: double.parse(item['sGst'].toString()),
            taxableAmount: double.parse(item['net'].toString())));
      }
      int actFromStateCode = fromActualStateCodeControl.text.isNotEmpty
              ? int.parse(fromActualStateCodeControl.text)
              : 0,
          actToStateCode = toStateCodeControl2.text.isNotEmpty
              ? int.parse(toStateCodeControl2.text)
              : 0,
          cessNonAdvolValue = 0,
          cessValue =
              cessControl.text.isNotEmpty ? int.parse(cessControl.text) : 0,
          fromPincode = fromPinCodeControl.text.isNotEmpty
              ? int.parse(fromPinCodeControl.text)
              : 0,
          fromStateCode = fromStateCodeControl.text.isNotEmpty
              ? int.parse(fromStateCodeControl.text)
              : 0,
          igstValue =
              iGSTControl.text.isNotEmpty ? int.parse(iGSTControl.text) : 0,
          otherValue = 0,
          toPincode = toPinCodeControl.text.isNotEmpty
              ? int.parse(toPinCodeControl.text)
              : 0,
          toStateCode = toStateCodeControl1.text.isNotEmpty
              ? int.parse(toStateCodeControl1.text)
              : 0,
          totInvValue =
              totalControl.text.isNotEmpty ? int.parse(totalControl.text) : 0;
      double ?cgstValue =
              (cGSTControl.text.isNotEmpty ? int.parse(cGSTControl.text) : 0) as double?,
          sgstValue =
              (sGSTControl.text.isNotEmpty ? int.parse(sGSTControl.text) : 0) as double?,
          totalValue = (totalValueControl.text.isNotEmpty
              ? int.parse(totalValueControl.text)
              : 0) as double?;
      String docDate =
              invoiceDateControl.text.isNotEmpty ? invoiceDateControl.text : '',
          docNo = invoiceNoControl.text.isNotEmpty ? invoiceNoControl.text : '',
          fromAddr1 = fromAddress1Control.text.isNotEmpty
              ? fromAddress1Control.text
              : '',
          fromAddr2 = fromAddress2Control.text.isNotEmpty
              ? fromAddress2Control.text
              : '',
          fromGstin =
              fromGstNoControl.text.isNotEmpty ? fromGstNoControl.text : '',
          fromPlace = fromAddress3Control.text.isNotEmpty
              ? fromAddress3Control.text
              : '',
          fromTrdName =
              fromNameControl.text.isNotEmpty ? fromNameControl.text : '',
          subSupplyDesc = '',
          toAddr1 =
              toAddress1Control.text.isNotEmpty ? toAddress1Control.text : '',
          toAddr2 =
              toAddress2Control.text.isNotEmpty ? toAddress2Control.text : '',
          toGstin = toGstNoControl.text.isNotEmpty ? toGstNoControl.text : '',
          toPlace =
              toAddress3Control.text.isNotEmpty ? toAddress3Control.text : '',
          toTrdName = toNameControl.text.isNotEmpty ? toNameControl.text : '',
          transDistance =
              distanceControl.text.isNotEmpty ? distanceControl.text : '',
          transDocDate = transDocDateControl.text.isNotEmpty
              ? transDocDateControl.text
              : '',
          transDocNo =
              transDocNoControl.text.isNotEmpty ? transDocNoControl.text : '',
          transporterId = transporterIdControl.text.isNotEmpty
              ? transporterIdControl.text
              : '',
          transporterName =
              transporterControl.text.isNotEmpty ? transporterControl.text : '',
          vehicleNo = vehicleControl.text.isNotEmpty ? vehicleControl.text : '';
      EwayModel eWayModel = EwayModel(
          actFromStateCode: actFromStateCode,
          actToStateCode: actToStateCode,
          cessNonAdvolValue: cessNonAdvolValue,
          cessValue: cessValue,
          cgstValue: cgstValue!,
          docDate: docDate,
          docNo: docNo,
          docType: docType,
          fromAddr1: fromAddr1,
          fromAddr2: fromAddr2,
          fromGstin: fromGstin,
          fromPincode: fromPincode,
          fromPlace: fromPlace,
          fromStateCode: fromStateCode,
          fromTrdName: fromTrdName,
          igstValue: igstValue,
          itemList: itemList,
          otherValue: otherValue,
          sgstValue: sgstValue!,
          subSupplyDesc: subSupplyDesc,
          subSupplyType: subSupplyType,
          supplyType: supplyType,
          toAddr1: toAddr1,
          toAddr2: toAddr2,
          toGstin: toGstin,
          toPincode: toPincode,
          toPlace: toPlace,
          toStateCode: toStateCode,
          totalValue: totalValue!,
          totInvValue: totInvValue,
          toTrdName: toTrdName,
          transactionType: transactionType,
          transDistance: transDistance,
          transDocDate: transDocDate,
          transDocNo: transDocNo,
          transMode: transMode,
          transporterId: transporterId,
          transporterName: transporterName,
          vehicleNo: vehicleNo,
          vehicleType: vehicleType);
      if (eWayBillClient != "SHERSOFT") {
        api
            .authEWay(eWayBillClient!, _username, _password, ipAddress,
                _clientId, _clientSecret, fromGstNoControl.text)
            .then((respond) {
          if (respond.status_cd != '0') {
            api
                .generateEWayBill(eWayBillClient!, fromGstNoControl.text,
                    _password, ipAddress, _clientId, _clientSecret, eWayModel)
                .then((result) {
              if (result.status_cd != '0') {
                setState(() {
                  var billNo = result.data.ewayBillNo ?? '';
                  var billDate = result.data.ewayBillDate ?? '';
                  var validUpTo = result.data.validUpto ?? '';
                  eWayBillNoControl.text = billNo + billDate + validUpTo;
                  _isLoading = false;
                });
              } else {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(result.status_desc)));
                setState(() {
                  _isLoading = false;
                });
              }
            });
          } else {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(respond.status_desc)));
            setState(() {
              _isLoading = false;
            });
          }
        });
      } else {
        api
            .generateEWayBill(eWayBillClient!, fromGstNoControl.text, _password,
                ipAddress, _clientId, _clientSecret, eWayModel)
            .then((result) {
          if (result.status_cd != '0') {
            setState(() {
              var billNo = result.data.ewayBillNo ?? '';
              var billDate = result.data.ewayBillDate ?? '';
              var validUpTo = result.data.validUpto ?? '';
              eWayBillNoControl.text = billNo + billDate + validUpTo;
              _isLoading = false;
            });
          } else {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(result.status_desc)));
            setState(() {
              _isLoading = false;
            });
          }
        });
      }
    }
  }

  void cancelEWayBill() {
    EWayBillCancelModel _data = EWayBillCancelModel(
        cancelRmrk: 'Data Entry Mistake',
        cancelRsnCode: 3,
        ewbNo: eWayBillNoControl.text);
    if (eWayBillClient != "SHERSOFT") {
      api
          .cancelEWayBill(eWayBillClient!, fromGstNoControl.text, _password,
              ipAddress, _clientId, _clientSecret, _data)
          .then((result) {
        _isLoading = false;
        if (result.status_cd != '0') {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Canceled! ' + result.status_desc)));
          setState(() {
            _isLoading = false;
          });
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(result.status_desc)));
          setState(() {
            _isLoading = false;
          });
        }
      });
    } else {
      api
          .cancelEWayBill(eWayBillClient!, fromGstNoControl.text, _password,
              ipAddress, _clientId, _clientSecret, _data)
          .then((result) {
        _isLoading = false;
        if (result.status_cd != '0') {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Canceled! ' + result.status_desc)));
          setState(() {
            _isLoading = false;
          });
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(result.status_desc)));
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }

  void showErrorCodeList(BuildContext context) {}

  calculateDistance() async {
    var pin1 = fromPinCodeControl.text ?? '';
    var pin2 = toPinCodeControl.text ?? '';
    if (pin1.isNotEmpty && pin2.isNotEmpty) {
      var yourData = await api.getGeoCode(pin1);
      var partyData = await api.getGeoCode(pin2);
      if (yourData.isNotEmpty && partyData.isNotEmpty) {
        double userLat = double.parse(yourData['lat'].toString()),
            userLng = double.parse(yourData['lon'].toString()),
            venueLat = double.parse(partyData['lat'].toString()),
            venueLng = double.parse(partyData['lon'].toString());
        var result =
            calculateDistanceInKilometer(userLat, userLng, venueLat, venueLng)
                .toStringAsFixed(2);
        setState(() {
          distanceControl.text = result;
          if (yourData['place'].toString().trim().isNotEmpty) {
            fromAddress3Control.text = yourData['place'].toString().trim();
          }
          if (partyData['place'].toString().trim().isNotEmpty) {
            toAddress3Control.text = partyData['place'].toString().trim();
          }
        });
      }
      setState(() {
        isKmLoading = false;
      });
    } else {
      setState(() {
        isKmLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Add PinCode')));
      return;
    }
  }

  double calculateDistanceInKilometer(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  void printEWayBill() {
    setState(() {
      _isLoading = false;
    });
  }

  bool interState = false;
  partBData(_data) {
    var itemData = [];
    int no = 0;
    for (var item in _data) {
      itemData.add({
        'no': no + 1,
        'name': item['itemname'],
        'hsn': item['hsncode'],
        'qty': item['Qty'],
        'unit': unitNameFormat(item['unitName']),
        'net': item['Net'],
        'cGst': interState ? '0' : gstDiv(item['igst'], 1),
        'sGst': interState ? '0' : gstDiv(item['igst'], 1),
        'iGst': interState ? item['igst'] : '0',
        'cess': item['cessper']
      });
      no++;
    }

    return itemData;
  }

  unitNameFormat(var name) {
    String result = 'NOS';
    if (name == null || name.toString().isEmpty) {
      return result;
    }
    if (name == "KG") {
      result = "KGS";
    } else if (name == "KGS") {
      result = "KGS";
    } else if (name == "NOS") {
      result = "NOS";
    } else if (name == "PCS") {
      result = "PCS";
    } else if (name == "PKT") {
      result = "PAC";
    } else if (name == "BOTTLE") {
      result = "BTL";
    } else if (name == "CS") {
      result = "BOX";
    } else if (name != "TIN") {
      result = "NOS";
    } else {
      result = "BOX";
    }
    return result;
  }

  gstDiv(value, int decimal) {
    String result = '0';
    if (value == null) {
      return result;
    } else {
      result = (double.parse(value.toString()) / 2).toStringAsFixed(decimal);
      result = int.parse(result.split('.')[1].toString()) > 0
          ? result
          : result.split('.')[0].toString();
      return result;
    }
  }
}
