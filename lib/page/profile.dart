import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:ru_on_time/authentication_service.dart';
import 'package:ru_on_time/page/pets.dart';

import '../data.dart';
import '../util_widgets.dart';
import '../data_manager.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserData? _userData;
  bool _editingName = false;

  @override
  Widget build(BuildContext context) {
    DataManager dataManager = context.read<DataManager>();
    return StreamBuilder<DocumentSnapshot>(
      stream: DataManager.usersCollection.doc(dataManager.uid).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }
        if (snapshot.hasData && !snapshot.data!.exists) {
          return Text("Document does not exist");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          if (_userData == null) {
            return CircularProgressIndicator();
          }
          return buildDisplay(context);
        }
        _userData = UserData.fromJson(snapshot.data!.data()! as Map<String, dynamic>, dataManager.uid);
        return buildDisplay(context);
      },
    );
  }

  Widget buildDisplay(BuildContext context) {
    DataManager dataManager = context.read<DataManager>();
    TextEditingController usernameController = TextEditingController(text: _userData!.name);
    return Scaffold(
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          Padding(
            padding: EdgeInsets.all(10.0),
            child: CurrencyDisplay(),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  (_editingName)
                      ? IconButton(
                          onPressed: () {
                            setState(() {
                              _editingName = false;
                            });
                          },
                          icon: Icon(Icons.cancel_outlined),
                        )
                      : SizedBox(width: 48.0),
                  (_editingName)
                      ? Padding(
                          padding: EdgeInsets.only(bottom: 5.0),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width - 20 - 48 - 48,
                            child: TextField(
                              controller: usernameController,
                              decoration: InputDecoration(
                                labelText: "Username",
                              ),
                            ),
                          ),
                        )
                      : Expanded(
                          child: Text(
                            _userData!.name,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                            textAlign: TextAlign.center,
                          ),
                        ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (_editingName) {
                          _editingName = false;
                          if (_userData!.name != usernameController.text.trim()) {
                            _userData!.name = usernameController.text.trim();
                            _userData!.updateDocument(context);
                          }
                        } else {
                          _editingName = true;
                        }
                      });
                    },
                    icon: Icon((_editingName) ? Icons.check : Icons.edit),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                _userData!.email,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          FavoritePetWidget(_userData!),
          buildButton(context, (_userData!.xp / 100).floor().toString(), "Level:"),
          buildStatBar("XP", (_userData!.xp.round() % 100), 100),
          buildButton(context, _userData!.completed.toString(), "Assignments Completed:"),
          buildButton(context, _userData!.heartsTotal.toString(), "Total Hearts Earned:"),
          buildButton(context, _userData!.gemsTotal.toString(), "Total Gems Earned:"),
          Padding(
            padding: EdgeInsets.only(left: 10.0, right: 10.0),
            child: ElevatedButton(
              onPressed: () {
                context.read<AuthenticationService>().signOut();
              },
              child: Text("Sign Out"),
            ),
          ),
        ],
      ),
    );
  }
  Widget buildButton(BuildContext context, String value, String text) {
    return MaterialButton(
      padding: EdgeInsets.all(10.0),
      onPressed: () {},
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(text, style: TextStyle(fontSize: 20)),
          Spacer(),
          Text(value, style: TextStyle(fontSize: 20)),
        ],
      ),
    );
  }
}

Widget buildStatBar(String name, double value, double maxValue) {
  return Padding(
    padding: EdgeInsets.only(left: 10.0, right: 10.0),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name),
            Text(value.toStringAsFixed(0) + " / " + maxValue.toStringAsFixed(0)),
          ],
        ),
        SizedBox(height: 5.0),
        LinearProgressIndicator(minHeight: 30, value: value / maxValue),
      ],
    ),
  );
}
