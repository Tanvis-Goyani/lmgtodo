import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/todo_model.dart';
import 'todo_event.dart';
import 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  TodoBloc() : super(TodoInitial()) {
    on<LoadTodos>(_onLoadTodos);
  }

  void _onLoadTodos(LoadTodos event, Emitter<TodoState> emit) {
    // Hardcoded dummy data for now
    final todos = [
      Todo(
        id: '1',
        title: 'Design UI Mockups',
        description: 'Create wireframes for all 3 screens',
        status: TodoStatus.done,
        elapsedSeconds: 3720,
      ),
      Todo(
        id: '2',
        title: 'Setup BLoC',
        description: 'Integrate flutter_bloc for state management',
        status: TodoStatus.inProgress,
        elapsedSeconds: 540,
      ),
      Todo(
        id: '3',
        title: 'Write Unit Tests',
        description: 'Cover all BLoC events and states',
        status: TodoStatus.todo,
        elapsedSeconds: 0,
      ),
    ];

    emit(TodoLoaded(todos));
  }
}
