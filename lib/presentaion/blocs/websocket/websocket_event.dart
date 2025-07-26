import 'package:equatable/equatable.dart';

sealed class WebsocketEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

final class ConnectWebsocketEvent extends WebsocketEvent {}

final class DisconnectWebsocketEvent extends WebsocketEvent {}

final class TickerDataReceivedEvent extends WebsocketEvent {}

final class ConnectionStatusChangedEvent extends WebsocketEvent {}
