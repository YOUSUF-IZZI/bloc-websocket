import 'package:bloc_testing/data/repos/joke_repository.dart';
import 'package:bloc_testing/presentaion/blocs/joke/joke_bloc.dart';
import 'package:bloc_testing/presentaion/blocs/joke/joke_event.dart';
import 'package:bloc_testing/presentaion/blocs/joke/joke_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => JokeBloc(jokeRepository: JokeRepository(dio: Dio()))..add(FetchJokeEvent()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Home')),
        body: BlocBuilder<JokeBloc, JokeState>(
          builder: (_, state) {
            if (state is JokeLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is JokeSuccess) {
              return Center(
                child: Card(
                  child: Column(
                    children: [
                      Text(state.joke.setup ?? ''),
                      Text(state.joke.punchline ?? ''),
                    ],
                  ),
                ),
              );
            } else if (state is JokeError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
