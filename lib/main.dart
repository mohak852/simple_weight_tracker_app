import 'package:flutter/material.dart';
import 'package:simple_weight_tracker_app/pages/ads_page.dart';
import 'package:simple_weight_tracker_app/pages/homePage.dart';
import 'package:simple_weight_tracker_app/pages/settings.dart';
import 'package:simple_weight_tracker_app/pages/statistics_page.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      routes: {
        '/HomePage':(BuildContext context) => HomePage(),
        '/StatsPage':(BuildContext context) => StatsPage(),
        '/WatchAds':(BuildContext context) => AdsPage(),
        '/SettingsPage':(BuildContext context) => SettingsPage(),
//        '/RemindersPage':(BuildContext context) => RemindersPage(),
      },
      debugShowCheckedModeBanner: false,
      title: 'Weight Tracker App',
      theme: new ThemeData(
        primarySwatch: Colors.brown,
        accentColor: Colors.black
      ),
      home: HomePage(),
    );
  }
}