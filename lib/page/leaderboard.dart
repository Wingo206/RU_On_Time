import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ru_on_time/page/pets.dart';
import 'package:ru_on_time/util_widgets.dart';
import 'package:intl/intl.dart';

import '../data.dart';
import '../data_manager.dart';

class LeaderboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          FutureBuilder<QuerySnapshot>(
            future: DataManager.usersQuery.get(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text("Something went wrong");
              }
              if (snapshot.connectionState == ConnectionState.done) {
                List<Widget> widgets = snapshot.data!.docs.map((DocumentSnapshot document) {
                  return LeaderboardWidget(UserData.fromJson((document.data()! as Map<String, dynamic>), document.id));
                }).toList();
                return Expanded(
                  child: PaddingListView(
                    itemCount: widgets.length,
                    itemBuilder: (BuildContext context, int index) {
                      return widgets[index];
                    },
                  ),
                );
              }
              return CenteredLoading();
            },
          ),
        ],
      ),
    );
  }
}

class LeaderboardWidget extends StatelessWidget {
  final UserData _userData;

  LeaderboardWidget(this._userData);

  @override
  Widget build(BuildContext context) {
    return OutlineBox(
      child: Row(
        children: [
          SizedBox(
            width: 100 + 20,
            height: PetWidgetMini.height + 20,
            child: FavoritePetWidget(_userData),
          ),
          SizedBox(width: 10.0),
          Expanded(
            child: OutlineBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _userData.name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  Text("Level " + (_userData.xp / 100).floor().toString()),
                  Text("Completed " + _userData.completed.toString()),
                  Text("Joined " + DateFormat('MMM d, y').format(_userData.startDate))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
