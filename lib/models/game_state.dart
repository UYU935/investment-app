import 'investment.dart';
import 'event.dart';

class GameState {
  final int cash;
  final int salary;
  final int livingCost;
  final int turn;
  final List<Investment> ownedInvestments;
  final List<EventRecord> eventHistory;
  final bool isGameOver;
  final bool isVictory;
  final int marketBoomTurnsLeft;  // 好景気残りターン
  final int marketBustTurnsLeft;  // 不景気残りターン

  const GameState({
    required this.cash,
    required this.salary,
    required this.livingCost,
    required this.turn,
    required this.ownedInvestments,
    required this.eventHistory,
    this.isGameOver = false,
    this.isVictory = false,
    this.marketBoomTurnsLeft = 0,
    this.marketBustTurnsLeft = 0,
  });

  factory GameState.initial() => const GameState(
        cash: 100000,
        salary: 100000,
        livingCost: 80000,
        turn: 1,
        ownedInvestments: [],
        eventHistory: [],
      );

  int get passiveIncome {
    int total = 0;
    for (final inv in ownedInvestments) {
      if (!inv.active) continue;
      if (inv.incomeSuspended) continue;
      int income = inv.monthlyIncome;
      if (inv.incomeHalved) income = (income / 2).round();
      if (marketBoomTurnsLeft > 0) income = (income * 1.5).round();
      if (marketBustTurnsLeft > 0) income = (income * 0.5).round();
      total += income;
    }
    return total;
  }

  int get totalMonthlyIncome => salary + passiveIncome;
  int get monthlyCashFlow => totalMonthlyIncome - livingCost;
  bool get canEscape => passiveIncome >= livingCost;

  GameState copyWith({
    int? cash,
    int? salary,
    int? livingCost,
    int? turn,
    List<Investment>? ownedInvestments,
    List<EventRecord>? eventHistory,
    bool? isGameOver,
    bool? isVictory,
    int? marketBoomTurnsLeft,
    int? marketBustTurnsLeft,
  }) {
    return GameState(
      cash: cash ?? this.cash,
      salary: salary ?? this.salary,
      livingCost: livingCost ?? this.livingCost,
      turn: turn ?? this.turn,
      ownedInvestments: ownedInvestments ?? this.ownedInvestments,
      eventHistory: eventHistory ?? this.eventHistory,
      isGameOver: isGameOver ?? this.isGameOver,
      isVictory: isVictory ?? this.isVictory,
      marketBoomTurnsLeft: marketBoomTurnsLeft ?? this.marketBoomTurnsLeft,
      marketBustTurnsLeft: marketBustTurnsLeft ?? this.marketBustTurnsLeft,
    );
  }

  Map<String, dynamic> toJson() => {
        'cash': cash,
        'salary': salary,
        'livingCost': livingCost,
        'turn': turn,
        'ownedInvestments': ownedInvestments.map((e) => e.toJson()).toList(),
        'eventHistory': eventHistory.map((e) => e.toJson()).toList(),
        'isGameOver': isGameOver,
        'isVictory': isVictory,
        'marketBoomTurnsLeft': marketBoomTurnsLeft,
        'marketBustTurnsLeft': marketBustTurnsLeft,
      };

  factory GameState.fromJson(Map<String, dynamic> json) => GameState(
        cash: json['cash'],
        salary: json['salary'],
        livingCost: json['livingCost'],
        turn: json['turn'],
        ownedInvestments: (json['ownedInvestments'] as List)
            .map((e) => Investment.fromJson(e))
            .toList(),
        eventHistory: (json['eventHistory'] as List)
            .map((e) => EventRecord.fromJson(e))
            .toList(),
        isGameOver: json['isGameOver'] ?? false,
        isVictory: json['isVictory'] ?? false,
        marketBoomTurnsLeft: json['marketBoomTurnsLeft'] ?? 0,
        marketBustTurnsLeft: json['marketBustTurnsLeft'] ?? 0,
      );
}
