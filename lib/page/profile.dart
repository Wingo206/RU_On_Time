import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:ru_on_time/page/pets.dart';

import '../authentication_service.dart';
import '../data_manager.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final profile = UserPreferences.myProfile;
    return Scaffold(
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          NumbersWidget(),
          ProfileWidget(
            userImagePath: profile.userImagePath,
            onClicked: () async {},
          ),
          const SizedBox(height: 24),
          buildName(profile),
          buildStatBar("Level", 20, 100),
          MoreNumbersWidget(),
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

  Widget buildName(Profile profile) => Column(
        children: [
          Text(
            profile.name,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            profile.email,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      );
}

class Profile {
  final String userImagePath;
  final String name;
  final String email;
  final String petImagePath;

  const Profile({
    required this.userImagePath,
    required this.name,
    required this.email,
    required this.petImagePath,
  });
}

class UserPreferences {
  static const myProfile = Profile(
    userImagePath: 'https://images.squarespace-cdn.com/content/v1/551c36e1e4b072084065ac42/1551130460935-CKV711P68O4F5XCJ0161/IMG_34391.jpg',
    name: 'Hazem Zaky',
    email: 'hgz5@scarletmail.rutgers.edu',
    petImagePath: '',
  );
}

class ProfileWidget extends StatelessWidget {
  final String userImagePath;
  final VoidCallback onClicked;

  const ProfileWidget({
    Key? key,
    required this.userImagePath,
    required this.onClicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Center(
      child: buildImage(),
    );
  }

  Widget buildImage() {
    final userImage = NetworkImage(userImagePath);

    return ClipOval(
      child: Material(
        color: Colors.transparent,
        child: Ink.image(
          image: userImage,
          fit: BoxFit.cover,
          width: 256,
          height: 256,
          child: InkWell(onTap: onClicked),
        ),
      ),
    );
  }
}

class NumbersWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(children: [
              CurrencyDisplay(),
            ])));
  }

  Widget buildDivider() => VerticalDivider();

  Widget buildButton(BuildContext context, String value, String text) => MaterialButton(
        padding: EdgeInsets.all(20.0),
        onPressed: () {},
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
            SizedBox(height: 2),
            Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
          ],
        ),
      );
}

class MoreNumbersWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          buildButton(context, '5', 'Completed'),
          buildDivider(),
          buildButton(context, '1', 'To Do'),
        ],
      );

  Widget buildDivider() => VerticalDivider();

  Widget buildButton(BuildContext context, String value, String text) => MaterialButton(
        padding: EdgeInsets.all(20.0),
        onPressed: () {},
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
            SizedBox(height: 2),
            Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
          ],
        ),
      );
}

Widget buildStatBar(String name, double value, double maxValue) {
  return Padding(
    padding: EdgeInsets.all(10.0),
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
        LinearProgressIndicator(minHeight: 30, value: value / maxValue),
      ],
    ),
  );
}
