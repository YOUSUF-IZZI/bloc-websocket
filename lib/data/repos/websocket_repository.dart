import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:bloc_testing/data/models/ticker_data.dart';

class WebsocketRepository {
  WebSocketChannel? _channel;  //Holds the WebSocketChannel connection
  StreamController<TickerData>? _tickerController;
  StreamController<String>? _connectionController;
  StreamSubscription? _subscription;  //Subscription to the WebSocket stream
  
  // Store latest data
  TickerData? _latestTickerData;
  String _connectionStatus = 'disconnected';
  
  // Getters for streams
  Stream<TickerData> get tickerStream => _tickerController?.stream ?? const Stream.empty();
  Stream<String> get connectionStream => _connectionController?.stream ?? const Stream.empty();
  
  // Getters for latest data
  TickerData? get latestTickerData => _latestTickerData;
  String get connectionStatus => _connectionStatus;
  
  bool get isConnected => _channel != null;

  /*
  The constructor calls _initializeControllers() which sets up broadcast StreamControllers
  These controllers allow multiple listeners to receive updates
  */
  WebsocketRepository() {
    _initializeControllers();
  }

  void _initializeControllers() {
    _tickerController = StreamController<TickerData>.broadcast();
    _connectionController = StreamController<String>.broadcast();
  }

  /*
  The connect() method takes a symbol parameter (default is 'btcusdt')
  It first checks if the WebSocket is already connected
  If not, it creates a new WebSocket connection using the provided symbol
  */
  Future<void> connect({String symbol = 'btcusdt'}) async {
    try {
      if (_channel != null) {
        log('WebSocket already connected');
        return;
      }

      final uri = Uri.parse('wss://stream.binance.com:9443/ws/${symbol.toLowerCase()}@ticker');
      _channel = WebSocketChannel.connect(uri);
      
      _connectionStatus = 'connecting';
      _connectionController?.add(_connectionStatus);
      log('Connecting to: ${uri.toString()}');

      // Listen to the WebSocket stream
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
            _connectionStatus = 'error: Failed to parse data';
            _connectionController?.add(_connectionStatus);
          }
        },
        onError: (error) {
          log('WebSocket error: $error');
          _connectionStatus = 'error: $error';
          _connectionController?.add(_connectionStatus);
          _handleDisconnection();
        },
        onDone: () {
          log('WebSocket connection closed');
          _connectionStatus = 'disconnected';
          _connectionController?.add(_connectionStatus);
          _handleDisconnection();
        },
      );

      _connectionStatus = 'connected';
      _connectionController?.add(_connectionStatus);
      log('WebSocket connected successfully');
    } catch (e) {
      log('Failed to connect: $e');
      _connectionStatus = 'error: $e';
      _connectionController?.add(_connectionStatus);
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
      _connectionStatus = 'disconnected';
      _connectionController?.add(_connectionStatus);
      log('WebSocket disconnected');
    } catch (e) {
      log('Error during disconnect: $e');
      _connectionStatus = 'error: $e';
      _connectionController?.add(_connectionStatus);
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