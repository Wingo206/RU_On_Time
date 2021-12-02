import 'package:flutter/material.dart';
import 'package:ru_on_time/data_manager.dart';
import 'package:ru_on_time/page/pet_render.dart';
import 'package:provider/src/provider.dart';

import '../UtilWidgets.dart';

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
            Text("Accessory Shop"),
            SizedBox(
              height: 240,
              child: OutlineBox(
                padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: PaddingListView(
                  scrollDirection: Axis.horizontal,
                  itemCount: Constants.pets.length,
                  itemBuilder: (BuildContext context, int index) {
                    return PetShopWidget(Constants.pets[index], Constants.petPrices[index]);
                  },
                ),
              ),
            ),
            SizedBox(height: 10.0),
            Text("Accessory Shop"),
            SizedBox(
              height: 240,
              child: OutlineBox(
                padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: PaddingListView(
                  scrollDirection: Axis.horizontal,
                  itemCount: Constants.accessories.length,
                  itemBuilder: (BuildContext context, int index) {
                    return AccessoryShopWidget(Constants.accessories[index], Constants.accessoryPrices[index]);
                  },
                ),
              ),
            ),
            SizedBox(height: 10.0),
            Text("Your Accessories"),
            SizedBox(
              height: 240,
              child: OutlineBox(
                padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: PaddingListView(
                  scrollDirection: Axis.horizontal,
                  itemCount: Constants.accessories.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Text("insert accessory here");
                  },
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

/*
class AccessoryMenu extends StatefulWidget {
  @override
  _AccessoryMenuState createState() => _AccessoryMenuState();
}

class _AccessoryMenuState extends State<AccessoryMenu> {

}
*/
