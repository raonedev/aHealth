import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../domain/entities/progress_entry.dart';

abstract class ProgressEvent extends Equatable {
  const ProgressEvent();
  @override
  List<Object?> get props => [];
}

class LoadProgressEntries extends ProgressEvent {}

class AddProgressEntry extends ProgressEvent {
  final DateTime date;
  final double weight;
  final File image;
  const AddProgressEntry({required this.date, required this.weight, required this.image});
  @override
  List<Object?> get props => [date, weight, image];
}

class EditProgressEntry extends ProgressEvent {
  final ProgressEntry existing;
  final DateTime date;
  final double weight;
  final File? newImage;
  const EditProgressEntry({
    required this.existing,
    required this.date,
    required this.weight,
    this.newImage,
  });
  @override
  List<Object?> get props => [existing, date, weight, newImage];
}

class DeleteProgressEntry extends ProgressEvent {
  final ProgressEntry entry;
  const DeleteProgressEntry(this.entry);
  @override
  List<Object?> get props => [entry];
}
