import 'package:flutter/material.dart';
import 'package:simple_weight_tracker_app/components/dateTimeItem.dart';
import 'package:numberpicker/numberpicker.dart';
import '../components/db_helper.dart';

class AddEntryDialog extends StatefulWidget {
  @override
  AddEntryDialogState createState() => new AddEntryDialogState();
}

class AddEntryDialogState extends State<AddEntryDialog> {
  TextEditingController _textEditingController = TextEditingController();
  double _weight = 1.0;
  DateTime _dateTime = new DateTime.now();
  String _note;

  // reference to our single class that manages the database
  final dbHelper = DatabaseHelper.instance;

  void _saveButtonClk() async {
    Map<String, dynamic> row = {
      DatabaseHelper.columnDateTime: DateTime.now().toString(),
      DatabaseHelper.columnWeight: _weight,
      DatabaseHelper.columnNote: _textEditingController.text ?? ""
    };
    final id = await dbHelper.insert(row);
    print("Inserted Record id: $id");

    Navigator.of(context).popAndPushNamed("/HomePage");
  }

  void _showWeightPicker(BuildContext context) {
    showDialog(
        context: context,
        child: NumberPickerDialog.decimal(
          minValue: 1,
          maxValue: 150,
          initialDoubleValue: _weight,
          title: new Text("Enter your weight"),
        )).then((value) {
      if (value != null) {
        setState(() => _weight = value);
      }
    });
  }

  @override
  void initState() {
    _textEditingController = new TextEditingController(text: _note);
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: new AppBar(
          backgroundColor: Colors.blue,
          title: const Text('New entry'),
          actions: [
            new FlatButton(
                onPressed: _saveButtonClk,
                child: new Text('Save',
                    style: Theme.of(context)
                        .textTheme
                        .subhead
                        .copyWith(color: Colors.white))),
          ],
        ),
        body: Column(
          children: <Widget>[
            new ListTile(
              leading: new Icon(Icons.today, color: Colors.grey[500]),
              title: new DateTimeItem(
                dateTime: _dateTime,
                onChanged: (dateTime) => setState(() => _dateTime = dateTime),
              ),
            ),
            new ListTile(
              leading: Icon(Icons.airplay),
              title: new Text(
                "$_weight kg",
              ),
              onTap: () => _showWeightPicker(context),
            ),
            new ListTile(
              leading: new Icon(Icons.speaker_notes, color: Colors.grey[500]),
              title: new TextField(
                decoration: new InputDecoration(
                  hintText: 'Optional note',
                ),
                controller: _textEditingController,
                onChanged: (value) => _note = value,
              ),
            ),
          ],
        ),
      );
}
