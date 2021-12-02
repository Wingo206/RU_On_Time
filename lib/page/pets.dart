import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:ru_on_time/data_manager.dart';
import 'package:provider/src/provider.dart';
import 'package:ru_on_time/page/pet_render.dart';

import '../data.dart';
import '../util_widgets.dart';

int pettingCost = 3;
double pettingAmount = 5.0;
int feedingCost = 5;
double feedingAmount = 5.0;
int cleaningCost = 15;
double cleaningAmount = 5.0;

class PetsPage extends StatelessWidget {
  List<Pet> _pets = [];

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
                  return CircularProgressIndicator();
                }
                return FutureBuilder<List<Pet>>(
                  future: createPetList(dataManager, snapshot.data!),
                  builder: (BuildContext context, AsyncSnapshot<List<Pet>> pets) {
                    if (pets.hasError) {
                      return Text('Something went wrong');
                    }
                    if (pets.connectionState == ConnectionState.waiting) {
                      //return Text("Loading");
                    } else {
                      _pets = pets.data ?? [];
                    }
                    if (_pets.length == 0) {
                      return CircularProgressIndicator();
                    }
                    return PetList(_pets);
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

class PetList extends StatelessWidget {
  final List<Pet> _pets;

  PetList(this._pets);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: PaddingListView(
        itemCount: _pets.length,
        itemBuilder: (BuildContext context, int index) {
          return PetWidget(_pets[index]);
        },
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
  int _selectedIndex = -1;
  Accessory? _currentAccessory;

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
    List<Widget> columnWidgets = [
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
                      decoration: InputDecoration(labelText: "Pet Name"),
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
    ];

    if (_selectedIndex == -1) {
      _currentAccessory = null;
      columnWidgets.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                if (widget.pet.love.round() < 100.0) {
                  widget.pet.love += pettingAmount;
                  widget.pet.love = min(widget.pet.love, 100.0);
                  context.read<DataManager>().getUserData().then((UserData userData) {
                    if (userData.hearts >= pettingCost) {
                      userData.hearts -= pettingCost;
                      widget.pet.updateDocument(context);
                      userData.updateDocument(context);
                    } else {
                      print("not enough coins");
                    }
                  });
                }
              },
              child: Row(
                children: [
                  Text("Pet " + pettingCost.toString()),
                  Icon(heartsIcon, size: 20.0),
                ],
              ),
            ),
            SizedBox(width: 5.0),
            ElevatedButton(
              onPressed: () {
                if (widget.pet.food.round() < 100.0) {
                  widget.pet.food += feedingAmount;
                  widget.pet.food = min(widget.pet.food, 100.0);
                  context.read<DataManager>().getUserData().then((UserData userData) {
                    if (userData.hearts >= feedingCost) {
                      userData.hearts -= feedingCost;
                      widget.pet.updateDocument(context);
                      userData.updateDocument(context);
                    } else {
                      print("not enough coins");
                    }
                  });
                }
              },
              child: Row(
                children: [
                  Text("Feed " + feedingCost.toString()),
                  Icon(heartsIcon, size: 20.0),
                ],
              ),
            ),
            SizedBox(width: 5.0),
            ElevatedButton(
              onPressed: () {
                if (widget.pet.cleanliness.round() < 100.0) {
                  widget.pet.cleanliness += cleaningAmount;
                  widget.pet.cleanliness = min(widget.pet.cleanliness, 100.0);
                  context.read<DataManager>().getUserData().then((UserData userData) {
                    if (userData.hearts >= cleaningCost) {
                      userData.hearts -= cleaningCost;
                      widget.pet.updateDocument(context);
                      userData.updateDocument(context);
                    } else {
                      print("not enough coins");
                    }
                  });
                }
              },
              child: Row(
                children: [
                  Text("Clean " + cleaningCost.toString()),
                  Icon(heartsIcon, size: 20.0),
                ],
              ),
            ),
          ],
        ),
      );
      columnWidgets.add(buildStatBar("Love", widget.pet.love, 100));
      columnWidgets.add(buildStatBar("Food", widget.pet.food, 100));
      columnWidgets.add(buildStatBar("Cleanliness", widget.pet.cleanliness, 100));
    } else {
      _currentAccessory = widget.pet.accessories[_selectedIndex];
      columnWidgets.addAll(getEditMenuWidgets(context));
    }

    if (widget.pet.accessories.length > 0) {

      columnWidgets.add(Text("Accessories"));
      columnWidgets.add(
        PaddingListView(
          scrollBar: true,
          childCrossAxisSize: AccessoryWidget.height,
          scrollDirection: Axis.horizontal,
          itemCount: widget.pet.accessories.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (_currentAccessory != null) {
                    _currentAccessory!.updateDocument(context);
                  }
                  if (_selectedIndex == index) {
                    _selectedIndex = -1;
                  } else {
                    _selectedIndex = index;
                  }
                });
              },
              child: AccessoryWidget(accessory: widget.pet.accessories[index], color: (_selectedIndex == index) ? Theme.of(context).primaryColor : Theme.of(context).dividerColor),
            );
          },
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 10.0),
      child: OutlineBox(
        child: SingleChildScrollView(
          child: Column(
            children: columnWidgets,
          ),
        ),
      ),
    );
  }

  List<Widget> getEditMenuWidgets(BuildContext context) {
    return [
      Text("Editing: " + Constants.displayNameMap[_currentAccessory!.type]!),
      Slider(
        value: _currentAccessory!.xPos,
        min: -256,
        max: 256,
        onChanged: (double value) {
          setState(() {
            _currentAccessory!.xPos = value;
          });
        },
      ),
      Slider(
        value: _currentAccessory!.yPos,
        min: -256,
        max: 256,
        onChanged: (double value) {
          setState(() {
            _currentAccessory!.yPos = value;
          });
        },
      ),
      Slider(
        value: _currentAccessory!.size,
        min: 0,
        max: 1,
        onChanged: (double value) {
          setState(() {
            _currentAccessory!.size = value;
          });
        },
      ),
      Slider(
        value: _currentAccessory!.angle,
        min: -pi,
        max: pi,
        onChanged: (double value) {
          setState(() {
            _currentAccessory!.angle = value;
          });
        },
      ),
      ElevatedButton(
        onPressed: () {
          _currentAccessory!.updateDocument(context).then((_) => setState(() {
                _selectedIndex = -1;
              }));
        },
        child: Text("Done"),
      ),
    ];
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
              Text(value.toStringAsFixed(0) + " / " + maxValue.toStringAsFixed(0)),
            ],
          ),
          SizedBox(height: 5.0),
          LinearProgressIndicator(value: value / maxValue),
        ],
      ),
    );
  }
}

class PetWidgetMini extends StatelessWidget {
  static final double height = 130;
  final Pet pet;
  final Color color;

  PetWidgetMini({required this.pet, required this.color});

  @override
  Widget build(BuildContext context) {
    return OutlineBox(
      borderColor: color,
      child: Column(
        children: [
          Text(pet.name),
          SizedBox(height: 5.0),
          PetDisplay(size: Size(100, 100), pet: pet),
        ],
      ),
    );
  }
}
