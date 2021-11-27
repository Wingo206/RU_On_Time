import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';

import '../authentication_service.dart';
import '../data_manager.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DataManager _dataManager = context.read<DataManager>();
    QueryDocumentSnapshot doc = _dataManager.userData;
    return Center(
      child: Column(
        children: [
          Text('Profile', style: TextStyle(fontSize: 60)),
          Text("Document ID:" + doc.id),
          Text("username: " + doc.get('username')),
          Text("level: " + doc.get('level')),
          ElevatedButton(
            onPressed: () {
              context.read<AuthenticationService>().signOut();
            },
            child: Text("JANKY SIGN OUT BUTTON"),
          ),
        ],
      ),
    );
  }
}
