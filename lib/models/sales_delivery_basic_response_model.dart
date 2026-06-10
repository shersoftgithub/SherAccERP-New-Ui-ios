// sales_delivery_basic_model.dart
class SalesDeliveryBasicResponse {
  final bool success;
  final int count;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final List<SalesDeliveryBasicItem> data;

  SalesDeliveryBasicResponse({
    required this.success,
    required this.count,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.data,
  });

  factory SalesDeliveryBasicResponse.fromJson(Map<String, dynamic> json) {
    return SalesDeliveryBasicResponse(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      pageSize: json['pageSize'] ?? 20,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((item) => SalesDeliveryBasicItem.fromJson(item))
          .toList(),
    );
  }
}

class SalesDeliveryBasicItem {
  final DateTime? dDate;
  final int entryNo;
  final int salesType;
  final int fyId;
  final String customer;
  final int totalItems;
  final DateTime? lastDeliveryDate;
  final double totalQty;

  // Composite key for grouping
  String get uniqueKey => '$entryNo-$salesType-$fyId';

  SalesDeliveryBasicItem({
    this.dDate,
    required this.entryNo,
    required this.salesType,
    required this.fyId,
    required this.customer,
    required this.totalItems,
    this.lastDeliveryDate,
    required this.totalQty,
  });

  factory SalesDeliveryBasicItem.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? dateString) {
      if (dateString == null) return null;
      try {
        return DateTime.tryParse(dateString);
      } catch (e) {
        return null;
      }
    }

    return SalesDeliveryBasicItem(
      dDate: parseDate(json['DDate']?.toString()),
      entryNo: (json['EntryNo'] as num).toInt(),
      salesType: (json['SalesType'] as num).toInt(),
      fyId: (json['fyid'] as num).toInt(),
      customer: json['Customer']?.toString() ?? '',
      totalItems: (json['TotalItems'] as num?)?.toInt() ?? 0,
      lastDeliveryDate: parseDate(json['LastDeliveryDate']?.toString()),
      totalQty: (json['TotalQty'] as num?)?.toDouble() ?? 0.0,
    );
  }
}