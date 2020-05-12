import 'package:flutter/material.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../components/db_helper.dart';
class StatsPage extends StatefulWidget {
  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  static DateTime currDateTime = DateTime.now();
  String currDay = DateFormat.yMMMd().format(currDateTime);
  String currLiquidUnit = " kg";

  int currGraph = 0;
  bool _isMetric = true;
  List drList = [];
  List drinkList = [];
  List weightList=[];
  List totalDrinksPerWeek = List<double>.generate(7, (int index) => 0.0);
  List totalDrinksPerMonth = List<double>.generate(31, (int index) => 0.0);
  List totalDrinksPerYear = List<double>.generate(12, (int index) => 0.0);

  int averageByDay = 0;
  double averageWaterPerYear = 0;
  int averageWaterPerWeek = 0;
  int averageWaterPerMonth = 0;

  int selectedWeekNo = _getweekNumber(DateTime.now());
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  int currentWeekNo = _getweekNumber(DateTime.now());
  int currentDateNo = DateTime.now().day;

  double _adSpacer = 30.0;

  final dbHelper = DatabaseHelper.instance;

  List<Color> gradientColors = [
    Colors.deepOrange,
    Colors.deepOrangeAccent,
  ];

  void initState() {
    super.initState();
    initPrefs();
  }

  void initPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool _isPremium = prefs.getBool('is_premium') ?? false;

    setState(() {
      _isMetric = (prefs.getBool('is_metric')) ?? true;
      currLiquidUnit = (_isMetric) ? " ml" : " fl oz";
      _isPremium ? _adSpacer = 0.0 : _adSpacer = 30.0;
    });

    drinkList = await dbHelper.queryAllRows();
   print(drinkList);

    await updateDailyAverage();
    await makeChartByMonth();
    await makeChartByWeek();
  }

  String _getMonthName(monthNo) {
    switch (monthNo) {
      case 1:
        return "January";
        break;
      case 2:
        return "February";
        break;
      case 3:
        return "March";
        break;
      case 4:
        return "April";
        break;
      case 5:
        return "May";
        break;
      case 6:
        return "June";
        break;
      case 7:
        return "July";
        break;
      case 8:
        return "August";
        break;
      case 9:
        return "September";
        break;
      case 10:
        return "October";
        break;
      case 11:
        return "November";
        break;
      case 12:
        return "December";
        break;
      default:
        return "Not a month!";
        break;
    }
  }

  // Arranges data according to all days in a given week
  Future makeChartByWeek() async {
    totalDrinksPerWeek = List<double>.generate(7, (int index) => 0.0);
    averageWaterPerWeek = 0;

    for (var log in drinkList) {
      var date = DateTime.parse(log["date"]);
      if (_getweekNumber(date) == selectedWeekNo) {
        var dayofWeek = DateFormat('E').format(date);
        print(_getweekNumber(date));
        switch (dayofWeek) {
          case "Mon":
            totalDrinksPerWeek[0] += log["weight"];
            break;
          case "Tue":
            totalDrinksPerWeek[1] += log["weight"];
            break;
          case "Wed":
            totalDrinksPerWeek[2] += log["weight"];
            break;
          case "Thu":
            totalDrinksPerWeek[3] += log["weight"];
            break;
          case "Fri":
            totalDrinksPerWeek[4] += log["weight"];
            break;
          case "Sat":
            totalDrinksPerWeek[5] += log["weight"];
            break;
          case "Sun":
            totalDrinksPerWeek[6] += log["weight"];
            break;
          default:
        }
        averageWaterPerWeek += log["weight"];
      }
    }
    var todayDayOfWeek = DateFormat('E').format(DateTime.now());
    int todayDayNoOfWeek = 7;
    switch (todayDayOfWeek) {
      case "Mon":
        todayDayNoOfWeek = 1;
        break;
      case "Tue":
        todayDayNoOfWeek = 2;
        break;
      case "Wed":
        todayDayNoOfWeek = 3;
        break;
      case "Thu":
        todayDayNoOfWeek = 4;
        break;
      case "Fri":
        todayDayNoOfWeek = 5;
        break;
      case "Sat":
        todayDayNoOfWeek = 6;
        break;
      case "Sun":
        todayDayNoOfWeek = 7;
        break;
      default:
    }

    if (currentWeekNo == selectedWeekNo)
      averageWaterPerWeek = (averageWaterPerWeek / todayDayNoOfWeek).round();
    else
      averageWaterPerWeek = (averageWaterPerWeek / 7).round();

     print(averageWaterPerWeek);
     print(totalDrinksPerWeek);
  }

  // Arranges data according to all days in a given month
  Future makeChartByMonth() async {
    totalDrinksPerMonth = List<double>.generate(31, (int index) => 0.0);
    averageWaterPerMonth = 0;

    for (var log in drinkList) {
      var date = DateTime.parse(log["date"]);

      print("DATE: $date");
      if (date.month == selectedMonth) {
        var dayofMonth = int.parse(DateFormat('d').format(date));
        totalDrinksPerMonth[dayofMonth - 1] += log["weight"];

        averageWaterPerMonth += log["weight"];
      }
    }

    print(totalDrinksPerMonth);

    if (DateTime.now().month == selectedMonth)
      averageWaterPerMonth =
          (averageWaterPerMonth / DateTime.now().day).round();
    else
      averageWaterPerMonth = (averageWaterPerMonth / 31).round();
  }

  void makeChartByYear() {
    totalDrinksPerYear = List<double>.generate(12, (int index) => 0.0);
    averageWaterPerYear = 0;

    for (var log in drinkList) {
      var date = DateTime.parse(log["date"]);
      if (date.year == selectedYear) {
        var monthofYear = int.parse(DateFormat('M').format(date));
        // print(monthofYear);
        totalDrinksPerYear[monthofYear - 1] += log["weight"];

        print(date.year);
        averageWaterPerYear += log["weight"];
      }
    }

    print(totalDrinksPerYear);

    averageWaterPerYear =
        (averageWaterPerYear / totalDrinksPerYear.length).roundToDouble();
  }

  static int _getweekNumber(DateTime date) {
    int dayOfYear = int.parse(DateFormat("D").format(date));
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  List<FlSpot> _generateGraphDataWeek() {
    List<FlSpot> lineChartRows = [];
    for (int i = 0; i < totalDrinksPerWeek.length; i++) {
      var dr;
      if (_isMetric)
        dr = FlSpot(i.toDouble(), totalDrinksPerWeek[i] );
      else
        dr = FlSpot(i.toDouble(), totalDrinksPerWeek[i]);
      lineChartRows.add(dr);
      print(totalDrinksPerWeek[i]);
    }
    return lineChartRows;
  }

  List<FlSpot> _generateGraphDataMonth() {
    List<FlSpot> lineChartRows = [];
    for (int i = 0; i < totalDrinksPerMonth.length; i++) {
      var dr;
      if (_isMetric)
        dr = FlSpot(i.toDouble(), totalDrinksPerMonth[i] );
      else
        dr = FlSpot(i.toDouble(), totalDrinksPerMonth[i]);
      lineChartRows.add(dr);
      print(totalDrinksPerMonth[i]);
    }

    return lineChartRows;
  }

  Future updateDailyAverage() async {
    //print(drinkList.length);

    var tot = 0;
    for (var log in drinkList) {
      tot += log["weight"];
    }
    averageByDay = (tot / drinkList.length).round();

    //print("AVG: $averageByDay");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text("Statistics"),
        ),
        persistentFooterButtons: (_adSpacer != 0.0)
            ? <Widget>[
          Container(
            height: _adSpacer,
          )
        ]
            : null,
        body:  Container(
            child: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SizedBox(
                      height: 15,
                    ),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          
                          RaisedButton(
                            child: Text(" Monthly Stats"),
                            color: Colors.deepOrangeAccent,
                            onPressed: () {
                              setState(() {
                                currGraph = 0;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    (currGraph == 1)
                        ?
                    // By Week
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        RaisedButton(
                          child: Text("Previous"),
                          color: Colors.deepOrangeAccent,
                          onPressed: () {
                            setState(() {
                              if (selectedWeekNo > 1) selectedWeekNo--;
                              updateDailyAverage();
                              makeChartByWeek();
                            });
                          },
                        ),
                        Text(
                          "Week $selectedWeekNo",
                          style: TextStyle(fontSize: 20),
                        ),
                        RaisedButton(
                          child: Text("Next"),
                          color: Colors.deepOrangeAccent,
                          onPressed: () {
                            setState(() {
                              if (selectedWeekNo < 52) selectedWeekNo++;
                              updateDailyAverage();
                              makeChartByWeek();
                            });
                          },
                        )
                      ],
                    )
                        :
                    // By Month
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        RaisedButton(
                          child: Text("Previous"),
                          color: Colors.deepOrangeAccent,
                          onPressed: () {
                            setState(() {
                              if (selectedMonth > 1) selectedMonth--;
                              updateDailyAverage();
                              makeChartByMonth();
                            });
                          },
                        ),
                        Text(
                          _getMonthName(selectedMonth),
                          style: TextStyle(fontSize: 20),
                        ),
                        RaisedButton(
                          child: Text("Next"),
                          color: Colors.deepOrangeAccent ,
                          onPressed: () {
                            setState(() {
                              setState(() {
                                if (selectedMonth < 12) selectedMonth++;
                                updateDailyAverage();
                                makeChartByMonth();
                              });
                            });
                          },
                        )
                      ],
                    ),
                    // Monthly Graph
                    (currGraph == 0)
                        ? Container(
                        padding: EdgeInsets.only(
                            top: 30, bottom: 20, left: 20, right: 35),
                        child: LineChart(LineChartData(
                          clipToBorder: true,
                          gridData: FlGridData(
                            show: false,
                            drawVerticalLine: true,
                            getDrawingHorizontalLine: (value) {
                              return const FlLine(
                                color: Colors.deepOrangeAccent,
                                strokeWidth: 1,
                              );
                            },
                            getDrawingVerticalLine: (value) {
                              return const FlLine(
                                color: Colors.deepOrangeAccent,
                                strokeWidth: 1,
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: SideTitles(
                               //rotateAngle: 315,
                              showTitles: true,
                              reservedSize: 22,
                              textStyle: TextStyle(
                                  color:  Colors.deepOrangeAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                              getTitles: (value) {
                                if (value % 2== 0)
                                  return " ${value.toInt().toString()}";
                                return "";
                              },
                              margin: 8,
                            ),
                            leftTitles: SideTitles(
                              showTitles: true,
                              textStyle: TextStyle(
                                color: Colors.deepOrangeAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              getTitles: (value) {
                                if (_isMetric) {
                                  if (value.toInt() % 10 == 0)
                                    return '${value.toInt()} ';
                                } else {
                                  if (value.toInt() % 10 == 0)
                                    return '${value.toInt()}';
                                }
                                return "";
                              },
                              reservedSize: 10,
                              margin: 12,
                            ),
                          ),
                          borderData: FlBorderData(
                              show: true,
                              border: Border.all(
                                  color:  Colors.deepOrangeAccent,
                                  width: 1)),
                          minX: 0,
                          maxX: 31,
                          minY: 0,
                          maxY: null,
                          lineBarsData: [
                            LineChartBarData(
                              spots: _generateGraphDataMonth(),
                              isCurved: true,
                              preventCurveOverShooting: true,
                              colors: gradientColors,
                              barWidth: 5,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(
                                show: false,
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                colors: gradientColors
                                    .map((color) => color.withOpacity(0.3))
                                    .toList(),
                              ),
                            ),
                          ],
                        )))
                     //Weekly Graph
                         : Container(
                       // padding: EdgeInsets.all(20),

                       padding: EdgeInsets.only(
                           top: 30, bottom: 20, left: 20, right: 35),
                       child: LineChart(LineChartData(
                         gridData: FlGridData(
                           show: false,
                           drawVerticalLine: true,
                           getDrawingHorizontalLine: (value) {
                             return const FlLine(
                               color: Colors.deepOrangeAccent,
                               strokeWidth: 1,
                             );
                           },
                           getDrawingVerticalLine: (value) {
                             return const FlLine(
                               color: Colors.deepOrangeAccent,
                               strokeWidth: 1,
                             );
                           },
                         ),
                         titlesData: FlTitlesData(
                           show: true,
                           bottomTitles: SideTitles(
                             rotateAngle: 315,
                             showTitles: true,
                             reservedSize: 22,
                             textStyle: TextStyle(
                                 color: Colors.black,
                                 fontWeight: FontWeight.bold,
                                 fontSize: 12),
                             getTitles: (value) {
                               return "Day ${(value + 1).toInt().toString()}";
                             },
                             margin: 10,
                           ),
                           leftTitles: SideTitles(
                             showTitles: true,
                             textStyle: TextStyle(
                               color: Colors.deepOrangeAccent,
                               fontWeight: FontWeight.bold,
                               fontSize: 12,
                             ),
                             getTitles: (value) {
                               if (value.toInt() % 1 == 1) if (_isMetric)
                                 return '${value.toInt()} ';
                               else
                                 return '${value.toInt()}';
                               return "weight";
                             },
                             reservedSize: 10,
                             margin: 10,
                           ),
                         ),
                         borderData: FlBorderData(
                             show: true,
                             border: Border.all(
                                 color:  Colors.deepOrangeAccent,
                                 width: 1)),
                         minX: 0,
                         maxX: 6,
                         minY: 0,
                         maxY: null,
                         lineBarsData: [
                           LineChartBarData(
                             spots: _generateGraphDataWeek(),
                             isCurved: true,
                             preventCurveOverShooting: true,
                             colors: gradientColors,
                             barWidth: 5,
                             isStrokeCapRound: true,
                             dotData: const FlDotData(
                               show: false,
                             ),
                             belowBarData: BarAreaData(
                               show: true,
                               colors: gradientColors
                                   .map((color) => color.withOpacity(0.3))
                                   .toList(),
                             ),
                           ),
                         ],
                       )),
                     ),
                    Container(padding: EdgeInsets.all(50))
                  ]),
            ),
          ),
        );
  }
}
