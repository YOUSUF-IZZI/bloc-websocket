import 'package:bloc_testing/data/models/joke.dart';
import 'package:dio/dio.dart';

class JokeRepository {
  final Dio dio;

  JokeRepository({required this.dio});

  Future<Joke> getUsers() async {
    try {
      final response = await dio.get('https://official-joke-api.appspot.com/random_joke');
      if (response.statusCode == 200) {
        final formatedResponse = Joke.fromJson(response.data);
        return formatedResponse;
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }
}
