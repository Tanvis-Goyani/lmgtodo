import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'todo_model.g.dart';

enum TodoStatus { todo, inProgress, done }

@HiveType(typeId: 0)
class Todo extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final int statusIndex;

  @HiveField(4)
  final int elapsedSeconds;

  @HiveField(5)
  final bool isRunning;

  const Todo({
    required this.id,
    required this.title,
    required this.description,
    this.statusIndex = 0,
    this.elapsedSeconds = 0,
    this.isRunning = false,
  });

  TodoStatus get status => TodoStatus.values[statusIndex];

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    TodoStatus? status,
    int? elapsedSeconds,
    bool? isRunning,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      statusIndex: status != null ? status.index : statusIndex,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isRunning: isRunning ?? this.isRunning,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    statusIndex,
    elapsedSeconds,
    isRunning,
  ];
}
