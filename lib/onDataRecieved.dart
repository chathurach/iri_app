//This recieves the Uint8 data from the sensor which decode it to the atual
//accelerometer values

import 'dart:typed_data';

List<double> onDataReceived(Uint8List data) {
  List<double> _fData = List<double>.filled(11, 0.0);
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
          _fData[0] = (packBuffer[1].abs().toInt() << 8 |
                  (packBuffer[0].abs().toInt() & 0xff)) /
              32768.0 *
              16;

          _fData[1] = (packBuffer[3].abs().toInt() << 8 |
                  (packBuffer[2].abs().toInt() & 0xff)) /
              32768.0 *
              16;
          _fData[2] = (packBuffer[5].abs().toInt() << 8 |
                  (packBuffer[4].abs().toInt() & 0xff)) /
              32768.0 *
              16;
          if (packBuffer[1] < 0 || packBuffer[0] < 0) {
            _fData[0] = _fData[0] * -1;
          }
          if (packBuffer[3] < 0 || packBuffer[2] < 0) {
            _fData[1] = _fData[1] * -1;
          }
          if (packBuffer[5] < 0 || packBuffer[4] < 0) {
            _fData[2] = _fData[2] * -1;
          }
          //print('${_fData[0]}, ${_fData[1]}, ${_fData[2]}');
          break;
        case 82: // for angular accelerations
          _fData[3] = (packBuffer[1].abs().toInt() << 8 |
                  (packBuffer[0].abs().toInt() & 0xff)) /
              32768.0 *
              2000;

          _fData[4] = (packBuffer[3].abs().toInt() << 8 |
                  (packBuffer[2].abs().toInt() & 0xff)) /
              32768.0 *
              2000;
          _fData[5] = (packBuffer[5].abs().toInt() << 8 |
                  (packBuffer[4].abs().toInt() & 0xff)) /
              32768.0 *
              2000;
          if (packBuffer[1] < 0 || packBuffer[0] < 0) {
            _fData[3] = _fData[3] * -1;
          }
          if (packBuffer[3] < 0 || packBuffer[2] < 0) {
            _fData[4] = _fData[4] * -1;
          }
          if (packBuffer[5] < 0 || packBuffer[4] < 0) {
            _fData[5] = _fData[5] * -1;
          }
          //print('${_fData[3]}, ${_fData[4]}, ${_fData[5]}');
          break;
        case 83: // for gyrascope values
          _fData[6] = (packBuffer[1].abs().toInt() << 8 |
                  (packBuffer[0].abs().toInt() & 0xff)) /
              32768.0 *
              180;

          _fData[7] = (packBuffer[3].abs().toInt() << 8 |
                  (packBuffer[2].abs().toInt() & 0xff)) /
              32768.0 *
              180;
          _fData[8] = (packBuffer[5].abs().toInt() << 8 |
                  (packBuffer[4].abs().toInt() & 0xff)) /
              32768.0 *
              180;
          if (packBuffer[1] < 0 || packBuffer[0] < 0) {
            _fData[6] = _fData[6] * -1;
          }
          if (packBuffer[3] < 0 || packBuffer[2] < 0) {
            _fData[7] = _fData[7] * -1;
          }
          if (packBuffer[5] < 0 || packBuffer[4] < 0) {
            _fData[8] = _fData[8] * -1;
          }
          //print('${_fData[3]}, ${_fData[4]}, ${_fData[5]}');
          break;
      }
    }
  }
  return _fData;
}
