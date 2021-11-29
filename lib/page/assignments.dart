import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:intl/intl.dart';

import '../data_manager.dart';

DateFormat _dateFormat = DateFormat('yyyy-MM-dd – HH:mm');

class AssignmentsPage extends StatefulWidget{

  @override
  _AssignmentsPageState createState() => _AssignmentsPageState();
}

class _AssignmentsPageState extends State<AssignmentsPage> {
  bool showForm = false;
  AssignmentForm currentForm = AssignmentForm();

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [
      Text('Assignments', style: TextStyle(fontSize: 60)),
      ElevatedButton(
        onPressed: () {
          setState(() {
            showForm = !showForm;
          });
        },
        child: Text((showForm)?"Cancel":"New Assignment"),
      ),
      Expanded(
        child: AssignmentList(),
      )
    ];
    if (showForm) {
      widgets.insert(2, currentForm);
      widgets.insert(3, ElevatedButton(
        onPressed: () {
          setState(() {
            showForm = false;
            context.read<DataManager>().assignmentCollection.add(currentForm.currentState!.getAssignment().toJson());
            currentForm = AssignmentForm();
          });
        },
        child: Text("Submit"),
      ));
    }
    return Column(
      children: widgets,
    );
  }
}

// ignore: must_be_immutable
class AssignmentForm extends StatefulWidget {
  _AssignmentFormState? currentState;

  @override
  _AssignmentFormState createState() {
    currentState = _AssignmentFormState();
    return currentState!;
  }
}

class _AssignmentFormState extends State<AssignmentForm> {
  DateTime _assignmentStartDate = DateTime.now();
  DateTime _assignmentDueDate = DateTime.now();
  final TextEditingController _nameController = TextEditingController();

  Assignment getAssignment() {
    return Assignment(name: _nameController.text.trim(), startDate: _assignmentStartDate, dueDate: _assignmentDueDate);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 2.0, color: Theme.of(context).dividerColor),
        ),
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Column(
            children: [
              Text("New Assignment"),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Assignment Name",
                ),
              ),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.0, right: 10.0),
                    child: ElevatedButton(
                      child: Text("Start Date"),
                      onPressed: () => _selectDateAndTime(
                              context, _assignmentStartDate, DateTime(2015))
                          .then((value) =>
                              setState(() => _assignmentStartDate = value)),
                    ),
                  ),
                  Text(_dateFormat.format(_assignmentStartDate)),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.0, right: 10.0),
                    child: ElevatedButton(
                      child: Text("due Date"),
                      onPressed: () => _selectDateAndTime(
                              context, _assignmentDueDate, _assignmentStartDate)
                          .then((value) =>
                              setState(() => _assignmentDueDate = value)),
                    ),
                  ),
                  Text(_dateFormat.format(_assignmentDueDate)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<DateTime> _selectDateAndTime(BuildContext context, DateTime initial, DateTime startDate) async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: startDate,
        lastDate: DateTime(2030));
    if (pickedDate != null && pickedDate != initial) {
      final DateTime dateWithTime = await _selectTime(context, pickedDate);
      if (dateWithTime != initial) {
        return dateWithTime;
      }
    }
    return initial;
  }

  Future<DateTime> _selectTime(BuildContext context, DateTime date) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(date),
    );
    if (picked != null) {
      return DateTime(date.year, date.month, date.day, picked.hour, picked.minute);
    }
    return date;
  }


}

class AssignmentList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DataManager _dataManager = context.read<DataManager>();
    return StreamBuilder<QuerySnapshot>(
      stream: _dataManager.assignmentStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }
        return ListView(
          itemExtent: 80,
          children: snapshot.data!.docs
              .map((DocumentSnapshot document) =>
                  Assignment.fromJson(document.data()! as Map<String, dynamic>)
                      .getWidget())
              .toList(),
        );
      },
    );
  }
}

class Assignment {
  final String name;
  final DateTime dueDate;
  final DateTime startDate;
  Assignment({required this.name, required this.dueDate, required this.startDate});


  Assignment.fromJson(Map<String, Object?> json)
    : this(
      name: json['name']! as String,
      dueDate: DateTime.parse(json['due date']! as String),
      startDate: DateTime.parse(json['start date']! as String),
    );

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'due date': dueDate.toIso8601String(),
      'start date': startDate.toIso8601String(),
    };
  }

  Widget getWidget() {

    return ListTile(
      title: Text(name),
      subtitle: Text(_dateFormat.format(startDate) + "--->" + _dateFormat.format(dueDate)),
    );
  }

}