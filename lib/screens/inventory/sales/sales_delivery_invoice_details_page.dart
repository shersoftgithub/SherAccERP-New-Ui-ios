import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sheraccerp/models/sales_delivery_basic_response_model.dart';
import 'package:sheraccerp/models/sales_delivery_model.dart';
import 'package:sheraccerp/provider/sales_delivery_provider.dart';
import 'package:sheraccerp/util/fullscreen_image_view.dart';
import 'package:sheraccerp/util/res_color.dart';
import 'dart:html' as html;

  class InvoiceDetailsScreen extends StatefulWidget {
    final SalesDeliveryBasicItem basicItem;

    const InvoiceDetailsScreen({
      Key? key,
      required this.basicItem,
    }) : super(key: key);

  @override
  State<InvoiceDetailsScreen> createState() => _InvoiceDetailsScreenState();
}

class _InvoiceDetailsScreenState extends State<InvoiceDetailsScreen> {
    final Map<int, GlobalKey> _cardKeys = {};

    final ValueNotifier<Set<int>> _selectedItemIds = ValueNotifier<Set<int>>({});

    final ValueNotifier<bool> _selectionMode = ValueNotifier(false);

    final ValueNotifier<bool> _isCapturing = ValueNotifier(false);

    @override
    void initState() {
      super.initState();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider =
            Provider.of<DeliveryReportProvider>(context, listen: false);

        provider.fetchDetailsForInvoice(
          entryNo: widget.basicItem.entryNo,
          salesType: widget.basicItem.salesType,
          fyId: widget.basicItem.fyId,
        );
      });
    }

    @override
    Widget build(BuildContext context) {
      // final provider = Provider.of<DeliveryReportProvider>(context); 

    //  final provider = Provider.of<DeliveryReportProvider>(context, listen: false);

    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     provider.fetchDetailsForInvoice(
    //       entryNo: widget.basicItem.entryNo,
    //       salesType: widget.basicItem.salesType,
    //       fyId: widget.basicItem.fyId,
    //     );
    //   });

      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Item Details',
            style: TextStyle(
              fontFamily: 'poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
            actions: [
              ValueListenableBuilder<Set<int>>(
                valueListenable: _selectedItemIds,
                builder: (context, selectedIds, _) {
                  if (selectedIds.isEmpty) return const SizedBox();

                  return IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () => _shareSelectedCards(context),
                  );
                },
              ),
            ValueListenableBuilder<bool>(
              valueListenable: _selectionMode,
              builder: (context, isSelecting, _) {
                return ValueListenableBuilder<Set<int>>(
                  valueListenable: _selectedItemIds,
                  builder: (context, selectedIds, _) {
                    if (!isSelecting) {
                      return IconButton(
                        icon: const Icon(CupertinoIcons.circle_grid_3x3),
                        onPressed: () {
                          _selectionMode.value = true;
                          _toggleSelectAll();
                        },
                      );
                    }

                    final allIds = _cardKeys.keys.toSet();
                    final isAllSelected =
                        allIds.isNotEmpty && selectedIds.length == allIds.length;

                    return IconButton(
                      icon: Icon(
                        isAllSelected
                            ? CupertinoIcons.circle_grid_3x3_fill
                            : CupertinoIcons.circle_grid_3x3,
                      ),
                      onPressed: _toggleSelectAll,
                    );
                  },
                );
              },
            ),
          ],
        ),
       body: Consumer<DeliveryReportProvider>(
          builder: (context, provider, _) {

            final details = provider.getDetails(widget.basicItem.uniqueKey);
            final isFetching = provider.areDetailsLoading(widget.basicItem.uniqueKey);
            final hasTried = details != null;   
            final hasData = details != null && details.isNotEmpty;

            if (hasData) {
              return _buildDetailsContent(context, details);
            }

            if (isFetching || !hasTried) {
              return const Center(
                child: CircularProgressIndicator(color: kPrimaryColor),
              );
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Unable to load details',
                    style: TextStyle(fontFamily: 'poppins'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.fetchDetailsForInvoice(
                        entryNo: widget.basicItem.entryNo,
                        salesType: widget.basicItem.salesType,
                        fyId: widget.basicItem.fyId,
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    Map<int, List<SalesDeliveryItem>> _groupByItemId(List<SalesDeliveryItem> list) {
    final Map<int, List<SalesDeliveryItem>> grouped = {};
    for (var item in list) {
      grouped.putIfAbsent(item.itemId, () => []).add(item);
    }
    return grouped;
  }

    Widget _buildDetailsContent(BuildContext context, List<SalesDeliveryItem> details) {
      final groupedItems = _groupByItemId(details);
      final groupedKeys = groupedItems.keys.toList();
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Invoice Header
            // Card(
            //   margin: const EdgeInsets.all(16),
            //   child: Padding(
            //     padding: const EdgeInsets.all(16.0),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Text(
            //           basicItem.customer,
            //           style: const TextStyle(
            //             fontSize: 20,
            //             fontWeight: FontWeight.bold,
            //             fontFamily: 'poppins',
            //           ),
            //         ),
            //         const SizedBox(height: 8),
            //         Row(
            //           children: [
            //             _buildDetailItem(
            //               icon: Icons.receipt,
            //               label: 'Invoice No',
            //               value: 'INV-${basicItem.entryNo}',
            //             ),
            //             const SizedBox(width: 16),
            //             _buildDetailItem(
            //               icon: Icons.date_range,
            //               label: 'Date',
            //               value: basicItem.dDate != null
            //                   ? DateFormat('dd-MM-yyyy').format(basicItem.dDate!)
            //                   : 'N/A',
            //             ),
            //           ],
            //         ),
            //         const SizedBox(height: 8),
            //         Row(
            //           children: [
            //             _buildDetailItem(
            //               icon: Icons.inventory_2,
            //               label: 'Total Items',
            //               value: basicItem.totalItems.toString(),
            //             ),
            //             const SizedBox(width: 16),
            //             _buildDetailItem(
            //               icon: Icons.scale,
            //               label: 'Total Qty',
            //               value: basicItem.totalQty.toString(),
            //             ),
            //           ],
            //         ),
            //       ],
            //     ),
            //   ),
            // ),

            // Items List
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16),
            //   child: Text(
            //     'Items (${details.length})',
            //     style: TextStyle(
            //       fontSize: 18,
            //       fontWeight: FontWeight.bold,
            //       color: kPrimaryColor,
            //       fontFamily: 'poppins',
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 8),
            
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: groupedKeys.length,
              itemBuilder: (context, index) {
                final itemId = groupedKeys[index];
                final items = groupedItems[itemId]!;
                final item = items.first;

                final remark = items.firstWhere(
              (e) => e.remark != null && e.remark!.isNotEmpty && e.remark! != 'null',
              orElse: () => SalesDeliveryItem.empty(),
            ).remark;
            _cardKeys.putIfAbsent(itemId, () => GlobalKey());
                return GestureDetector(
                  onLongPress: () {
                    HapticFeedback.mediumImpact();
                    // HapticFeedback.lightImpact();   // subtle
                    // HapticFeedback.mediumImpact();  // recommended
                    // HapticFeedback.heavyImpact();   // strong
                    _selectionMode.value = true;
                    _selectedItemIds.value = {itemId};
                  },
                  onTap: () {
                    if (_selectionMode.value) {
                      HapticFeedback.selectionClick();
                      final newSet = Set<int>.from(_selectedItemIds.value);
                      if (newSet.contains(itemId)) {
                        newSet.remove(itemId);
                      } else {
                        newSet.add(itemId);
                      }

                      _selectedItemIds.value = newSet;

                      if (newSet.isEmpty) {
                        _selectionMode.value = false;
                      }
                    }
                  },
                  child: Stack(
                    children: [
                      ValueListenableBuilder<Set<int>>(
                        valueListenable: _selectedItemIds,
                        builder: (context, selectedIds, _) {
                          final isSelected = selectedIds.contains(itemId);

                          return RepaintBoundary(
                            key: _cardKeys[itemId],
                            child: Material(
                              color: Colors.white,
                              child: AnimatedContainer(
                                duration: _isCapturing.value
                                          ? Duration.zero
                                          : const Duration(milliseconds: 200),
                                curve: Curves.easeOut,
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected ? kPrimaryColor.withOpacity(0.08) : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected ? kPrimaryColor : Colors.grey.shade300,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: _cardBody(
                                  context: context,
                                  item: item,
                                  items: items,
                                  remark: remark,
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      ValueListenableBuilder<bool>(
                        valueListenable: _selectionMode,
                        builder: (context, isSelecting, _) {
                          return ValueListenableBuilder<bool>(
                            valueListenable: _isCapturing,
                            builder: (context, isCapturing, _) {
                              if (!isSelecting || isCapturing) {
                                return const SizedBox(); 
                              }

                              return Positioned(
                                top: 8,
                                right: 8,
                                child: AnimatedScale(
                                  scale: 1,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeOutBack,
                                  child: ValueListenableBuilder<Set<int>>(
                                    valueListenable: _selectedItemIds,
                                    builder: (context, selectedIds, _) {
                                      return Checkbox(
                                        value: selectedIds.contains(itemId),
                                        activeColor: kPrimaryColor,
                                        onChanged: (_) {},
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      );
    }

   Widget _cardBody({
  required BuildContext context,
  required SalesDeliveryItem item,
  required List<SalesDeliveryItem> items,
  required String? remark,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        item.itemname,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'poppins',
        ),
      ),

      const SizedBox(height: 8),

      Row(
        children: [
          _buildItemDetail(
            icon: Icons.scale,
            label: 'Qty',
            value: item.qty.toString(),
          ),
          const SizedBox(width: 16),
          _buildItemDetail(
            icon: Icons.local_shipping,
            label: 'Delivery',
            value: item.deliveryDate == null ||
                    item.deliveryDate!.year == 1900
                ? 'N/A'
                : DateFormat('dd-MM-yyyy')
                    .format(item.deliveryDate!),
          ),
        ],
      ),
      if (remark != null && remark.isNotEmpty && remark != 'null') ...[
        const SizedBox(height: 8),
        _buildRemarkSection(remark),
      ],
      if (items.any(
        (e) =>
            e.photo != null &&
            e.photo.toString().isNotEmpty &&
            e.photo.toString() != 'null',
      )) ...[
        const SizedBox(height: 8),
        _buildMultiImageSection(context, items),
      ],
    ],
  );
}

  Future<Uint8List?> _captureCard(GlobalKey key) async {
  try {
    final context = key.currentContext;
    if (context == null) return null;

    // ✅ Wait for real rendered frame (RELEASE SAFE)
    await WidgetsBinding.instance.endOfFrame;

    final boundary =
        context.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;

    final pixelRatio = MediaQuery.of(context).devicePixelRatio;

    final image = await boundary.toImage(
      pixelRatio: pixelRatio * 2,
    );

    final byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData?.buffer.asUint8List();
  } catch (e) {
    debugPrint('Capture error: $e');
    return null;
  }
}

  void _toggleSelectAll() {
    final allIds = _cardKeys.keys.toSet();

    if (_selectedItemIds.value.length == allIds.length) {
      _selectedItemIds.value = {};
      _selectionMode.value = false;
    } else {
      _selectionMode.value = true;
      _selectedItemIds.value = allIds;
    }
  }

Future<void> _shareSelectedCards(BuildContext context) async {
  final selectedIds = _selectedItemIds.value;
  if (selectedIds.isEmpty) return;

  _isCapturing.value = true;

  await WidgetsBinding.instance.endOfFrame;
  await WidgetsBinding.instance.endOfFrame;

  if (kIsWeb) {
    for (final itemId in selectedIds) {
      final key = _cardKeys[itemId];
      if (key == null) continue;

      final bytes = await _captureCard(key);
      if (bytes == null) continue;

      _downloadBytesOnWeb(bytes, 'item_$itemId.png');
    }

    _isCapturing.value = false;

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          selectedIds.length == 1
              ? 'Image downloaded!'
              : '${selectedIds.length} images downloaded!',
        ),
        backgroundColor: Colors.green,
      ),
    );
  } else {
    final List<XFile> files = [];

    for (final itemId in selectedIds) {
      final key = _cardKeys[itemId];
      if (key == null) continue;

      final bytes = await _captureCard(key);
      if (bytes == null) continue;

      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/item_$itemId.png';
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      files.add(XFile(filePath));
    }

    _isCapturing.value = false;

    if (!mounted) return;

    if (files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No files to share')),
      );
      return;
    }

    final dateText = widget.basicItem.dDate != null
        ? DateFormat('dd-MM-yyyy').format(widget.basicItem.dDate!.toLocal())
        : 'N/A';

    await Share.shareXFiles(
      files,
      text: widget.basicItem.customer.isNotEmpty
          ? 'Customer : ${widget.basicItem.customer}\nDate : $dateText'
          : 'Invoice item details',
    );
  }
}

void _downloadBytesOnWeb(Uint8List bytes, String filename) {
  if (!kIsWeb) return;
  final blob = html.Blob([bytes], 'image/png');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  html.Url.revokeObjectUrl(url);
}

    Widget _buildRemarkSection(String remark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.note, size: 14, color: grey),
            SizedBox(width: 4),
            Text(
              'Remark',
              style: TextStyle(
                fontSize: 10,
                color: grey,
                fontFamily: 'poppins',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text(
            remark,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'poppins',
            ),
          ),
        ),
      ],
    );
  }

    // Widget _buildDetailItem({
    Widget _buildItemDetail({
      required IconData icon,
      required String label,
      required String value,
    }) {
      return Expanded(
        child: Row(
          children: [
            Icon(icon, size: 14, color: grey),
            const SizedBox(width: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: grey,
                    fontFamily: 'poppins',
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'poppins',
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

  Widget _buildMultiImageSection(BuildContext context, List<SalesDeliveryItem> items) {
  final provider = Provider.of<DeliveryReportProvider>(context, listen: false);

  final images = items
      .map((e) => e.photo)
      .where((e) => e != null && e.toString().isNotEmpty && e.toString() != 'null')
      .toList();

  if (images.isEmpty) return const SizedBox();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 8),
      const Text(
        'Images',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 6),

      SizedBox(
        height: 85,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: images.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => _showImageFullScreen(context, images, index),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(color: grey),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: FutureBuilder<Uint8List?>(
                  future: provider.decodeImage(images[index]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Icon(Icons.broken_image);
                    }

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.memory(
                        snapshot.data!,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      )
    ],
  );
}

    void _showImageFullScreen(
    BuildContext context,
    List<dynamic> photos,
    int initialIndex,
) async {
  final provider = Provider.of<DeliveryReportProvider>(context, listen: false);

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(
      child: CircularProgressIndicator(color: kPrimaryColor),
    ),
  );

  final List<Uint8List> imageBytes = [];

  for (var photo in photos) {
    final bytes = await provider.decodeImage(photo);
    if (bytes != null) imageBytes.add(bytes);
  }

  if (!context.mounted) return;

  Navigator.pop(context); 

  if (imageBytes.isEmpty) return;

  showDialog(
    context: context,
    builder: (_) => FullScreenImageViewer(
      images: imageBytes,
      initialIndex: initialIndex,
      onClose: () => Navigator.pop(context),
    ),
  );
}
}