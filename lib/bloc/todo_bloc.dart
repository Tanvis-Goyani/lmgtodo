import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lmgtodo/models/todo_model.dart';
import 'package:lmgtodo/repository/todo_repository.dart';
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
      bool reachedZero = false;
      final updated = (state as TodoLoaded).todos.map((t) {
        if (t.isRunning) {
          final newTime = t.remainingSeconds - 1;
          if (newTime <= 0) {
            reachedZero = true;
            return t.copyWith(
              remainingSeconds: 0,
              isRunning: false,
              status: TodoStatus.done,
            );
          }
          return t.copyWith(remainingSeconds: newTime);
        }
        return t;
      }).toList();

      emit(TodoLoaded(updated));

      _tickCount++;
      if (_tickCount % 10 == 0 || reachedZero) {
        for (final t in updated) {
          if (t.status != TodoStatus.todo) await repository.update(t);
        }
      }

      final anyRunning = updated.any((t) => t.isRunning);
      if (!anyRunning) _ticker?.cancel();
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
