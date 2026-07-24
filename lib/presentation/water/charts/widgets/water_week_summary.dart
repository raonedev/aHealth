class WaterWeekSummary {
  final int weekNum;
  final DateTime start, end;
  final double total, avg;
  const WaterWeekSummary({required this.weekNum, required this.start,
      required this.end, required this.total, required this.avg});
}