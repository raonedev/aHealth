class StepDayRecord {
  const StepDayRecord({required this.time, required this.steps});

  final DateTime time;
  final double steps;
}

class StepHourCount {
  const StepHourCount({required this.time, required this.steps});

  final DateTime time;
  final double steps;
}

class StepDayData {
  const StepDayData({
    required this.hourlyCounts,
    required this.records,
  });

  factory StepDayData.fromRecords({
    required DateTime day,
    required Iterable<StepDayRecord> records,
  }) {
    final startOfDay = DateTime(day.year, day.month, day.day);
    final hourCounts = List<double>.filled(24, 0);
    final sortedRecords = records.toList()
      ..sort((a, b) => b.time.compareTo(a.time));

    for (final record in sortedRecords) {
      hourCounts[record.time.hour] += record.steps;
    }

    return StepDayData(
      hourlyCounts: List.generate(
        24,
        (hour) => StepHourCount(
          time: startOfDay.add(Duration(hours: hour)),
          steps: hourCounts[hour],
        ),
        growable: false,
      ),
      records: List.unmodifiable(sortedRecords),
    );
  }

  final List<StepHourCount> hourlyCounts;
  final List<StepDayRecord> records;

  double get totalSteps =>
      records.fold(0, (total, record) => total + record.steps);
}
