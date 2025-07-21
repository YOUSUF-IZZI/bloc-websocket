import 'package:bloc_testing/data/models/joke.dart';

sealed class JokeState {}

final class JokeInitial extends JokeState {}

final class JokeLoading extends JokeState {}

final class JokeSuccess extends JokeState {
  final Joke joke;

  JokeSuccess({required this.joke});
}

final class JokeError extends JokeState {
  final String message;

  JokeError({required this.message});
}
