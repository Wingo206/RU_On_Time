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
        child: Column(
          children: [
            CurrencyDisplay(),
            Text('Shop', style: TextStyle(fontSize: 60)),
            ElevatedButton(
              onPressed: () {
                context.read<DataManager>().petsCollection.add(
                      Pet(type: "cat", name: "Binky", love: 30, food: 20, cleanliness: 60, startDate: DateTime.now(), lastUpdate: DateTime.now(), accessories: <Accessory>[]).toJson(),
                    );
              },
              child: Text("Debug Button Add Pet"),
            ),
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
              height: 350,
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
                      PetShopWidget('cat', 10),
                      PetShopWidget('dog', 10),
                      PetShopWidget('dragon', 20),
                      PetShopWidget('penguin', 20),
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
  String _type;
  int _cost;

  PetShopWidget(this._type, this._cost);

  @override
  Widget build(BuildContext context) {
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
              Text(ImageData.displayNameMap[_type]!),
              PetDisplay(
                size: Size(200, 200),
                pet: Pet(type: _type, name: ImageData.displayNameMap[_type]!, love: 30, food: 20, cleanliness: 60, startDate: DateTime.now(), lastUpdate: DateTime.now(), accessories: []),
              ),
              ElevatedButton(
                child: Row(
                  children: [
                    Text("Purchase: " + _cost.toString()),
                    Icon(gemsIcon, size: 20.0),
                  ],
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
