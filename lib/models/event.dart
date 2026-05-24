enum EventType { good, expense, market }

class GameEvent {
  final String title;
  final String titleEn;
  final String description;
  final String descriptionEn;
  final EventType type;
  final int cashEffect;
  final bool isMarketBoom;
  final bool isMarketBust;

  const GameEvent({
    required this.title,
    required this.titleEn,
    required this.description,
    required this.descriptionEn,
    required this.type,
    this.cashEffect = 0,
    this.isMarketBoom = false,
    this.isMarketBust = false,
  });

  String localizedTitle(String locale) => locale == 'ja' ? title : titleEn;
  String localizedDescription(String locale) =>
      locale == 'ja' ? description : descriptionEn;
}

// トラブルメッセージ（日英両対応）
class TroubleMessage {
  final String ja;
  final String en;
  const TroubleMessage(this.ja, this.en);
  String localized(String locale) => locale == 'ja' ? ja : en;
}

class EventRecord {
  final String title;
  final String titleEn;
  final String description;
  final String descriptionEn;
  final EventType type;
  final int turn;

  const EventRecord({
    required this.title,
    required this.titleEn,
    required this.description,
    required this.descriptionEn,
    required this.type,
    required this.turn,
  });

  String localizedTitle(String locale) => locale == 'ja' ? title : titleEn;
  String localizedDescription(String locale) =>
      locale == 'ja' ? description : descriptionEn;

  Map<String, dynamic> toJson() => {
        'title': title,
        'titleEn': titleEn,
        'description': description,
        'descriptionEn': descriptionEn,
        'type': type.index,
        'turn': turn,
      };

  factory EventRecord.fromJson(Map<String, dynamic> json) => EventRecord(
        title: json['title'],
        titleEn: json['titleEn'] ?? json['title'],
        description: json['description'],
        descriptionEn: json['descriptionEn'] ?? json['description'],
        type: EventType.values[json['type']],
        turn: json['turn'],
      );
}
