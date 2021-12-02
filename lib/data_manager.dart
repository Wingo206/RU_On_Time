import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';

class DataManager {
  String uid;

  CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

  DocumentReference get userRef => usersCollection.doc(uid);

  CollectionReference get assignmentsCollection => usersCollection.doc(uid).collection('assignments');
  Stream<QuerySnapshot> get assignmentStream => assignmentsCollection.orderBy('due date', descending: false).snapshots();

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

class UserData {
  String name;
  String email;
  int hearts;
  int gems;
  int xp;
  String? documentID;

  UserData({
    required this.name,
    required this.email,
    required this.hearts,
    required this.gems,
    required this.xp,
    this.documentID,
  });

  UserData.fromJson(Map<String, Object?> json, String id)
      : this(
          name: json['name']! as String,
          email: json['email']! as String,
          hearts: json['hearts']! as int,
          gems: json['gems']! as int,
          xp: json['xp']! as int,
          documentID: id,
        );

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'email': email,
      'hearts': hearts,
      'gems': gems,
      'xp': xp,
    };
  }

  Future<void> updateDocument(BuildContext context) async {
    context.read<DataManager>().usersCollection.doc(documentID).update(toJson());
  }
}
