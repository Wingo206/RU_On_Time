import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui show Image;
import 'package:provider/src/provider.dart';

import 'data_manager.dart';

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

    await addData("background", "");
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


  static Future<Pet> createFromJson(CollectionReference accessoriesCollection, Map<String, Object?> json, String id) async {
    List<String> ids = (json['accessories'] as List<dynamic>).map((dynamic d) => d as String).toList();
    List<Accessory> accessories = [];
    for (String id in ids) {
      await accessoriesCollection.doc(id).get().then((DocumentSnapshot document) {
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

class Assignment {
  String name;
  DateTime dueDate;
  DateTime startDate;
  bool completed;
  String? documentId;

  Assignment({required this.name, required this.dueDate, required this.startDate, required this.completed, this.documentId});

  Assignment.fromJson(Map<String, Object?> json, String id)
      : this(
          name: json['name']! as String,
          dueDate: DateTime.parse(json['due date']! as String),
          startDate: DateTime.parse(json['start date']! as String),
          completed: json['completed']! as bool,
          documentId: id,
        );

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'due date': dueDate.toIso8601String(),
      'start date': startDate.toIso8601String(),
      'completed': completed,
    };
  }

  Future<void> updateDocument(BuildContext context) async {
    context.read<DataManager>().assignmentsCollection.doc(documentId).update(toJson());
  }
}

class UserData {
  String name;
  String email;
  int hearts;
  int heartsTotal;
  int gems;
  int gemsTotal;
  double xp;
  int completed;
  String favorite;
  DateTime startDate;
  String? documentID;

  UserData({
    required this.name,
    required this.email,
    required this.hearts,
    required this.heartsTotal,
    required this.gems,
    required this.gemsTotal,
    required this.xp,
    required this.completed,
    required this.favorite,
    required this.startDate,
    this.documentID,
  });

  UserData.fromJson(Map<String, Object?> json, String id)
      : this(
          name: json['name']! as String,
          email: json['email']! as String,
          hearts: json['hearts']! as int,
          heartsTotal: json['hearts total']! as int,
          gems: json['gems']! as int,
          gemsTotal: json['gems total']! as int,
          xp: (json['xp']! as num).toDouble(),
          completed: json['completed']! as int,
          favorite: json['favorite']! as String,
          startDate: DateTime.parse(json['start date']! as String),
          documentID: id,
        );

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'email': email,
      'hearts': hearts,
      'hearts total': heartsTotal,
      'gems': gems,
      'gems total': gemsTotal,
      'xp': xp,
      'completed': completed,
      'favorite': favorite,
      'start date': startDate.toIso8601String(),
    };
  }

  void addHearts(int amount) {
    hearts += amount;
    heartsTotal += amount;
  }

  void addGems(int amount) {
    gems += amount;
    gemsTotal += amount;
  }

  Future<void> updateDocument(BuildContext context) async {
    DataManager.usersCollection.doc(documentID).update(toJson());
  }
}
