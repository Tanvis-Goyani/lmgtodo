import 'package:equatable/equatable.dart';

enum TodoStatus { todo, inProgress, done }

class Todo extends Equatable {
  final String id;
  final String title;
  final String description;
  final TodoStatus status;
  final int elapsedSeconds; // for timer

  const Todo({
    required this.id,
    required this.title,
    required this.description,
    this.status = TodoStatus.todo,
    this.elapsedSeconds = 0,
  });

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    TodoStatus? status,
    int? elapsedSeconds,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    );
  }

  @override
  List<Object?> get props => [id, title, description, status, elapsedSeconds];
}
