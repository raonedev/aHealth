import 'package:ahealth/blocs/charts/step_chart/step_day_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StepDayData.fromRecords', () {
    test('creates all 24 hourly buckets and sums records by hour', () {
      final day = DateTime(2026, 10, 14);
      final data = StepDayData.fromRecords(
        day: day,
        records: [
          StepDayRecord(time: DateTime(2026, 10, 14, 8, 10), steps: 120),
          StepDayRecord(time: DateTime(2026, 10, 14, 8, 45), steps: 80),
          StepDayRecord(time: DateTime(2026, 10, 14, 23, 5), steps: 25),
        ],
      );

      expect(data.hourlyCounts, hasLength(24));
      expect(data.hourlyCounts.first.time, DateTime(2026, 10, 14));
      expect(data.hourlyCounts[8].steps, 200);
      expect(data.hourlyCounts[9].steps, 0);
      expect(data.hourlyCounts.last.time, DateTime(2026, 10, 14, 23));
      expect(data.hourlyCounts.last.steps, 25);
      expect(data.totalSteps, 225);
    });

    test('orders records newest first', () {
      final data = StepDayData.fromRecords(
        day: DateTime(2026, 10, 14),
        records: [
          StepDayRecord(time: DateTime(2026, 10, 14, 8), steps: 10),
          StepDayRecord(time: DateTime(2026, 10, 14, 19), steps: 20),
        ],
      );

      expect(data.records.first.time.hour, 19);
    });
  });
}
