import 'dart:async';
import 'dart:developer';

import 'package:bloc_testing/data/models/ticker_data.dart';
import 'package:bloc_testing/data/repos/websocket_repository.dart';
import 'package:bloc_testing/presentaion/blocs/websocket/websocket_event.dart';
import 'package:bloc_testing/presentaion/blocs/websocket/websocket_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WebsocketBloc extends Bloc<WebsocketEvent, WebsocketState> {
  final WebsocketRepository _websocketRepository;
  StreamSubscription? _tickerSubscription;
  StreamSubscription? _connectionSubscription;

  WebsocketBloc(this._websocketRepository) : super(WebsocketInitial()) {
    on<ConnectWebsocketEvent>(_onConnect);
    on<DisconnectWebsocketEvent>(_onDisconnect);
    on<TickerDataReceivedEvent>(_onTickerDataReceived);
    on<ConnectionStatusChangedEvent>(_onConnectionStatusChanged);
    
    // Listen to repository streams
    _setupStreamListeners();
  }

  void _setupStreamListeners() {
    // Listen to ticker data stream
    _tickerSubscription = _websocketRepository.tickerStream.listen(
      (tickerData) {
        add(TickerDataReceivedEvent(data: tickerData.toJson()));
      },
      onError: (error) {
        log('Ticker stream error: $error');
        add(ConnectionStatusChangedEvent(status: 'error: Ticker stream error: $error'));
      },
    );

    // Listen to connection status stream
    _connectionSubscription = _websocketRepository.connectionStream.listen(
      (status) {
        log('Connection status: $status');
        add(ConnectionStatusChangedEvent(status: status));
      },
      onError: (error) {
        log('Connection stream error: $error');
        add(ConnectionStatusChangedEvent(status: 'error: Connection error: $error'));
      },
    );
  }

  Future<void> _onConnect(
    ConnectWebsocketEvent event,
    Emitter<WebsocketState> emit,
  ) async {
    try {
      emit(WebsocketConnecting());
      await _websocketRepository.connect(symbol: 'btcusdt');
    } catch (e) {
      log('Connect error: $e');
      emit(WebsocketError(message: 'Failed to connect: $e'));
    }
  }

  Future<void> _onDisconnect(
    DisconnectWebsocketEvent event,
    Emitter<WebsocketState> emit,
  ) async {
    try {
      await _websocketRepository.disconnect();
      emit(WebsocketDisconnected(message: 'Disconnected'));
    } catch (e) {
      log('Disconnect error: $e');
      emit(WebsocketError(message: 'Failed to disconnect: $e'));
    }
  }



  void _onTickerDataReceived(
    TickerDataReceivedEvent event,
    Emitter<WebsocketState> emit,
  ) {
    try {
      final tickerData = TickerData.fromJson(event.data);
      emit(WebsocketTickerDataReceived(tickerData: tickerData));
    } catch (e) {
      log('Error processing ticker data: $e');
      emit(WebsocketError(message: 'Failed to process ticker data: $e'));
    }
  }

  void _onConnectionStatusChanged(
    ConnectionStatusChangedEvent event,
    Emitter<WebsocketState> emit,
  ) {
    final status = event.status;
    switch (status) {
      case 'connecting':
        emit(WebsocketConnecting());
        break;
      case 'connected':
        emit(WebsocketConnected(message: 'Connected to Bitcoin'));
        break;
      case 'disconnected':
        emit(WebsocketDisconnected(message: 'Disconnected'));
        break;
      default:
        if (status.startsWith('error:')) {
          emit(WebsocketError(message: status));
        }
        break;
    }
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    _connectionSubscription?.cancel();
    _websocketRepository.dispose();
    return super.close();
  }
}
