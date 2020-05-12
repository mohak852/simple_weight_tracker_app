import 'package:flutter/material.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({Key key}) : super(key: key);

  @override
  _RemindersPageState createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  void initState() {
    super.initState();
    print("Init State from ReminderPage");
    initPrefs();
    initializeNotifs();
  }

  final globalKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final myController = TextEditingController();



  bool hourlyNotif = false;
  TimeOfDay _wakeTime = TimeOfDay.now();
  TimeOfDay _sleepTime = TimeOfDay.now();

  double _adSpacer = 30.0;

  List _timeIntervals = [
    "No Reminders",
    "3 Minutes (Testing)",
    "1 Hour",
    "2 Hours",
    "3 Hours",
    "4 Hours",
    "6 Hours",
  ];
  String _selectedInterval = "1 Hour";

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  static AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/icon');
  static IOSInitializationSettings initializationSettingsIOS =
  IOSInitializationSettings();
  static InitializationSettings initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);

  void initPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String _wakeTimeString =
        (prefs.getString('wake_time')) ?? TimeOfDay.now().toString();
    String _sleepTimeString =
        (prefs.getString('sleep_time')) ?? TimeOfDay.now().toString();
    bool _isPremium = prefs.getBool('is_premium') ?? false;

    setState(() {
      _selectedInterval = prefs.getString('notif_interval') ?? "1 Hour";
      _isPremium ? _adSpacer = 0.0 : _adSpacer = 30.0;
    });

    _wakeTime = TimeOfDay(
        hour: int.parse(_wakeTimeString.substring(10, 12)),
        minute: int.parse(_wakeTimeString.substring(13, 15)));
    _sleepTime = TimeOfDay(
        hour: int.parse(_sleepTimeString.substring(10, 12)),
        minute: int.parse(_sleepTimeString.substring(13, 15)));
  }

  void initializeNotifs() async {
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    // await Navigator.of(context).pushNamed("/HomePage");
  }

  void getScheduleTimes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Cancel All Previously set Notifications
    cancalAllNotifs();

    print("Scheduling notifs");

    Duration _intervalDuration;
    switch (_selectedInterval) {
      case "3 Minutes (Testing)":
        _intervalDuration = Duration(minutes: 3);
        prefs.setString('notif_interval', "3 Minutes (Testing)");
        break;
      case "1 Hour":
        _intervalDuration = Duration(hours: 1);
        prefs.setString('notif_interval', "1 Hour");
        break;
      case "2 Hours":
        _intervalDuration = Duration(hours: 2);
        prefs.setString('notif_interval', "2 Hours");
        break;
      case "3 Hours":
        _intervalDuration = Duration(hours: 3);
        prefs.setString('notif_interval', "3 Hours");
        break;
      case "4 Hours":
        _intervalDuration = Duration(hours: 4);
        prefs.setString('notif_interval', "4 Hours");
        break;
      case "6 Hours":
        _intervalDuration = Duration(hours: 6);
        prefs.setString('notif_interval', "6 Hours");
        break;
      case "No Reminders":
        print("All Notifications Cancelled");
        cancalAllNotifs();
        break;
      default:
        _intervalDuration = Duration(hours: 1);
        prefs.setString('notif_interval', "1 Hour");
    }

    if (_intervalDuration != null) {
      DateTime wakeDayofTime = new DateTime.now();
      DateTime startTime = DateTime(wakeDayofTime.year, wakeDayofTime.month,
          wakeDayofTime.day, _wakeTime.hour, _wakeTime.minute);
      DateTime endTime = DateTime(wakeDayofTime.year, wakeDayofTime.month,
          wakeDayofTime.day, _sleepTime.hour, _sleepTime.minute);
      DateTime currTime = startTime;

      List<DateTime> timesArray = [];
      int id = 0;

      while (currTime.isBefore(endTime)) {
        currTime = currTime.add(_intervalDuration);
        // print("Time inserted: ${currTime.hour} ${currTime.minute}");
        timesArray.add(currTime);
      }

      for (DateTime time in timesArray) {
        await showDailyAtTime(id, time);
        // print("Scheduling at Time: ${time.toString()}");
        id += 1;
      }
    }
  }

  Future getNotifications() async {
    var pendingNotificationRequests =
    await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    for (var pendingNotificationRequest in pendingNotificationRequests) {
      debugPrint(
          'pending notification: [id: ${pendingNotificationRequest.id}, title: ${pendingNotificationRequest.title}, body: ${pendingNotificationRequest.body}, payload: ${pendingNotificationRequest.payload}]');
    }
  }

  Future scheduleNotifAtTime(id, selectedTime) async {
    // DateTime testTime = DateTime.now().add(Duration(seconds: 3));
    String notifText = "Drink Water!";

    print("Schedules at: " + selectedTime.toString());

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your other channel id',
        'your other channel name',
        'your other channel description');

    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.schedule(
        id,
        notifText,
        'Notification from the Water Reminder App',
        selectedTime,
        platformChannelSpecifics);
  }

  Future showDailyAtTime(id, datetime) async {
    var time = Time(datetime.hour, datetime.minute);
    // print("${time.hour} ${time.minute}");

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'repeatDailyAtTime channel id',
        'repeatDailyAtTime channel name',
        'repeatDailyAtTime description');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.showDailyAtTime(id, 'Water Reminder',
        'A reminder to drink water now!', time, platformChannelSpecifics);
  }

  void cancalAllNotifs() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: globalKey,
        appBar: AppBar(
          title: Text("Reminders"),
        ),
        persistentFooterButtons: (_adSpacer != 0.0)
            ? <Widget>[
          Container(
            height: _adSpacer,
          )
        ]
            : null,
        body: DoubleBackToCloseApp(
          snackBar: const SnackBar(
            content: Text('Tap back again to leave'),
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Card(
                    child: Container(
                      padding: EdgeInsets.all(20.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // Container(
                            //   padding: EdgeInsets.symmetric(vertical: 10),
                            //   child: Text("Schedule Reminder Notifications",
                            //       style: TextStyle(fontSize: 26)),
                            // ),
                            // Container(
                            //   padding: EdgeInsets.symmetric(vertical: 10),
                            //   child: Text("Enter Notification Text",
                            //       style: TextStyle(fontSize: 20)),
                            // ),
                            // TextField(
                            //   controller: myController,
                            //   decoration: InputDecoration(
                            //       prefixIcon: Icon(Icons.text_fields)),
                            // ),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Text("Remind me every",
                                  style: TextStyle(fontSize: 26)),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              child: DropdownButton(
                                value: _selectedInterval,
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedInterval = newValue;
                                    globalKey.currentState.showSnackBar(
                                        SnackBar(
                                            content: Text('Notification Set')));
                                    getScheduleTimes();
                                  });
                                },
                                items: _timeIntervals.map((interval) {
                                  return DropdownMenuItem(
                                    child: new Text(interval),
                                    value: interval,
                                  );
                                }).toList(),
                              ),
                            ),
                            // Container(
                            //   padding: EdgeInsets.symmetric(vertical: 10.0),
                            //   child: RaisedButton(
                            //     onPressed: () {
                            //       globalKey.currentState.showSnackBar(SnackBar(
                            //           content: Text('Notification Set')));
                            //       getScheduleTimes(myController.text);
                            //     },
                            //     child: Text('Schedule'),
                            //   ),
                            // ),
                            // Container(
                            //   // padding: EdgeInsets.symmetric(vertical: 10.0),
                            //   child: RaisedButton(
                            //       child: Text("Cancel All Notifications"),
                            //       onPressed: () {
                            //         globalKey.currentState.showSnackBar(SnackBar(
                            //             content: Text(
                            //                 'All notifications cancelled')));
                            //         cancalAllNotifs();
                            //       }),
                            // ),
                            Container(padding: EdgeInsets.all(40))
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Card(
                  //   child: Container(
                  //     padding: EdgeInsets.all(20.0),
                  //     width: MediaQuery.of(context).size.width,
                  //     child: Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: <Widget>[
                  //         Text("Schedule Hourly Notification",
                  //             style: TextStyle(fontSize: 22)),
                  //         Text("Schedule reminder to drink water every hour"),
                  //         RaisedButton(
                  //           child: Text("Schedule every hour"),
                  //           onPressed: _scheduleNotifRepeated,
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ));
  }
}
