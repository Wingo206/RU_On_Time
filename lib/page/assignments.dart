import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';

import '../data_manager.dart';

class AssignmentsPage extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text('Assignments', style: TextStyle(fontSize: 60)),
          AssignmentList(),
        ],
      ),
    );
  }
}


class AssignmentList extends StatelessWidget {
  AssignmentList();
  @override
  Widget build(BuildContext context) {
    DataManager _dataManager = context.read<DataManager>();
    QueryDocumentSnapshot doc = _dataManager.userData;
    return Column(
        children:[
          ElevatedButton(
            onPressed: () {
              print("lmao I dont do anything right now");
            },
            child: Text("New Assignment"),
          ),
          StreamBuilder<QuerySnapshot>(
              stream: _dataManager.assignmentStream,
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text("Loading");
                }
                return SizedBox(
                  height:200.0,
                  child:ListView(
                    itemExtent: 80,
                    children: snapshot.data!.docs.map((DocumentSnapshot document) => buildListItem(context, document)).toList(),
                  ),
                );
              }
          ),
        ]
    );
  }

  Widget buildListItem(BuildContext context, DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    return ListTile(
      title: Text(data['name']),
      subtitle: Text(data['due date']),
    );
  }
}