import 'package:equatable/equatable.dart';
import 'package:lmgtodo/models/todo_model.dart';

abstract class TodoState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TodoInitial extends TodoState {}

class TodoLoaded extends TodoState {
  final List<Todo> todos;

  TodoLoaded(this.todos);

  @override
  List<Object?> get props => [todos];
}

class TodoError extends TodoState {
  final String message;
  final List<Todo> previousTodos;

  TodoError(this.message, this.previousTodos);

  @override
  List<Object?> get props => [message, previousTodos];
}
