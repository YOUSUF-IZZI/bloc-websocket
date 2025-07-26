// Import necessary packages
import 'dart:async';  // For StreamSubscription and async operations
import 'dart:developer';  // For logging
import 'package:bloc_testing/data/repos/websocket_repository.dart';  // Repository for WebSocket operations
import 'package:bloc_testing/presentaion/blocs/websocket/websocket_event.dart';  // Event classes
import 'package:bloc_testing/presentaion/blocs/websocket/websocket_state.dart';  // State classes
import 'package:flutter_bloc/flutter_bloc.dart';  // BLoC pattern implementation

/// BLoC class that manages WebSocket connection state and data flow
/// Takes WebsocketEvent as input and outputs WebsocketState
class WebsocketBloc extends Bloc<WebsocketEvent, WebsocketState> {
  final WebsocketRepository _websocketRepository;  // Repository that handles the actual WebSocket connection
  StreamSubscription? _tickerSubscription;  // Subscription to ticker data stream from repository
  StreamSubscription? _connectionSubscription;  // Subscription to connection status stream from repository

  /// Constructor takes a WebsocketRepository and sets up event handlers
  /// Initializes with WebsocketInitial state
  WebsocketBloc(this._websocketRepository) : super(WebsocketInitial()) {
    // Register event handlers for each event type
    on<ConnectWebsocketEvent>(_onConnect);  // Handle connection requests
    on<DisconnectWebsocketEvent>(_onDisconnect);  // Handle disconnection requests
    on<TickerDataReceivedEvent>(_onTickerDataReceived);  // Handle when new ticker data arrives
    on<ConnectionStatusChangedEvent>(_onConnectionStatusChanged);  // Handle connection status changes
    
    // Set up listeners for the repository streams
    _setupStreamListeners();
  }

  /// Sets up listeners for the repository streams
  /// This connects the BLoC to the repository's data sources
  void _setupStreamListeners() {
    // Listen to ticker data stream from the repository
    _tickerSubscription = _websocketRepository.tickerStream.listen(
      (tickerData) {
        // When new ticker data arrives, add a TickerDataReceivedEvent to the BLoC
        add(TickerDataReceivedEvent());
      },
      onError: (error) {
        // Log errors and update connection status when ticker stream has an error
        log('Ticker stream error: $error');
        add(ConnectionStatusChangedEvent());
      },
    );

    // Listen to connection status stream from the repository
    _connectionSubscription = _websocketRepository.connectionStream.listen(
      (status) {
        // Log and update state when connection status changes
        log('Connection status: $status');
        add(ConnectionStatusChangedEvent());
      },
      onError: (error) {
        // Log errors and update connection status when connection stream has an error
        log('Connection stream error: $error');
        add(ConnectionStatusChangedEvent());
      },
    );
  }

  /// Handler for ConnectWebsocketEvent
  /// Attempts to establish a WebSocket connection via the repository
  Future<void> _onConnect(
    ConnectWebsocketEvent event,
    Emitter<WebsocketState> emit,
  ) async {
    try {
      // First emit a connecting state to update UI
      emit(WebsocketConnecting());
      // Call the repository to establish the connection (hardcoded to Bitcoin/USDT)
      await _websocketRepository.connect(symbol: 'btcusdt');
      // Note: The actual connected state will be emitted by _onConnectionStatusChanged
      // when the repository's connectionStream emits a 'connected' status
    } catch (e) {
      // Log and emit error state if connection fails
      log('Connect error: $e');
      emit(WebsocketError(message: 'Failed to connect: $e'));
    }
  }

  /// Handler for DisconnectWebsocketEvent
  /// Closes the WebSocket connection via the repository
  Future<void> _onDisconnect(
    DisconnectWebsocketEvent event,
    Emitter<WebsocketState> emit,
  ) async {
    try {
      // Call the repository to close the connection
      await _websocketRepository.disconnect();
      // Emit disconnected state to update UI
      emit(WebsocketDisconnected(message: 'Disconnected'));
    } catch (e) {
      // Log and emit error state if disconnection fails
      log('Disconnect error: $e');
      emit(WebsocketError(message: 'Failed to disconnect: $e'));
    }
  }



  /// Handler for TickerDataReceivedEvent
  /// Retrieves the latest ticker data from the repository and emits it as a state
  void _onTickerDataReceived(
    TickerDataReceivedEvent event,
    Emitter<WebsocketState> emit,
  ) {
    try {
      // Get the latest ticker data from the repository
      final tickerData = _websocketRepository.latestTickerData;
      if (tickerData != null) {
        // If data exists, emit it as a state to update the UI
        emit(WebsocketTickerDataReceived(tickerData: tickerData));
      }
    } catch (e) {
      // Log and emit error state if processing fails
      log('Error processing ticker data: $e');
      emit(WebsocketError(message: 'Failed to process ticker data: $e'));
    }
  }

  /// Handler for ConnectionStatusChangedEvent
  /// Maps the repository's connection status string to appropriate BLoC states
  void _onConnectionStatusChanged(
    ConnectionStatusChangedEvent event,
    Emitter<WebsocketState> emit,
  ) {
    // Get current connection status from repository
    final status = _websocketRepository.connectionStatus;
    
    // Map string status to appropriate state objects
    switch (status) {
      case 'connecting':
        emit(WebsocketConnecting());  // Emit connecting state
        break;
      case 'connected':
        emit(WebsocketConnected(message: 'Connected to Bitcoin'));  // Emit connected state
        break;
      case 'disconnected':
        emit(WebsocketDisconnected(message: 'Disconnected'));  // Emit disconnected state
        break;
      default:
        // Handle error states (which start with 'error:')
        if (status.startsWith('error:')) {
          emit(WebsocketError(message: status));  // Emit error state with the error message
        }
        break;
    }
  }

  /// Clean up resources when the BLoC is closed
  /// This is important to prevent memory leaks
  @override
  Future<void> close() {
    // Cancel stream subscriptions
    _tickerSubscription?.cancel();  // Cancel ticker stream subscription
    _connectionSubscription?.cancel();  // Cancel connection stream subscription
    
    // Dispose the repository to clean up its resources
    _websocketRepository.dispose();
    
    // Call the parent class's close method
    return super.close();
  }
}
