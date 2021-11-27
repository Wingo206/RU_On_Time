import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class DataManager {
  final FirebaseAuth _firebaseAuth;
  QueryDocumentSnapshot userData;
  DataManager(this._firebaseAuth, this.userData);

  static Future<DataManager> create(FirebaseAuth _firebaseAuth) async {
    String uid = _firebaseAuth.currentUser!.uid;
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    Query filteredQuery = users.where('uid', isEqualTo:uid).limit(1);
    QuerySnapshot queryResults = await filteredQuery.get();
    List<QueryDocumentSnapshot> docs = queryResults.docs;
    //can be no documents found? make a hasError thing and call it in the FutureBuiler
    //when the DataManager is being created
    QueryDocumentSnapshot userData = docs[0];

    DataManager manager = DataManager(_firebaseAuth, userData);
    return manager;
  }



}