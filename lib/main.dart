import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ru_on_time/sign_in.dart';

import 'authentication_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _fbApp = Firebase.initializeApp();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthenticationService> (
          create: (_) => AuthenticationService(FirebaseAuth.instance),
        ),

        StreamProvider(
          create: (context) => context.read<AuthenticationService>().authStateChanges,
          initialData: null,
        ),
      ],
      child: MaterialApp(
        title: 'RU On Time',
        theme: ThemeData(
          primarySwatch: Colors.red,
        ),
        home: FutureBuilder(
          future:_fbApp,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print ('Failed to initialize Firebase ${snapshot.error.toString()}');
              return Text('Something went wrong!');
            } else if (snapshot.hasData) {
              return AuthenticationWrapper();
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        )
      )
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();
    if(firebaseUser != null) {
      return MyHomePage(title: 'RU On Time Home Page');
    } else {
      return SignInPage();
    }
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final screens = [
    Center(child: Text('Calendar', style: TextStyle(fontSize: 60))),
    Center(child: Text('Assignments', style: TextStyle(fontSize: 60))),
    Center(child: Text('Leaderboard', style: TextStyle(fontSize: 60))),
  ];

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    int currentIndex = 0;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'The image of the pet goes here',
            ),
            TextButton(
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  overlayColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.hovered))
                        return Colors.redAccent;
                      if (states.contains(MaterialState.focused) ||
                          states.contains(MaterialState.pressed))
                        return Colors.white.withOpacity(0.1);
                      return null; // Defer to the widget's default.
                    },
                  ),
                ),
                onPressed: () {},
                child: Text('Add Assignment')),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            ElevatedButton(
                onPressed: () {
                  context.read<AuthenticationService>().signOut();
                },
                child: Text("JANKY SIGN OUT BUTTON")
            ),
            AssignmentList(FirebaseAuth.instance),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        iconSize: 50,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_rounded),
            label: 'Calendar',
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_rounded),
            label: 'Submissions',
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard_rounded),
            label: 'Leaderboard',
            backgroundColor: Colors.blue,
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

class AssignmentList extends StatelessWidget {
  final FirebaseAuth _firebaseAuth;
  AssignmentList(this._firebaseAuth);
  @override
  Widget build(BuildContext context) {
    String uid = _firebaseAuth.currentUser!.uid;
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    Query filteredQuery = users.where('uid', isEqualTo:uid).limit(1);
    return FutureBuilder<QuerySnapshot>(
      future: filteredQuery.get(),
      builder:
        (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }
        if (snapshot.hasData && snapshot.data!.docs.length == 0) {
          return Text("No Documents found for current uid");
        }
        if (snapshot.connectionState == ConnectionState.done) {
          List<QueryDocumentSnapshot> docs = snapshot.data!.docs;
          QueryDocumentSnapshot doc = docs[0];
          Stream<QuerySnapshot> assignmentStream = FirebaseFirestore.instance.collection('users').doc(doc.id).collection('assignments').snapshots();
         return Column(
             children:[
               Text(doc.id + ", username: " + doc.get('username') + ", level: " + doc.get('level')),
                Text("Assignment list:"),
                StreamBuilder<QuerySnapshot>(
                  stream: assignmentStream,
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
          return Text("Loading...");
      },
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