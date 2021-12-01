import 'package:flutter/material.dart';
import 'package:ru_on_time/data_manager.dart';
import 'package:ru_on_time/page/pets.dart';
import 'package:provider/src/provider.dart';

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
                      Pet(type: "cat", name: "Binky", love: 30, food: 20, cleanliness: 60, startDate: DateTime.now(), lastUpdate: DateTime.now(), accessories:<Accessory>[]).toJson(),
                    );
              },
              child: Text("Debug Button Add Pet"),
            ),
          ],
        ),
      ),
    );
  }
}
