import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ru_on_time/Util.dart';
import 'package:ru_on_time/data_manager.dart';
import 'package:ru_on_time/page/assignments.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/src/provider.dart';
import 'package:intl/intl.dart';

import '../data.dart';
import '../util_widgets.dart';

final double scaleFactor = 0.8;

class CalendarPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height:10.0),
            Calendar(),
          ],
        ),
      ),
    );
  }
}

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

class _CalendarState extends State<Calendar> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  List<Assignment>? _assignments;

  List<Assignment> getAssignmentsOnDay(DateTime day, List<Assignment> assignments) {
    List<Assignment> matches = [];
    for (Assignment a in assignments) {
      if (day.isSameDate(a.dueDate)) {
        matches.add(a);
      }
    }
    return matches;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: context.read<DataManager>().assignmentStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        List<Widget> widgetsList = [
          SizedBox(
            width: MediaQuery.of(context).size.width * scaleFactor,
            height: MediaQuery.of(context).size.width * scaleFactor * 1.1,
            child: OutlineBox(child:TableCalendar(
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: _focusedDay,
                shouldFillViewport: true,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                ),
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                eventLoader: (day) {
                  if (_assignments != null) {
                    return getAssignmentsOnDay(day, _assignments!).map((e) => Event('bruh')).toList();
                  } else {
                    return [];
                  }
                },
              ),
            ),
          ),
        ];

        if (snapshot.hasError) {
          return Text('Something went wrong');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          widgetsList.add(SizedBox(
            height: MediaQuery.of(context).size.height - MediaQuery.of(context).size.width * scaleFactor - 240,
            child: AssignmentList([]),
          ));
          return Column(
            children: widgetsList,
          );
        }

        _assignments = snapshot.data!.docs.map((DocumentSnapshot document) => Assignment.fromJson(document.data()! as Map<String, dynamic>, document.id)).toList();

        List<Assignment> toShow = getAssignmentsOnDay(_selectedDay, _assignments ?? []);
        if (toShow.length >= 0) {
          widgetsList.add(SizedBox(
            height: MediaQuery.of(context).size.height - MediaQuery.of(context).size.width * scaleFactor - 240,
            child: AssignmentList(toShow),
          ));
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: widgetsList,
        );
      },
    );
  }
}
