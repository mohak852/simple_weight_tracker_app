import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isMetric = true;
  String currWeightUnit = "kg";
  void _changeUnits(isMetric) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('is_metric', isMetric);
    setState(() {
      _isMetric = isMetric;
      currWeightUnit = (_isMetric) ? " kg" : " lbs";
      _isMetric = (prefs.getBool('is_metric')) ?? true;
    });
    print('$currWeightUnit');
    Navigator.of(context).pop();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Simple Weight Tracker'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                crossAxisAlignment: CrossAxisAlignment.spa,
                children: <Widget>[
                ListTile(
                    title: Text("Unit Conversion"),
                    subtitle:
                    (_isMetric) ? Text("kg") : Text("lbs"),
                    leading: Icon(
                      Icons.settings,
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                              title: Text('Select Units in KG or LBS'),
                              content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    RadioListTile(
                                        title: Text("kg"),
                                        groupValue: _isMetric,
                                        value: true,
                                        onChanged: (val) {
                                          _changeUnits(val);
                                        }),
                                    RadioListTile(
                                        title: Text("lbs"),
                                        groupValue: _isMetric,
                                        value: false,
                                        onChanged: (val) {
                                          _changeUnits(val);
                                        }),
                                  ]));
                        },
                      );
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

