import '../models/todo_model.dart';

abstract class TodoRepository {
  Future<List<Todo>> getTodos({Map<String, dynamic>? queryParameters});
  Future<void> createTodo(Todo todo);
  Future<void> updateTodo(int id, Todo todo);
  Future<void> deleteTodo(int id);
  Future<void> toggleTodo(int id);
}
