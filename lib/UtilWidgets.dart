import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/src/provider.dart';

import '../data_manager.dart';

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
    return OutlineBox(
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
    );
  }
}

class OutlineBox extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  OutlineBox({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 2.0, color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(10.0),
        child: child,
      ),
    );
  }
}

class PaddingListView extends StatelessWidget {
  final int itemCount;
  final Function itemBuilder;
  final Axis scrollDirection;

  PaddingListView({required this.itemCount, required this.itemBuilder, this.scrollDirection = Axis.vertical});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: scrollDirection,
      physics: BouncingScrollPhysics(),
      itemCount: itemCount + 2,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0 || index == itemCount + 1) {
          return SizedBox();
        } else {
          return itemBuilder(context, index - 1);
        }
      },
      separatorBuilder: (BuildContext context, int index) => SizedBox(width: 10.0),
    );
  }
}