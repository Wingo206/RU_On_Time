import 'package:flutter/material.dart';
import 'package:ru_on_time/data_manager.dart';
import 'package:ru_on_time/page/pet_render.dart';
import 'package:ru_on_time/page/pets.dart';
import 'package:provider/src/provider.dart';
import 'package:ru_on_time/page/profile.dart';

class ShopPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: ListView(
          children: [
            CurrencyDisplay(),
            ElevatedButton(
              onPressed: () {
                context.read<DataManager>().accessoriesCollection.add(Accessory(
                      type: "top_hat",
                      date: DateTime.now(),
                      inUse: false,
                      xPos: 0,
                      yPos: 0,
                      angle: 0,
                      size: 1,
                    ).toJson());
              },
              child: Text("Debug Button Add accessory"),
            ),
            SizedBox(
              height: 240,
              child: Padding(
                padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 2.0, color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      SizedBox(width: 10.0),
                      PetShopWidget('cat', 100),
                      PetShopWidget('dog', 100),
                      PetShopWidget('dragon', 200),
                      PetShopWidget('penguin', 200),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 240,
              child: Padding(
                padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 2.0, color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      SizedBox(width: 10.0),
                      AccessoryShopWidget("bandana", 10),
                      AccessoryShopWidget("bowtie", 10),
                      AccessoryShopWidget("collar", 10),
                      AccessoryShopWidget("flower_crown", 10),
                      AccessoryShopWidget("santa_hat", 10),
                      AccessoryShopWidget("top_hat", 10),
                    ],
                  ),
                ),
              ),
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
    Pet pet = Pet(type: _type, name: ImageData.displayNameMap[_type]!, love: 50, food: 50, cleanliness: 50, startDate: DateTime.now(), lastUpdate: DateTime.now(), accessories: []);
    return Padding(
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0, right: 10.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 2.0, color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [
              Text(
                ImageData.displayNameMap[_type]!,
                style: TextStyle(fontSize: 20),
              ),
              PetDisplay(
                size: Size(100, 100),
                pet: pet,
              ),
              ElevatedButton(
                child: Row(
                  children: [
                    Text("Adopt: " + _cost.toString()),
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
        ),
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
    Accessory accessory = Accessory(type: _type, date: DateTime.now(), inUse: false, xPos: 0, yPos: 0, angle: 0, size: 0.5);
    return Padding(
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0, right: 10.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 2.0, color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [
              Text(
                ImageData.displayNameMap[_type]!,
                style: TextStyle(fontSize: 20),
              ),
              AccessoryDisplay(
                size: Size(100, 100),
                accessory: accessory,
              ),
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
        ),
      ),
    );
  }
}

class AccessoryMenu extends StatefulWidget {
  @override
  _AccessoryMenuState createState() => _AccessoryMenuState();
}

class _AccessoryMenuState extends State<AccessoryMenu> {

}