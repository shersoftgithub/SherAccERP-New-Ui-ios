import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class FullScreenImageViewer extends StatefulWidget {
  final List<Uint8List> images;
  final int initialIndex;
  final VoidCallback onClose;

  const FullScreenImageViewer({
    super.key,
    required this.images,
    required this.initialIndex,
    required this.onClose,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late PageController _controller;
  bool _saving = false;
  bool _saved = false;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: Stack(
        children: [

          PageView.builder(
            itemCount: widget.images.length,
            controller: _controller,
            onPageChanged: (i) => setState(() => currentIndex = i),
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 0.8,
                maxScale: 5,
                child: Center(
                  child: Image.memory(
                    widget.images[index],
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: FloatingActionButton.small(
              backgroundColor: Colors.black54,
              onPressed: widget.onClose,
              child: const Icon(Icons.close, color: Colors.white),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: FloatingActionButton.small(
              backgroundColor: Colors.black54,
              onPressed: _shareImage,
              child: const Icon(Icons.share, color: Colors.white),
            ),
          ),

          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: Colors.black54,
              onPressed: _saving ? null : _saveImage,
              child: _saving
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : const Icon(Icons.download, color: Colors.white),
            ),
          ),

          Positioned(
            bottom: 18,
            left: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${currentIndex + 1} / ${widget.images.length}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),

          if (_saved)
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Saved to Gallery',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _shareImage() async {
  try {
    final bytes = widget.images[currentIndex];

    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/shared_image_${DateTime.now().millisecondsSinceEpoch}.png',
    );

    await file.writeAsBytes(bytes);

    await Share.shareXFiles(
      [XFile(file.path)],
    );
  } catch (e) {
    debugPrint('Share error: $e');
  }
}


  Future<void> _saveImage() async {
    try {
      setState(() => _saving = true);

      final bytes = widget.images[currentIndex];
      final filePath = await _writeToFile(bytes);

      await GallerySaver.saveImage(filePath, albumName: 'Delivery Reports');

      if (mounted) {
        setState(() => _saved = true);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _saved = false);
        });
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<String> _writeToFile(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await file.writeAsBytes(bytes);
    return file.path;
  }
}
