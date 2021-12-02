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

class LoadingScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class CenteredLoading extends StatelessWidget {
  @override
  Widget build (BuildContext context) {
    return Expanded(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class OutlineBox extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? borderColor;

  OutlineBox({required this.child, this.padding, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 2.0, color: borderColor ?? Theme.of(context).dividerColor),
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
  static final double scrollPadding = 20;
  static final double itemPadding = 10;
  final int itemCount;
  final Function itemBuilder;
  final Axis scrollDirection;
  final bool scrollBar;
  final double childCrossAxisSize;

  PaddingListView({required this.itemCount, required this.itemBuilder, this.scrollDirection = Axis.vertical, this.scrollBar = false, this.childCrossAxisSize = 0});

  @override
  Widget build(BuildContext context) {
    Widget w = ListView.separated(
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
      separatorBuilder: (BuildContext context, int index) => (scrollDirection == Axis.vertical) ? SizedBox(height: itemPadding) : SizedBox(width: itemPadding),
    );
    Widget w2 = w;
    if (scrollBar) {
      w2 = Scrollbar(
        child: Padding(
          padding: (scrollDirection == Axis.vertical) ? EdgeInsets.only(right: scrollPadding) : EdgeInsets.only(bottom: scrollPadding),
          child: w,
        ),
      );
    }
    Widget w3;
    if (childCrossAxisSize == 0) {
      w3 = w2;
    } else {
      double totalSize = childCrossAxisSize + itemPadding * 2 + ((scrollBar) ? scrollPadding : 0);
      if (scrollDirection == Axis.vertical) {
        w3 = SizedBox(width: totalSize, child: w2);
      } else {
        w3 = SizedBox(height: totalSize, child: w2);
      }
    }
    return OutlineBox(child: w3, padding: (scrollDirection == Axis.vertical) ? EdgeInsets.only(right: itemPadding, left: itemPadding) : EdgeInsets.only(bottom: itemPadding, top: itemPadding));
  }
}
