import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sheraccerp/models/company.dart';
import 'package:sheraccerp/models/sales_type.dart';
import 'package:sheraccerp/scoped-models/mains.dart';
import 'package:sheraccerp/service/api_dio.dart';
import 'package:sheraccerp/shared/constants.dart';
import 'package:sheraccerp/util/dateUtil.dart';
import 'package:sheraccerp/util/res_color.dart';

class SalesListCalendarView extends StatefulWidget {
  const SalesListCalendarView({Key? key}) : super(key: key);

  @override
  State<SalesListCalendarView> createState() => _SalesListCalendarViewState();
}

class _SalesListCalendarViewState extends State<SalesListCalendarView> {
  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDay;
  DioService api = DioService();

  final Map<String, List<dynamic>> _monthCache = {};
  bool _isLoading = false;

  double _monthTotal = 0;
  double _monthCash = 0;
  double _monthBalance = 0;
  List<SalesType> salesTypeDataList = [];
  List<dynamic> dataSType = [];
  bool taxGroupUpdate = false;
  bool  manualInvoiceNumberInSales = false;
  CompanyInformation? companySettings;
  List<CompanySettings>? settings;
  bool keyDeliveryDetialsOnItems = false;
  late final PageController _pageController;
  static const int _initialPage = 500;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: _initialPage);
    companySettings = ScopedModel.of<MainModel>(context).getCompanySettings();
    settings = ScopedModel.of<MainModel>(context).getSettings();
    taxGroupUpdate = 
        ComSettings.getStatus('KEY TAXGROUP UPDATE', settings!); 
    manualInvoiceNumberInSales = 
        ComSettings.getStatus('MANNUAL INVOICE NUMBER IN SALES', settings!);   
    keyDeliveryDetialsOnItems = 
        ComSettings.getStatus('KEY DELIVERY DETAILS ON ITEMS', settings!);     
    salesTypeDataList = salesTypeList;
    _fetchMonthData(_focusedMonth);
  }

    @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _monthFromPage(int page) {
    final now = DateTime.now();
    final base = DateTime(now.year, now.month, 1);
    return DateTime(base.year, base.month + (page - _initialPage), 1);
  }

  String _monthKey(DateTime dt) => DateFormat('yyyy-MM').format(dt);

  String _formatYMD(DateTime dt) => DateFormat('yyyy-MM-dd').format(dt);

  Future<void> _fetchMonthData(DateTime month) async {
    final key = _monthKey(month);
    if (_monthCache.containsKey(key)) {
      _recalcTotals(key);
      return;
    }

    setState(() => _isLoading = true);

    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);

    var locationData = [];
    bool isAdminUser =
        companyUserData!.userType.toUpperCase() == 'ADMIN' ? true : false;
    if (isAdminUser) {
      for (var data in locationList) {
        if (data.value.toString().isNotEmpty) {
          locationData.add({'id': data.key});
        }
      }
    } else {
      int locationId = ComSettings.appSettings(
              'int', 'key-dropdown-default-location-view', 2) -
          1;
      locationData.add({'id': locationId});
    }
     for (var data in salesTypeDataList) {
      // if (data.stock)
       dataSType.add({'id': data.id});
    }

    final dataJson = '[' +
        json.encode({
          'statementType': 'Sales_Summery', 
          'sDate': _formatYMD(firstDay),
          'eDate': _formatYMD(lastDay),
          'itemId': '0',
          'customerId': '0',
          'mfr': '0',
          'category': '0',
          'subcategory': '0',
          'location': jsonEncode(locationData),
          'project': '0',
          'salesman': '0',
          'salesType': jsonEncode(dataSType), //jsonEncode([{'id': 0}]),
          'toName': '',
          'taxGroup': '0',
          'groupId': '0',
          'areaId': '0',
          'type': '0',
          'hsnCode': '',
          'cashSale': '0',
          'creditSales': '0',
          'rateType': 'PRate',
          'serialNo': '',
          'supplierId': '0',
          'srCheck': '0',
          'serviceCheck': '0',
          'expenseCheck': '0',
          'counterNo': '',
          'cardNo': '',
          'salesman2': '0',
          'typeOfSupply': 'ALL',
          'barcode': '0',
          'userId': '0',
          'hsn': '',
          'supLed': '0',
        }) +
        ']';

    // try {
    //   final result = await api.getSalesReport(dataJson);
    //   _monthCache[key] = result ?? [];
    // } catch (e) {
    //   _monthCache[key] = [];
    // }
    try {
      List<dynamic>? result;
      if (keyDeliveryDetialsOnItems) {
        final deliveryJson = '[' +
            json.encode({
              'sDate': _formatYMD(firstDay),
              'eDate': _formatYMD(lastDay),
            }) +
            ']';
        result = await api.getSalesReportCalendarDeliveryWise(_formatYMD(firstDay), _formatYMD(lastDay));
      } else {
        result = await api.getSalesReport(dataJson);
      }
      _monthCache[key] = result ?? [];
    } catch (e) {
      _monthCache[key] = [];
    }

    setState(() {
      _isLoading = false;
    });
    _recalcTotals(key);
  }

  void _recalcTotals(String key) {
    final records = _monthCache[key] ?? [];
    if (keyDeliveryDetialsOnItems) {
      setState(() {
        _monthTotal = records.length.toDouble();
        _monthCash = 0;
        _monthBalance = 0;
      });
      return;
    }
    double total = 0, cash = 0, balance = 0;
    for (var r in records) {
      total += _toDouble(r['GrandTotal'] ?? r['NetAmount'] ?? r['Total']);
      cash += _toDouble(r['CashSales'] ?? r['Cash']);
      balance += _toDouble(r['Balance']);
    }
    setState(() {
      _monthTotal = total;
      _monthCash = cash;
      _monthBalance = balance;
    });
  }

  double _toDouble(dynamic val) {
    if (val == null) return 0.0;
    return double.tryParse(val.toString()) ?? 0.0;
  }

  List<dynamic> _recordsForDay(DateTime day) {
  final key = _monthKey(day);
  final records = _monthCache[key] ?? [];
  if (keyDeliveryDetialsOnItems) {
    return records.where((r) {
      final dateVal = r['deliverydate']?.toString() ?? '';
      return dateVal.contains(DateFormat('yyyy-MM-dd').format(day)) ||
             dateVal.contains(DateFormat('dd-MM-yyyy').format(day)) ||
             dateVal.contains(DateFormat('MM/dd/yyyy').format(day));
    }).toList();
  }
  return records.where((r) {
    final dateVal = r['Date'] ?? r['SDate'] ?? r['EntryDate'] ?? '';
    return dateVal.toString().contains(DateFormat('yyyy-MM-dd').format(day)) ||
           dateVal.toString().contains(DateFormat('dd-MM-yyyy').format(day)) ||
           dateVal.toString().contains(DateFormat('MM/dd/yyyy').format(day));
  }).toList();
}

double _dayTotal(DateTime day) {
  final recs = _recordsForDay(day);
  if (keyDeliveryDetialsOnItems) {
    return recs.length.toDouble();
  }
  return recs.fold(0.0, (sum, r) {
    return sum + _toDouble(r['Total'] ?? r['GrandTotal'] ?? r['NetAmount']);
  });
}

// double _dayTotal(DateTime day) {
//   return _recordsForDay(day).fold(0.0, (sum, r) {
//     return sum + _toDouble(r['Total'] ?? r['GrandTotal'] ?? r['NetAmount']);
//   });
// }

  // List<dynamic> _recordsForDay(DateTime day) {
  //   final key = _monthKey(day);
  //   final records = _monthCache[key] ?? [];
  //   final dayStr = _formatYMD(day);
  //   return records.where((r) {
  //     final dateVal = r['Date'] ?? r['SDate'] ?? r['EntryDate'] ?? '';
  //     return dateVal.toString().contains(
  //           DateFormat('yyyy-MM-dd').format(day),
  //         ) ||
  //         dateVal.toString().contains(
  //           DateFormat('dd-MM-yyyy').format(day),
  //         ) ||
  //         dateVal.toString().contains(
  //           DateFormat('MM/dd/yyyy').format(day),
  //         );
  //   }).toList();
  // }

  // double _dayTotal(DateTime day) {
  //   return _recordsForDay(day).fold(0.0, (sum, r) {
  //     return sum + _toDouble(r['GrandTotal'] ?? r['NetAmount'] ?? r['Total']);
  //   });
  // }

  void _previousMonth() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
    );
  }

  void _nextMonth() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _showDayDetails(DateTime day) async {
  final records = _recordsForDay(day);

   if (keyDeliveryDetialsOnItems) {
    await _showDeliveryDayDetails(day, records);
    return;
  }else{
  
  double dayTotal = records.fold(0.0, (s, r) => s + _toDouble(r['GrandTotal'] ?? r['NetAmount'] ?? r['Total']));
  double dayCash = records.fold(0.0, (s, r) => s + _toDouble(r['CashSales'] ?? r['Cash']));
  double dayBalance = records.fold(0.0, (s, r) => s + _toDouble(r['Balance']));
  double dayDiscount = records.fold(0.0, (s, r) => s + _toDouble(r['Discount']));
  double dayTax = records.fold(0.0, (s, r) => s + _toDouble(r['Tax'] ?? r['GST']));
  
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE, d MMMM yyyy').format(day),
                          style: const TextStyle(
                            fontFamily: 'poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${records.length} Invoice${records.length != 1 ? 's' : ''}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontFamily: 'poppins',
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  simpleSummary('Total', dayTotal),
                  Container(width: 1, height: 40, color: Colors.grey.shade200),
                  simpleSummary('Cash', dayCash),
                  Container(width: 1, height: 40, color: Colors.grey.shade200),
                  simpleSummary('Balance', dayBalance),
                ],
              ),
            ),
            if (dayDiscount > 0 || dayTax > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    if (dayDiscount > 0) infoLabel('Discount', dayDiscount),
                    if (dayDiscount > 0 && dayTax > 0) const SizedBox(width: 16),
                    if (dayTax > 0) infoLabel('Tax', dayTax),
                  ],
                ),
              ),
            
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Invoices',
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            const Divider(height: 1),
            records.isEmpty
                ? const Expanded(
                    child: Center(
                      child: Text(
                        'No sales on this day',
                        style: TextStyle(
                          color: Colors.grey,
                          fontFamily: 'poppins',
                        ),
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.all(12),
                      itemCount: records.length,
                      itemBuilder: (_, i) => _InvoiceCard(
                        record: records[i],
                        salesTypeDataList: salesTypeDataList,
                        taxGroupUpdate: taxGroupUpdate,
                        api: api,
                        manualInvoiceNumberInSales: manualInvoiceNumberInSales,
                      ),
                      // itemBuilder: (_, i) {
                      //   final r = records[i];
                      //   return _buildExpansionInvoiceCard(r);
                      // },
                    ),
                  ),
          ],
        ),
      ),
    ),
  );
  }
}

Future<void> _showDeliveryDayDetails(DateTime day, List<dynamic> deliveryRecords) async {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // drag handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE, d MMMM yyyy').format(day),
                          style: const TextStyle(
                            fontFamily: 'poppins', fontSize: 18,
                            fontWeight: FontWeight.w600, color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${deliveryRecords.length} Delivery Invoice${deliveryRecords.length != 1 ? 's' : ''}',
                            style: TextStyle(color: Colors.grey[600], fontFamily: 'poppins', fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Invoices', style: TextStyle(
                  fontFamily: 'poppins', fontSize: 15, fontWeight: FontWeight.w600,
                )),
              ),
            ),
            const Divider(height: 1),
            deliveryRecords.isEmpty
                ? const Expanded(
                    child: Center(
                      child: Text('No deliveries on this day',
                          style: TextStyle(color: Colors.grey, fontFamily: 'poppins')),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.all(12),
                      itemCount: deliveryRecords.length,
                      itemBuilder: (_, i) {
                        final r = deliveryRecords[i];
                        final entryNo = int.tryParse(r['EntryNo']?.toString() ?? '');
                        final sType = int.tryParse(r['Stype']?.toString() ?? '0') ?? 0;
                        final toName = r['toname']?.toString() ?? '';
                        return _DeliveryInvoiceCard(
                          entryNo: entryNo,
                          sType: sType, 
                          toName: toName,
                          deliveryDate: day,
                          salesTypeDataList: salesTypeDataList,
                          taxGroupUpdate: taxGroupUpdate,
                          api: api,
                          manualInvoiceNumberInSales: manualInvoiceNumberInSales,
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    ),
  );
}

  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'poppins',
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget summaryRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: 12,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            _formatCurrency(amount),
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: 12,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget simpleSummary(String title, double amount) {
    return Expanded(
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatCurrency(amount),
            style: const TextStyle(
              fontFamily: 'poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget infoLabel(String label, double amount) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$label: ',
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              _formatCurrency(amount),
              style: const TextStyle(
                fontFamily: 'poppins',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget simpleDetail(String label, double amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'poppins',
            fontSize: 10,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _formatCompactCurrency(amount),
          style: const TextStyle(
            fontFamily: 'poppins',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  String _formatCompactCurrency(double amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bagroundColor,
      appBar: AppBar(
        titleTextStyle: const TextStyle(fontFamily: 'poppins'),
        title: const Text('Sales Calendar'),
      ),
      body: Column(
        children: [
          _buildMonthHeader(),
          _buildMonthSummaryBar(),
          _buildWeekdayLabels(),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (page) {
                final month = _monthFromPage(page);
                setState(() => _focusedMonth = month);
                _fetchMonthData(month);
              },
              itemBuilder: (ctx, page) {
                final month = _monthFromPage(page);
                return _buildCalendarGrid(month); // pass month as param
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMonthHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      color: kPrimaryColor,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white),
            onPressed: _previousMonth,
          ),
          Expanded(
            child: GestureDetector(
              onTap: _showMonthYearPicker,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('MMMM  yyyy').format(_focusedMonth),
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down, color: Colors.white70, size: 20),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white),
            onPressed: _nextMonth,
          ),
          TextButton(
            onPressed: () {
              final today = DateTime.now();
              final targetMonth = DateTime(today.year, today.month, 1);
              final diff = (targetMonth.year - _focusedMonth.year) * 12 +
                  targetMonth.month - _focusedMonth.month;
              _pageController.animateToPage(
                _pageController.page!.round() + diff,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOut,
              );
            },
            child: const Text('Today',
                style: TextStyle(color: Colors.white, fontFamily: 'poppins', fontSize: 12)),
          ),
        ],
      ),
    );
  }
  
  void _showMonthYearPicker() async {
  final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  int selectedYear  = _focusedMonth.year;
  int selectedMonth = _focusedMonth.month; // 1-based

  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setLocal) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Year row ──────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => setLocal(() => selectedYear--),
                  ),
                  Text(
                    '$selectedYear',
                    style: const TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => setLocal(() => selectedYear++),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // ── Month grid ────────────────────────────────────────────────
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 2.2,
                ),
                itemCount: 12,
                itemBuilder: (_, i) {
                  final isSelected = (i + 1) == selectedMonth &&
                      selectedYear == _focusedMonth.year;
                  return GestureDetector(
                    onTap: () => setLocal(() => selectedMonth = i + 1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      decoration: BoxDecoration(
                        color: (i + 1) == selectedMonth
                            ? kPrimaryColor
                            : Colors.transparent,
                        border: Border.all(
                          color: (i + 1) == selectedMonth
                              ? kPrimaryColor
                              : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          months[i],
                          style: TextStyle(
                            fontFamily: 'poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: (i + 1) == selectedMonth
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              // ── Actions ───────────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(fontFamily: 'poppins')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        final target =
                            DateTime(selectedYear, selectedMonth, 1);
                        final diff =
                            (target.year - _focusedMonth.year) * 12 +
                            target.month - _focusedMonth.month;
                        if (diff == 0) return;
                        _pageController.animateToPage(
                          _pageController.page!.round() + diff,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Go',
                          style: TextStyle(
                              fontFamily: 'poppins', color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
   
  Widget _buildMonthSummaryBar() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _isLoading
          ? Container(
              key: const ValueKey('loading'),
              padding: const EdgeInsets.symmetric(vertical: 10),
              color: kPrimaryColor.withOpacity(0.08),
              child: const Center(
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))),
            )
          : Container(
              key: ValueKey(_monthKey(_focusedMonth)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _barItem(
                      keyDeliveryDetialsOnItems ? 'Deliveries' : 'Month Total',
                      keyDeliveryDetialsOnItems
                          ? _monthTotal.toInt().toString()
                          : _monthTotal.toStringAsFixed(2),
                      black,
                    ),
                  _barItem('Cash', _monthCash.toStringAsFixed(2),
                      black),
                  _barItem('Balance', _monthBalance.toStringAsFixed(2),
                      black),
                ],
              ),
            ),
    );
  }

  Widget _barItem(String label, String value, Color color) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                  fontFamily: 'poppins', fontSize: 11, color: Colors.grey[600])),
          Text(value,
              style: TextStyle(
                  fontFamily: 'poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: color)),
        ],
      );

  Widget _buildWeekdayLabels() {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: days
            .map((d) => Expanded(
                  child: Text(d,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: d == 'Sun'
                              ? Colors.red[400]
                              : Colors.grey[600])),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(DateTime month) {      
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final startWeekday = firstDayOfMonth.weekday % 7;
    final today = DateTime.now();
    final key = _monthKey(month);  

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.75,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: startWeekday + daysInMonth,
      itemBuilder: (ctx, index) {
        if (index < startWeekday) return const SizedBox();
        final day = index - startWeekday + 1;
        final date = DateTime(month.year, month.month, day); // ← use param
        final isToday = date.year == today.year &&
            date.month == today.month &&
            date.day == today.day;
        final isSelected = _selectedDay != null &&
            _selectedDay!.year == date.year &&
            _selectedDay!.month == date.month &&
            _selectedDay!.day == date.day;
        final isSunday = date.weekday == DateTime.sunday;

       final dayAmt = _monthCache.containsKey(key) ? _dayTotal(date) : null;
       final hasSales = dayAmt != null && dayAmt > 0;

        return Material(    
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() => _selectedDay = date);
              _showDayDetails(date);
            },
            borderRadius: BorderRadius.circular(8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected
                    ? kPrimaryColor
                    : isToday
                        ? kPrimaryColor.withOpacity(0.12)
                        : hasSales
                            ? Colors.green.withOpacity(0.07)
                            : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isToday || isSelected
                      ? kPrimaryColor
                      : Colors.grey.withOpacity(0.15),
                  width: isToday || isSelected ? 1.5 : 0.8,
                ),
                boxShadow: hasSales
                    ? [BoxShadow(color: Colors.green.withOpacity(0.08), blurRadius: 4)]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$day',
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                      fontSize: 13,
                      color: isSelected
                          ? Colors.white
                          : isSunday
                              ? Colors.red[400]
                              : Colors.black87,
                    ),
                  ),
                  if (_isLoading)
                    const SizedBox(height: 12)
                  else if (hasSales) ...[
                    const SizedBox(height: 2),
                    Text(
                       keyDeliveryDetialsOnItems
                        ? '${dayAmt!.toInt()} inv'
                        : _formatAmount(dayAmt!),
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.green[700],
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.green[400],
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  String _formatAmount(double amt) {
    if (amt >= 100000) {
      return '${(amt / 100000).toStringAsFixed(1)}L';
    } else if (amt >= 1000) {
      return '${(amt / 1000).toStringAsFixed(1)}K';
    }
    return amt.toStringAsFixed(0);
  }
}

class _DeliveryInvoiceCard extends StatefulWidget {
  final int? entryNo;
  final int sType; 
  final String toName;
  final DateTime deliveryDate;
  final List<SalesType> salesTypeDataList;
  final bool taxGroupUpdate;
  final DioService api;
  final bool manualInvoiceNumberInSales;

  const _DeliveryInvoiceCard({
    Key? key,
    required this.entryNo,
    required this.sType,
    required this.toName,
    required this.deliveryDate,
    required this.salesTypeDataList,
    required this.taxGroupUpdate,
    required this.api,
    required this.manualInvoiceNumberInSales,
  }) : super(key: key);

  @override
  State<_DeliveryInvoiceCard> createState() => _DeliveryInvoiceCardState();
}

class _DeliveryInvoiceCardState extends State<_DeliveryInvoiceCard> {
  bool _isFetching = false;
  Map<String, dynamic>? _cachedData;
  String? _error;

  double _toDouble(dynamic val) =>
      val == null ? 0.0 : double.tryParse(val.toString()) ?? 0.0;

  String _formatCurrency(double amount) => NumberFormat.currency(
      locale: 'en_IN', symbol: '₹', decimalDigits: 2).format(amount);

  String _formatCompact(double amount) {
    if (amount >= 10000000) return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
    if (amount >= 100000)   return '₹${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000)     return '₹${(amount / 1000).toStringAsFixed(1)}K';
    return '₹${amount.toStringAsFixed(0)}';
  }

  String _formatQty(dynamic qty) {
    if (qty == null) return '0';
    final val = double.tryParse(qty.toString()) ?? 0;
    return val == val.toInt() ? val.toInt().toString() : val.toString();
  }

  bool _isDeliveryMatch(dynamic itemDeliveryDate) {
    if (itemDeliveryDate == null) return false;
    final s = itemDeliveryDate.toString();
    final day = widget.deliveryDate;
    return s.contains(DateFormat('yyyy-MM-dd').format(DateTime.now())) ||
           s.contains(DateFormat('dd-MM-yyyy').format(DateTime.now())) ||
           s.contains(DateFormat('MM/dd/yyyy').format(DateTime.now()));
  }

  Future<void> _fetchOnce() async {
    if (_cachedData != null || _isFetching || widget.entryNo == null) return;
    setState(() { _isFetching = true; _error = null; });
    try {
      final result = await widget.api.fetchSalesInvoice(
        widget.entryNo!,  widget.sType, widget.taxGroupUpdate,
      );
      if (!mounted) return;
      if (result != null &&
          result['Information'] != null &&
          (result['Information'] as List).isNotEmpty) {
        setState(() { _cachedData = result; });
      } else {
        setState(() { _error = 'No details found'; });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = 'Error: $e'; });
    } finally {
      if (mounted) setState(() { _isFetching = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final entryLabel = widget.entryNo != null ? 'INV-${widget.entryNo}' : 'INV-?';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          childrenPadding: const EdgeInsets.all(12),
          backgroundColor: Colors.white,
          collapsedBackgroundColor: Colors.white,
          onExpansionChanged: (expanded) {
            if (expanded) _fetchOnce();
          },
          title: Text(
            widget.toName,
            style: TextStyle(
              fontFamily: 'poppins', fontSize: 13,
              fontWeight: FontWeight.w600, color: Colors.grey[800],
            ),
          ),
          subtitle: Text(
            entryLabel,
            style: TextStyle(
              fontFamily: 'poppins', fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
          children: [_buildExpanded()],
        ),
      ),
    );
  }

  Widget _buildExpanded() {
    if (_isFetching) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: SizedBox(width: 24, height: 24,
            child: CircularProgressIndicator(strokeWidth: 2))),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(child: Text(_error!,
            style: TextStyle(fontFamily: 'poppins', fontSize: 12, color: Colors.red[400]))),
      );
    }
    if (_cachedData == null) return const SizedBox.shrink();

    final particulars = (_cachedData!['Particulars'] as List?) ?? [];
    final infoList    = _cachedData!['Information'] as List?;
    final info        = (infoList != null && infoList.isNotEmpty) ? infoList[0] : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (info != null)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((info['ToName']?.toString().isNotEmpty ?? false))
                  _infoRow('Customer', info['ToName'].toString()),
                _infoRow('Bill Date',
                  '${DateUtil.dateDMY(info['DDate']?.toString())} : '
                  '${DateUtil.timeHMSA(info['BTime']?.toString())}'),
                if ((info['Add1']?.toString().isNotEmpty ?? false))
                  _infoRow('Address', info['Add1'].toString()),
                if ((info['Add2']?.toString().isNotEmpty ?? false))
                  _infoRow('Address', info['Add2'].toString()),
              ],
            ),
          ),

        // column header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              _headerCell('Item', flex: 3, align: TextAlign.start),
              _headerCell('Delivery', flex: 2),
              _headerCell('Qty',   flex: 1),
              _headerCell('Rate',  flex: 1),
              // _headerCell('Total', flex: 1),
            ],
          ),
        ),

        ...particulars.map((item) {
          final matched = _isDeliveryMatch(item['DeliveryDate'] ?? item['DDate']);
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            decoration: BoxDecoration(
              color: matched ? Colors.orange.withOpacity(0.08) : null,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade100),
                left: matched
                    ? const BorderSide(color: Colors.orange, width: 3)
                    : BorderSide.none,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child:
                  RichText(
              text:  TextSpan(
                text: '${item['itemname']?.toString()}\n' ?? '-',
                style: TextStyle(fontFamily: 'poppins', fontSize: 14,fontWeight: matched ? FontWeight.w700 : FontWeight.normal,color: black),// DefaultTextStyle.of(context).style,
                children: <TextSpan>[
                   TextSpan(
                      text: item['Remark']?.toString(),
                      style:  TextStyle(fontFamily: 'poppins', fontSize: 11,fontWeight: matched ? FontWeight.w600 : FontWeight.normal,color: grey[600]),),
                ],
              ),
            ),
                  //  Text(
                  //   item['itemname']?.toString() ?? '-',
                  //   style: TextStyle(
                  //     fontFamily: 'poppins', fontSize: 11,
                  //     fontWeight: matched ? FontWeight.w600 : FontWeight.normal,
                  //   ),
                  //   overflow: TextOverflow.ellipsis,
                  // ),
                ),
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (matched)
                        const Padding(
                          padding: EdgeInsets.only(right: 3),
                          child: Icon(Icons.local_shipping,
                              size: 11, color: Colors.orange),
                        ),
                      Flexible(
                        child: Text(item['DeliveryDate'] != null &&
                                          item['DeliveryDate'].toString() != '1900-01-01T00:00:00.000Z'
                                      ? DateUtil.dateDMY(item['DeliveryDate'].toString())
                                      : (item['DDate']?.toString() ?? '-'),
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontFamily: 'poppins',
                                    fontSize: 10,
                                    color: matched ? Colors.orange[700] : Colors.black,
                                    fontWeight:
                                        matched ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                )
                        // Text(
                        //   DateUtil.dateDMY(item['DeliveryDate']?.toString()) ??
                        //   item['DDate']?.toString() ?? '-',
                        //   textAlign: TextAlign.right,
                        //   style: TextStyle(
                        //     fontFamily: 'poppins', fontSize: 10,
                        //     color: matched ? Colors.orange[700] : Colors.black,
                        //     fontWeight: matched ? FontWeight.w600 : FontWeight.normal,
                        //   ),
                        //   overflow: TextOverflow.ellipsis,
                        // ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(_formatQty(item['Qty']),
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontFamily: 'poppins', fontSize: 11)),
                ),
                Expanded(
                  flex: 1,
                  child: Text(_formatCompact(_toDouble(item['Rate'])),
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontFamily: 'poppins', fontSize: 11)),
                ),
                // Expanded(
                //   flex: 1,
                //   child: Text(_formatCompact(_toDouble(item['Total'])),
                //     textAlign: TextAlign.right,
                //     style: const TextStyle(
                //       fontFamily: 'poppins', fontSize: 12, fontWeight: FontWeight.w500)),
                // ),
              ],
            ),
          );
        }),

        if (info != null)
          Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50, borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              children: [
                _summaryRow('Subtotal', _toDouble(info['NetAmount'])),
                if (_toDouble(info['Discount']) > 0)
                  _summaryRow('Discount', -_toDouble(info['Discount'])),
                if (_toDouble(info['IGST']) > 0)
                  _summaryRow('Tax (IGST)', _toDouble(info['IGST']))
                else if (_toDouble(info['CGST']) > 0)
                  _summaryRow('Tax (CGST+SGST)',
                    _toDouble(info['CGST']) + _toDouble(info['SGST'])),
                const Divider(height: 8),
                _summaryRow('Grand Total', _toDouble(info['GrandTotal']), bold: true),
              ],
            ),
          ),
      ],
    );
  }

  Widget _headerCell(String text, {int flex = 1, TextAlign align = TextAlign.right}) =>
      Expanded(flex: flex, child: Text(text, textAlign: align,
        style: TextStyle(fontFamily: 'poppins', fontSize: 11,
            fontWeight: FontWeight.w600, color: Colors.grey[700])));

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 80, child: Text(label,
          style: TextStyle(fontFamily: 'poppins', fontSize: 11, color: Colors.grey[600]))),
      Expanded(child: Text(value,
          style: const TextStyle(fontFamily: 'poppins', fontSize: 11))),
    ]),
  );

  Widget _summaryRow(String label, double amount, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(fontFamily: 'poppins', fontSize: 12,
          fontWeight: bold ? FontWeight.w600 : FontWeight.normal)),
      Text(_formatCurrency(amount), style: TextStyle(fontFamily: 'poppins', fontSize: 12,
          fontWeight: bold ? FontWeight.w600 : FontWeight.normal)),
    ]),
  );
}

class _InvoiceCard extends StatefulWidget {
  final Map record;
  final List<SalesType> salesTypeDataList;
  final bool taxGroupUpdate;
  final DioService api;
  final bool manualInvoiceNumberInSales;

  const _InvoiceCard({
    Key? key,
    required this.record,
    required this.salesTypeDataList,
    required this.taxGroupUpdate,
    required this.api,
    required this.manualInvoiceNumberInSales,
  }) : super(key: key);

  @override
  State<_InvoiceCard> createState() => _InvoiceCardState();
}

class _InvoiceCardState extends State<_InvoiceCard> {
  bool _isExpanded = false;
  bool _isFetching = false;
  Map<String, dynamic>? _cachedData;
  String? _error;


  double _toDouble(dynamic val) =>
      val == null ? 0.0 : double.tryParse(val.toString()) ?? 0.0;

  String _formatCurrency(double amount) => NumberFormat.currency(
        locale: 'en_IN', symbol: '₹', decimalDigits: 2,
      ).format(amount);

  String _formatCompact(double amount) {
    if (amount >= 10000000) return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
    if (amount >= 100000)   return '₹${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000)     return '₹${(amount / 1000).toStringAsFixed(1)}K';
    return '₹${amount.toStringAsFixed(0)}';
  }

  String _formatQty(dynamic qty) {
    if (qty == null) return '0';
    final val = double.tryParse(qty.toString()) ?? 0;
    return val == val.toInt() ? val.toInt().toString() : val.toString();
  }


  Future<void> _fetchOnce() async {
    if (_cachedData != null || _isFetching) return;

    final r = widget.record;
    // final entryNo = r['EntryNo']?.toString() ?? r['InvNo']?.toString() ?? '0';
    final rawEntry = widget.manualInvoiceNumberInSales ?  r['EntryNo']?.toString() : r['InvNo']?.toString() ?? '0';
    String entryNo = '';
    if(widget.manualInvoiceNumberInSales){
      final matches = RegExp(r'\d+').allMatches(rawEntry!);
      entryNo = matches.isNotEmpty ? matches.last.group(0)! : '0';
    }else{
      entryNo = rawEntry!;
    }
    
    final saleTypeId = int.tryParse(r['SType']?.toString() ?? '0') ?? 0;
    final id = int.tryParse(entryNo);
    if (id == null) {
      setState(() => _error = 'Invalid entry number');
      return;
    }

    setState(() { _isFetching = true; _error = null; });

    try {
      final result = await widget.api.fetchSalesInvoice(
        id, saleTypeId, widget.taxGroupUpdate,
      );

      if (!mounted) return;

      if (result != null &&
          result['Information'] != null &&
          (result['Information'] as List).isNotEmpty) {
        setState(() { _cachedData = result; });
      } else {
        setState(() { _error = 'No details found'; });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = 'Error: $e'; });
    } finally {
      if (mounted) setState(() { _isFetching = false; });
    }
  }


  @override
  Widget build(BuildContext context) {
    final r = widget.record;

    final invoiceNo = r['InvNo']?.toString() ?? r['EntryNo']?.toString() ?? '-';
    final toName    = r['ToName']?.toString() ?? r['CustomerName']?.toString() ?? '-';
    final grandTotal = _toDouble(r['GrandTotal'] ?? r['NetAmount'] ?? r['Total']);
    final cash       = _toDouble(r['CashSales']  ?? r['Cash']);
    final balance    = _toDouble(r['Balance']);

    String saleTypeName = '';
    if (r['SType'] != null) {
      final id = int.tryParse(r['SType'].toString()) ?? 0;
      saleTypeName = widget.salesTypeDataList
          .firstWhere(
            (st) => st.id == id,
            orElse: () => SalesType(
              id: 0, name: '', type: '', accounts: false, stock: false,
              rateType: '', location: 0, eInvoice: false, sColor: '', tax: false,
            ),
          )
          .name;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          childrenPadding: const EdgeInsets.all(12),
          backgroundColor: Colors.white,
          collapsedBackgroundColor: Colors.white,
          onExpansionChanged: (expanded) {
            setState(() => _isExpanded = expanded);
            if (expanded) _fetchOnce(); 
          },
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'INV-$invoiceNo',
                    style: TextStyle(
                      fontFamily: 'poppins', fontSize: 13,
                      fontWeight: FontWeight.w600, color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (saleTypeName.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        saleTypeName,
                        style: TextStyle(
                          fontFamily: 'poppins', fontSize: 10, color: Colors.grey[600],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                toName,
                style: const TextStyle(
                  fontFamily: 'poppins', fontSize: 14, fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                Expanded(child: _detail('Total',   grandTotal)),
                Expanded(child: _detail('Cash',    cash)),
                Expanded(child: _detail('Balance', balance)),
              ],
            ),
          ),
          children: [expandedWidget()],
        ),
      ),
    );
  }


  Widget expandedWidget() {
    if (_isFetching) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: SizedBox(
            width: 24, height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            _error!,
            style: TextStyle(
              fontFamily: 'poppins', fontSize: 12, color: Colors.red[400],
            ),
          ),
        ),
      );
    }
    if (_cachedData == null) {
      return const SizedBox.shrink();
    }

    final particulars = (_cachedData!['Particulars'] as List?) ?? [];
    final infoList    = _cachedData!['Information'] as List?;
    final info        = (infoList != null && infoList.isNotEmpty) ? infoList[0] : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (info != null)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow(
                  'Bill Date',
                  '${DateUtil.dateDMY(info['DDate']?.toString())} : '
                  '${DateUtil.timeHMSA(info['BTime']?.toString())}',
                ),
                if ((info['Add1']?.toString().isNotEmpty ?? false))
                  _infoRow('Address', info['Add1'].toString()),
                if ((info['Address']?.toString().isNotEmpty ?? false))
                  _infoRow('Address', info['Address'].toString()),
              ],
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              _headerCell('Item',  flex: 3, align: TextAlign.start),
              _headerCell('Qty',   flex: 1),
              _headerCell('Rate',  flex: 1),
              _headerCell('Total', flex: 1),
            ],
          ),
        ),
        ...particulars.asMap().entries.map((e) {
          final item = e.value;
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade100),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    item['itemname']?.toString() ?? '-',
                    style: const TextStyle(fontFamily: 'poppins', fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    _formatQty(item['Qty']),
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontFamily: 'poppins', fontSize: 11),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    _formatCompact(_toDouble(item['Rate'])),
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontFamily: 'poppins', fontSize: 11),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    _formatCompact(_toDouble(item['Total'])),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontFamily: 'poppins', fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        if (info != null)
          Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              children: [
                _summaryRow('Subtotal', _toDouble(info['NetAmount'])),
                if (_toDouble(info['Discount']) > 0)
                  _summaryRow('Discount', -_toDouble(info['Discount'])),
                if (_toDouble(info['IGST']) > 0)
                  _summaryRow('Tax (IGST)', _toDouble(info['IGST']))
                else if (_toDouble(info['CGST']) > 0)
                  _summaryRow(
                    'Tax (CGST+SGST)',
                    _toDouble(info['CGST']) + _toDouble(info['SGST']),
                  ),
                const Divider(height: 8),
                _summaryRow('Grand Total', _toDouble(info['GrandTotal']), bold: true),
              ],
            ),
          ),
      ],
    );
  }

  Widget _detail(String label, double amount) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontFamily: 'poppins', fontSize: 10, color: Colors.grey[500])),
          const SizedBox(height: 2),
          Text(_formatCompact(amount),
              style: const TextStyle(
                fontFamily: 'poppins', fontSize: 13, fontWeight: FontWeight.w500,
              )),
        ],
      );

  Widget _headerCell(String text, {int flex = 1, TextAlign align = TextAlign.right}) =>
      Expanded(
        flex: flex,
        child: Text(
          text,
          textAlign: align,
          style: TextStyle(
            fontFamily: 'poppins', fontSize: 11,
            fontWeight: FontWeight.w600, color: Colors.grey[700],
          ),
        ),
      );

  Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 80,
              child: Text(label,
                  style: TextStyle(fontFamily: 'poppins', fontSize: 11, color: Colors.grey[600])),
            ),
            Expanded(
              child: Text(value,
                  style: const TextStyle(fontFamily: 'poppins', fontSize: 11)),
            ),
          ],
        ),
      );

  Widget _summaryRow(String label, double amount, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(
                  fontFamily: 'poppins', fontSize: 12,
                  fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
                )),
            Text(_formatCurrency(amount),
                style: TextStyle(
                  fontFamily: 'poppins', fontSize: 12,
                  fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
                )),
          ],
        ),
      );
}