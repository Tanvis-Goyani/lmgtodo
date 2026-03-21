import 'package:hive_flutter/hive_flutter.dart';
import '../models/todo_model.dart';

class TodoRepository {
  static const _boxName = 'todos';
  late Box<Todo> _box;

  Future<void> init() async {
    _box = await Hive.openBox<Todo>(_boxName);
  }

  List<Todo> getAll() => _box.values.toList();

  Future<void> add(Todo todo) async => await _box.put(todo.id, todo);

  Future<void> update(Todo todo) async => await _box.put(todo.id, todo);

  Future<void> delete(String id) async => await _box.delete(id);
}
