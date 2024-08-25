import 'package:dio/dio.dart';
import 'package:fl_starter/features/todos/models/todo_model.dart';
import 'package:fl_starter/features/todos/repositories/todo_repository.dart';
import 'package:fl_starter/services/dio_client.dart';

class TodoRepositoryImpl implements TodoRepository {
  @override
  Future<List<Todo>> getTodos({Map<String, dynamic>? queryParameters}) async {
    final Response<dynamic> response = await dio.get(
      'todos',
      queryParameters: queryParameters,
    );

    final List<Todo> todos =
        response.data.map((item) => Todo.fromJson(item)).toList();
    return todos;
  }

  @override
  Future<void> createTodo(Todo todo) async {}

  @override
  Future<void> updateTodo(int id, Todo todo) async {}

  @override
  Future<void> deleteTodo(int id) async {}

  @override
  Future<void> toggleTodo(int id) async {}
}
