import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class DataModel extends ChangeNotifier {
  List<double> _fData = List<double>.filled(11, 0.0);
  List<double> get fData => _fData;

  void setData(List<double> data) {
    _fData = List.from(data);
    notifyListeners();
  }
}
