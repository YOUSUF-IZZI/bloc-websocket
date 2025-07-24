import 'package:equatable/equatable.dart';

sealed class WebsocketEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

final class ConnectWebsocketEvent extends WebsocketEvent {}

final class DisconnectWebsocketEvent extends WebsocketEvent {}

final class TickerDataReceivedEvent extends WebsocketEvent {
  final Map<String, dynamic> data;
  
  TickerDataReceivedEvent({required this.data});
  
  @override
  List<Object?> get props => [data];
}

final class ConnectionStatusChangedEvent extends WebsocketEvent {
  final String status;
  
  ConnectionStatusChangedEvent({required this.status});
  
  @override
  List<Object?> get props => [status];
}
