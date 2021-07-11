//This is based on the
//https://stackoverflow.com/questions/37727340/android-detect-downward-acceleration-specifically-an-elevator/39333427#39333427
import 'dart:async';

import 'dart:io';

double vAcceleration(Map results) {
  final double verticleAcc = ((results['x'] * results['gx'] / 9.8) +
      (results['y'] * results['gy'] / 9.8) +
      (results['z'] * results['gz'] / 9.8));
  return verticleAcc;
}
