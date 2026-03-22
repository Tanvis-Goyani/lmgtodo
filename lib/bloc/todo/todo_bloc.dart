import 'package:lmgtodo/services/notification_service.dart';
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
    on<UpdateTodo>(_onUpdateTodo);
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

  void _emitError(Emitter<TodoState> emit, Object error) {
    if (state is TodoLoaded) {
      final todos = (state as TodoLoaded).todos;
      emit(TodoError(error.toString(), todos));
      emit(TodoLoaded(todos));
    }
  }

  Future<void> _onAddTodo(AddTodo event, Emitter<TodoState> emit) async {
    try {
      await repository.add(event.todo);
      if (state is TodoLoaded) {
        final current = (state as TodoLoaded).todos;
        emit(TodoLoaded([...current, event.todo]));
      }
    } catch (e) {
      _emitError(emit, e);
    }
  }

  Future<void> _onUpdateTodo(UpdateTodo event, Emitter<TodoState> emit) async {
    try {
      await repository.update(event.todo);
      if (state is TodoLoaded) {
        final updated = (state as TodoLoaded).todos.map((t) {
          return t.id == event.todo.id ? event.todo : t;
        }).toList();
        emit(TodoLoaded(updated));
      }
    } catch (e) {
      _emitError(emit, e);
    }
  }

  Future<void> _onDeleteTodo(DeleteTodo event, Emitter<TodoState> emit) async {
    try {
      await repository.delete(event.id);
      if (state is TodoLoaded) {
        final updated = (state as TodoLoaded).todos
            .where((t) => t.id != event.id)
            .toList();
        emit(TodoLoaded(updated));
      }
    } catch (e) {
      _emitError(emit, e);
    }
  }

  Future<void> _onStartTimer(StartTimer event, Emitter<TodoState> emit) async {
    try {
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
        NotificationService.instance.showStarted(updatedTodo.title);
      }
    } catch (e, stack) {
      print('StartTimer error: $e');
      print(stack);
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
      NotificationService.instance.showPaused(updatedTodo.title);

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
              status: TodoStatus.incomplete,
            );
          }
          return t.copyWith(remainingSeconds: newTime);
        }
        return t;
      }).toList();

      emit(TodoLoaded(updated));

      try {
        _tickCount++;
        if (_tickCount % 10 == 0 || reachedZero) {
          for (final t in updated) {
            if (t.status != TodoStatus.todo) await repository.update(t);
          }
        }
        if (reachedZero) {
          final incompleteTasks = updated.where(
            (t) => t.status == TodoStatus.incomplete && t.remainingSeconds == 0,
          );
          for (final t in incompleteTasks) {
            await repository.update(t);
            await NotificationService.instance.showTimerExpired(t.title);
          }
        }
      } catch (e) {
        _emitError(emit, e);
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
      NotificationService.instance.showCompleted(updatedTodo.title);

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
