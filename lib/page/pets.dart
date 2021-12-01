import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui show Image;

import 'package:flutter/services.dart';
import 'package:ru_on_time/data_manager.dart';
import 'package:provider/src/provider.dart';

/*
List<Pet> testPets = [
  Pet(type: "cat", name: "Binky", love: 30, food: 20, cleanliness: 60, startDate: DateTime.now(), lastUpdate: DateTime.now()),
  Pet(type: "dog", name: "Buster", love: 40, food: 30, cleanliness: 90, startDate: DateTime.now(), lastUpdate: DateTime.now()),
  Pet(type: "dragon", name: "Broga", love: 70, food: 40, cleanliness: 80, startDate: DateTime.now(), lastUpdate: DateTime.now()),
  Pet(type: "penguin", name: "Yoiticus", love: 80, food: 10, cleanliness: 50, startDate: DateTime.now(), lastUpdate: DateTime.now()),
];
*/
int pettingCost = 1;
double pettingAmount = 20.0;
int feedingCost = 2;
double feedingAmount = 20.0;
int cleaningCost = 3;
double cleaningAmount = 20.0;

class PetsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DataManager dataManager = context.read<DataManager>();
    return Center(
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: [
            CurrencyDisplay(),
            SizedBox(height: 10.0),
            StreamBuilder<QuerySnapshot>(
              stream: dataManager.petStream,
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text("Loading");
                }
                return FutureBuilder<List<Pet>>(
                  future: createPetList(dataManager, snapshot.data!),
                  builder: (BuildContext context, AsyncSnapshot<List<Pet>> pets) {
                    if (snapshot.hasError) {
                      return Text('Something went wrong');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text("Loading");
                    }
                    return PetList(pets.data ?? []);
                  },
                );
//                return PetList(snapshot.data!.docs.map((DocumentSnapshot document) => Pet.createFromJson(dataManager, document.data()! as Map<String, dynamic>, document.id)).toList());
              },
            )
          ],
        ),
      ),
    );
  }

  Future<List<Pet>> createPetList(DataManager dataManager, QuerySnapshot snapshot) async {
    List<Pet> pets = [];
    for (DocumentSnapshot document in snapshot.docs) {
      await Pet.createFromJson(dataManager, document.data()! as Map<String, dynamic>, document.id).then((Pet p) {
        pets.add(p);
      });
    }

    return pets;
  }
}

class PetList extends StatelessWidget {
  final List<Pet> _pets;

  PetList(this._pets);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 2.0, color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: 10.0),
          child: ListView(
            physics: BouncingScrollPhysics(),
            children: _pets.map((Pet p) => PetWidget(p)).toList(),
          ),
        ),
      ),
    );
  }
}

class CurrencyDisplay extends StatefulWidget {
  @override
  _CurrencyDisplayState createState() => _CurrencyDisplayState();
}

class _CurrencyDisplayState extends State<CurrencyDisplay> {
  int coins = 0;
  int gems = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(context.read<DataManager>().uid).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }
        if (snapshot.hasData && !snapshot.data!.exists) {
          return Text("Document does not exist");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return buildDisplay(context);
        }
        Map<String, dynamic> data = snapshot.data!.data()! as Map<String, dynamic>;
        coins = data['coins'] as int;
        gems = data['gems'] as int;
        return buildDisplay(context);
      },
    );
  }

  Widget buildDisplay(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 2.0, color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Icon(Icons.attach_money, size: 30.0),
                Text("Coins: " + coins.toString()),
              ],
            ),
            Column(
              children: [
                Icon(Icons.sports_soccer_rounded, size: 30.0),
                Text("Gems: " + gems.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PetWidget extends StatefulWidget {
  final Pet pet;

  PetWidget(this.pet);

  @override
  _PetWidgetState createState() => _PetWidgetState();
}

class _PetWidgetState extends State<PetWidget> {
  bool _editingName = false;

  @override
  Widget build(BuildContext context) {
    TextEditingController nameController = TextEditingController(text: widget.pet.name);
    //update info for pet
    int hours = DateTime.now().difference(widget.pet.lastUpdate).inHours;
    if (hours > 0) {
      widget.pet.lastUpdate = DateTime.now();
      widget.pet.love -= hours / 24.0 * 3.0;
      widget.pet.love = max(0, widget.pet.love);
      widget.pet.food -= hours / 24.0 * 10.0 * (1 - (widget.pet.love / 100.0));
      widget.pet.food = max(0, widget.pet.food);
      widget.pet.cleanliness -= hours / 24.0 * 5.0 * (1 - (widget.pet.love / 100.0));
      widget.pet.cleanliness = max(0, widget.pet.cleanliness);
      widget.pet.updateDocument(context);
    }
    return Padding(
      padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 2.0, color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 48.0),
                  Expanded(
                    child: (_editingName)
                        ? Padding(
                            padding: EdgeInsets.only(bottom: 5.0),
                            child: TextField(
                              controller: nameController,
                              decoration: InputDecoration(
                                labelText: "Pet Name",
                              ),
                            ),
                          )
                        : Text(
                            widget.pet.name,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                  ),
                  IconButton(
                    icon: Icon((_editingName) ? Icons.check : Icons.edit),
                    color: Theme.of(context).primaryColor,
                    onPressed: () {
                      setState(() {
                        if (_editingName) {
                          if (widget.pet.name != nameController.text.trim()) {
                            widget.pet.name = nameController.text.trim();
                            widget.pet.updateDocument(context);
                          }
                        }
                        _editingName = !_editingName;
                      });
                    },
                  ),
                ],
              ),
              PetDisplay(
                size: Size(250, 250),
                pet: widget.pet,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (widget.pet.love < 100.0) {
                        widget.pet.love += pettingAmount;
                        widget.pet.love = min(widget.pet.love, 100.0);
                        context.read<DataManager>().getUserData().then((UserData userData) {
                          if (userData.coins > pettingCost) {
                            userData.coins -= pettingCost;
                            widget.pet.updateDocument(context);
                            userData.updateDocument(context);
                          } else {
                            print("not enough coins");
                          }
                        });
                      }
                    },
                    child: Text("Pet (\$1)"),
                  ),
                  SizedBox(width: 5.0),
                  ElevatedButton(
                    onPressed: () {
                      if (widget.pet.food < 100.0) {
                        widget.pet.food += feedingAmount;
                        widget.pet.food = min(widget.pet.food, 100.0);
                        context.read<DataManager>().getUserData().then((UserData userData) {
                          if (userData.coins > feedingCost) {
                            userData.coins -= feedingCost;
                            widget.pet.updateDocument(context);
                            userData.updateDocument(context);
                          } else {
                            print("not enough coins");
                          }
                        });
                      }
                    },
                    child: Text("Feed (\$2)"),
                  ),
                  SizedBox(width: 5.0),
                  ElevatedButton(
                    onPressed: () {
                      if (widget.pet.cleanliness < 100.0) {
                        widget.pet.cleanliness += cleaningAmount;
                        widget.pet.cleanliness = min(widget.pet.cleanliness, 100.0);
                        context.read<DataManager>().getUserData().then((UserData userData) {
                          if (userData.coins > cleaningCost) {
                            userData.coins -= cleaningCost;
                            widget.pet.updateDocument(context);
                            userData.updateDocument(context);
                          } else {
                            print("not enough coins");
                          }
                        });
                      }
                    },
                    child: Text("Clean (\$3)"),
                  ),
                ],
              ),
              buildStatBar("Love", widget.pet.love, 100),
              buildStatBar("Food", widget.pet.food, 100),
              buildStatBar("Cleanliness", widget.pet.cleanliness, 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildStatBar(String name, double value, double maxValue) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name),
              Text(value.toStringAsFixed(2) + " / " + maxValue.toStringAsFixed(0)),
            ],
          ),
          SizedBox(height: 5.0),
          LinearProgressIndicator(value: value / maxValue),
        ],
      ),
    );
  }
}

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
