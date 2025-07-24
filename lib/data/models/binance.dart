class Binance {
  final String symbol;
  final double price;

  Binance({required this.symbol, required this.price});

  factory Binance.fromJson(Map<String, dynamic> json) {
    return Binance(
      symbol: json['symbol'],
      price: json['price'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'price': price,
    };
  }
}