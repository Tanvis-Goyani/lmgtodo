import 'package:hive_flutter/hive_flutter.dart';
import '../models/todo_model.dart';

class TodoRepository {
  static const _boxName = 'todos';
  late Box<Todo> _box;

  Future<void> init() async {
    try {
      _box = await Hive.openBox<Todo>(_boxName);
    } catch (e) {
      throw Exception('Failed to open database: $e');
    }
  }

  List<Todo> getAll() {
    try {
      return _box.values.toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> add(Todo todo) async {
    try {
      await _box.put(todo.id, todo);
    } catch (e) {
      throw Exception('Failed to save task: $e');
    }
  }

  Future<void> update(Todo todo) async {
    try {
      await _box.put(todo.id, todo);
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _box.delete(id);
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }
}
