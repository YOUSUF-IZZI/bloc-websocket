class Joke {
  String? type;
  String? setup;
  String? punchline;
  int? id;

  Joke({this.type, this.setup, this.punchline, this.id});

  factory Joke.fromJson(Map<String, dynamic> json) => Joke(
    type: json['type'] as String?,
    setup: json['setup'] as String?,
    punchline: json['punchline'] as String?,
    id: json['id'] as int?,
  );

  Map<String, dynamic> toJson() => {
    'type': type,
    'setup': setup,
    'punchline': punchline,
    'id': id,
  };
}
