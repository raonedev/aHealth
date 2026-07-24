import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart' show LatLng;
import '../../domain/entities/activity.dart';
import '../viewmodels/tracking_cubit.dart';
import 'widgets/journey_share_card.dart';

class TrackingHistoryView extends StatefulWidget {
  const TrackingHistoryView({super.key});

  @override
  State<TrackingHistoryView> createState() => _TrackingHistoryViewState();
}

class _TrackingHistoryViewState extends State<TrackingHistoryView> {
  final GlobalKey _shareCardKey = GlobalKey();
  List<LatLng> _shareLatLngs = [];
  String _shareKm = '';
  String _shareTime = '';

  Future<void> _shareItem(Activity a) async {
  final cubit = context.read<TrackingCubit>();
  final points = await cubit.repository.getPointsForActivity(a.id);

  setState(() {
    _shareLatLngs = points.map((p) => LatLng(p.lat, p.lng)).toList();
    _shareKm = (a.distanceMeters / 1000).toStringAsFixed(2);
    _shareTime =
        '${a.durationSeconds ~/ 60}:${(a.durationSeconds % 60).toString().padLeft(2, '0')}';
  });

  await WidgetsBinding.instance.endOfFrame;
  final bytes = await captureCardAsPng(_shareCardKey);
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/journey_${a.id}.png');
  await file.writeAsBytes(bytes);

  if (!mounted) return;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      content: SingleChildScrollView(child: Image.file(file)),
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
      text: 'I tracked $_shareKm km in $_shareTime on aHealth! 🏃‍♂️',
      subject: 'My Activity on aHealth',
    ));
  }
}

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TrackingCubit>();
    return Scaffold(
      appBar: AppBar(title: const Text('Activity History')),
      body: Stack(
        children: [
          FutureBuilder(
            future: cubit.getHistory(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final items = snapshot.data as List<Activity>;
              if (items.isEmpty) {
                return const Center(child: Text('No activities yet'));
              }
              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final item = items[i];
                  final km = (item.distanceMeters / 1000).toStringAsFixed(2);
                  final mins = item.durationSeconds ~/ 60;
                  final secs =
                      (item.durationSeconds % 60).toString().padLeft(2, '0');
                  return ListTile(
                    leading: const Icon(Icons.directions_run),
                    title: Text('$km km'),
                    subtitle: Text('$mins:$secs'),
                    trailing: IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () => _shareItem(item),
                    ),
                  );
                },
              );
            },
          ),
          Positioned(
            left: -9999,
            child: JourneyShareCard(
              repaintKey: _shareCardKey,
              points: _shareLatLngs,
              km: _shareKm,
              time: _shareTime,
            ),
          ),
        ],
      ),
    );
  }
}