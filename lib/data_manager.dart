import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'data.dart';

class DataManager {
  String uid;

  CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

  DocumentReference get userRef => usersCollection.doc(uid);

  CollectionReference get assignmentsCollection => usersCollection.doc(uid).collection('assignments');
  Stream<QuerySnapshot> get assignmentStreamAll => assignmentsCollection.orderBy('due date', descending: false).snapshots();
  Stream<QuerySnapshot> get assignmentStreamIncomplete => assignmentsCollection.where('completed', isEqualTo: false).orderBy('due date', descending: false).snapshots();
  Stream<QuerySnapshot> get assignmentStreamCompleted => assignmentsCollection.where('completed', isEqualTo: true).orderBy('due date', descending: false).snapshots();

  CollectionReference get petsCollection => usersCollection.doc(uid).collection('pets');
  Stream<QuerySnapshot> get petStream => petsCollection.orderBy('start date', descending: false).snapshots();

  CollectionReference get accessoriesCollection => usersCollection.doc(uid).collection('accessories');
  Stream<QuerySnapshot> get accessoriesStream => accessoriesCollection.orderBy('date', descending: false).snapshots();

  DataManager(this.uid);

  static Future<DataManager> create(FirebaseAuth _firebaseAuth) async {
    //need separate constructor to make it async
    String uid = _firebaseAuth.currentUser!.uid;

    DataManager manager = DataManager(uid);

    await manager.userRef.get().then((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
      } else {
        manager.userRef.set(
          UserData(
            name: "Default Username",
            email: _firebaseAuth.currentUser!.email!,
            hearts: 0,
            gems: 0,
            xp: 0,
          ).toJson(),
        );
      }
    });
    return manager;
  }

  Future<UserData> getUserData() {
    return userRef.get().then(
      (DocumentSnapshot snapshot) {
        return UserData.fromJson(snapshot.data()! as Map<String, dynamic>, uid);
      },
    );
  }
}
