import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:sheraccerp/models/company.dart';
import 'package:sheraccerp/models/sales_delivery_basic_response_model.dart';
import 'package:sheraccerp/models/sales_delivery_model.dart';
import 'package:sheraccerp/service/api_dio.dart';

class DeliveryReportProvider with ChangeNotifier {
  final DioService api;
  
  SalesDeliveryBasicResponse? _basicReport;
  bool _isLoading = false;
  bool isLoadingMore = false;
  String? _error;
  
  final Map<String, List<SalesDeliveryItem>> _detailsCache = {};
  final Map<String, bool> _loadingDetails = {};
  
  DateTime? _fromDate;
  DateTime? _toDate;
  List<int> _salesTypes = [];
  int? _locationId;
  FinancialYear? _financialYear;
  
  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMoreData = true;
  
  DeliveryReportProvider(this.api);
  
  SalesDeliveryBasicResponse? get basicReport => _basicReport;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;
  List<int> get salesTypes => _salesTypes;
  int? get locationId => _locationId;
  FinancialYear? get financialYear => _financialYear;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  bool get hasMoreData => _hasMoreData;

 int get totalPages {
  if (_basicReport == null) return 1;
  final totalCount = _basicReport!.count;
  return (totalCount / _pageSize).ceil();
}
  
  bool areDetailsLoaded(String uniqueKey) {
    return _detailsCache.containsKey(uniqueKey);
  }
  
  bool areDetailsLoading(String uniqueKey) {
    return _loadingDetails[uniqueKey] ?? false;
  }
  
  List<SalesDeliveryItem>? getDetails(String uniqueKey) {
    return _detailsCache[uniqueKey];
  }
  
  void setFromDate(DateTime? date) {
    _fromDate = date;
    notifyListeners();
  }
  
  void setToDate(DateTime? date) {
    _toDate = date;
    notifyListeners();
  }
  
  void setSalesTypes(List<int> types) {
    _salesTypes = types;
    notifyListeners();
  }
  
  void setLocationId(int? id) {
    _locationId = id;
    notifyListeners();
  }
  
  void setFinancialYear(FinancialYear? fy) {
    _financialYear = fy;
    notifyListeners();
  }
  
  Future<void> fetchBasicReport() async {
    if (_fromDate == null || _toDate == null) {
      _error = "Please select date range";
      _isLoading = false;
      notifyListeners();
      return;
    }
    
    _isLoading = true;
    _error = null;
    _currentPage = 1;
    _hasMoreData = true;
    _detailsCache.clear(); 
    _loadingDetails.clear();
    notifyListeners();
    
    try {
      final response = await api.getSalesDeliveryReportBasic(
        sDate: _formatYMD(_fromDate!),
        eDate: _formatYMD(_toDate!),
        salesTypes: _salesTypes,
        location: _locationId,
        fyId: _financialYear?.id,
        page: _currentPage,
        pageSize: _pageSize,
      );
      
      _basicReport = response;
      _hasMoreData = _currentPage < response.totalPages;
      _error = null;
    } catch (e) {
      _error = "Error: ${e.toString()}";
      _basicReport = null;
      _hasMoreData = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Load more basic data
  Future<void> loadMoreBasicData() async {
    if (isLoadingMore || !_hasMoreData || _basicReport == null) return;
    
    isLoadingMore = true;
    notifyListeners();
    
    try {
      final nextPage = _currentPage + 1;
      
      final response = await api.getSalesDeliveryReportBasic(
        sDate: _formatYMD(_fromDate!),
        eDate: _formatYMD(_toDate!),
        salesTypes: _salesTypes,
        location: _locationId,
        fyId: _financialYear?.id,
        page: nextPage,
        pageSize: _pageSize,
      );
      
      _basicReport = SalesDeliveryBasicResponse(
        success: response.success,
        count: response.count,
        currentPage: response.currentPage,
        totalPages: response.totalPages,
        pageSize: response.pageSize,
        data: [..._basicReport!.data, ...response.data],
      );
      
      _currentPage = nextPage;
      _hasMoreData = _currentPage < response.totalPages;
    } catch (e) {
      _error = "Error loading more data: ${e.toString()}";
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }
  
  Future<void> fetchDetailsForInvoice({
    required int entryNo,
    required int salesType,
    required int fyId,
  }) async {
    final uniqueKey = '$entryNo-$salesType-$fyId';
    
    if (_loadingDetails[uniqueKey] == true || _detailsCache.containsKey(uniqueKey)) {
      return;
    }
    
    _loadingDetails[uniqueKey] = true;
    notifyListeners();
    
    try {
      final details = await api.getSalesDeliveryFullDetails(
        entryNo: entryNo,
        salesType: salesType,
        fyId: fyId,
      );
      
      _detailsCache[uniqueKey] = details;
      _error = null;
    } catch (e) {
      _error = "Error loading details: ${e.toString()}";
    } finally {
      _loadingDetails.remove(uniqueKey);
      notifyListeners();
    }
  }
  
  void clear() {
    _basicReport = null;
    _isLoading = false;
    isLoadingMore = false;
    _error = null;
    _currentPage = 1;
    _hasMoreData = true;
    _detailsCache.clear();
    _loadingDetails.clear();
    notifyListeners();
  }
  
  String _formatYMD(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
  
  Future<Uint8List?> decodeImage(dynamic photo) async {
    try {
      if (photo == null || photo.toString().isEmpty) {
        return null;
      }

      final String photoString = photo.toString();
      
      try {
        final bytes = base64.decode(photoString);
        return bytes;
      } catch (e) {
        // Not base64, continue
      }
      
      final match = RegExp(r'data:\s*\[([0-9,\s]+)\]').firstMatch(photoString);
      if (match != null) {
        final numbers = match.group(1)!.split(',');
        final List<int> bytes = [];
        
        for (String numStr in numbers) {
          final trimmed = numStr.trim();
          if (trimmed.isNotEmpty) {
            try {
              final num = int.parse(trimmed);
              if (num >= 0 && num <= 255) {
                bytes.add(num);
              }
            } catch (e) {
              // Skip invalid numbers
            }
          }
        }
        
        return Uint8List.fromList(bytes);
      }
      
      if (photo is List) {
        try {
          final List<int> bytes = [];
          for (var item in photo) {
            if (item is int) {
              bytes.add(item);
            } else if (item is String) {
              bytes.add(int.parse(item));
            }
          }
          return Uint8List.fromList(bytes);
        } catch (e) {
          return null;
        }
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
}