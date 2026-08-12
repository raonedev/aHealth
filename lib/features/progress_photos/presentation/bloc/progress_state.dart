import 'package:equatable/equatable.dart';
import '../../domain/entities/progress_entry.dart';

enum ProgressStatus { initial, loading, loaded, error }

class ProgressState extends Equatable {
  final ProgressStatus status;
  final List<ProgressEntry> entries;
  final String? errorMessage;

  const ProgressState({
    this.status = ProgressStatus.initial,
    this.entries = const [],
    this.errorMessage,
  });

  ProgressState copyWith({
    ProgressStatus? status,
    List<ProgressEntry>? entries,
    String? errorMessage,
  }) {
    return ProgressState(
      status: status ?? this.status,
      entries: entries ?? this.entries,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, entries, errorMessage];
}
