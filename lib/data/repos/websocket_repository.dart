import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:bloc_testing/data/models/ticker_data.dart';

class WebsocketRepository {
  WebSocketChannel? _channel;  //Holds the WebSocketChannel connection
  StreamSubscription? _subscription;  //Subscription to the WebSocket stream
  StreamController<String>? _connectionController;
  StreamController<TickerData>? _tickerController;
  
  // Getters for streams
  Stream<TickerData> get tickerStream => _tickerController?.stream ?? const Stream.empty();
  Stream<String> get connectionStream => _connectionController?.stream ?? const Stream.empty();

 // Store latest data
  TickerData? _latestTickerData;
  
  // Getters for latest data
  TickerData? get latestTickerData => _latestTickerData;
  
  bool get isConnected => _channel != null;

  void _initializeControllers() {
    _tickerController = StreamController<TickerData>.broadcast();
    _connectionController = StreamController<String>.broadcast();
  }

  WebsocketRepository() {
    _initializeControllers();
  }

  Future<void> connect() async {
    try {
      if (_channel != null) {
        log('WebSocket already connected');
        return;
      }

      final uri = Uri.parse('wss://stream.binance.com:9443/ws/btcusdt@ticker');
      _channel = WebSocketChannel.connect(uri);
      log('Connecting to: ${uri.toString()}');

      _subscription = _channel!.stream.listen(
        (data) {
          try {
            final jsonData = json.decode(data);
            final tickerData = TickerData.fromJson(jsonData);
            _latestTickerData = tickerData;
            _tickerController?.add(tickerData);
            log('Received ticker data for ${tickerData.symbol}');
          } catch (e) {
            log('Error parsing ticker data: $e');
          }
        },
        onError: (error) {
          log('WebSocket error: $error');
          _handleDisconnection();
        },
        onDone: () {
          log('WebSocket connection closed');
          _handleDisconnection();
        },
      );

      log('WebSocket connected successfully');
    } catch (e) {
      log('Failed to connect: $e');
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
      log('WebSocket disconnected');
    } catch (e) {
      log('Error during disconnect: $e');
    }
  }

  void dispose() {
    disconnect();
    _tickerController?.close();
    _connectionController?.close();
    _tickerController = null;
    _connectionController = null;
  }
}