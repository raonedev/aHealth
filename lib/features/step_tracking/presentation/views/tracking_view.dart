import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' hide ActivityType;
import 'package:share_plus/share_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../domain/entities/activity.dart';
import '../viewmodels/tracking_cubit.dart';
import '../viewmodels/tracking_state.dart';
import 'tracking_history_view.dart';
import 'widgets/journey_share_card.dart';

class StepsTrackingView extends StatefulWidget {
  const StepsTrackingView({super.key});
  static const String name = '/steps-tracking';
  @override
  State<StepsTrackingView> createState() => _StepsTrackingViewState();
}

class _StepsTrackingViewState extends State<StepsTrackingView>
    with WidgetsBindingObserver {
  PlatformMapController? _mapController;
  static const LatLng _fallbackCenter = LatLng(30.7046, 76.7179);
  LatLng? _initialCenter;

  final GlobalKey _shareCardKey = GlobalKey();
  String _lastKm = '';
  String _lastTime = '';
  final double _currentZoom = 16;

  Future<void> _shareWithImage() async {
    await WidgetsBinding.instance.endOfFrame;
    final bytes = await captureCardAsPng(_shareCardKey);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/journey.png');
    await file.writeAsBytes(bytes);

    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: SingleChildScrollView(
          child: Image.file(file),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Share'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path)],
        text: 'I just tracked $_lastKm km in $_lastTime on aHealth! 🏃‍♂️',
        subject: 'My Activity on aHealth',
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    debugPrint('permission: $permission');

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (mounted) setState(() => _initialCenter = _fallbackCenter);
      return;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    debugPrint('serviceEnabled: $serviceEnabled');

    if (!serviceEnabled) {
      if (mounted) setState(() => _initialCenter = _fallbackCenter);
      return;
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: Platform.isAndroid
            ? AndroidSettings(
                accuracy: LocationAccuracy.high,
                distanceFilter: 5,
                intervalDuration: const Duration(seconds: 3),
                foregroundNotificationConfig:
                    const ForegroundNotificationConfig(
                  notificationTitle: "OCTO is tracking",
                  notificationText: "Recording your route in the background",
                  enableWakeLock: true,
                ),
              )
            : AppleSettings(
                accuracy: LocationAccuracy.high,
                distanceFilter: 5,
                pauseLocationUpdatesAutomatically: false,
                showBackgroundLocationIndicator: true,
              ),
      ).timeout(const Duration(seconds: 10));
      if (mounted) {
        setState(() => _initialCenter = LatLng(pos.latitude, pos.longitude));
      }
    } catch (e) {
      debugPrint('location error: $e');
      if (mounted) setState(() => _initialCenter = _fallbackCenter);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cubit = context.read<TrackingCubit>();
    if (state == AppLifecycleState.paused && cubit.state is TrackingActive) {
      cubit.pause();
    } else if (state == AppLifecycleState.resumed &&
        cubit.state is TrackingPaused) {
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
            _mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(
                  LatLng(last.lat, last.lng), _currentZoom),
            );
          }
        } else {
          WakelockPlus.disable();
        }
      },
      builder: (context, state) {
        // build(): fix points extraction
        final points = state is TrackingActive
            ? state.points
            : state is TrackingCompleted
                ? (state).points
                : [];
        final latLngs = points.map((p) => LatLng(p.lat, p.lng)).toList();
        final resolvedCenter = latLngs.isNotEmpty
            ? latLngs.last
            : (_initialCenter ?? _fallbackCenter);
        final stillLoading = _initialCenter == null && latLngs.isEmpty;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Track Activity'),
            actions: [
              IconButton(
                icon: const Icon(Icons.history),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const TrackingHistoryView()),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: stillLoading
                    ? const Center(child: CircularProgressIndicator())
                    : PlatformMap(
                        initialCameraPosition: CameraPosition(
                            target: resolvedCenter, zoom: 16, bearing: 2),
                        onMapCreated: (c) => _mapController = c,
                        polylines: latLngs.length >= 2
                            ? {
                                Polyline(
                                  polylineId: PolylineId('route'),
                                  points: latLngs,
                                  width: 4,
                                  color: Colors.blue,
                                ),
                              }
                            : {},
                        markers: {
                          Marker(
                            markerId: MarkerId('current'),
                            position: latLngs.isNotEmpty
                                ? latLngs.last
                                : resolvedCenter,
                          ),
                        },
                      ),
              ),
              _StatsBar(
                state: state,
                onShare: () {
                  if (state is TrackingCompleted) {
                    final a = (state).activity;
                    _lastKm = (a.distanceMeters / 1000).toStringAsFixed(2);
                    _lastTime =
                        '${a.durationSeconds ~/ 60}:${(a.durationSeconds % 60).toString().padLeft(2, '0')}';
                    setState(() {});
                    Future.delayed(
                        const Duration(milliseconds: 100), _shareWithImage);
                  }
                },
              ),
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
  final VoidCallback onShare;
  const _StatsBar({required this.state, required this.onShare});

  @override
  Widget build(BuildContext context) {
    if (state is TrackingActive) {
      final s = state as TrackingActive;
      final km = s.distanceMeters / 1000;
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('${km.toStringAsFixed(2)} km'),
            Text(
                '${s.elapsed.inMinutes}:${(s.elapsed.inSeconds % 60).toString().padLeft(2, '0')}'),
            Text('${s.paceSecPerKm.toStringAsFixed(0)} s/km'),
          ],
        ),
      );
    }
    if (state is TrackingCompleted) {
      final a = (state as TrackingCompleted).activity;
      final km = a.distanceMeters / 1000;
      final mins = a.durationSeconds ~/ 60;
      final secs = (a.durationSeconds % 60).toString().padLeft(2, '0');
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('${km.toStringAsFixed(2)} km'),
                Text('$mins:$secs'),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: onShare,
              icon: const Icon(Icons.share),
              label: const Text('Share Journey'),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
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
            ElevatedButton(
                onPressed: cubit.resume, child: const Text('Resume')),
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
