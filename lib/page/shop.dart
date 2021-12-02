import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ru_on_time/data_manager.dart';
import 'package:ru_on_time/page/pet_render.dart';
import 'package:provider/src/provider.dart';
import 'package:ru_on_time/page/pets.dart';

import '../data.dart';
import '../util_widgets.dart';

class ShopPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: ListView(
          children: [
            CurrencyDisplay(),
            SizedBox(height: 10.0),
            Center(
              child: Text("Your Accessories"),
            ),
            AccessoryMenu(),
            SizedBox(height: 10.0),
            Center(
              child: Text("Pet Shop"),
            ),
            PaddingListView(
              scrollBar: true,
              childCrossAxisSize: 180,
              scrollDirection: Axis.horizontal,
              itemCount: Constants.pets.length,
              itemBuilder: (BuildContext context, int index) {
                return PetShopWidget(Constants.pets[index], Constants.petPrices[index]);
              },
            ),
            SizedBox(height: 10.0),
            Center(
              child: Text("Accessory Shop"),
            ),
            PaddingListView(
              scrollBar: true,
              childCrossAxisSize: 180,
              scrollDirection: Axis.horizontal,
              itemCount: Constants.accessories.length,
              itemBuilder: (BuildContext context, int index) {
                return AccessoryShopWidget(Constants.accessories[index], Constants.accessoryPrices[index]);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PetShopWidget extends StatelessWidget {
  final String _type;
  final int _cost;

  PetShopWidget(this._type, this._cost);

  @override
  Widget build(BuildContext context) {
    Pet pet = Pet(type: _type, name: Constants.displayNameMap[_type]!, love: 50, food: 50, cleanliness: 50, startDate: DateTime.now(), lastUpdate: DateTime.now(), accessories: []);
    return OutlineBox(
      child: Column(
        children: [
          Text(
            Constants.displayNameMap[_type]!,
            style: TextStyle(fontSize: 20),
          ),
          PetDisplay(
            size: Size(100, 100),
            pet: pet,
          ),
          Spacer(),
          ElevatedButton(
            child: Row(
              children: [
                Text("Buy: " + _cost.toString()),
                Icon(gemsIcon, size: 20.0),
              ],
            ),
            onPressed: () {
              context.read<DataManager>().getUserData().then((UserData userData) {
                if (userData.gems >= _cost) {
                  userData.gems -= _cost;
                  context.read<DataManager>().petsCollection.add(pet.toJson());
                  userData.updateDocument(context);
                } else {
                  print("not enough coins");
                }
              });
            },
          ),
        ],
      ),
    );
  }
}

class AccessoryShopWidget extends StatelessWidget {
  final String _type;
  final int _cost;

  AccessoryShopWidget(this._type, this._cost);

  @override
  Widget build(BuildContext context) {
    Accessory accessory = Accessory(type: _type, date: DateTime.now(), petId: "", xPos: 0, yPos: 0, angle: 0, size: 0.5);
    return OutlineBox(
      child: Column(
        children: [
          Text(
            Constants.displayNameMap[_type]!,
            style: TextStyle(fontSize: 20),
          ),
          AccessoryDisplay(
            size: Size(100, 100),
            accessory: accessory,
          ),
          Spacer(),
          ElevatedButton(
            child: Row(
              children: [
                Text("Buy: " + _cost.toString()),
                Icon(gemsIcon, size: 20.0),
              ],
            ),
            onPressed: () {
              context.read<DataManager>().getUserData().then((UserData userData) {
                if (userData.gems >= _cost) {
                  userData.gems -= _cost;
                  context.read<DataManager>().accessoriesCollection.add(accessory.toJson());
                  userData.updateDocument(context);
                } else {
                  print("not enough coins");
                }
              });
            },
          ),
        ],
      ),
    );
  }
}

class AccessoryMenu extends StatefulWidget {
  @override
  _AccessoryMenuState createState() => _AccessoryMenuState();
}

class _AccessoryMenuState extends State<AccessoryMenu> {
  int _selectedIndex = -1;
  List<Accessory> _accessories = [];
  List<Pet> _pets = [];

  @override
  Widget build(BuildContext context) {
    DataManager dataManager = context.read<DataManager>();
    return FutureBuilder<QuerySnapshot>(
      future: dataManager.petsCollection.orderBy('start date', descending: false).get(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong 1');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
        } else {
          return FutureBuilder<List<Pet>>(
            future: createPetList(dataManager, snapshot.data!),
            builder: (BuildContext context, AsyncSnapshot<List<Pet>> pets) {
              if (pets.hasError) {
                return Text('Something went wrong 2');
              }
              if (pets.connectionState == ConnectionState.waiting) {
              } else {
                _pets = pets.data ?? [];
              }
              return StreamBuilder<QuerySnapshot>(
                stream: dataManager.accessoriesStream,
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong 3');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                  } else {
                    _accessories = snapshot.data!.docs.map((DocumentSnapshot document) => Accessory.fromJson(document.data()! as Map<String, dynamic>, document.id)).toList();
                  }
                  return buildDisplay(context);
                },
              );
            },
          );
        }
        return buildDisplay(context);
      },
    );
  }

  Widget buildDisplay(BuildContext context) {
    List<Widget> columnWidgets = [];

    if (_selectedIndex == -1) {
      columnWidgets.add(
        PaddingListView(
          scrollBar: true,
          childCrossAxisSize: AccessoryWidget.height,
          scrollDirection: Axis.horizontal,
          itemCount: _accessories.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (_selectedIndex == index) {
                    _selectedIndex = -1;
                  } else {
                    _selectedIndex = index;
                  }
                });
              },
              child: AccessoryWidget(
                accessory: _accessories[index],
              ),
            );
          },
        ),
      );
    } else {
      if (_pets.length == 0) {
        columnWidgets.add(CircularProgressIndicator());
      } else {
        columnWidgets.add(
          PaddingListView(
            scrollBar: true,
            childCrossAxisSize: PetWidgetMini.height,
            scrollDirection: Axis.horizontal,
            itemCount: _pets.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    Accessory a = _accessories[_selectedIndex];
                    Pet selected = _pets[index];
                    if (a.petId == selected.documentId) {
                      //take the accessory off
                      a.petId = "";
                      selected.accessories.remove(getAccessoryWithId(selected.accessories, a.documentId!));
                    } else {
                      if (a.petId != "") {
                        //accessory is applied to a different pet
                        Pet old = getPetWithId(_pets, a.petId)!;
                        old.accessories.remove(getAccessoryWithId(old.accessories, a.documentId!));
                        old.updateDocument(context);
                      }
                      a.petId = selected.documentId!;
                      selected.accessories.add(a);
                    }

                    a.updateDocument(context).then((_) {
                      selected.updateDocument(context).then((_) {
                        setState(() {
                          _selectedIndex = -1;
                        });
                      });
                    });
                  });
                },
                child: PetWidgetMini(
                  pet: _pets[index],
                  color: (_pets[index].documentId == _accessories[_selectedIndex].petId) ? Theme.of(context).primaryColor : Theme.of(context).dividerColor,
                ),
              );
            },
          ),
        );
      }
      columnWidgets.add(
        ElevatedButton(
          child: Text("Cancel"),
          onPressed: () {
            setState(() {
              _selectedIndex = -1;
            });
          },
        ),
      );
    }

    return Column(
      children: columnWidgets,
    );
  }

  Pet? getPetWithId(List<Pet> pets, String id) {
    for (int i = 0; i < pets.length; i++) {
      if (pets[i].documentId == id) {
        return pets[i];
      }
    }
    return null;
  }

  Accessory? getAccessoryWithId(List<Accessory> accessories, String id) {
    for (int i = 0; i < accessories.length; i++) {
      if (accessories[i].documentId == id) {
        return accessories[i];
      }
    }
    return null;
  }
}
