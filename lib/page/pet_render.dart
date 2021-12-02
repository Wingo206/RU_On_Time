import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui show Image;
import 'package:flutter/services.dart';

import 'package:ru_on_time/data_manager.dart';
import 'package:provider/src/provider.dart';
import 'package:intl/intl.dart';

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

Future<ui.Image> loadImage(String path) async {
  final data = await rootBundle.load(path);
  final bytes = data.buffer.asUint8List();
  final image = await decodeImageFromList(bytes);
  return image;
}

class Constants {
  static final List<String> pets = ["cat", "dog", "dragon", "penguin"];
  static final List<int> petPrices = [50, 50, 80, 60];
  static final List<String> accessories = ["bandana", "bowtie", "collar", "flower_crown", "santa_hat", "top_hat"];
  static final List<int> accessoryPrices = [10, 10, 10, 20, 20, 20];
  static final Map<String, ui.Image> imageMap = new Map<String, ui.Image>();
  static final Map<String, String> displayNameMap = new Map<String, String>();

  static Future<void> addData(String name, String displayName) async {
    imageMap[name] = await loadImage('assets/' + name + '.png');
    displayNameMap[name] = displayName;
  }

  static Future<void> loadImageData() async {
    await addData("cat", "Cat");
    await addData("dog", "Dog");
    await addData("dragon", "Dragon");
    await addData("penguin", "Penguin");
    await addData("bandana", "Bandana");
    await addData("bowtie", "Bowtie");
    await addData("collar", "Collar");
    await addData("flower_crown", "Flower Crown");
    await addData("santa_hat", "Santa Hat");
    await addData("top_hat", "Top Hat");
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
  String petId;
  double xPos;
  double yPos;
  double angle;
  double size;
  String? documentId;

  Accessory({required this.type, required this.date, required this.petId, required this.xPos, required this.yPos, required this.angle, required this.size, this.documentId});

  Accessory.fromJson(Map<String, Object?> json, String id)
      : this(
          type: json['type']! as String,
          petId: json['petId']! as String,
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
      'petId': petId,
      'date': date.toIso8601String(),
      'x pos': xPos,
      'y pos': yPos,
      'angle': angle,
      'size': size,
    };
  }

  Future<void> updateDocument(BuildContext context) async {
    context.read<DataManager>().accessoriesCollection.doc(documentId).update(toJson());
  }
}
