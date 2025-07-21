import 'package:bloc_testing/data/repos/joke_repository.dart';
import 'package:bloc_testing/presentaion/blocs/joke/joke_event.dart';
import 'package:bloc_testing/presentaion/blocs/joke/joke_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show Bloc, Emitter;

class JokeBloc extends Bloc<JokeEvent, JokeState> {
  JokeBloc({required this.jokeRepository}) : super(JokeInitial()) {
    on<FetchJokeEvent>(_onFetchJoke);
  }

  final JokeRepository jokeRepository;

  Future<void> _onFetchJoke(FetchJokeEvent event, Emitter<JokeState> emit) async {
    emit(JokeLoading());
    try {
      final joke = await jokeRepository.getUsers();
      emit(JokeSuccess(joke: joke));
    } catch (e) {
      emit(JokeError(message: e.toString()));
    }
  }
}