import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui show Image;
import 'package:flutter/services.dart';

import 'package:ru_on_time/data_manager.dart';
import 'package:provider/src/provider.dart';

class PetDisplay extends StatefulWidget {
  final Size size;
  final Pet pet;

  PetDisplay({required this.size, required this.pet});

  @override
  _PetDisplayState createState() => _PetDisplayState();
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
    return CustomPaint(
      size: widget.size,
      painter: _PetPainter(animation.value, widget.pet),
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
    canvas.drawRect(
        Rect.fromPoints(Offset.zero, Offset(size.width, size.height)),
        Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.fill);

    double v = 5 * cos(value);
    /*canvas.drawImageRect(
        ImageData.imageDataMap[pet.type]!._image,
        Rect.fromPoints(Offset(0, 0), Offset(512, 512)),
        Rect.fromPoints(
          Offset(size.width * 0.1, size.height * 0.1 + 30),
          Offset(size.width * 0.9, size.height * 0.9 + 30),
        ),
        Paint());*/
    drawImage(canvas, size, pet.type, 0, 20+v, 0.8, 0);
    for (Accessory a in pet.accessories) {
      drawImage(canvas, size, a.type, a.xPos, a.yPos + v, a.size, a.angle);
    }
  }

  void drawImage(Canvas canvas, Size size, String imageName, double cx, double cy, double scaleFactor, double angle) {
    double scaledSize = convertDouble(512.0 * scaleFactor, size);
    Offset c = convertOffset(Offset(256.0 + cx, 256.0 + cy), size);
    rotate(canvas, c, angle);
    canvas.drawImageRect(
        ImageData.imageDataMap[imageName]!._image,
        Rect.fromPoints(Offset(0, 0), Offset(512, 512)),
        Rect.fromPoints(
          Offset(c.dx - scaledSize/2, c.dy - scaledSize/2),
          Offset(c.dx + scaledSize/2, c.dy + scaledSize/2),
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

  @override
  bool shouldRepaint(CustomPainter old) {
    return true;
  }
}

Future<ui.Image> loadImage(String path) async {
  final data = await rootBundle.load(path);
  final bytes = data.buffer.asUint8List();
  final image = await decodeImageFromList(bytes);
  return image;
}

class ImageData {
  static final Map<String, ImageData> imageDataMap = new Map<String, ImageData>();

  final String _name;
  late ui.Image _image;

  ImageData(this._name) {
    loadImage('assets/' + _name + '.png').then((image) {
      _image = image;
      imageDataMap[_name] = this;
    });
  }

  static loadImageData() {
    ImageData("cat");
    ImageData("dog");
    ImageData("dragon");
    ImageData("penguin");
    ImageData("bandana");
    ImageData("bowtie");
    ImageData("collar");
    ImageData("flower_crown");
    ImageData("santa_hat");
    ImageData("top_hat");
  }
}

class Pet {
  String type;
  String name;
  double love;
  double food;
  double cleanliness;
  DateTime startDate;
  DateTime lastUpdate;
  List<Accessory> accessories;
  String? documentId;

  Pet({
    required this.type,
    required this.name,
    required this.love,
    required this.food,
    required this.cleanliness,
    required this.startDate,
    required this.lastUpdate,
    required this.accessories,
    this.documentId,
  });

  static Future<Pet> createFromJson(DataManager manager, Map<String, Object?> json, String id) async {
    List<String> ids = (json['accessories'] as List<dynamic>).map((dynamic d) => d as String).toList();
    List<Accessory> accessories = [];
    for (String id in ids) {
      await manager.accessoriesCollection.doc(id).get().then((DocumentSnapshot document) {
        accessories.add(Accessory.fromJson(document.data()! as Map<String, dynamic>, id));
      });
    }
    return Pet(
      type: json['type']! as String,
      name: json['name']! as String,
      love: (json['love']! as num).toDouble(),
      food: (json['food']! as num).toDouble(),
      cleanliness: (json['cleanliness']! as num).toDouble(),
      startDate: DateTime.parse(json['start date']! as String),
      lastUpdate: DateTime.parse(json['last update']! as String),
      accessories: accessories,
      documentId: id,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'type': type,
      'name': name,
      'love': love,
      'food': food,
      'cleanliness': cleanliness,
      'start date': startDate.toIso8601String(),
      'last update': lastUpdate.toIso8601String(),
      'accessories': accessories.map((Accessory a) => a.documentId).toList(),
    };
  }

  Future<void> updateDocument(BuildContext context) async {
    context.read<DataManager>().petsCollection.doc(documentId).update(toJson());
  }
}

class Accessory {
  String type;
  DateTime date;
  bool inUse;
  double xPos;
  double yPos;
  double angle;
  double size;
  String? documentId;

  Accessory({required this.type, required this.date, required this.inUse, required this.xPos, required this.yPos, required this.angle, required this.size, this.documentId});

  Accessory.fromJson(Map<String, Object?> json, String id)
      : this(
    type: json['type']! as String,
    inUse: json['in use']! as bool,
    date: DateTime.parse(json['date']! as String),
    xPos: (json['x pos']! as num).toDouble(),
    yPos: (json['y pos']! as num).toDouble(),
    angle: (json['angle']! as num).toDouble(),
    size: (json['size']! as num).toDouble(),
    documentId: id,
  );

  Map<String, Object?> toJson() {
    return {
      'type': type,
      'in use': inUse,
      'date': date.toIso8601String(),
      'x pos': xPos,
      'y pos': yPos,
      'angle': angle,
      'size': size,
    };
  }

  Future<void> updateDocument(BuildContext context) async {
    context.read<DataManager>().petsCollection.doc(documentId).update(toJson());
  }
}
