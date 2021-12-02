import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:ru_on_time/authentication_service.dart';
import 'package:ru_on_time/page/pets.dart';

import '../data_manager.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserData? _userData;

  @override
  Widget build(BuildContext context) {
    DataManager dataManager = context.read<DataManager>();
    return StreamBuilder<DocumentSnapshot>(
      stream: dataManager.usersCollection.doc(dataManager.uid).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }
        if (snapshot.hasData && !snapshot.data!.exists) {
          return Text("Document does not exist");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          if (_userData == null) {
            return Text("Loading");
          }
          return buildDisplay(context);
        }
        _userData = UserData.fromJson(snapshot.data!.data()! as Map<String, dynamic>, dataManager.uid);
        return buildDisplay(context);
      },
    );

  }

  Widget buildDisplay(BuildContext context) {
    return Scaffold(
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          NumbersWidget(),
          ProfileWidget(
            userImagePath: 'https://images.squarespace-cdn.com/content/v1/551c36e1e4b072084065ac42/1551130460935-CKV711P68O4F5XCJ0161/IMG_34391.jpg',
            onClicked: () async {},
          ),
          const SizedBox(height: 24),
          buildName(_userData!),
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

  Widget buildName(UserData userData) => Column(
        children: [
          Text(
            userData.name,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            userData.email,
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

IconData heartsIcon = Icons.favorite_border;
IconData gemsIcon = Icons.sports_soccer_rounded;
class CurrencyDisplay extends StatefulWidget {

  @override
  _CurrencyDisplayState createState() => _CurrencyDisplayState();
}

class _CurrencyDisplayState extends State<CurrencyDisplay> {
  int hearts = 0;
  int gems = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(context.read<DataManager>().uid).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }
        if (snapshot.hasData && !snapshot.data!.exists) {
          return Text("Document does not exist");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return buildDisplay(context);
        }
        Map<String, dynamic> data = snapshot.data!.data()! as Map<String, dynamic>;
        hearts = data['hearts'] as int;
        gems = data['gems'] as int;
        return buildDisplay(context);
      },
    );
  }

  Widget buildDisplay(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 2.0, color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Icon(heartsIcon, size: 30.0),
                Text("Hearts: " + hearts.toString()),
              ],
            ),
            Column(
              children: [
                Icon(gemsIcon, size: 30.0),
                Text("Gems: " + gems.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
