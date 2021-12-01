import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ru_on_time/page/assignments.dart';
import 'package:ru_on_time/page/calendar.dart';
import 'package:ru_on_time/page/leaderboard.dart';
import 'package:ru_on_time/page/pets.dart';
import 'package:ru_on_time/page/profile.dart';
import 'package:ru_on_time/page/shop.dart';
import 'package:ru_on_time/sign_in.dart';

import 'authentication_service.dart';
import 'data_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _fbApp = Firebase.initializeApp();

  MyApp() {
    PetData.loadPetData();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthenticationService>(
          create: (_) => AuthenticationService(FirebaseAuth.instance),
        ),
        StreamProvider(
          create: (context) =>
              context.read<AuthenticationService>().authStateChanges,
          initialData: null,
        ),
      ],
      child: MaterialApp(
        title: 'RU On Time',
        theme: ThemeData(
          primarySwatch: Colors.red,
        ),
        home: FutureBuilder(
          future: _fbApp,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print(
                  'Failed to initialize Firebase ${snapshot.error.toString()}');
              return Text('Something went wrong!');
            } else if (snapshot.hasData) {
              return AuthenticationWrapper();
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();
    if (firebaseUser != null) {
      Future<DataManager> _dataManager =
          DataManager.create(FirebaseAuth.instance);

      return FutureBuilder<DataManager>(
        future: _dataManager,
        builder: (BuildContext context, AsyncSnapshot<DataManager> snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong");
          }
          //if (snapshot.hasData && snapshot.data!.userData == null) {
          //  return Text("Failed to fetch user data");
          //}
          if (snapshot.connectionState == ConnectionState.done) {
            return Provider<DataManager>(
              /*The provider adds the instance of the Data Manager to the context,
              so anything within the context of the provider (The home page) can
              access the Data Manager by doing context.read<DataManager>(), like
              in the AssignmentsPage's build method.*/
              create: (_) => snapshot.data!,
              child: MyHomePage(),
            );
          }
          return Text("Loading...");
        },
      );
    } else {
      return SignInPage();
    }
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentIndex = 0;
  final screens = [
    ProfilePage(),
    ShopPage(),
    PetsPage(),
    CalendarPage(),
    AssignmentsPage(),
    LeaderboardPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("RU On Time"),
      ),
      body: SafeArea(
        child: Center(
          child: screens[currentIndex],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        iconSize: 50,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Shop',
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.house_outlined),
            label: 'Pets',
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_rounded),
            label: 'Calendar',
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_rounded),
            label: 'Assign',
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard_rounded),
            label: 'Leaderboard',
            backgroundColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}

Widget buildStatBar(String name, double value, double maxValue) {
  return Padding(
    padding: EdgeInsets.all(5.0),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name),
            Text(value.toString() + " / " + maxValue.toString()),
          ],
        ),
        SizedBox(height: 5.0),
        LinearProgressIndicator(value: value / maxValue),
      ],
    ),
  );
}
