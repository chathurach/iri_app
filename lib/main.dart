// @dart=2.9

import 'dart:async';

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iri_app/newProject.dart';
import 'package:sensors/sensors.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as l;
import 'package:fl_chart/fl_chart.dart';
import 'package:iri_app/verticalAcceleration.dart';

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
  double gx = 0.0;
  double gy = 0.0;
  double gz = 0.0;
  List locationList;
  List vAccList;
  var storagePermission;
  var locationPermission;
  var accelerations = new Map();
  bool saving = false;
  var getLocation;
  var location = l.Location();
  final limitCount = 100; //number of chart points to show
  final xPoints = <FlSpot>[];
  // final yPoints = <FlSpot>[];
  // final zPoints = <FlSpot>[];
  int timeCount = 0;
  String btnName = 'Record';
  String roadName = 'Add a Road';
  var pageResult;
  String saveName = 'my_file';

  @override
  void initState() {
    xPoints.add(FlSpot(0.0, 0.0));
    // yPoints.add(FlSpot(0.0, 0.0));
    // zPoints.add(FlSpot(0.0, 0.0));
    super.initState();
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (saving == true) {
        // print('here');
        _writeData();
      }
      while (xPoints.length > limitCount) {
        xPoints.removeAt(0);
        // yPoints.removeAt(0);
        // zPoints.removeAt(0);
      }
    });
    locationPermission = location.requestPermission().then((value) {
      if (value == l.PermissionStatus.granted) {
        location.onLocationChanged.listen((l.LocationData event) {
          getLocation = event;
          //print(getLocation);
        });
      }
    });

    Permission.storage.request().then((value) {
      setState(() {
        storagePermission = value;
        //print(storagePermission);
      });
    });

    //get the accelerometer readings without the graity
    userAccelerometerEvents.listen((event) {
      x = event.x;
      y = event.y;
      z = event.z;

      // setState(() {
      //   x = event.x;
      //   y = event.y;
      //   z = event.z;
      //   xPoints.add(FlSpot(timeCount * 1.0, x));
      //   yPoints.add(FlSpot(timeCount * 1.0, y));
      //   zPoints.add(FlSpot(timeCount * 1.0, z));
      //   timeCount++;
      // });
    });
    //get the accelerometer eading with the gavity
    accelerometerEvents.listen((event) {
      gx = event.x;
      gy = event.y;
      gz = event.z;
      accelerations = {
        'x': x,
        'y': y,
        'z': z,
        'gx': gx,
        'gy': gy,
        'gz': gz,
      };
      xPoints.add(FlSpot(
        timeCount * 1.0,
        vAcceleration(accelerations),
      ));
      // print(x);
      // print(accelerations);
      //print(vAcceleration(accelerations));
      // yPoints.add(FlSpot(timeCount * 1.0, y));
      // zPoints.add(FlSpot(timeCount * 1.0, z));
      timeCount++;
      setState(() {});
      // setState(() {
      //   gx = event.x;
      //   gy = event.y;
      //   gz = event.z;
      // xPoints.add(FlSpot(timeCount * 1.0, x));
      // yPoints.add(FlSpot(timeCount * 1.0, y));
      // zPoints.add(FlSpot(timeCount * 1.0, z));
      // });
    });
  }

  _writeData() async {
    if (storagePermission == PermissionStatus.granted) {
      final directory = await ExtStorage.getExternalStoragePublicDirectory(
          ExtStorage.DIRECTORY_DOWNLOADS);
      final File file =
          await File('$directory/$saveName.txt').create(recursive: true);
      //print(getLocation);
      locationList.add(getLocation);
      vAccList.add(vAcceleration(accelerations));
      final lat = getLocation.latitude;
      final lon = getLocation.longitude;
      //print('$lat, $lon');
      final time = DateTime.now();
      file.writeAsStringSync(
          '${time.toString()}, x: ${x.toStringAsFixed(4)} , y: ${y.toStringAsFixed(4)} , z: ${z.toStringAsFixed(4)}, lat: $lat, lon: $lon\n',
          mode: FileMode.append);
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
                        // yLine(yPoints),
                        // zLine(zPoints),
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

//   //This is based on the
// //https://stackoverflow.com/questions/37727340/android-detect-downward-acceleration-specifically-an-elevator/39333427#39333427
//   double _verticalAcceleration(Map results) {
//     final double verticleAcc = ((results['x'] * results['gx'] / 9.8) +
//         (results['y'] * results['gy'] / 9.8) +
//         (results['z'] * results['gz'] / 9.8));
//     return verticleAcc;
//   }
}
