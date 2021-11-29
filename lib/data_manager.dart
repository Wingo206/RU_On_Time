import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ru_on_time/page/assignments.dart';

class DataManager {
  QueryDocumentSnapshot userData;
  CollectionReference get assignmentCollection => FirebaseFirestore.instance.collection('users').doc(userData.id).collection('assignments');
  Stream<QuerySnapshot> get assignmentStream => assignmentCollection.snapshots();
  /*Stream<QuerySnapshot<Assignment>> get assignmentStreamConv => FirebaseFirestore.instance.collection('users').doc(userData.id).collection('assignments')
      .withConverter<Assignment>(
        fromFirestore: (snapshot, _) => Assignment.fromJson(snapshot.data()!),
        toFirestore: (assignment, _) => assignment.toJson(),
      ).snapshots();*/


  DataManager(this.userData);

  static Future<DataManager> create(FirebaseAuth _firebaseAuth) async {
    //need separate constructor to make it async
    String uid = _firebaseAuth.currentUser!.uid;
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    Query filteredQuery = users.where('uid', isEqualTo:uid).limit(1);
    QuerySnapshot queryResults = await filteredQuery.get();
    List<QueryDocumentSnapshot> docs = queryResults.docs;
    //can be no documents found? make a hasError thing and call it in the FutureBuiler
    //when the DataManager is being created

    QueryDocumentSnapshot userData = docs[0];

    DataManager manager = DataManager(userData);
    return manager;
  }



}