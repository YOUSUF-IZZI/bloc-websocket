import 'package:bloc_testing/presentaion/blocs/websocket/websocket_bloc.dart';
import 'package:bloc_testing/presentaion/blocs/websocket/websocket_event.dart';
import 'package:bloc_testing/presentaion/blocs/websocket/websocket_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CryptoScreen extends StatefulWidget {
  const CryptoScreen({super.key});

  @override
  State<CryptoScreen> createState() => _CryptoScreenState();
}

class _CryptoScreenState extends State<CryptoScreen> {
  @override
  void initState() {
    super.initState();
    // Connect to BTCUSDT on startup
    context.read<WebsocketBloc>().add(ConnectWebsocketEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BTC/USDT', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<WebsocketBloc>().add(ConnectWebsocketEvent());
            },
          ),
        ],
      ),
      body: BlocBuilder<WebsocketBloc, WebsocketState>(
        builder: (context, state) {
          return _buildStateWidget(context, state, theme);
        },
      ),
      floatingActionButton: BlocBuilder<WebsocketBloc, WebsocketState>(
        builder: (context, state) {
          final isConnected = state is WebsocketConnected || state is WebsocketTickerDataReceived;

          return FloatingActionButton.extended(
            onPressed: () {
              if (isConnected) {
                context.read<WebsocketBloc>().add(DisconnectWebsocketEvent());
              } else {
                context.read<WebsocketBloc>().add(ConnectWebsocketEvent());
              }
            },
            icon: Icon(isConnected ? Icons.stop : Icons.play_arrow),
            label: Text(isConnected ? 'Disconnect' : 'Connect'),
            backgroundColor: isConnected ? theme.colorScheme.error : theme.colorScheme.primary,
            foregroundColor: isConnected ? theme.colorScheme.onError : theme.colorScheme.onPrimary,
          );
        },
      ),
    );
  }

  Widget _buildStateWidget(BuildContext context, WebsocketState state, ThemeData theme) {
    switch (state) {
      case WebsocketInitial():
        return _buildInitialWidget(theme);
      case WebsocketConnecting():
        return _buildConnectingWidget(state);
      case WebsocketConnected():
        return _buildConnectedWidget(state);
      case WebsocketTickerDataReceived():
        return _buildTickerDataWidget(state);
      case WebsocketDisconnected():
        return _buildDisconnectedWidget(state);
      case WebsocketError():
        return _buildErrorWidget(state);
    }
  }

  Widget _buildInitialWidget(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.currency_bitcoin, size: 64, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text('Welcome to Crypto Dashboard', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Select a cryptocurrency and tap Connect to start',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConnectingWidget(WebsocketConnecting state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.green),
          const SizedBox(height: 16),
          Text('Connecting to Bitcoin...', style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 24)),
        ],
      ),
    );
  }

  Widget _buildConnectedWidget(WebsocketConnected state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 64, color: Colors.green),
          const SizedBox(height: 16),
          Text(state.message, style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 24)),
          const SizedBox(height: 8),
          Text('Waiting for data...', style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 24)),
        ],
      ),
    );
  }

  Widget _buildTickerDataWidget(WebsocketTickerDataReceived state) {
    final ticker = state.tickerData;
    final currentPrice = double.tryParse(ticker.lastPrice) ?? 0;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Bitcoin Icon
            Icon(Icons.currency_bitcoin, size: 80, color: Colors.orange),
            const SizedBox(height: 24),
            // Symbol
            Text(
              'Bitcoin (BTC/USDT)',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 24),
            ),
            const SizedBox(height: 16),
            // Current Price
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '\$',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 30),
                ),
                const SizedBox(width: 4),
                Text(
                  currentPrice.toStringAsFixed(2),
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 28),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDisconnectedWidget(WebsocketDisconnected state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Disconnected', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 24)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(WebsocketError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Connection Error',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: TextStyle(color: Colors.red, fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                context.read<WebsocketBloc>().add(ConnectWebsocketEvent());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry Connection'),
            ),
          ],
        ),
      ),
    );
  }
}
