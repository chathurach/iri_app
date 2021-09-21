// @dart=2.9

// import 'dart:async';

// import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iri_app/bluetooth.dart';
// import 'package:iri_app/getDistance.dart';
// import 'package:iri_app/iriCalculation.dart';
// import 'package:iri_app/newProject.dart';
// import 'package:sensors/sensors.dart';
// import 'package:ext_storage/ext_storage.dart';
// import 'package:location/location.dart' as l;
// import 'package:fl_chart/fl_chart.dart';
// import 'package:iri_app/verticalAcceleration.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
  //     new GlobalKey<ScaffoldMessengerState>();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MaterialApp(
      home: BluetoothApp(),
    );
  }
}

// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   //for acceleration values without gravity
//   double x = 0.0;
//   double y = 0.0;
//   double z = 0.0;
//   //for accelration values with gravity
//   double gx = 0.0;
//   double gy = 0.0;
//   double gz = 0.0;
//   double getIRI = 0.0; //hold the last IRI value
//   double tempIRI = 0.0; //hold the temp. IRI value
//   int distance100 = 0; //distance travelled (in 100m sections)
//   double vertAcc = 0.0; //get the verticle accelerations
//   List<l.LocationData> locationList = List<l.LocationData>.empty(
//       growable: true); //hold the location points for 100m section
//   List<double> vAccList = List<double>.empty(
//       growable: true); //hold the verticle accelerations for 100m section
//   var storagePermission; //storage permission status
//   var locationPermission; //location permission status
//   var accelerations =
//       new Map(); //hold accelerations values to pass to verticleAcceleration.dart
//   bool saving = false; //start recording the data
//   l.LocationData getLocation; //get the loation data
//   var location = l.Location();
//   final limitCount = 10; //number of chart points to show
//   final xPoints = <FlSpot>[];

//   String btnName = 'Record';
//   String roadName = 'Add a Road';
//   var pageResult;
//   String saveName = 'my_file';

//   @override
//   void initState() {
//     xPoints.add(FlSpot(0.0, 0.0));

//     super.initState();
//     Timer.periodic(Duration(milliseconds: 50), (timer) {
//       if (saving == true) {
//         _writeData();
//       }
//       while (xPoints.length > limitCount) {
//         xPoints.removeAt(0);
//       }
//     });
//     locationPermission = location.requestPermission().then((value) {
//       if (value == l.PermissionStatus.granted) {
//         location.onLocationChanged.listen((l.LocationData event) {
//           getLocation = event;
//         });
//       }
//     });

//     Permission.storage.request().then((value) {
//       setState(() {
//         storagePermission = value;
//       });
//     });

//     //get the accelerometer readings without the graity
//     userAccelerometerEvents.listen((event) {
//       x = event.x;
//       y = event.y;
//       z = event.z;
//     });
//     //get the accelerometer eading with the gavity
//     accelerometerEvents.listen((event) {
//       gx = event.x;
//       gy = event.y;
//       gz = event.z;
//       accelerations = {
//         'x': x,
//         'y': y,
//         'z': z,
//         'gx': gx,
//         'gy': gy,
//         'gz': gz,
//       };

//       setState(() {});
//     });
//   }

// //write the data to a file and draw it on the chart
//   _writeData() async {
//     if (storagePermission == PermissionStatus.granted) {
//       final directory = await ExtStorage.getExternalStoragePublicDirectory(
//           ExtStorage.DIRECTORY_DOWNLOADS);
//       final File file =
//           await File('$directory/$saveName.txt').create(recursive: true);

//       if (getLocation != null && accelerations != null) {
//         vertAcc = vAcceleration(accelerations);
//         locationList.add(getLocation);
//         vAccList.add(vertAcc);
//         final double distance = getDistance(locationList);
//         //get the IRI values for every 100m distance
//         if (locationList.length > 1) {
//           if (distance <= 0.1) {
//             //impliment the iri logging for every 100 m
//             tempIRI = iriCalc(vAccList);
//           } else if (distance > 0.1) {
//             getIRI = tempIRI;
//             //print('distance: $distance100, iri: $getIRI');
//             xPoints.add(FlSpot(
//               distance100 * 1.0,
//               getIRI,
//             ));
//             //get the final iri value
//             locationList.clear();
//             vAccList.clear();
//             distance100++;
//           }
//         }
//       }
//       final lat = getLocation.latitude;
//       final lon = getLocation.longitude;

//       final time = DateTime.now();
//       //write to the text file with the road name
//       file.writeAsStringSync(
//           '${time.toString()}, x: ${x.toStringAsFixed(4)} , y: ${y.toStringAsFixed(4)} , z: ${z.toStringAsFixed(4)}, lat: $lat, lon: $lon iri: $getIRI\n',
//           mode: FileMode.append);
//     } else {
//       return;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final _width = MediaQuery.of(context).size.width;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("IRI Data Collection"),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text(
//                 roadName,
//                 style: TextStyle(
//                   fontSize: 25.0,
//                 ),
//               ),
//             ),
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Container(
//                   width: _width,
//                   height: 300,
//                   child: LineChart(
//                     LineChartData(
//                       minY: 0,
//                       maxY: 30,
//                       minX: xPoints.first.x,
//                       maxX: xPoints.last.x,
//                       lineTouchData: LineTouchData(enabled: false),
//                       clipData: FlClipData.all(),
//                       gridData: FlGridData(
//                         show: true,
//                       ),
//                       lineBarsData: [
//                         xLine(xPoints),
//                       ],
//                       titlesData: FlTitlesData(
//                         show: true,
//                         leftTitles: SideTitles(showTitles: false),
//                         bottomTitles: SideTitles(
//                           showTitles: true,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Table(
//                 border: TableBorder.all(
//                     width: 2.0,
//                     color: Colors.blueAccent,
//                     style: BorderStyle.solid),
//                 children: [
//                   TableRow(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                           "Vert. Acceleration : ",
//                           style: TextStyle(fontSize: 20.0),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                           vertAcc.toStringAsFixed(
//                               2), //trim the asis value to 2 digit after decimal point
//                           style: TextStyle(
//                             fontSize: 20.0,
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                   TableRow(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                           "IRI(100m) : ",
//                           style: TextStyle(fontSize: 20.0),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                             getIRI.toStringAsFixed(
//                                 2), //trim the asis value to 2 digit after decimal point
//                             style: TextStyle(fontSize: 20.0)),
//                       )
//                     ],
//                   ),
//                   TableRow(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                           "Distance(m) : ",
//                           style: TextStyle(fontSize: 20.0),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text((distance100 * 100).toString(),
//                             style: TextStyle(fontSize: 20.0)),
//                       )
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: MaterialButton(
//                 color: Colors.redAccent,
//                 height: 40.0,
//                 minWidth: 40.0,
//                 onPressed: () {
//                   if (roadName == 'Add a Road') {
//                     showDialog(
//                       context: context,
//                       builder: (BuildContext context) => AlertDialog(
//                         title: Text('Missing Road Name!'),
//                         content: Text('Please add a valid Road Name.'),
//                         actions: [
//                           TextButton(
//                             onPressed: () => Navigator.pop(context),
//                             child: Text('Cancel'),
//                           ),
//                           TextButton(
//                             onPressed: () {
//                               Navigator.pop(context);
//                               _waitforRoad(context);
//                             },
//                             child: Text('OK'),
//                           ),
//                         ],
//                       ),
//                     );
//                   } else {
//                     setState(() {
//                       if (saving == true) {
//                         saving = false;
//                         btnName = 'Record';
//                       } else if (saving == false) {
//                         saving = true;
//                         btnName = 'Stop';
//                       }
//                     });
//                   }
//                 },
//                 child: Text(btnName),
//               ),
//             ),
//             SizedBox(
//               height: 5.0,
//             ),
//           ],
//         ),
//       ),
//       drawer: Drawer(
//         child: ListView(
//           children: [
//             DrawerHeader(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   Text(
//                     'Options',
//                     style: TextStyle(
//                       fontSize: 25.0,
//                       color: Colors.white,
//                     ),
//                   ),
//                   SizedBox(height: 8.0),
//                 ],
//               ),
//               decoration: BoxDecoration(
//                 color: Colors.blueAccent,
//               ),
//             ),
//             ListTile(
//               title: Row(
//                 children: [
//                   Icon(
//                     Icons.add,
//                     color: Colors.black,
//                     size: 25.0,
//                   ),
//                   SizedBox(
//                     width: 5.0,
//                   ),
//                   Text(
//                     'Add a Road',
//                     style: TextStyle(
//                       fontSize: 20.0,
//                     ),
//                   ),
//                 ],
//               ),
//               onTap: () {
//                 Navigator.pop(context);
//                 _waitforRoad(context);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   LineChartBarData xLine(List<FlSpot> points) {
//     return LineChartBarData(
//       spots: points,
//       dotData: FlDotData(
//         show: false,
//       ),
//       colors: [Colors.redAccent.withOpacity(0), Colors.redAccent],
//       colorStops: [0.1, 1.0],
//       barWidth: 4,
//       isCurved: false,
//     );
//   }

//   void _waitforRoad(BuildContext context) async {
//     pageResult = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => NewRoad(),
//       ),
//     );
//     setState(() {
//       roadName = pageResult;
//       saveName = roadName.replaceAll(RegExp('[^a-zA-Z0-9]'), '');
//       //print(saveName);
//     });

//     var spermission = await Permission.storage.status;
//     if (spermission.isGranted) {
//       final directory = await ExtStorage.getExternalStoragePublicDirectory(
//           ExtStorage.DIRECTORY_DOWNLOADS);
//       final File file =
//           await File('$directory/$saveName.txt').create(recursive: true);
//       final today = DateTime.now();
//       file.writeAsStringSync(
//           'Road : $roadName , Collection Date : ${today.toString()}\n',
//           mode: FileMode.write);
//     } else {
//       return;
//     }
//   }
// }
