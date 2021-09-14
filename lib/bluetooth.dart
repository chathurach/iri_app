// For performing some operations asynchronously
import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

// For using PlatformException
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:iri_app/onDataRecieved.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BluetoothApp(),
    );
  }
}

class BluetoothApp extends StatefulWidget {
  @override
  _BluetoothAppState createState() => _BluetoothAppState();
}

class _BluetoothAppState extends State<BluetoothApp> {
  // Initializing the Bluetooth connection state to be unknown
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  // Get the instance of the Bluetooth
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  // Track the Bluetooth connection with the remote device
  BluetoothConnection? connection;

  late int _deviceState;

  bool isDisconnecting = false;

  Map<String, Color> colors = {
    'onBorderColor': Colors.green,
    'offBorderColor': Colors.red,
    'neutralBorderColor': Colors.transparent,
    'onTextColor': Colors.green.shade700,
    'offTextColor': Colors.red.shade200,
    'neutralTextColor': Colors.blue,
  };

  // To track whether the device is still connected to Bluetooth
  bool get isConnected => connection != null && connection!.isConnected;

  // Define some variables, which will be required later
  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice? _device = null;
  bool _connected = false;
  bool _isButtonUnavailable = false;
  List<double> fData = List<double>.filled(11, 0.0); // formatted data

  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    _deviceState = 0; // neutral

    // If the bluetooth of the device is not enabled,
    // then request permission to turn on bluetooth
    // as the app starts up
    enableBluetooth();

    // Listen for further state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
        if (_bluetoothState == BluetoothState.STATE_OFF) {
          _isButtonUnavailable = true;
        }
        getPairedDevices();
      });
    });
  }

  @override
  void dispose() {
    // Avoid memory leak and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection!.dispose();
      //connection = null;
    }

    super.dispose();
  }

  // Request Bluetooth permission from the user
  Future<bool?> enableBluetooth() async {
    // Retrieving the current Bluetooth state
    _bluetoothState = await FlutterBluetoothSerial.instance.state;

    // If the bluetooth is off, then turn it on first
    // and then retrieve the devices that are paired.
    if (_bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      await getPairedDevices();
      return true;
    } else {
      await getPairedDevices();
    }
    return false;
  }

  // For retrieving and storing the paired devices
  // in a list.
  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    // To get the list of paired devices
    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }

    // It is an error to call [setState] unless [mounted] is true.
    if (!mounted) {
      return;
    }

    // Store the [devices] list in the [_devicesList] for accessing
    // the list outside this class
    setState(() {
      _devicesList = devices;
    });
  }

  // Now, its time to build the UI
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Flutter Bluetooth"),
          backgroundColor: Colors.deepPurple,
          actions: <Widget>[
            TextButton.icon(
              icon: Icon(
                Icons.refresh,
                color: Colors.white,
              ),
              label: Text(
                "Refresh",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              // shape: RoundedRectangleBorder(
              //   borderRadius: BorderRadius.circular(30),
              // ),
              // splashColor: Colors.deepPurple,
              onPressed: () async {
                // So, that when new devices are paired
                // while the app is running, user can refresh
                // the paired devices list.
                await getPairedDevices().then((_) {
                  show('Device list refreshed');
                });
              },
            ),
          ],
        ),
        body: Container(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Visibility(
                visible: _isButtonUnavailable &&
                    _bluetoothState == BluetoothState.STATE_ON,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.yellow,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Enable Bluetooth',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Switch(
                      value: _bluetoothState.isEnabled,
                      onChanged: (bool value) {
                        future() async {
                          if (value) {
                            await FlutterBluetoothSerial.instance
                                .requestEnable();
                          } else {
                            await FlutterBluetoothSerial.instance
                                .requestDisable();
                          }

                          await getPairedDevices();
                          _isButtonUnavailable = false;

                          if (_connected) {
                            _disconnect();
                          }
                        }

                        future().then((_) {
                          setState(() {});
                        });
                      },
                    )
                  ],
                ),
              ),
              Stack(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      // Padding(
                      //   padding: const EdgeInsets.only(top: 10),
                      //   child: Text(
                      //     "PAIRED DEVICES",
                      //     style: TextStyle(fontSize: 24, color: Colors.blue),
                      //     textAlign: TextAlign.center,
                      //   ),
                      // ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              // Text(
                              //   'Device:',
                              //   style: TextStyle(
                              //     fontWeight: FontWeight.bold,
                              //   ),
                              // ),
                              DropdownButton<BluetoothDevice>(
                                items: _getDeviceItems(),
                                onChanged: (value) =>
                                    setState(() => _device = value!),
                                value: _devicesList.isNotEmpty ? _device : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _isButtonUnavailable
                            ? null
                            : _connected
                                ? _disconnect
                                : _connect,
                        child: Text(_connected ? 'Disconnect' : 'Connect'),
                      ),
                      Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: Table(
                              defaultColumnWidth: FixedColumnWidth(
                                  ((MediaQuery.of(context).size.width - 35) /
                                      6)),
                              children: [
                                TableRow(
                                  children: [
                                    _fillCell('x :'),
                                    _fillCell(
                                      fData[0].toStringAsFixed(2),
                                    ),
                                    _fillCell('y :'),
                                    _fillCell(
                                      fData[1].toStringAsFixed(2),
                                    ),
                                    _fillCell('z :'),
                                    _fillCell(
                                      fData[2].toStringAsFixed(2),
                                    ),
                                  ],
                                ),
                                TableRow(children: [
                                  _fillCell('xa:'),
                                  _fillCell(
                                    fData[3].toStringAsFixed(2),
                                  ),
                                  _fillCell('ya:'),
                                  _fillCell(
                                    fData[4].toStringAsFixed(2),
                                  ),
                                  _fillCell('za:'),
                                  _fillCell(
                                    fData[5].toStringAsFixed(2),
                                  ),
                                ]),
                                TableRow(children: [
                                  _fillCell('xr:'),
                                  _fillCell(
                                    fData[6].toStringAsFixed(2),
                                  ),
                                  _fillCell('yr:'),
                                  _fillCell(
                                    fData[7].toStringAsFixed(2),
                                  ),
                                  _fillCell('zr:'),
                                  _fillCell(
                                    fData[8].toStringAsFixed(2),
                                  ),
                                ])
                              ],
                            ),
                          )),
                    ],
                  ),
                  Container(
                    color: Colors.blue,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Create the List of devices to be shown in Dropdown Menu
  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devicesList.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      _devicesList.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text(device.name!),
          value: device,
        ));
      });
    }
    return items;
  }

  // Method to connect to bluetooth
  void _connect() async {
    setState(() {
      _isButtonUnavailable = true;
    });
    if (_device == null) {
      show('No device selected');
    } else {
      if (!isConnected) {
        await BluetoothConnection.toAddress(_device!.address)
            .then((_connection) {
          print('Connected to the device');
          connection = _connection;
          setState(() {
            _connected = true;
          });

          connection!.input!
              .listen((value) => {
                    setState(() {
                      fData = onDataReceived(value);
                    })
                  })
              .onDone(() {
            if (isDisconnecting) {
              print('Disconnecting locally!');
            } else {
              print('Disconnected remotely!');
            }
            if (this.mounted) {
              setState(() {});
            }
          });
        }).catchError((error) {
          print('Cannot connect, exception occurred');
          print(error);
        });
        show('Device connected');

        setState(() => _isButtonUnavailable = false);
      }
    }
  }

  // Method to disconnect bluetooth
  void _disconnect() async {
    setState(() {
      _isButtonUnavailable = true;
      _deviceState = 0;
    });

    await connection!.close();
    show('Device disconnected');
    fData.fillRange(0, 11, 0.0);
    if (!connection!.isConnected) {
      setState(() {
        _connected = false;
        _isButtonUnavailable = false;
      });
    }
  }

  // // Method to send message,
  // // for turning the Bluetooth device on
  // void _sendOnMessageToBluetooth() async {
  //   connection.output.add(utf8.encode("1" + "\r\n"));
  //   await connection.output.allSent;
  //   show('Device Turned On');
  //   setState(() {
  //     _deviceState = 1; // device on
  //   });
  // }

  // // Method to send message,
  // // for turning the Bluetooth device off
  // void _sendOffMessageToBluetooth() async {
  //   connection.output.add(utf8.encode("0" + "\r\n"));
  //   await connection.output.allSent;
  //   show('Device Turned Off');
  //   setState(() {
  //     _deviceState = -1; // device off
  //   });
  // }

  // Method to show a Snackbar,
  // taking message as the text
  Future show(
    String message, {
    Duration duration: const Duration(seconds: 3),
  }) async {
    await new Future.delayed(new Duration(milliseconds: 100));
    _scaffoldKey.currentState!.showSnackBar(
      new SnackBar(
        content: new Text(
          message,
        ),
        duration: duration,
      ),
    );
  }

  TableCell _fillCell(String _text) {
    TableCell _cell;
    _cell = TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Text(
        _text,
        textAlign: TextAlign.end,
      ),
    );
    return _cell;
  }
}
