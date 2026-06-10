import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FullGalleryViewer extends StatefulWidget {
  final List<XFile> images;
  final int initialIndex;
  final Function(int index) onDelete;

  const FullGalleryViewer({
    super.key,
    required this.images,
    required this.initialIndex,
    required this.onDelete,
  });

  @override
  _FullGalleryViewerState createState() => _FullGalleryViewerState();
}

class _FullGalleryViewerState extends State<FullGalleryViewer> {
  late PageController _pageController;
  late int currentIndex;
  late List<XFile> _images; // Local copy of images

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _images = List.from(widget.images); // Create a local copy
    _pageController = PageController(initialPage: currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            _buildCustomAppBar(),
            // Image Viewer
            Expanded(
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: _images.length,
                    onPageChanged: (index) {
                      setState(() {
                        currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.all(8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: InteractiveViewer(
                            maxScale: 5,
                            minScale: 0.5,
                            child: 
                            kIsWeb
                          ? FutureBuilder<Uint8List>(
                              future: _images[index].readAsBytes(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                return Image.memory(
                                  snapshot.data!,
                                  fit: BoxFit.contain,
                                );
                              },
                            )
                           : Image.file(
                              File(_images[index].path),
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[900],
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.white54,
                                    size: 50,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // Bottom Indicator
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: _buildBottomIndicator(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Back Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          
          const Spacer(),
          
          // Image Counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "${currentIndex + 1}/${_images.length}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          const Spacer(),
          
          // Delete Button
          Container(
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _showDeleteConfirmation,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomIndicator() {
    return Column(
      children: [
        // Dots Indicator
        Container(
          height: 30,
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: _images.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: currentIndex == index 
                    ? Colors.white 
                    : Colors.white.withOpacity(0.3),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Image Info
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(
            "Image ${currentIndex + 1} of ${_images.length}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Delete Image?",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "This image will be permanently deleted.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL", style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCurrentImage();
            },
            child: const Text("DELETE", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteCurrentImage() {
    final deleteIndex = currentIndex;
    
    // Call the parent's onDelete callback first
    widget.onDelete(deleteIndex);
    
    // Update local state
    setState(() {
      _images.removeAt(deleteIndex);
      
      if (_images.isEmpty) {
        Navigator.pop(context);
        return;
      }
      
      // Adjust current index if needed
      if (currentIndex >= _images.length) {
        currentIndex = _images.length - 1;
        _pageController.jumpToPage(currentIndex);
      }
    });
  }
}
// import 'dart:io';
// import 'dart:ui';

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// class FullGalleryViewer extends StatefulWidget {
//   final List<XFile> images;
//   final int initialIndex;
//   final Function(int index) onDelete;

//   const FullGalleryViewer({
//     super.key,
//     required this.images,
//     required this.initialIndex,
//     required this.onDelete,
//   });

//   @override
//   _FullGalleryViewerState createState() => _FullGalleryViewerState();
// }

// class _FullGalleryViewerState extends State<FullGalleryViewer>
//     with SingleTickerProviderStateMixin {
//   late PageController _pageController;
//   late int currentIndex;

//   late AnimationController _animController;
//   late Animation<Color?> _color1;
//   late Animation<Color?> _color2;

//   @override
//   void initState() {
//     super.initState();

//     currentIndex = widget.initialIndex;
//     _pageController = PageController(initialPage: currentIndex);

//     // Animated gradient controller
//     _animController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 6),
//     )..repeat(reverse: true);

//     _color1 = ColorTween(
//       begin: Colors.black,
//       end: Colors.deepPurple.shade900,
//     ).animate(_animController);

//     _color2 = ColorTween(
//       begin: Colors.grey.shade900,
//       end: Colors.indigo.shade800,
//     ).animate(_animController);
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     _animController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _animController,
//       builder: (context, _) {
//         return Scaffold(
//           backgroundColor: Colors.transparent,
//           appBar: AppBar(
//             backgroundColor: Colors.black26,
//             elevation: 0,
//             iconTheme: const IconThemeData(color: Colors.white),
//             actions: [
//               IconButton(
//                 icon: const Icon(Icons.delete, color: Colors.redAccent),
//                 onPressed: () {
//                   int deleteIndex = currentIndex;
//                   widget.onDelete(deleteIndex);

//                   if (widget.images.isEmpty) {
//                     Navigator.pop(context);
//                     return;
//                   }

//                   setState(() {
//                     if (currentIndex >= widget.images.length) {
//                       currentIndex = widget.images.length - 1;
//                     }
//                   });
//                 },
//               )
//             ],
//           ),
//           body: Stack(
//             children: [
//               // Smooth animated gradient background
//               Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       _color1.value ?? Colors.black,
//                       _color2.value ?? Colors.grey.shade900,
//                     ],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                 ),
//               ),

//               // Glass blur overlay (subtle)
//               BackdropFilter(
//                 filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
//                 child: Container(
//                   color: Colors.black.withOpacity(0), // keep transparent
//                 ),
//               ),

//               // Main content
//               PageView.builder(
//                 controller: _pageController,
//                 itemCount: widget.images.length,
//                 onPageChanged: (index) {
//                   setState(() => currentIndex = index);
//                 },
//                 itemBuilder: (context, index) {
//                   return Center(
//                     child: Hero(
//                       tag: widget.images[index].path,
//                       child: InteractiveViewer(
//                         maxScale: 5,
//                         minScale: 0.4,
//                         child: Image.file(
//                           File(widget.images[index].path),
//                           fit: BoxFit.contain,
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),

//               // Image counter with glass effect
//               Positioned(
//                 bottom: 25,
//                 left: 0,
//                 right: 0,
//                 child: Center(
//                   child: Container(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: Colors.black45,
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: Colors.white24, width: 0.8),
//                     ),
//                     child: Text(
//                       "${currentIndex + 1} / ${widget.images.length}",
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 15,
//                         fontFamily: 'poppins',
//                       ),
//                     ),
//                   ),
//                 ),
//               )
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
