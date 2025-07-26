import 'package:bloc_testing/data/repos/websocket_repository.dart';
import 'package:bloc_testing/presentaion/blocs/websocket/websocket_bloc.dart';
import 'package:bloc_testing/presentaion/screens/crypto_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        create: (context) => WebsocketBloc(WebsocketRepository()),
        child: const CryptoScreen(),
      ),
    );
  }
}
