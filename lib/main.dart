// @dart=2.9

import 'dart:async';

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iri_app/newProject.dart';
import 'package:sensors/sensors.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart';
import 'package:fl_chart/fl_chart.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IRI Data Collection',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double x = 0.0;
  double y = 0.0;
  double z = 0.0;
  bool saving = false;
  var lastLocation;
  final limitCount = 100; //number of chart points to show
  final xPoints = <FlSpot>[];
  final yPoints = <FlSpot>[];
  final zPoints = <FlSpot>[];
  int timeCount = 0;
  String btnName = 'Record';
  String roadName = 'Add a Road';
  var pageResult;
  String saveName = 'my_file';

  @override
  void initState() {
    xPoints.add(FlSpot(0.0, 0.0));
    yPoints.add(FlSpot(0.0, 0.0));
    zPoints.add(FlSpot(0.0, 0.0));
    super.initState();
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (saving == true) {
        _writeData();
      }
      while (xPoints.length > limitCount) {
        xPoints.removeAt(0);
        yPoints.removeAt(0);
        zPoints.removeAt(0);
      }
    });
    userAccelerometerEvents.listen((event) {
      setState(() {
        x = event.x;
        y = event.y;
        z = event.z;
        xPoints.add(FlSpot(timeCount * 1.0, x));
        yPoints.add(FlSpot(timeCount * 1.0, y));
        zPoints.add(FlSpot(timeCount * 1.0, z));
      });
      timeCount++;
    });
  }

  _writeData() async {
    var spermission = await Permission.storage.status;
    if (spermission.isGranted) {
      final directory = await ExtStorage.getExternalStoragePublicDirectory(
          ExtStorage.DIRECTORY_DOWNLOADS);
      final File file =
          await File('$directory/$saveName.txt').create(recursive: true);
      final _getLoc = await _getLocation();
      final lat = _getLoc.latitude.toString();
      final lon = _getLoc.longitude.toString();
      final time = DateTime.now();
      file.writeAsStringSync(
          '${time.toString()}, x: ${x.toStringAsFixed(4)} , y: ${y.toStringAsFixed(4)} , z: ${z.toStringAsFixed(4)}, lat: $lat, lon: $lon\n',
          mode: FileMode.append);
    } else {
      return;
    }
  }

  _getLocation() async {
    var lpermission = await Permission.location.status;
    if (lpermission.isGranted) {
      var _location = await Location().getLocation();
      return _location;
    } else {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("IRI Data Collection"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                roadName,
                style: TextStyle(
                  fontSize: 25.0,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: _width,
                  height: 300,
                  child: LineChart(
                    LineChartData(
                      minY: -10,
                      maxY: 10,
                      minX: xPoints.first.x,
                      maxX: xPoints.last.x,
                      lineTouchData: LineTouchData(enabled: false),
                      clipData: FlClipData.all(),
                      gridData: FlGridData(
                        show: true,
                      ),
                      lineBarsData: [
                        xLine(xPoints),
                        yLine(yPoints),
                        zLine(zPoints),
                      ],
                      titlesData: FlTitlesData(
                        show: false,
                        bottomTitles: SideTitles(
                          showTitles: false,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Table(
                border: TableBorder.all(
                    width: 2.0,
                    color: Colors.blueAccent,
                    style: BorderStyle.solid),
                children: [
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "X Asis : ",
                          style: TextStyle(fontSize: 20.0),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          x.toStringAsFixed(
                              2), //trim the asis value to 2 digit after decimal point
                          style: TextStyle(
                            fontSize: 20.0,
                          ),
                        ),
                      )
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Y Asis : ",
                          style: TextStyle(fontSize: 20.0),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            y.toStringAsFixed(
                                2), //trim the asis value to 2 digit after decimal point
                            style: TextStyle(fontSize: 20.0)),
                      )
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Z Asis : ",
                          style: TextStyle(fontSize: 20.0),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            z.toStringAsFixed(
                                2), //trim the asis value to 2 digit after decimal point
                            style: TextStyle(fontSize: 20.0)),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: MaterialButton(
                color: Colors.redAccent,
                height: 40.0,
                minWidth: 40.0,
                onPressed: () {
                  if (roadName == 'Add a Road') {
                    print('in the if');
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: Text('Missing Road Name!'),
                        content: Text('Please add a valid Road Name.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _waitforRoad(context);
                            },
                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    setState(() {
                      if (saving == true) {
                        saving = false;
                        btnName = 'Record';
                      } else if (saving == false) {
                        saving = true;
                        btnName = 'Stop';
                      }
                    });
                  }
                },
                child: Text(btnName),
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Options',
                    style: TextStyle(
                      fontSize: 25.0,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.0),
                ],
              ),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
              ),
            ),
            ListTile(
              title: Row(
                children: [
                  Icon(
                    Icons.add,
                    color: Colors.black,
                    size: 25.0,
                  ),
                  SizedBox(
                    width: 5.0,
                  ),
                  Text(
                    'Add a Road',
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                ],
              ),
              onTap: () {
                Navigator.pop(context);
                _waitforRoad(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  LineChartBarData xLine(List<FlSpot> points) {
    return LineChartBarData(
      spots: points,
      dotData: FlDotData(
        show: false,
      ),
      colors: [Colors.redAccent.withOpacity(0), Colors.redAccent],
      colorStops: [0.1, 1.0],
      barWidth: 4,
      isCurved: false,
    );
  }

  LineChartBarData yLine(List<FlSpot> points) {
    return LineChartBarData(
      spots: points,
      dotData: FlDotData(
        show: false,
      ),
      colors: [Colors.blueAccent.withOpacity(0), Colors.blueAccent],
      colorStops: [0.1, 1.0],
      barWidth: 4,
      isCurved: false,
    );
  }

  LineChartBarData zLine(List<FlSpot> points) {
    return LineChartBarData(
      spots: points,
      dotData: FlDotData(
        show: false,
      ),
      colors: [Colors.greenAccent.withOpacity(0), Colors.greenAccent],
      colorStops: [0.1, 1.0],
      barWidth: 4,
      isCurved: false,
    );
  }

  void _waitforRoad(BuildContext context) async {
    pageResult = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewRoad(),
      ),
    );
    setState(() {
      roadName = pageResult;
      saveName = roadName.replaceAll(RegExp('[^a-zA-Z0-9]'), '');
      print(saveName);
    });

    var spermission = await Permission.storage.status;
    if (spermission.isGranted) {
      final directory = await ExtStorage.getExternalStoragePublicDirectory(
          ExtStorage.DIRECTORY_DOWNLOADS);
      final File file =
          await File('$directory/$saveName.txt').create(recursive: true);
      final today = DateTime.now();
      file.writeAsStringSync(
          'Road : $roadName , Collection Date : ${today.toString()}\n',
          mode: FileMode.write);
    } else {
      return;
    }
  }
}
