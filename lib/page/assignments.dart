import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:intl/intl.dart';

import '../data.dart';
import '../util_widgets.dart';
import '../data_manager.dart';

DateFormat _dateFormat = DateFormat('MMM d, y,').add_jm();

class AssignmentsPage extends StatefulWidget {
  @override
  _AssignmentsPageState createState() => _AssignmentsPageState();
}

class _AssignmentsPageState extends State<AssignmentsPage> {
  bool _showForm = false;
  int _showIndex = 0;
  final List<String> showOptions = ["All Assignments", "Incomplete", "Completed"];
  AssignmentForm _currentForm = AssignmentForm();
  List<Assignment> _assignments = [];

  @override
  Widget build(BuildContext context) {
    DataManager dataManager = context.read<DataManager>();
    List<Stream<QuerySnapshot>> streams = [dataManager.assignmentStreamAll, dataManager.assignmentStreamIncomplete, dataManager.assignmentStreamCompleted];
    List<Widget> rowWidgets = [
      Expanded(
        child: Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _showIndex++;
                _showIndex%=3;
              });
            },
            child: OutlineBox(
              child: Text(showOptions[_showIndex]),
            ),
          ),
        ),
      ),
      IconButton(
        color: Theme.of(context).primaryColor,
        onPressed: () {
          setState(() {
            _showForm = !_showForm;
          });
        },
        icon: Icon((_showForm) ? Icons.undo : Icons.add),
      ),
    ];
    List<Widget> columnWidgets = [
      Padding(
        padding: EdgeInsets.only(left: 10.0, top: 10.0, right: 10.0),
        child: OutlineBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: rowWidgets,
          ),
        ),
      )
    ];
    if (_showForm) {
      columnWidgets.insert(1, _currentForm);
      rowWidgets.add(
        IconButton(
          color: Theme.of(context).primaryColor,
          onPressed: () {
            setState(() {
              _showForm = false;
              context.read<DataManager>().assignmentsCollection.add(_currentForm.currentState!.getAssignment().toJson());
              _currentForm = AssignmentForm();
            });
          },
          icon: Icon(Icons.check),
        ),
      );
    }
    columnWidgets.add(
      StreamBuilder<QuerySnapshot>(
        stream: streams[_showIndex],
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
          } else {
            _assignments = snapshot.data!.docs.map((DocumentSnapshot document) => Assignment.fromJson(document.data()! as Map<String, dynamic>, document.id)).toList();
          }
          return Expanded(
            child: AssignmentList(_assignments),
          );
        },
      ),
    );
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
    return Assignment(name: _nameController.text.trim(), startDate: _assignmentStartDate, dueDate: _assignmentDueDate, completed: false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: OutlineBox(
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

class AssignmentList extends StatelessWidget {
  final List<Assignment> _assignments;

  AssignmentList(this._assignments);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: PaddingListView(
        itemCount: _assignments.length,
        itemBuilder: (BuildContext context, int index) {
          return AssignmentWidget(_assignments[index]);
        },
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
    await context.read<DataManager>().assignmentsCollection.doc(widget._assignment.documentId).update(data);
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
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text("Delete"),
                      content: Text("Delete Assignment \"" + widget._assignment.name + "\"?"),
                      actions: [
                        MaterialButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("No"),
                        ),
                        MaterialButton(
                          onPressed: () {
                            setState(() {
                              context.read<DataManager>().assignmentsCollection.doc(widget._assignment.documentId).delete();
                            });
                            Navigator.pop(context);
                          },
                          child: Text("Yes"),
                        ),
                      ],
                    ),
                    barrierDismissible: true,
                  );
                },
              ),
              (widget._assignment.completed)
                  ? SizedBox(
                      width: 48.0,
                      height: 48.0,
                    )
                  : IconButton(
                      icon: Icon(Icons.edit),
                      color: Theme.of(context).primaryColor,
                      onPressed: () {
                        setState(() {
                          _editing = true;
                        });
                      },
                    ),
              (widget._assignment.completed)
                  ? SizedBox(
                      width: 48.0,
                      height: 48.0,
                    )
                  : IconButton(
                      icon: Icon(Icons.check),
                      color: Theme.of(context).primaryColor,
                      onPressed: () {
                        Assignment a = widget._assignment;
                        a.completed = true;
                        context.read<DataManager>().getUserData().then((UserData userData) {
                          Random rng = new Random();
                          int assignmentLength = a.dueDate.difference(a.startDate).inHours;
                          double multiplier = (1+0.1*(a.dueDate.difference(DateTime.now()).inHours / 24));

                          //hearts: (5 - 15) + 1 per 6 hours assignmentLength * extra 10% per day early
                          double hearts = (5*rng.nextDouble()+10) + (assignmentLength / 6.0);
                          hearts = hearts * multiplier;
                          userData.addHearts(hearts.round());
                          //(1-3) + 1 per day assignmentLength
                          double gems = (3*rng.nextDouble()+1) + (assignmentLength / 24.0);
                          gems = gems * multiplier;
                          userData.addGems(gems.round());
                          userData.completed++;

                          userData.updateDocument(context).then((_) {
                            a.updateDocument(context);
                          });
                        });
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
          value: (DateTime.now().microsecondsSinceEpoch - widget._assignment.startDate.microsecondsSinceEpoch) / (widget._assignment.dueDate.microsecondsSinceEpoch - widget._assignment.startDate.microsecondsSinceEpoch),
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
    return OutlineBox(
      borderColor: (widget._assignment.completed) ? Colors.lightGreen : null,
      child: Column(
        children: columnWidgets,
      ),
    );
  }
}
