import 'package:bloc_testing/presentaion/blocs/websocket/websocket_bloc.dart';
import 'package:bloc_testing/presentaion/blocs/websocket/websocket_event.dart';
import 'package:bloc_testing/presentaion/blocs/websocket/websocket_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CryptoDashboard extends StatefulWidget {
  const CryptoDashboard({super.key});

  @override
  State<CryptoDashboard> createState() => _CryptoDashboardState();
}

class _CryptoDashboardState extends State<CryptoDashboard> {
  // Fixed to BTCUSDT only
  final String symbol = 'BTCUSDT';

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
        title: const Text(
          'Bitcoin (BTCUSDT) Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<WebsocketBloc>().add(
                ConnectWebsocketEvent(),
              );
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
          final isConnected = state is WebsocketConnected || 
                            state is WebsocketTickerDataReceived;
          
          return FloatingActionButton.extended(
            onPressed: () {
              if (isConnected) {
                context.read<WebsocketBloc>().add(DisconnectWebsocketEvent());
              } else {
                context.read<WebsocketBloc>().add(
                  ConnectWebsocketEvent(),
                );
              }
            },
            icon: Icon(isConnected ? Icons.stop : Icons.play_arrow),
            label: Text(isConnected ? 'Disconnect' : 'Connect'),
            backgroundColor: isConnected 
              ? theme.colorScheme.error 
              : theme.colorScheme.primary,
            foregroundColor: isConnected 
              ? theme.colorScheme.onError 
              : theme.colorScheme.onPrimary,
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
        return _buildConnectingWidget(state, theme);
      
      case WebsocketConnected():
        return _buildConnectedWidget(state, theme);
      
      case WebsocketTickerDataReceived():
        return _buildTickerDataWidget(state, theme);
      
      case WebsocketDisconnected():
        return _buildDisconnectedWidget(state, theme);
      
      case WebsocketError():
        return _buildErrorWidget(state, theme);
      

    }
  }

  Widget _buildInitialWidget(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.currency_bitcoin,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Welcome to Crypto Dashboard',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a cryptocurrency and tap Connect to start',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConnectingWidget(WebsocketConnecting state, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Connecting to Bitcoin...',
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedWidget(WebsocketConnected state, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            size: 64,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          Text(
            state.message,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Waiting for data...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTickerDataWidget(WebsocketTickerDataReceived state, ThemeData theme) {
    final ticker = state.tickerData;
    final priceChange = double.tryParse(ticker.priceChange) ?? 0;
    final priceChangePercent = double.tryParse(ticker.priceChangePercent) ?? 0;
    final isPositive = priceChange >= 0;
    final currentPrice = double.tryParse(ticker.lastPrice) ?? 0;
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Bitcoin Icon
          Icon(
            Icons.currency_bitcoin,
            size: 80,
            color: Colors.orange,
          ),
          const SizedBox(height: 24),
          
          // Symbol
          Text(
            'Bitcoin (BTC/USDT)',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          
          // Current Price
          Text(
            '\$${currentPrice.toStringAsFixed(2)}',
            style: theme.textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          
          // Price Change
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isPositive ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isPositive ? Colors.green : Colors.red,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: isPositive ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${isPositive ? '+' : ''}\$${priceChange.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: isPositive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${isPositive ? '+' : ''}${priceChangePercent.toStringAsFixed(2)}%)',
                  style: TextStyle(
                    color: isPositive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Essential Stats
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    '24h Statistics',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSimpleStatColumn(
                        'High',
                        '\$${double.tryParse(ticker.highPrice)?.toStringAsFixed(2) ?? ticker.highPrice}',
                        Colors.green,
                        theme,
                      ),
                      _buildSimpleStatColumn(
                        'Low',
                        '\$${double.tryParse(ticker.lowPrice)?.toStringAsFixed(2) ?? ticker.lowPrice}',
                        Colors.red,
                        theme,
                      ),
                      _buildSimpleStatColumn(
                        'Volume',
                        (double.tryParse(ticker.volume) ?? 0).toStringAsFixed(0),
                        theme.colorScheme.primary,
                        theme,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSimpleStatColumn(String label, String value, Color color, ThemeData theme) {
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }



  Widget _buildDisconnectedWidget(WebsocketDisconnected state, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Disconnected',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(WebsocketError state, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Connection Error',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                context.read<WebsocketBloc>().add(
                  ConnectWebsocketEvent(),
                );
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
