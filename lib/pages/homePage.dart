import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_weight_tracker_app/models/weightSave.dart';
import 'package:simple_weight_tracker_app/pages/addEntryDialog.dart';
import '../components/db_helper.dart';

import '../models/weightSave.dart';
import 'package:intl/intl.dart';

const String testDevice = 'MobileId';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int weightDifference;

  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    testDevices: testDevice != null ? <String>[testDevice] : null,
    nonPersonalizedAds: true,
    keywords: <String>['Game', 'Mario'],
  );
  BannerAd _bannerAd;
  BannerAd createBannerAd() {
    return BannerAd(
        adUnitId: BannerAd.testAdUnitId,
      //Change BannerAd adUnitId with Admob ID
        size: AdSize.banner,
        targetingInfo: targetingInfo,
        listener: (MobileAdEvent event) {
          print("BannerAd $event");
        });
  }
  List<WeightSave> _weightSaves = [];
  final dbHelper = DatabaseHelper.instance;
  List weightList = [];
  String currWeightUnit = " kg";
  bool _isMetric = true;

  void initPrefs() async {
    weightList = await dbHelper.queryAllRows();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currWeightUnit = (_isMetric) ? " kg" : " lbs";
    setState(() {
      currWeightUnit = (_isMetric) ? " kg" : " lbs";
    });
    print(weightList);
  }

  Future _addWeight() async {
    await Navigator.of(context)
        .pushReplacement(new MaterialPageRoute<WeightSave>(
            builder: (BuildContext context) {
              return AddEntryDialog();
            },
            fullscreenDialog: false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Simple Weight Tracker'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              child: Center(
                child: Text(
                  "Simple Weight Tracker",
                  style: TextStyle(color: Colors.white, fontSize: 20.0),
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.all(10.0),
              title: Text('History'),
              subtitle: Text("Check your previous weight"),
              leading: Icon(Icons.history),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.all(10.0),
              title: Text('Statistics'),
              subtitle: Text("View your weight in graph"),
              leading: Icon(Icons.show_chart),
              onTap: () {
                Navigator.pushNamed(context, '/StatsPage');
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.all(10.0),
              title: Text("Watch Ad"),
              subtitle: Text("Click here to watch ad"),
              leading: Icon(Icons.attach_money),
              onTap: () {
                Navigator.pushNamed(context, '/WatchAds');
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.all(10.0),
              title: Text('Settings'),
              subtitle: Text("Change your settings"),
              leading: Icon(Icons.settings),
              onTap: () {
                Navigator.pushNamed(context, '/SettingsPage');
              },
            ),

          ],
        ),
      ),
      body: ListView.builder(
        itemCount: weightList.length,
        itemBuilder: (context, indice) {
          DateTime parsedTime = DateTime.parse(weightList[indice]["date"]);

          // Change the Date format below
          String formattedTime = DateFormat.yMd().add_jm().format(parsedTime);
//          for(int i=0;i<weightList.length;i++)
//            {
//              weightDifference = weightList[i] - weightList[i-1];
////              print(weightDifference);
//            }
          // Change the Note format below
          String note;
          if (weightList[indice]["note"] != null)
            note = weightList[indice]["note"].toString() ;
          else
            note = "";
          // Change the Weight format below
          String weight = weightList[indice]["weight"].toString() + currWeightUnit;
          // Change the Display format below
          return ListTile(
            title: Text(weight + " " + note ),
            subtitle: Text(formattedTime),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addWeight,
        child: Icon(Icons.add),
      ),
    );
  }
}
