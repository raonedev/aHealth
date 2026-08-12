import 'package:equatable/equatable.dart';

class ProgressEntry extends Equatable {
  final String id;
  final DateTime date;
  final double weight;
  final String photoPath; // local file path

  const ProgressEntry({
    required this.id,
    required this.date,
    required this.weight,
    required this.photoPath,
  });

  ProgressEntry copyWith({
    String? id,
    DateTime? date,
    double? weight,
    String? photoPath,
  }) {
    return ProgressEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      weight: weight ?? this.weight,
      photoPath: photoPath ?? this.photoPath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'weight': weight,
      'photoPath': photoPath,
    };
  }

  factory ProgressEntry.fromMap(Map<String, dynamic> map) {
    return ProgressEntry(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      weight: (map['weight'] as num).toDouble(),
      photoPath: map['photoPath'] as String,
    );
  }

  @override
  List<Object?> get props => [id, date, weight, photoPath];
}
