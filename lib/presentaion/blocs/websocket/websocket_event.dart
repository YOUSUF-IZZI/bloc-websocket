sealed class WebsocketEvent {}

final class ConnectWebsocketEvent extends WebsocketEvent {}
final class DisconnectWebsocketEvent extends WebsocketEvent {}
final class TickerDataReceivedEvent extends WebsocketEvent {}
final class ConnectionStatusChangedEvent extends WebsocketEvent {}
