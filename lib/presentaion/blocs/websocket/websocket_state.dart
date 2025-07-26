// Import necessary packages
import 'package:equatable/equatable.dart';  // For value equality comparison
import 'package:bloc_testing/data/models/ticker_data.dart';  // For ticker data model

/// Base abstract class for all WebSocket states
/// Extends Equatable to enable value equality comparisons between state instances
/// Uses the 'sealed' keyword to ensure all possible states are known at compile time
sealed class WebsocketState extends Equatable {
  @override
  List<Object?> get props => [];  // Default implementation returns empty list (no properties to compare)
}

/// Initial state when the BLoC is first created
/// No properties needed as it's just a marker state
class WebsocketInitial extends WebsocketState {}
/// State representing an in-progress connection attempt
/// No properties needed as it's just a marker state for the connecting process
class WebsocketConnecting extends WebsocketState {}

/// State representing a successful WebSocket connection
/// Contains a message that can be displayed to the user
class WebsocketConnected extends WebsocketState {
  final String message;  // Message describing the connection (e.g., "Connected to Bitcoin")
  
  WebsocketConnected({required this.message});
  
  @override
  List<Object?> get props => [message];  // Include message in equality comparison
}

/// State representing a disconnected WebSocket
/// Contains a message that can be displayed to the user
class WebsocketDisconnected extends WebsocketState {
  final String message;  // Message describing the disconnection (e.g., "Disconnected")
  
  WebsocketDisconnected({required this.message});
  
  @override
  List<Object?> get props => [message];  // Include message in equality comparison
}

/// State representing an error in the WebSocket connection
/// Contains an error message that can be displayed to the user
class WebsocketError extends WebsocketState {
  final String message;  // Error message describing what went wrong
  
  WebsocketError({required this.message});
  
  @override
  List<Object?> get props => [message];  // Include message in equality comparison
}

/// State representing successful receipt of ticker data from the WebSocket
/// Contains the actual ticker data and the current connection status
class WebsocketTickerDataReceived extends WebsocketState {
  final TickerData tickerData;  // The cryptocurrency ticker data received
  final String connectionStatus;  // Current connection status (defaults to 'connected')
  
  WebsocketTickerDataReceived({
    required this.tickerData,
    this.connectionStatus = 'connected',  // Default value assumes connection is active
  });
  
  @override
  List<Object?> get props => [tickerData, connectionStatus];  // Include both properties in equality comparison
}