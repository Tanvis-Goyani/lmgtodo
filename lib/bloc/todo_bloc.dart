import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/todo_model.dart';
import '../repository/todo_repository.dart';
import 'todo_event.dart';
import 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoRepository repository;
  Timer? _ticker;
  int _tickCount = 0;

  TodoBloc({required this.repository}) : super(TodoInitial()) {
    on<LoadTodos>(_onLoadTodos);
    on<AddTodo>(_onAddTodo);
    on<DeleteTodo>(_onDeleteTodo);
    on<StartTimer>(_onStartTimer);
    on<PauseTimer>(_onPauseTimer);
    on<TickTimers>(_onTickTimers);
    on<CompleteTodo>(_onCompleteTodo);
  }

  Future<void> _onLoadTodos(LoadTodos event, Emitter<TodoState> emit) async {
    final todos = repository.getAll();
    emit(TodoLoaded(todos));

    // Resume ticker if any todos were running when app was closed
    final anyRunning = todos.any((t) => t.isRunning);
    if (anyRunning) _startGlobalTicker();
  }

  Future<void> _onAddTodo(AddTodo event, Emitter<TodoState> emit) async {
    await repository.add(event.todo);
    if (state is TodoLoaded) {
      final current = (state as TodoLoaded).todos;
      emit(TodoLoaded([...current, event.todo]));
    }
  }

  Future<void> _onDeleteTodo(DeleteTodo event, Emitter<TodoState> emit) async {
    await repository.delete(event.id);
    if (state is TodoLoaded) {
      final updated = (state as TodoLoaded).todos
          .where((t) => t.id != event.id)
          .toList();
      emit(TodoLoaded(updated));
    }
  }

  Future<void> _onStartTimer(StartTimer event, Emitter<TodoState> emit) async {
    if (state is TodoLoaded) {
      final updated = (state as TodoLoaded).todos.map((t) {
        if (t.id == event.id) {
          return t.copyWith(isRunning: true, status: TodoStatus.inProgress);
        }
        return t;
      }).toList();

      final updatedTodo = updated.firstWhere((t) => t.id == event.id);
      await repository.update(updatedTodo);

      emit(TodoLoaded(updated));
      _startGlobalTicker();
    }
  }

  Future<void> _onPauseTimer(PauseTimer event, Emitter<TodoState> emit) async {
    if (state is TodoLoaded) {
      final updated = (state as TodoLoaded).todos.map((t) {
        if (t.id == event.id) return t.copyWith(isRunning: false);
        return t;
      }).toList();

      final updatedTodo = updated.firstWhere((t) => t.id == event.id);
      await repository.update(updatedTodo);

      emit(TodoLoaded(updated));

      final anyRunning = updated.any((t) => t.isRunning);
      if (!anyRunning) _ticker?.cancel();
    }
  }

  Future<void> _onTickTimers(TickTimers event, Emitter<TodoState> emit) async {
    if (state is TodoLoaded) {
      final updated = (state as TodoLoaded).todos.map((t) {
        if (t.isRunning)
          return t.copyWith(elapsedSeconds: t.elapsedSeconds + 1);
        return t;
      }).toList();

      emit(TodoLoaded(updated));

      // Persist to Hive every 10 seconds, not every tick
      _tickCount++;
      if (_tickCount % 10 == 0) {
        for (final t in updated.where((t) => t.isRunning)) {
          await repository.update(t);
        }
      }
    }
  }

  Future<void> _onCompleteTodo(
    CompleteTodo event,
    Emitter<TodoState> emit,
  ) async {
    if (state is TodoLoaded) {
      final updated = (state as TodoLoaded).todos.map((t) {
        if (t.id == event.id) {
          return t.copyWith(status: TodoStatus.done, isRunning: false);
        }
        return t;
      }).toList();

      final updatedTodo = updated.firstWhere((t) => t.id == event.id);
      await repository.update(updatedTodo);

      emit(TodoLoaded(updated));

      final anyRunning = updated.any((t) => t.isRunning);
      if (!anyRunning) _ticker?.cancel();
    }
  }

  void _startGlobalTicker() {
    if (_ticker != null && _ticker!.isActive) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      add(TickTimers());
    });
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}
