import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:intl/intl.dart';

import '../data_manager.dart';

DateFormat _dateFormat = DateFormat('MMM d, y,').add_jm();

class AssignmentsPage extends StatefulWidget {
  @override
  _AssignmentsPageState createState() => _AssignmentsPageState();
}

class _AssignmentsPageState extends State<AssignmentsPage> {
  bool _showForm = false;
  AssignmentForm _currentForm = AssignmentForm();

  @override
  Widget build(BuildContext context) {
    List<Widget> rowWidgets = [
      Padding(
        padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              _showForm = !_showForm;
            });
          },
          child: Text((_showForm) ? "Cancel" : "New Assignment"),
          style: ElevatedButton.styleFrom(primary: (_showForm) ? Theme.of(context).disabledColor : Theme.of(context).primaryColor),
        ),
      ),
    ];
    List<Widget> columnWidgets = [
      //Text('Assignments', style: TextStyle(fontSize: 60)),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: rowWidgets,
      ),
      Expanded(
        child: AssignmentFetcher(),
      )
    ];
    if (_showForm) {
      columnWidgets.insert(1, _currentForm);
      rowWidgets.add(
        Padding(
          padding: EdgeInsets.only(right: 10.0, top: 10.0),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _showForm = false;
                context.read<DataManager>().assignmentCollection.add(_currentForm.currentState!.getAssignment().toJson());
                _currentForm = AssignmentForm();
              });
            },
            child: Text("Submit"),
          ),
        ),
      );
    }
    return Column(
      children: columnWidgets,
    );
  }
}

// ignore: must_be_immutable
class AssignmentForm extends StatefulWidget {
  _AssignmentFormState? currentState;
  Assignment? _initialAssignment;

  AssignmentForm();

  AssignmentForm.withInitial(this._initialAssignment);

  @override
  _AssignmentFormState createState() {
    currentState = _AssignmentFormState(_initialAssignment);
    return currentState!;
  }
}

class _AssignmentFormState extends State<AssignmentForm> {
  DateTime _assignmentStartDate = DateTime.now();
  DateTime _assignmentDueDate = DateTime.now();
  late TextEditingController _nameController;

  _AssignmentFormState(Assignment? initialAssignment) {
    if (initialAssignment != null) {
      _assignmentStartDate = initialAssignment.startDate;
      _assignmentDueDate = initialAssignment.dueDate;
      _nameController = TextEditingController(text: initialAssignment.name);
    } else {
      _nameController = TextEditingController();
    }
  }

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
                      onPressed: () => _selectDateAndTime(context, _assignmentStartDate, DateTime(2015)).then((value) => setState(() => _assignmentStartDate = value)),
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
                      onPressed: () => _selectDateAndTime(context, _assignmentDueDate, _assignmentStartDate).then((value) => setState(() => _assignmentDueDate = value)),
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
    final DateTime? pickedDate = await showDatePicker(context: context, initialDate: initial, firstDate: startDate, lastDate: DateTime(2030));
    if (pickedDate != null && pickedDate != initial) {
      final DateTime dateWithTime = await _selectTime(context, initial, pickedDate);
      if (dateWithTime != initial) {
        return dateWithTime;
      }
    }
    return initial;
  }

  Future<DateTime> _selectTime(BuildContext context, DateTime initial, DateTime date) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (picked != null) {
      return DateTime(date.year, date.month, date.day, picked.hour, picked.minute);
    }
    return date;
  }
}

class AssignmentFetcher extends StatelessWidget {
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
        return AssignmentList(snapshot.data!.docs.map((DocumentSnapshot document) => Assignment.fromJson(document.data()! as Map<String, dynamic>, document.id)).toList());
      },
    );
  }
}

class AssignmentList extends StatelessWidget {
  final List<Assignment> _assignments;

  AssignmentList(this._assignments);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 2.0, color: Theme.of(context).dividerColor),
        ),
        child: ListView(
          physics: BouncingScrollPhysics(),
          children: _assignments.map((e) => AssignmentWidget(e)).toList(),
        ),
      ),
    );
  }
}

class AssignmentWidget extends StatefulWidget {
  final Assignment _assignment;

  AssignmentWidget(this._assignment);

  @override
  _AssignmentWidgetState createState() => _AssignmentWidgetState();
}

class _AssignmentWidgetState extends State<AssignmentWidget> {
  bool _editing = false;

  Future<void> updateData(Map<String, dynamic> data) async {
    await context.read<DataManager>().assignmentCollection.doc(widget._assignment.documentID).update(data);
  }

  @override
  Widget build(BuildContext context) {
    AssignmentForm currentForm = AssignmentForm.withInitial(widget._assignment);
    List<Widget> columnWidgets = [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(widget._assignment.name),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  setState(() {
                    //TODO confirmation?
                    context.read<DataManager>().assignmentCollection.doc(widget._assignment.documentID).delete();
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.edit),
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  setState(() {
                    _editing = true;
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.check),
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  print("add completion code here");
                },
              ),
            ],
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(_dateFormat.format(widget._assignment.startDate)),
          Text(_dateFormat.format(widget._assignment.dueDate)),
        ],
      ),
      Row(
        //TODO JANKY
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(DateTime.now().difference(widget._assignment.startDate).inDays.toString() + " Days ago"),
          Text("In " + widget._assignment.dueDate.difference(DateTime.now()).inDays.toString() + " Days"),
        ],
      ),
      Padding(
        padding: EdgeInsets.only(top: 5.0),
        child: LinearProgressIndicator(
          value: (DateTime.now().microsecondsSinceEpoch - widget._assignment.startDate.microsecondsSinceEpoch) /
              (widget._assignment.dueDate.microsecondsSinceEpoch - widget._assignment.startDate.microsecondsSinceEpoch),
        ),
      ),
    ];
    if (_editing) {
      columnWidgets.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: ElevatedButton(
                child: Text("Cancel"),
                onPressed: () {
                  setState(() {
                    _editing = false;
                  });
                },
                style: ElevatedButton.styleFrom(primary: Theme.of(context).disabledColor),
              ),
            ),
            ElevatedButton(
              child: Text("Update"),
              onPressed: () {
                updateData(currentForm.currentState!.getAssignment().toJson()).then((_) {
                  setState(() {
                    _editing = false;
                  });
                });
              },
            ),
          ],
        ),
      );
      columnWidgets.add(currentForm);
    }
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 2.0, color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: columnWidgets,
          ),
        ),
      ),
    );
  }
}

class Assignment {
  final String name;
  final DateTime dueDate;
  final DateTime startDate;
  String? documentID;

  Assignment({required this.name, required this.dueDate, required this.startDate, this.documentID});

  Assignment.fromJson(Map<String, Object?> json, String id)
      : this(
          name: json['name']! as String,
          dueDate: DateTime.parse(json['due date']! as String),
          startDate: DateTime.parse(json['start date']! as String),
          documentID: id,
        );

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'due date': dueDate.toIso8601String(),
      'start date': startDate.toIso8601String(),
    };
  }
}
