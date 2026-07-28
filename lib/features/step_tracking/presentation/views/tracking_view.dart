import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' hide ActivityType;
import 'package:share_plus/share_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../domain/entities/activity.dart';
import '../../domain/entities/location_point.dart';
import '../viewmodels/tracking_cubit.dart';
import '../viewmodels/tracking_state.dart';
import 'tracking_history_view.dart';
import 'widgets/journey_share_card.dart';
import 'widgets/marker.dart';

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
  BitmapDescriptor? _runnerIcon;
  bool? _lastIsMoving;
  double _lastHeading = 0;

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

  Future<Uint8List> _widgetToBytes(Widget widget, {double size = 100}) async {
    final repaintBoundary = RenderRepaintBoundary();
    final renderView = RenderView(
      view: WidgetsBinding.instance.platformDispatcher.views.first,
      configuration: ViewConfiguration(
        logicalConstraints: BoxConstraints.tight(Size(size, size)),
        devicePixelRatio: 3.0,
      ),
      child: RenderPositionedBox(child: repaintBoundary),
    );
    final pipelineOwner = PipelineOwner()..rootNode = renderView;
    renderView.prepareInitialFrame();

    final buildOwner = BuildOwner(focusManager: FocusManager());
    final element = RenderObjectToWidgetAdapter<RenderBox>(
      container: repaintBoundary,
      child: Directionality(textDirection: TextDirection.ltr, child: widget),
    ).attachToRenderTree(buildOwner);

    buildOwner
      ..buildScope(element)
      ..finalizeTree();
    pipelineOwner
      ..flushLayout()
      ..flushCompositingBits()
      ..flushPaint();

    final image = await repaintBoundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<BitmapDescriptor> _makeMarkerIcon(
      {required bool isMoving, required double heading}) async {
    final bytes = await _widgetToBytes(
      RunnerMarker(isMoving: isMoving, heading: heading),
    );
    return BitmapDescriptor.fromBytes(bytes);
  }

  double _calculateHeading(LocationPoint from, LocationPoint to) {
    final lat1 = from.lat * math.pi / 180;
    final lat2 = to.lat * math.pi / 180;
    final dLng = (to.lng - from.lng) * math.pi / 180;
    final y = math.sin(dLng) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLng);
    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
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
      listener: (context, state) async {
        if (state is TrackingActive) {
          WakelockPlus.enable();
          if (state.points.isNotEmpty) {
            final last = state.points.last;
            bool isMoving = last.speed > 0.15;
            if (state.points.length >= 2) {
              final prev = state.points[state.points.length - 2];
              final distance = Geolocator.distanceBetween(
                  prev.lat, prev.lng, last.lat, last.lng);
              final timeDelta =
                  last.timestamp.difference(prev.timestamp).inMilliseconds /
                      1000;
              final computedSpeed = timeDelta > 0 ? distance / timeDelta : 0.0;
              isMoving = computedSpeed > 0.15 || last.speed > 0.15;
            }
            final heading = state.points.length >= 2
                ? _calculateHeading(state.points[state.points.length - 2], last)
                : 0.0; // adjust to your LocationPoint field
            if (_lastIsMoving != isMoving ||
                (heading - _lastHeading).abs() > 10) {
              _lastIsMoving = isMoving;
              _lastHeading = heading;
              _runnerIcon =
                  await _makeMarkerIcon(isMoving: isMoving, heading: heading);
              if (mounted) setState(() {});
            }
            _mapController?.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                    target: LatLng(last.lat, last.lng),
                    zoom: _currentZoom,
                    tilt: 45),
              ),
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
                          target: resolvedCenter,
                          zoom: 16,
                          bearing: 2,
                          tilt: 45,
                        ),
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
                            icon: _runnerIcon ?? BitmapDescriptor.defaultMarker,
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
      
      // Format pace as min:sec
      final paceMinutes = s.paceSecPerKm ~/ 60;
      final paceSeconds = (s.paceSecPerKm % 60).toInt();
      final paceFormatted = '$paceMinutes:${paceSeconds.toString().padLeft(2, '0')}';
      
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('${km.toStringAsFixed(2)} km'),
            Text(
                '${s.elapsed.inMinutes}:${(s.elapsed.inSeconds % 60).toString().padLeft(2, '0')}'),
            Text('$paceFormatted /km'), 
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
