import 'package:geolocator/geolocator.dart';
import '../repositories/tracking_repository.dart';

class GetLocationStream {
  final TrackingRepository repo;
  GetLocationStream(this.repo);
  Stream<Position> call() => repo.positionStream;
}