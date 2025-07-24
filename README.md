# Flutter WebSocket with BLoC - Bitcoin Dashboard

A clean and focused Flutter application demonstrating real-time WebSocket communication using the BLoC pattern with Binance Bitcoin (BTCUSDT) data.

## 🚀 Features

- **Real-time Bitcoin Data**: Live BTC/USDT price updates from Binance WebSocket API
- **BLoC State Management**: Clean architecture with proper separation of concerns
- **Beautiful UI**: Modern Material Design 3 with dark/light theme support
- **Simplified Interface**: Focused on Bitcoin only for clarity and simplicity
- **Error Handling**: Robust error handling and connection management
- **Responsive Design**: Works on mobile, tablet, and desktop

## 📱 Screenshots

The app features:
- **Large Bitcoin Icon**: Clear visual identification
- **Real-time Price Display**: Prominent current BTC price
- **Price Change Indicators**: Visual green/red indicators with percentage and dollar changes
- **24h Statistics**: High, Low, and Volume in a clean card layout
- **Connection Controls**: Simple connect/disconnect functionality
- **Clean Interface**: Focused, distraction-free design

## 🏗️ Architecture

This project follows the **BLoC (Business Logic Component)** pattern with clean architecture:

```
lib/
├── data/
│   ├── models/
│   │   └── ticker_data.dart          # Data model for Binance ticker
│   └── repos/
│       └── websocket_repository.dart  # WebSocket connection management
├── presentation/
│   ├── blocs/
│   │   └── websocket/
│   │       ├── websocket_bloc.dart    # Business logic
│   │       ├── websocket_event.dart   # Events
│   │       └── websocket_state.dart   # States
│   └── screens/
│       └── crypto_dashboard.dart      # Main UI screen
└── main.dart                          # App entry point
```

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^9.1.1      # State management
  web_socket_channel: ^3.0.3 # WebSocket communication
  dio: ^5.8.0+1              # HTTP client
  equatable: ^2.0.7          # Value equality
  cupertino_icons: ^1.0.8    # iOS icons
```

## 🛠️ Setup Instructions

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code
- Android Emulator or iOS Simulator

### Installation

1. **Clone the repository**:
   ```bash
   git clone <your-repo-url>
   cd bloc-websocket
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the app**:
   ```bash
   flutter run
   ```

## 📚 Step-by-Step Tutorial

### Step 1: Data Models

Create the `TickerData` model to represent Binance WebSocket ticker data:

```dart
// lib/data/models/ticker_data.dart
class TickerData extends Equatable {
  final String symbol;
  final String priceChange;
  final String priceChangePercent;
  final String lastPrice;
  // ... other fields
  
  factory TickerData.fromJson(Map<String, dynamic> json) {
    return TickerData(
      symbol: json['s'] ?? '',
      priceChange: json['p'] ?? '0',
      // ... map other fields
    );
  }
}
```

### Step 2: WebSocket Repository

Implement the repository for WebSocket connection management:

```dart
// lib/data/repos/websocket_repository.dart
class WebsocketRepository {
  WebSocketChannel? _channel;
  StreamController<TickerData>? _tickerController;
  StreamController<String>? _connectionController;
  
  Stream<TickerData> get tickerStream => _tickerController?.stream ?? const Stream.empty();
  Stream<String> get connectionStream => _connectionController?.stream ?? const Stream.empty();
  
  Future<void> connect({String symbol = 'btcusdt'}) async {
    final uri = Uri.parse('wss://stream.binance.com:9443/ws/${symbol.toLowerCase()}@ticker');
    _channel = WebSocketChannel.connect(uri);
    
    _subscription = _channel!.stream.listen(
      (data) {
        final jsonData = json.decode(data);
        final tickerData = TickerData.fromJson(jsonData);
        _tickerController?.add(tickerData);
      },
      onError: (error) => _connectionController?.add('error: $error'),
      onDone: () => _connectionController?.add('disconnected'),
    );
  }
}
```

### Step 3: BLoC Events

Define events for WebSocket operations:

```dart
// lib/presentation/blocs/websocket/websocket_event.dart
sealed class WebsocketEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

final class ConnectWebsocketEvent extends WebsocketEvent {
  final String? symbol;
  ConnectWebsocketEvent({this.symbol});
}

final class DisconnectWebsocketEvent extends WebsocketEvent {}

final class SubscribeToSymbolEvent extends WebsocketEvent {
  final String symbol;
  SubscribeToSymbolEvent({required this.symbol});
}
```

### Step 4: BLoC States

Define states for different WebSocket connection states:

```dart
// lib/presentation/blocs/websocket/websocket_state.dart
sealed class WebsocketState extends Equatable {
  @override
  List<Object?> get props => [];
}

class WebsocketInitial extends WebsocketState {}

class WebsocketConnecting extends WebsocketState {
  final String symbol;
  WebsocketConnecting({required this.symbol});
}

class WebsocketTickerDataReceived extends WebsocketState {
  final TickerData tickerData;
  WebsocketTickerDataReceived({required this.tickerData});
}
```

### Step 5: BLoC Implementation

Implement the business logic:

```dart
// lib/presentation/blocs/websocket/websocket_bloc.dart
class WebsocketBloc extends Bloc<WebsocketEvent, WebsocketState> {
  final WebsocketRepository _websocketRepository;
  StreamSubscription? _tickerSubscription;
  StreamSubscription? _connectionSubscription;
  
  WebsocketBloc(this._websocketRepository) : super(WebsocketInitial()) {
    on<ConnectWebsocketEvent>(_onConnect);
    on<DisconnectWebsocketEvent>(_onDisconnect);
    on<SubscribeToSymbolEvent>(_onSubscribeToSymbol);
    
    _setupStreamListeners();
  }
  
  void _setupStreamListeners() {
    _tickerSubscription = _websocketRepository.tickerStream.listen(
      (tickerData) => add(TickerDataReceivedEvent(data: tickerData.toJson())),
    );
    
    _connectionSubscription = _websocketRepository.connectionStream.listen(
      (status) => add(ConnectionStatusChangedEvent(status: status)),
    );
  }
}
```

### Step 6: Beautiful UI

Create a clean, focused UI for Bitcoin data:

```dart
// lib/presentation/screens/crypto_dashboard.dart
class CryptoDashboard extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bitcoin (BTCUSDT) Dashboard'),
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: BlocBuilder<WebsocketBloc, WebsocketState>(
        builder: (context, state) => _buildStateWidget(state),
      ),
      floatingActionButton: _buildConnectionButton(),
    );
  }
}
```

## 🔧 Key Features Explained

### Real-time WebSocket Connection
- Connects to Binance WebSocket API (`wss://stream.binance.com:9443/ws/`)
- Handles connection states (connecting, connected, disconnected, error)
- Automatic reconnection on errors
- Stream-based data handling

### BLoC Pattern Implementation
- **Events**: User actions (connect, disconnect, subscribe)
- **States**: UI states (loading, success, error)
- **Repository**: Data layer abstraction
- **Stream Management**: Proper subscription handling

### UI/UX Features
- **Material Design 3**: Modern, accessible design
- **Dark/Light Theme**: System theme support
- **Focused Layout**: Clean, single-purpose interface
- **Real-time Updates**: Smooth price updates
- **Error Handling**: User-friendly error messages
- **Bitcoin Branding**: Orange Bitcoin icon for clear identification

## 🧪 Testing

Run tests with:
```bash
flutter test
```

Run analysis:
```bash
flutter analyze
```

## 🚀 Deployment

Build for production:
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## 📖 Learning Resources

- [Flutter BLoC Documentation](https://bloclibrary.dev/)
- [WebSocket Channel Package](https://pub.dev/packages/web_socket_channel)
- [Binance WebSocket API](https://binance-docs.github.io/apidocs/spot/en/#websocket-market-streams)
- [Material Design 3](https://m3.material.io/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Binance for providing free WebSocket API
- Flutter team for the amazing framework
- BLoC library maintainers
- Material Design team for the beautiful design system
