import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sheraccerp/models/other_registrations.dart';
import 'package:sheraccerp/models/sales_delivery_basic_response_model.dart';
import 'package:sheraccerp/models/sales_type.dart';
import 'package:sheraccerp/provider/sales_delivery_provider.dart';
import 'package:sheraccerp/screens/inventory/sales/sales_delivery_invoice_details_page.dart';
import 'package:sheraccerp/service/api_dio.dart';
import 'package:sheraccerp/shared/constants.dart';
import 'package:sheraccerp/util/res_color.dart';

class DeliveryReportPage extends StatefulWidget {
  final bool? isAdminUser;
  final List<DataJson>? locationList;
  final String? defaultLocation;
  final List<OtherRegistrationModel>? otherRegLocationList;
  final DateTime? initialFromDate;
  final DateTime? initialToDate;

  const DeliveryReportPage({
    Key? key,
    this.isAdminUser,
    this.locationList,
    this.defaultLocation,
    this.otherRegLocationList,
    this.initialFromDate,
    this.initialToDate,
  }) : super(key: key);

  @override
  State<DeliveryReportPage> createState() => _DeliveryReportPageState();
}

class _DeliveryReportPageState extends State<DeliveryReportPage> {
  late final ScrollController _scrollController;
  List<SalesType> salesTypeDataList = [];
  late String fromDate;
  late String toDate;
  bool isAdminUser = false;
  int? locationId;
  DataJson? location;
  String? selectedLocationName;
  final now = DateTime.now();
  
  DataJson? selectedLocation;
  
  
  @override
  void initState() {
    super.initState();
    
    fromDate = DateFormat('dd-MM-yyyy').format(now);
    toDate = DateFormat('dd-MM-yyyy').format(now);
    
    // salesTypeDataList = salesTypeList;

    salesTypeDataList = salesTypeList.map((e) {
      e.stock = true;
      return e;
    }).toList();
    
    isAdminUser = companyUserData?.userType.toUpperCase() == 'ADMIN' ? true : false;
    
    if (!isAdminUser) {
      locationId = 1; 
      
      if (widget.otherRegLocationList != null) {
        final otherData = widget.otherRegLocationList!.firstWhere(
          (element) => element.id == locationId,
          orElse: () => OtherRegistrationModel(
            add1: '',
            add2: '',
            add3: '',
            description: '',
            email: '',
            id: locationId ?? 0,
            name: widget.defaultLocation ?? 'Default Location',
            type: '',
          ),
        );
        location = DataJson(id: otherData.id, name: otherData.name);
        selectedLocationName = otherData.name;
      }
    }
    
    if (widget.locationList != null && widget.locationList!.isNotEmpty) {
      if (widget.defaultLocation != null) {
        selectedLocation = widget.locationList!.firstWhere(
          (element) => element.name == widget.defaultLocation,
          orElse: () => widget.locationList!.first,
        );
      } else {
        selectedLocation = widget.locationList!.first;
      }
      locationId = selectedLocation?.id;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProvider();
    });
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      final provider = Provider.of<DeliveryReportProvider>(context, listen: false);

      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (!provider.isLoadingMore && provider.hasMoreData) {
          provider.loadMoreBasicData();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeProvider() {
    try {
      final provider = Provider.of<DeliveryReportProvider>(context, listen: false);
      
      final salesTypeIds = salesTypeDataList
          .where((type) => type.stock)
          .map((type) => type.id)
          .toList();
      
      provider.setSalesTypes(salesTypeIds);
      provider.setLocationId(locationId);
      final fromDateTime = DateFormat('dd-MM-yyyy').parse(fromDate);
      final toDateTime = DateFormat('dd-MM-yyyy').parse(toDate);
      
      provider.setFromDate(fromDateTime);
      provider.setToDate(toDateTime);
      provider.setFinancialYear(currentFinancialYear);
      provider.fetchBasicReport();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error initializing: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void itemChange(bool val, int index) {
    setState(() {
      salesTypeDataList[index].stock = val;
    });
    
    final provider = Provider.of<DeliveryReportProvider>(context, listen: false);
    final salesTypeIds = salesTypeDataList
        .where((type) => type.stock)
        .map((type) => type.id)
        .toList();
    provider.setSalesTypes(salesTypeIds);
    provider.fetchBasicReport();
  }

  List<Widget> _getChildren(List<SalesType> data) {
  return [
    ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 250),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: data.length,
        itemBuilder: (context, index) {
          return CheckboxListTile(
            activeColor: kPrimaryColor,
            value: data[index].stock,
            title: Text(data[index].name),
            onChanged: (bool? value) {
              if (value != null) {
                itemChange(value, index);
              }
            },
          );
        },
      ),
    ),
  ];
}

  Future<void> _selectDate(String type) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (type == 'f') {
          fromDate = DateFormat('dd-MM-yyyy').format(picked);
        } else {
          toDate = DateFormat('dd-MM-yyyy').format(picked);
        }
      });
      
      final provider = Provider.of<DeliveryReportProvider>(context, listen: false);
      final fromDateTime = DateFormat('dd-MM-yyyy').parse(fromDate);
      final toDateTime = DateFormat('dd-MM-yyyy').parse(toDate);
      provider.setFromDate(fromDateTime);
      provider.setToDate(toDateTime);
      provider.fetchBasicReport();
    }
  }

  void _onLocationChanged(DataJson? newValue) {
    if (newValue != null) {
      setState(() {
        selectedLocation = newValue;
        locationId = newValue.id;
        selectedLocationName = newValue.name;
      });
      
      final provider = Provider.of<DeliveryReportProvider>(context, listen: false);
      provider.setLocationId(locationId);
      provider.fetchBasicReport();
    }
  }

  void _applyFilters() {
    final provider = Provider.of<DeliveryReportProvider>(context, listen: false);
    
    final fromDateTime = DateFormat('dd-MM-yyyy').parse(fromDate);
    final toDateTime = DateFormat('dd-MM-yyyy').parse(toDate);
    provider.setFromDate(fromDateTime);
    provider.setToDate(toDateTime);
    provider.setFinancialYear(currentFinancialYear);
    final salesTypeIds = salesTypeDataList
        .where((type) => type.stock)
        .map((type) => type.id)
        .toList();
    provider.setSalesTypes(salesTypeIds);
    provider.setLocationId(locationId);
    provider.fetchBasicReport();
  }

  void _resetFilters() {
    setState(() {
      fromDate = DateFormat('dd-MM-yyyy').format(now);
      toDate = DateFormat('dd-MM-yyyy').format(now);
      
      for (var type in salesTypeDataList) {
        type.stock = true;
      }
      
      if (widget.locationList != null && widget.locationList!.isNotEmpty) {
        selectedLocation = widget.locationList!.first;
        locationId = selectedLocation?.id;
      }
    });
    
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Delivery Item Wise Report',
          style: TextStyle(
            fontFamily: 'poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _applyFilters,
            tooltip: 'Refresh Report',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'From',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            fontFamily: 'poppins',
                          ),
                        ),
                        // const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate('f'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    fromDate,
                                    style: const TextStyle(
                                      fontFamily: 'poppins',
                                    ),
                                  ),
                                  const Icon(
                                    Icons.calendar_month_outlined,
                                    color: grey,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'To',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            fontFamily: 'poppins',
                          ),
                        ),
                        // const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate('t'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    toDate,
                                    style: const TextStyle(
                                      fontFamily: 'poppins',
                                    ),
                                  ),
                                  const Icon(
                                    Icons.calendar_month_outlined,
                                    color: grey,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                   
                    const SizedBox(height: 16),
                    if (isAdminUser && widget.locationList != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Location',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              fontFamily: 'poppins',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: DropdownButton<DataJson>(
                              value: selectedLocation,
                              isExpanded: true,
                              underline: const SizedBox(),
                              items: widget.locationList!
                                  .map<DropdownMenuItem<DataJson>>((DataJson value) {
                                return DropdownMenuItem<DataJson>(
                                  value: value,
                                  child: Text(
                                    value.name!,
                                    style: const TextStyle(fontFamily: 'poppins'),
                                  ),
                                );
                              }).toList(),
                              onChanged: _onLocationChanged,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    if (salesTypeDataList.isNotEmpty)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ExpansionTile(
                          title: const Text(
                            'Sales Name',
                            style: TextStyle(
                              fontFamily: 'poppins',
                              fontSize: 15,
                              fontWeight: ui.FontWeight.w500,
                            ),
                          ),
                          children: _getChildren(salesTypeDataList),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _applyFilters,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: const Text(
                              'Show',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'poppins',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _resetFilters,
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              side: const BorderSide(color: kPrimaryColor),
                            ),
                            child: const Text(
                              'Reset',
                              style: TextStyle(
                                color: kPrimaryColor,
                                fontFamily: 'poppins',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Consumer<DeliveryReportProvider>(
                builder: (context, provider, child) {
                  if (provider.fromDate == null || provider.toDate == null) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            "Please select date range",
                            style: TextStyle(fontFamily: 'poppins'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (provider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: kPrimaryColor,
                      ),
                    );
                  }

                  if (provider.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 64),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32.0),
                            child: Text(
                              provider.error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.red,
                                fontFamily: 'poppins',
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => provider.fetchBasicReport(),
                            icon: const Icon(Icons.refresh),
                            label: const Text(
                              'Retry',
                              style: TextStyle(fontFamily: 'poppins'),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (provider.basicReport == null) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            "No delivery records found",
                            style: TextStyle(fontFamily: 'poppins'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (!provider.basicReport!.success) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          const Text(
                            "Failed to load data",
                            style: TextStyle(fontFamily: 'poppins', color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => provider.fetchBasicReport(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  return _buildDeliveryCards(provider);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryCards(DeliveryReportProvider provider) {
    final basicData = provider.basicReport?.data ?? [];
    if (basicData.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "No delivery records found",
              style: TextStyle(fontFamily: 'poppins'),
            ),
          ],
        ),
      );
    }
    
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Delivery Report',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: kPrimaryColor,
                        fontFamily: 'poppins',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total: ${basicData.length} invoices',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontFamily: 'poppins',
                      ),
                    ),
                  ],
                ),
                Chip(
                  label: Text(
                    'Page ${provider.basicReport?.currentPage ?? 1}/${provider.basicReport?.totalPages ?? 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'poppins',
                    ),
                  ),
                  backgroundColor: kPrimaryColor,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: basicData.length + 1,
            itemBuilder: (context, index) {
              if (index == basicData.length) {
                if (provider.isLoadingMore) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (!provider.hasMoreData && basicData.isNotEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'All data loaded',
                        style: TextStyle(color: Colors.grey, fontFamily: 'poppins'),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }
              
              final item = basicData[index];
              String formattedDate = item.dDate != null 
                  ? DateFormat('dd-MM-yyyy').format(item.dDate!)
                  : 'N/A';
              
              String formattedDeliveryDate = item.lastDeliveryDate != null
                  ? DateFormat('dd-MM-yyyy').format(item.lastDeliveryDate!)
                  : 'Not Delivered';
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  onTap: () => _showInvoiceDetails(context, item, provider),
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        item.totalItems.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: kPrimaryColor,
                          fontFamily: 'poppins',
                        ),
                      ),
                    ),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.customer,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'poppins',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontFamily: 'poppins',
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.receipt, size: 14, color: grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Invoice: ${item.entryNo}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'poppins',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.inventory_2, size: 14, color: grey),
                          const SizedBox(width: 4),
                          Text(
                            'Items: ${item.totalItems}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'poppins',
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.scale, size: 14, color: grey),
                          const SizedBox(width: 4),
                          Text(
                            'Qty: ${item.totalQty}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'poppins',
                            ),
                          ),
                        ],
                      ),
                      // const SizedBox(height: 4),
                      // Row(
                      //   children: [
                      //     const Icon(Icons.local_shipping, size: 14, color: grey),
                      //     const SizedBox(width: 4),
                      //     Text(
                      //       'Delivery: $formattedDeliveryDate',
                      //       style: const TextStyle(
                      //         fontSize: 12,
                      //         fontFamily: 'poppins',
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                  trailing: provider.areDetailsLoading(item.uniqueKey)
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right, color: Colors.grey),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

Future<void> _showInvoiceDetails(
  BuildContext context,
  SalesDeliveryBasicItem item,
  DeliveryReportProvider provider,
) async {

  await provider.fetchDetailsForInvoice(
    entryNo: item.entryNo,
    salesType: item.salesType,
    fyId: item.fyId,
  );

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => InvoiceDetailsScreen(basicItem: item),
    ),
  );
}
}

class FullScreenImageViewer extends StatelessWidget {
  final Uint8List imageBytes;
  final VoidCallback onClose;

  const FullScreenImageViewer({
    Key? key,
    required this.imageBytes,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: Stack(
        children: [
          InteractiveViewer(
            minScale: 0.1,
            maxScale: 5.0,
            child: Center(
              child: Image.memory(
                imageBytes,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: FloatingActionButton.small(
              onPressed: onClose,
              backgroundColor: Colors.black54,
              child: const Icon(Icons.close, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}