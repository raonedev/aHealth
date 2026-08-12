import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screenshot/screenshot.dart';
import '../bloc/progress_bloc.dart';
import '../bloc/progress_event.dart';
import '../bloc/progress_state.dart';
import '../widgets/weight_chart.dart';
import '../widgets/monthly_collage.dart';
import 'add_edit_entry_screen.dart';

class ProgressPhotosScreen extends StatefulWidget {
  const ProgressPhotosScreen({super.key});
  static const String progressPhotos = "/progressPhotos";

  @override
  State<ProgressPhotosScreen> createState() => _ProgressPhotosScreenState();
}

class _ProgressPhotosScreenState extends State<ProgressPhotosScreen> {
  final screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    context.read<ProgressBloc>().add(LoadProgressEntries());
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: const Text('Progress Photos'),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_on),
            tooltip: 'Generate monthly collage',
            onPressed: () {
              MonthlyCollage.generateAndSave(
              context: context,
              controller: screenshotController,
            );
            },
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: kToolbarHeight+20),
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF3B6D11),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditEntryScreen()),
          ),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      body: BlocBuilder<ProgressBloc, ProgressState>(
        builder: (context, state) {
          if (state.status == ProgressStatus.loading) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF3B6D11)));
          }
          if (state.status == ProgressStatus.error) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          }
          final entries = state.entries;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              _card(child: WeightChart(entries: entries)),
              const SizedBox(height: 16),
              const Text('This month\'s collage',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 8),
              _card(
                child: MonthlyCollage(
                  month: DateTime.now(),
                  entries: entries,
                  controller: screenshotController,
                ),
              ),
              const SizedBox(height: 16),
              const Text('All entries',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 8),
              ...entries.reversed.map((e) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(File(e.photoPath),
                            width: 50, height: 50, fit: BoxFit.cover),
                      ),
                      title: Text('${e.weight} kg'),
                      subtitle:
                          Text('${e.date.day}/${e.date.month}/${e.date.year}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: Color(0xFF3B6D11)),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      AddEditEntryScreen(existing: e)),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.redAccent),
                            onPressed: () => context
                                .read<ProgressBloc>()
                                .add(DeleteProgressEntry(e)),
                          ),
                        ],
                      ),
                    ),
                  )),
            ],
          );
        },
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }
}
