import 'package:geolocator/geolocator.dart';
import '../entities/location_point.dart';

class CalculateDistance {
  double call(LocationPoint a, LocationPoint b) =>
      Geolocator.distanceBetween(a.lat, a.lng, b.lat, b.lng);
}