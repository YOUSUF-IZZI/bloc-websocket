import 'package:equatable/equatable.dart';
import 'package:bloc_testing/data/models/ticker_data.dart';

sealed class WebsocketState extends Equatable {
  @override
  List<Object?> get props => [];
}

class WebsocketInitial extends WebsocketState {}

class WebsocketConnecting extends WebsocketState {}

class WebsocketConnected extends WebsocketState {
  final String message;
  
  WebsocketConnected({required this.message});
  
  @override
  List<Object?> get props => [message];
}

class WebsocketDisconnected extends WebsocketState {
  final String message;
  
  WebsocketDisconnected({required this.message});
  
  @override
  List<Object?> get props => [message];
}

class WebsocketError extends WebsocketState {
  final String message;
  
  WebsocketError({required this.message});
  
  @override
  List<Object?> get props => [message];
}

class WebsocketTickerDataReceived extends WebsocketState {
  final TickerData tickerData;
  final String connectionStatus;
  
  WebsocketTickerDataReceived({
    required this.tickerData,
    this.connectionStatus = 'connected',
  });
  
  @override
  List<Object?> get props => [tickerData, connectionStatus];
}