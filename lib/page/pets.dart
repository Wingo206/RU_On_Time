import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui show Image;

import 'package:flutter/services.dart';
import 'package:ru_on_time/data_manager.dart';
import 'package:provider/src/provider.dart';

List<Pet> testPets = [
  Pet(type: "cat", name: "Binky", love: 30, food: 20, cleanliness: 60, startDate: DateTime.now(), lastUpdate: DateTime.now()),
  Pet(type: "dog", name: "Buster", love: 40, food: 30, cleanliness: 90, startDate: DateTime.now(), lastUpdate: DateTime.now()),
  Pet(type: "dragon", name: "Broga", love: 70, food: 40, cleanliness: 80, startDate: DateTime.now(), lastUpdate: DateTime.now()),
  Pet(type: "penguin", name: "Yoiticus", love: 80, food: 10, cleanliness: 50, startDate: DateTime.now(), lastUpdate: DateTime.now()),
];

int pettingCost = 1;
double pettingAmount = 20.0;
int feedingCost = 2;
double feedingAmount = 20.0;
int cleaningCost = 3;
double cleaningAmount = 20.0;

class PetsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: [
            CurrencyDisplay(),
            SizedBox(height: 10.0),
            StreamBuilder<QuerySnapshot>(
              stream: context.read<DataManager>().petStream,
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text("Loading");
                }
                return PetList(snapshot.data!.docs.map((DocumentSnapshot document) => Pet.fromJson(document.data()! as Map<String, dynamic>, document.id)).toList());
              },
            )
          ],
        ),
      ),
    );
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
  @override
  Widget build(BuildContext context) {
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
                    child: Text(
                      widget.pet.name,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    color: Theme.of(context).primaryColor,
                    onPressed: () {
                      setState(() {
                        print("name editing code"); //TODO
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
              Text(value.toString() + " / " + maxValue.toString()),
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
    //rotate(canvas, convert(Offset(150, 150), size), pi/4);
    double v = 5 * cos(value);
    canvas.drawImageRect(PetData.petDataMap[pet.type]!._image, Rect.fromPoints(Offset(0, v), Offset(512, 512)), Rect.fromPoints(Offset.zero, Offset(size.width, size.height)), Paint());
    //rotate(canvas, convert(Offset(150, 150), size), -pi/4);
  }

  Offset convert(Offset input, Size size) {
    return Offset(input.dx * size.width / 512.0, input.dy * size.height / 512.0);
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

class PetData {
  static final Map<String, PetData> petDataMap = new Map<String, PetData>();

  final String _name;
  late ui.Image _image;

  PetData(this._name) {
    loadImage('assets/' + _name + '.png').then((image) {
      _image = image;
      petDataMap[_name] = this;
    });
  }

  static loadPetData() {
    PetData("cat");
    PetData("dog");
    PetData("dragon");
    PetData("penguin");
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
  String? documentID;

  Pet({required this.type, required this.name, required this.love, required this.food, required this.cleanliness, required this.startDate, required this.lastUpdate, this.documentID});

  Pet.fromJson(Map<String, Object?> json, String id)
      : this(
          type: json['type']! as String,
          name: json['name']! as String,
          love: (json['love']! as num).toDouble(),
          food: (json['food']! as num).toDouble(),
          cleanliness: (json['cleanliness']! as num).toDouble(),
          startDate: DateTime.parse(json['start date']! as String),
          lastUpdate: DateTime.parse(json['last update']! as String),
          documentID: id,
        );

  Map<String, Object?> toJson() {
    return {
      'type': type,
      'name': name,
      'love': love,
      'food': food,
      'cleanliness': cleanliness,
      'start date': startDate.toIso8601String(),
      'last update': lastUpdate.toIso8601String(),
    };
  }

  Future<void> updateDocument(BuildContext context) async {
    context.read<DataManager>().petsCollection.doc(documentID).update(toJson());
  }
}
