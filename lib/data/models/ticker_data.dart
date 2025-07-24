import 'package:equatable/equatable.dart';

class TickerData extends Equatable {
  final String symbol;
  final String priceChange;
  final String priceChangePercent;
  final String weightedAvgPrice;
  final String prevClosePrice;
  final String lastPrice;
  final String lastQty;
  final String bidPrice;
  final String bidQty;
  final String askPrice;
  final String askQty;
  final String openPrice;
  final String highPrice;
  final String lowPrice;
  final String volume;
  final String quoteVolume;
  final int openTime;
  final int closeTime;
  final int firstId;
  final int lastId;
  final int count;

  const TickerData({
    required this.symbol,
    required this.priceChange,
    required this.priceChangePercent,
    required this.weightedAvgPrice,
    required this.prevClosePrice,
    required this.lastPrice,
    required this.lastQty,
    required this.bidPrice,
    required this.bidQty,
    required this.askPrice,
    required this.askQty,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.volume,
    required this.quoteVolume,
    required this.openTime,
    required this.closeTime,
    required this.firstId,
    required this.lastId,
    required this.count,
  });

  factory TickerData.fromJson(Map<String, dynamic> json) {
    return TickerData(
      symbol: json['s'] ?? '',
      priceChange: json['p'] ?? '0',
      priceChangePercent: json['P'] ?? '0',
      weightedAvgPrice: json['w'] ?? '0',
      prevClosePrice: json['x'] ?? '0',
      lastPrice: json['c'] ?? '0',
      lastQty: json['Q'] ?? '0',
      bidPrice: json['b'] ?? '0',
      bidQty: json['B'] ?? '0',
      askPrice: json['a'] ?? '0',
      askQty: json['A'] ?? '0',
      openPrice: json['o'] ?? '0',
      highPrice: json['h'] ?? '0',
      lowPrice: json['l'] ?? '0',
      volume: json['v'] ?? '0',
      quoteVolume: json['q'] ?? '0',
      openTime: json['O'] ?? 0,
      closeTime: json['C'] ?? 0,
      firstId: json['F'] ?? 0,
      lastId: json['L'] ?? 0,
      count: json['n'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      's': symbol,
      'p': priceChange,
      'P': priceChangePercent,
      'w': weightedAvgPrice,
      'x': prevClosePrice,
      'c': lastPrice,
      'Q': lastQty,
      'b': bidPrice,
      'B': bidQty,
      'a': askPrice,
      'A': askQty,
      'o': openPrice,
      'h': highPrice,
      'l': lowPrice,
      'v': volume,
      'q': quoteVolume,
      'O': openTime,
      'C': closeTime,
      'F': firstId,
      'L': lastId,
      'n': count,
    };
  }

  @override
  List<Object?> get props => [
        symbol,
        priceChange,
        priceChangePercent,
        weightedAvgPrice,
        prevClosePrice,
        lastPrice,
        lastQty,
        bidPrice,
        bidQty,
        askPrice,
        askQty,
        openPrice,
        highPrice,
        lowPrice,
        volume,
        quoteVolume,
        openTime,
        closeTime,
        firstId,
        lastId,
        count,
      ];
}
