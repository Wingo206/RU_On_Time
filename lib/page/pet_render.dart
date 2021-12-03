import 'dart:math';

import 'package:flutter/material.dart';

import '../data.dart';
import '../util_widgets.dart';

class PetDisplay extends StatefulWidget {
  final Size size;
  final Pet pet;

  PetDisplay({required this.size, required this.pet});

  @override
  _PetDisplayState createState() => _PetDisplayState();
}

void drawImage(Canvas canvas, Size size, String imageName, double cx, double cy, double scaleFactor, double angle) {
  double scaledSize = convertDouble(512.0 * scaleFactor, size);
  Offset c = convertOffset(Offset(256.0 + cx, 256.0 + cy), size);
  rotate(canvas, c, angle);
  canvas.drawImageRect(
      Constants.imageMap[imageName]!,
      Rect.fromPoints(Offset(0, 0), Offset(512, 512)),
      Rect.fromPoints(
        Offset(c.dx - scaledSize / 2, c.dy - scaledSize / 2),
        Offset(c.dx + scaledSize / 2, c.dy + scaledSize / 2),
      ),
      Paint());
  rotate(canvas, c, -angle);
}

Offset convertOffset(Offset input, Size size) {
  return Offset(input.dx * size.width / 512.0, input.dy * size.height / 512.0);
}

double convertDouble(double input, Size size) {
  return input * size.width / 512.0;
}

void rotate(Canvas canvas, Offset c, double angle) {
  canvas.translate(c.dx, c.dy);
  canvas.rotate(angle);
  canvas.translate(-c.dx, -c.dy);
}

class _PetDisplayState extends State<PetDisplay> with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;
  Tween<double> _tween = Tween(begin: -pi, end: pi);

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4),
    );

    animation = _tween.animate(controller)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.repeat();
        } else if (status == AnimationStatus.dismissed) {
          controller.forward();
        }
      });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: CustomPaint(
        size: widget.size,
        painter: _PetPainter(animation.value, widget.pet),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class _PetPainter extends CustomPainter {
  final double value;
  final Pet pet;

  _PetPainter(this.value, this.pet);

  @override
  void paint(Canvas canvas, Size size) {

    drawImage(canvas, size, "background", 0, 0, 1, 0);
    double v = 5 * cos(value);
    drawImage(canvas, size, pet.type, 0, 20 + v, 0.8, 0);
    for (Accessory a in pet.accessories) {
      drawImage(canvas, size, a.type, a.xPos, a.yPos + v, a.size, a.angle);
    }
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return true;
  }
}

class AccessoryWidget extends StatelessWidget {
  static final double height = 160;
  final Accessory accessory;
  final Color? color;

  AccessoryWidget({required this.accessory, this.color});

  @override
  Widget build(BuildContext context) {
    return OutlineBox(
      borderColor: color,
      child: Column(
        children: [
          AccessoryDisplay(size: Size(100, 100), accessory: accessory),
          SizedBox(height: 5.0),
          Text(Constants.displayNameMap[accessory.type]!),
          SizedBox(height: 5.0),
          //Text(DateFormat('MMM d, y').format(accessory.date)),
          Text((accessory.petId == "") ? "" : "(In Use)"),
        ],
      ),
    );
  }
}

class AccessoryDisplay extends StatelessWidget {
  final Size size;
  final Accessory accessory;

  AccessoryDisplay({required this.size, required this.accessory});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: CustomPaint(
        size: size,
        painter: _AccessoryPainter(accessory),
      ),
    );
  }
}

class _AccessoryPainter extends CustomPainter {
  final Accessory accessory;

  _AccessoryPainter(this.accessory);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Rect.fromPoints(Offset.zero, Offset(size.width, size.height)),
        Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.fill);
    drawImage(canvas, size, accessory.type, 0, 0, 1, 0);
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return true;
  }
}
