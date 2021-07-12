import 'dart:math' show cos, sqrt, asin;

double getDistance(List locations) {
  final size = locations.length;
  final lat1 = locations[0].latitude;
  final lat2 = locations[size - 1].latitude;
  final lon1 = locations[0].longitude;
  final lon2 = locations[size - 1].longitude;

  var p = 0.017453292519943295;
  var c = cos;
  var a = 0.5 -
      c((lat2 - lat1) * p) / 2 +
      c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a));
}
