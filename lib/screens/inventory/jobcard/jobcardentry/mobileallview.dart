import 'package:flutter/material.dart';
import 'package:sheraccerp/util/jobcard_lists.dart';

class Marker extends StatefulWidget {
  const Marker({super.key});

  @override
  State<Marker> createState() => _MarkerState();
}

class _MarkerState extends State<Marker> {
  final scaffoldKey = GlobalKey<ScaffoldState>();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Column( 
        children: [
          Expanded(flex: 3,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  final RenderBox renderBox =
                      context.findRenderObject() as RenderBox;
                  final localPosition =
                      renderBox.globalToLocal(details.globalPosition);
                  if (allPoints.isEmpty) {
                    allPoints.add([]);
                  }
                  allPoints.last.add(localPosition);
                });
              },
              onPanEnd: (details) {
                setState(() {
                  allPoints.add([]);
                });
              },
              child: Container(height: 600,
                child: Stack(
                  children: [
                   
                    Image.asset(
                      'assets/images/mobileview.jpeg',
                      width: double.infinity,
                      height: double.infinity,
                    ),
                    CustomPaint(
                      size: Size.infinite,
                      painter: DrawingLinesPainter(
                        allPoints: allPoints,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                     Navigator.of(context).pop();
                  },
                  child: Text("Exit"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: Size(60, 40)),
                ),
                SizedBox(width: 10), // Add some space between buttons
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  }
                  ,
                  child: Text("Save"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: Size(60, 40)),
                ),   SizedBox(width: 10), // Add some space between buttons
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DrawingLinesPainter extends CustomPainter {
  final List<List<Offset>> allPoints;

  DrawingLinesPainter({required this.allPoints});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.butt;

    for (final points in allPoints) {
      for (int i = 0; i < points.length - 1; i++) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}