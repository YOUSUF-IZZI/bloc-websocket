import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:bloc_testing/data/models/ticker_data.dart';

class WebsocketRepository {
  WebSocketChannel? _channel;
  StreamController<TickerData>? _tickerController;
  StreamController<String>? _connectionController;
  StreamSubscription? _subscription;
  
  // Getters for streams
  Stream<TickerData> get tickerStream => _tickerController?.stream ?? const Stream.empty();
  Stream<String> get connectionStream => _connectionController?.stream ?? const Stream.empty();
  
  bool get isConnected => _channel != null;

  WebsocketRepository() {
    _initializeControllers();
  }

  void _initializeControllers() {
    _tickerController = StreamController<TickerData>.broadcast();
    _connectionController = StreamController<String>.broadcast();
  }

  Future<void> connect({String symbol = 'btcusdt'}) async {
    try {
      if (_channel != null) {
        log('WebSocket already connected');
        return;
      }

      final uri = Uri.parse('wss://stream.binance.com:9443/ws/${symbol.toLowerCase()}@ticker');
      _channel = WebSocketChannel.connect(uri);
      
      _connectionController?.add('connecting');
      log('Connecting to: ${uri.toString()}');

      // Listen to the WebSocket stream
      _subscription = _channel!.stream.listen(
        (data) {
          try {
            final jsonData = json.decode(data);
            final tickerData = TickerData.fromJson(jsonData);
            _tickerController?.add(tickerData);
            log('Received ticker data for ${tickerData.symbol}');
          } catch (e) {
            log('Error parsing ticker data: $e');
            _connectionController?.add('error: Failed to parse data');
          }
        },
        onError: (error) {
          log('WebSocket error: $error');
          _connectionController?.add('error: $error');
          _handleDisconnection();
        },
        onDone: () {
          log('WebSocket connection closed');
          _connectionController?.add('disconnected');
          _handleDisconnection();
        },
      );

      _connectionController?.add('connected');
      log('WebSocket connected successfully');
    } catch (e) {
      log('Failed to connect: $e');
      _connectionController?.add('error: $e');
      _handleDisconnection();
    }
  }

  void _handleDisconnection() {
    _subscription?.cancel();
    _subscription = null;
    _channel = null;
  }

  Future<void> disconnect() async {
    try {
      log('Disconnecting WebSocket...');
      _subscription?.cancel();
      await _channel?.sink.close();
      _handleDisconnection();
      _connectionController?.add('disconnected');
      log('WebSocket disconnected');
    } catch (e) {
      log('Error during disconnect: $e');
      _connectionController?.add('error: $e');
    }
  }

  Future<void> subscribeToSymbol(String symbol) async {
    if (_channel != null) {
      await disconnect();
    }
    await connect(symbol: symbol);
  }

  void dispose() {
    disconnect();
    _tickerController?.close();
    _connectionController?.close();
    _tickerController = null;
    _connectionController = null;
  }
}