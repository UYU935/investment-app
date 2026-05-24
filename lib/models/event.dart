enum EventType { good, expense, market }

class GameEvent {
  final String title;
  final String description;
  final EventType type;
  final int cashEffect;       // 現金への直接影響
  final int passiveEffect;    // パッシブ収入への影響（全投資合計に割合）
  final bool isMarketBoom;    // 好景気フラグ
  final bool isMarketBust;    // 不景気フラグ

  const GameEvent({
    required this.title,
    required this.description,
    required this.type,
    this.cashEffect = 0,
    this.passiveEffect = 0,
    this.isMarketBoom = false,
    this.isMarketBust = false,
  });
}

class EventRecord {
  final String title;
  final String description;
  final EventType type;
  final int turn;

  const EventRecord({
    required this.title,
    required this.description,
    required this.type,
    required this.turn,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'type': type.index,
        'turn': turn,
      };

  factory EventRecord.fromJson(Map<String, dynamic> json) => EventRecord(
        title: json['title'],
        description: json['description'],
        type: EventType.values[json['type']],
        turn: json['turn'],
      );
}
