import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../blocs/weight/weight_cubit.dart';
import '../../../../core/di/service_locator.dart';
import '../../data/repositories/progress_repository.dart';
import 'progress_event.dart';
import 'progress_state.dart';

class ProgressBloc extends Bloc<ProgressEvent, ProgressState> {
  final ProgressRepository repository;

  ProgressBloc(this.repository) : super(const ProgressState()) {
    on<LoadProgressEntries>(_onLoad);
    on<AddProgressEntry>(_onAdd);
    on<EditProgressEntry>(_onEdit);
    on<DeleteProgressEntry>(_onDelete);
  }

  Future<void> _onLoad(
      LoadProgressEntries event, Emitter<ProgressState> emit) async {
    emit(state.copyWith(status: ProgressStatus.loading));
    try {
      final entries = await repository.getEntries();
      emit(state.copyWith(status: ProgressStatus.loaded, entries: entries));
    } catch (e) {
      emit(state.copyWith(
          status: ProgressStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onAdd(
      AddProgressEntry event, Emitter<ProgressState> emit) async {
    try {
      await repository.addEntry(date: event.date, weight: event.weight, pickedImage: event.image);
       await sl<WeightCubit>()
        .addWeight(wrightInKg: event.weight, date: event.date);
      final entries = await repository.getEntries();
      emit(state.copyWith(status: ProgressStatus.loaded, entries: entries));
    } catch (e) {
      emit(state.copyWith(
          status: ProgressStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onEdit(
      EditProgressEntry event, Emitter<ProgressState> emit) async {
    try {
      await repository.updateEntry(
        existing: event.existing,
        date: event.date,
        weight: event.weight,
        newPickedImage: event.newImage,
      );
      final entries = await repository.getEntries();
      emit(state.copyWith(status: ProgressStatus.loaded, entries: entries));
    } catch (e) {
      emit(state.copyWith(
          status: ProgressStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onDelete(
      DeleteProgressEntry event, Emitter<ProgressState> emit) async {
    try {
      await repository.deleteEntry(event.entry);
      final entries = await repository.getEntries();
      emit(state.copyWith(status: ProgressStatus.loaded, entries: entries));
    } catch (e) {
      emit(state.copyWith(
          status: ProgressStatus.error, errorMessage: e.toString()));
    }
  }
}
