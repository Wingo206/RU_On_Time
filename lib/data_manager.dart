import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DataManager {
  String uid;

  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  DocumentReference get userRef => usersCollection.doc(uid);

  CollectionReference get assignmentCollection =>
      usersCollection.doc(uid).collection('assignments');

  Stream<QuerySnapshot> get assignmentStream =>
      assignmentCollection.orderBy('due date', descending: false).snapshots();

  DataManager(this.uid);

  static Future<DataManager> create(FirebaseAuth _firebaseAuth) async {
    //need separate constructor to make it async
    String uid = _firebaseAuth.currentUser!.uid;

    DataManager manager = DataManager(uid);

    await manager.userRef.get().then((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
      } else {
        manager.userRef.set(
          UserInfo(
            name: "unset",
            email: _firebaseAuth.currentUser!.email!,
            coins: 0,
            gems: 0,
            xp: 0,
          ).toJson(),
        );
      }
    });

    return manager;
  }

  Future<UserInfo> getUserInfo() {
    return userRef.get().then(
      (DocumentSnapshot snapshot) {
        return UserInfo.fromJson(snapshot.data()! as Map<String, dynamic>, uid);
      },
    );
  }
}

class UserInfo {
  final String name;
  final String email;
  final int coins;
  final int gems;
  final int xp;
  String? documentID;

  UserInfo({
    required this.name,
    required this.email,
    required this.coins,
    required this.gems,
    required this.xp,
    this.documentID,
  });

  UserInfo.fromJson(Map<String, Object?> json, String id)
      : this(
          name: json['name']! as String,
          email: json['email']! as String,
          coins: json['coins']! as int,
          gems: json['gems']! as int,
          xp: json['xp']! as int,
          documentID: id,
        );

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'email': email,
      'coins': coins,
      'gems': gems,
      'xp': xp,
    };
  }
}
