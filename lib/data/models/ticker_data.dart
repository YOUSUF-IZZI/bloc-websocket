import 'package:equatable/equatable.dart';

class TickerData extends Equatable {
  final String symbol;
  final String lastPrice;

  const TickerData({
    required this.symbol,
    required this.lastPrice,
  });

  factory TickerData.fromJson(Map<String, dynamic> json) {
    return TickerData(
      symbol: json['s'] ?? '',
      lastPrice: json['c'] ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      's': symbol,
      'c': lastPrice,
    };
  }

  @override
  List<Object?> get props => [
        symbol,
        lastPrice,
      ];
}
