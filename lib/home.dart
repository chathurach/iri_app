import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;
  String a = '';
  List<BluetoothDiscoveryResult> _deviceList =
      List<BluetoothDiscoveryResult>.empty(growable: true); // device list

  void _startDiscovery() {
    print('in');
    _streamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      setState(() {
        print('listning');
        final existingIndex = _deviceList.indexWhere(
            (element) => element.device.address == r.device.address);
        if (existingIndex >= 0)
          _deviceList[existingIndex] = r;
        else
          _deviceList.add(r);
        print('add');
      });
    });

    _streamSubscription!.onError((e) {
      print(e);
    });

    _streamSubscription!.onDone(() {
      setState(() {
        print('done');
        print(_deviceList);
        //isDiscovering = false;
      });
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and cancel discovery
    _streamSubscription?.cancel();

    super.dispose();
  }

  List<DropdownMenuItem<BluetoothDiscoveryResult>> _getDevices() {
    List<DropdownMenuItem<BluetoothDiscoveryResult>> items = [];
    if (_deviceList.isEmpty) {
      items.add(
        DropdownMenuItem(
          child: Text(
            'None',
          ),
        ),
      );
    } else {
      _deviceList.forEach(
        (device) {
          items.add(
            DropdownMenuItem(
              child: Text(
                device.device.name.toString(),
              ),
              value: device,
            ),
          );
        },
      );
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Data Collection',
        ),
      ),
      body: Center(
        child: Row(
          children: [
            ElevatedButton(
              onPressed: () => _startDiscovery(),
              child: Text('Find'),
            ),
            DropdownButton(items: _getDevices()),
          ],
        ),
      ),
    );
  }
}
