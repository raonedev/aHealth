import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart' hide ActivityType;
import 'package:latlong2/latlong.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../domain/entities/activity.dart';
import '../viewmodels/tracking_cubit.dart';
import '../viewmodels/tracking_state.dart';

class StepsTrackingView extends StatefulWidget {
  const StepsTrackingView({super.key});

  @override
  State<StepsTrackingView> createState() => _StepsTrackingViewState();
}

class _StepsTrackingViewState extends State<StepsTrackingView> with WidgetsBindingObserver {
  final MapController _mapController = MapController();
  static const LatLng _fallbackCenter = LatLng(30.7046, 76.7179);
  LatLng? _initialCenter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() => _initialCenter = LatLng(pos.latitude, pos.longitude));
      }
    } catch (_) {
      // permission denied or location off — fallback stays in effect
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cubit = context.read<TrackingCubit>();
    if (state == AppLifecycleState.paused && cubit.state is TrackingActive) {
      cubit.pause();
    } else if (state == AppLifecycleState.resumed && cubit.state is TrackingPaused) {
      cubit.resume();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TrackingCubit, TrackingState>(
      listener: (context, state) {
        if (state is TrackingActive) {
          WakelockPlus.enable();
          if (state.points.isNotEmpty) {
            final last = state.points.last;
            _mapController.move(LatLng(last.lat, last.lng), _mapController.camera.zoom);
          }
        } else {
          WakelockPlus.disable();
        }
      },
      builder: (context, state) {
        final points = state is TrackingActive
            ? state.points
            : state is TrackingCompleted
                ? state.points
                : [];
        final latLngs = points.map((p) => LatLng(p.lat, p.lng)).toList();
        final resolvedCenter = latLngs.isNotEmpty
            ? latLngs.last
            : (_initialCenter ?? _fallbackCenter);
        final stillLoading = _initialCenter == null && latLngs.isEmpty;

        return Scaffold(
          appBar: AppBar(title: const Text('Track Activity')),
          body: Column(
            children: [
              Expanded(
                child: stillLoading
                    ? const Center(child: CircularProgressIndicator())
                    : FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: resolvedCenter,
                          initialZoom: 16,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'dev.raone.ahealth',
                            maxNativeZoom: 19,
                          ),
                          if (latLngs.length >= 2)
                            PolylineLayer(
                              polylines: [
                                Polyline(points: latLngs, strokeWidth: 4, color: Colors.blue),
                              ],
                            ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: latLngs.isNotEmpty ? latLngs.last : resolvedCenter,
                                width: 24,
                                height: 24,
                                child: const Icon(Icons.circle, color: Colors.blue, size: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
              _StatsBar(state: state),
              _Controls(state: state),
            ],
          ),
        );
      },
    );
  }
}

class _StatsBar extends StatelessWidget {
  final TrackingState state;
  const _StatsBar({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state is! TrackingActive) return const SizedBox.shrink();
    final s = state as TrackingActive;
    final km = s.distanceMeters / 1000;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text('${km.toStringAsFixed(2)} km'),
          Text('${s.elapsed.inMinutes}:${(s.elapsed.inSeconds % 60).toString().padLeft(2, '0')}'),
          Text('${s.paceSecPerKm.toStringAsFixed(0)} s/km'),
        ],
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  final TrackingState state;
  const _Controls({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TrackingCubit>();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (state is TrackingIdle)
            ElevatedButton(onPressed: cubit.start, child: const Text('Start')),
          if (state is TrackingActive && state is! TrackingPaused)
            ElevatedButton(onPressed: cubit.pause, child: const Text('Pause')),
          if (state is TrackingPaused)
            ElevatedButton(onPressed: cubit.resume, child: const Text('Resume')),
          if (state is TrackingActive)
            ElevatedButton(
              onPressed: () => cubit.stop(type: ActivityType.run, calories: 0),
              child: const Text('Stop'),
            ),
        ],
      ),
    );
  }
}