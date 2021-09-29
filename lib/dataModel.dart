import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:location/location.dart';

//This is used as the provider model to update the valus without refresing the build method
class DataModel extends ChangeNotifier {
  List<double> _fData = List<double>.filled(11, 0.0);
  late LocationData _location;
  bool _recording = false;
  bool get recording => _recording;
  List<double> get fData => _fData;
  LocationData get locationData => _location;
//set the acceleration data values and call listners
  void setData(Uint8List data) {
    //print(data);
    List<int> queuBuffer = List.empty(growable: true);
    if (data.length > 0) {
      for (int i = 0; i < data.length; i++) {
        if (data[i] > 127) {
          int temp = data[i] - 256;
          queuBuffer.add(temp);
        } else {
          queuBuffer.add(data[i]);
        }
      }
    }
    //print(queuBuffer);
    int sHead;
    List<int> packBuffer = List<int>.filled(9, 0);

    while (queuBuffer.length >= 11) {
      var temp = queuBuffer.first;
      queuBuffer.removeAt(0);
      //Header packet is 85 (0x55) which indicate start of the data stream
      if (temp == 85) {
        sHead = queuBuffer.first;
        queuBuffer.removeAt(0);
        for (int i = 0; i <= 8; i++) {
          packBuffer[i] = queuBuffer.first;
          queuBuffer.removeAt(0);
        }
        switch (sHead) {
          case 81: //for liner accelerations
            _fData[0] =
                ((packBuffer[1].abs().toInt() << 8) + packBuffer[0].toInt()) /
                    32768.0 *
                    16;

            _fData[1] =
                ((packBuffer[3].abs().toInt() << 8) + packBuffer[2].toInt()) /
                    32768.0 *
                    16;
            _fData[2] =
                ((packBuffer[5].abs().toInt() << 8) + packBuffer[4].toInt()) /
                    32768.0 *
                    16;
            if (packBuffer[1] < 0) {
              _fData[0] = _fData[0] * -1;
            }
            if (packBuffer[3] < 0) {
              _fData[1] = _fData[1] * -1;
            }
            if (packBuffer[5] < 0) {
              _fData[2] = _fData[2] * -1;
            }

            break;
          case 82: // for angular accelerations
            _fData[3] =
                ((packBuffer[1].abs().toInt() << 8) + packBuffer[0].toInt()) /
                    32768.0 *
                    2000;

            _fData[4] =
                ((packBuffer[3].abs().toInt() << 8) + packBuffer[2].toInt()) /
                    32768.0 *
                    2000;
            _fData[5] =
                ((packBuffer[5].abs().toInt() << 8) + packBuffer[4].toInt()) /
                    32768.0 *
                    2000;
            if (packBuffer[1] < 0) {
              _fData[3] = _fData[3] * -1;
            }
            if (packBuffer[3] < 0) {
              _fData[4] = _fData[4] * -1;
            }
            if (packBuffer[5] < 0) {
              _fData[5] = _fData[5] * -1;
            }
            //print('${_fData[3]}, ${_fData[4]}, ${_fData[5]}');
            break;
          case 83: // for gyrascope values
            _fData[6] =
                ((packBuffer[1].abs().toInt() << 8) + packBuffer[0].toInt()) /
                    32768.0 *
                    180;

            _fData[7] =
                ((packBuffer[3].abs().toInt() << 8) + packBuffer[2].toInt()) /
                    32768.0 *
                    180;
            _fData[8] =
                ((packBuffer[5].abs().toInt() << 8) + packBuffer[4].toInt()) /
                    32768.0 *
                    180;
            if (packBuffer[1] < 0) {
              _fData[6] = _fData[6] * -1;
            }
            if (packBuffer[3] < 0) {
              _fData[7] = _fData[7] * -1;
            }
            if (packBuffer[5] < 0) {
              _fData[8] = _fData[8] * -1;
            }
            // print(packBuffer[3]);
            // print(packBuffer[2]);
            //print('${_fData[3]}, ${_fData[4]}, ${_fData[5]}');
            break;
        }
      }
    }

    //_fData = List.from(data);
    notifyListeners();
  }

//update the location data and notify listners
  void getLocation(LocationData l) {
    _location = l;
    _recording = true;
    notifyListeners();
  }

//set the ecording bool
  void setRecording(bool r) {
    _recording = r;
    notifyListeners();
  }
}
