import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_state.dart';
import '../models/investment.dart';
import '../models/event.dart';
import '../data/events_data.dart';

class GameProvider extends ChangeNotifier {
  GameState _state = GameState.initial();
  GameEvent? _pendingEvent;
  List<TroubleMessage> _pendingTroubles = [];

  GameState get state => _state;
  GameEvent? get pendingEvent => _pendingEvent;
  List<TroubleMessage> get pendingTroubles => _pendingTroubles;

  bool get hasPendingEvents =>
      _pendingEvent != null || _pendingTroubles.isNotEmpty;

  GameProvider() {
    _load();
  }

  // ---- 月送り ----
  void nextTurn() {
    final rng = Random();
    int newCash = _state.cash;
    final List<Investment> updatedInvestments =
        _state.ownedInvestments.map((inv) => inv.copyWith()).toList();
    final List<TroubleMessage> troubles = [];

    // 市況ターン数減算
    int boomLeft = max(0, _state.marketBoomTurnsLeft - 1);
    int bustLeft = max(0, _state.marketBustTurnsLeft - 1);

    // ① フラグリセット
    for (int i = 0; i < updatedInvestments.length; i++) {
      final inv = updatedInvestments[i];
      updatedInvestments[i] = inv.copyWith(
        incomeSuspended: false,
        incomeHalved: false,
      );
    }

    // ② 月収計算
    final tempState = _state.copyWith(
      ownedInvestments: updatedInvestments,
      marketBoomTurnsLeft: boomLeft,
      marketBustTurnsLeft: bustLeft,
    );
    newCash += tempState.totalMonthlyIncome - tempState.livingCost;

    // ③ トラブル判定
    for (int i = 0; i < updatedInvestments.length; i++) {
      final inv = updatedInvestments[i];
      final troubleChance = (4 - inv.stability) * 10; // 10%, 20%, 30%
      if (rng.nextInt(100) < troubleChance) {
        final troubleType = rng.nextInt(4);
        int newTroubleCount = inv.troubleCount + 1;
        bool suspended = false;
        bool halved = false;

        if (newTroubleCount >= 3) {
          newCash += inv.sellPrice;
          troubles.add(TroubleMessage(
            '「${inv.name}」が3回トラブル！強制売却（${_yen(inv.sellPrice)}）',
            '"${inv.nameEn}" hit 3 troubles! Force sold (${_usd(inv.sellPrice)})',
          ));
          updatedInvestments[i] = inv.copyWith(
            active: false,
            troubleCount: newTroubleCount,
          );
        } else {
          switch (troubleType) {
            case 0:
              final cost = 10000 + rng.nextInt(5) * 5000;
              newCash -= cost;
              troubles.add(TroubleMessage(
                '「${inv.name}」修理費が発生（-${_yen(cost)}）',
                '"${inv.nameEn}" repair cost (-${_usd(cost)})',
              ));
              break;
            case 1:
              halved = true;
              troubles.add(TroubleMessage(
                '「${inv.name}」今月の収入が半減',
                '"${inv.nameEn}" income halved this month',
              ));
              break;
            case 2:
              suspended = true;
              troubles.add(TroubleMessage(
                '「${inv.name}」今月の収入が停止',
                '"${inv.nameEn}" income suspended this month',
              ));
              break;
            case 3:
              final reduced = (inv.monthlyIncome * 0.2).round();
              newCash -= reduced;
              troubles.add(TroubleMessage(
                '「${inv.name}」収入の一部が損失（-${_yen(reduced)}）',
                '"${inv.nameEn}" partial income loss (-${_usd(reduced)})',
              ));
              break;
          }
          updatedInvestments[i] = inv.copyWith(
            troubleCount: newTroubleCount,
            incomeSuspended: suspended,
            incomeHalved: halved,
          );
        }
      }
    }

    final activeInvestments =
        updatedInvestments.where((inv) => inv.active).toList();

    // ④ イベント抽選
    GameEvent? event;
    if (rng.nextInt(4) != 0) {
      final typeRoll = rng.nextInt(3);
      final pool = typeRoll == 0
          ? goodEvents
          : typeRoll == 1
              ? expenseEvents
              : marketEvents;
      event = pool[rng.nextInt(pool.length)];
      newCash += event.cashEffect;
      if (event.isMarketBoom) boomLeft = 2;
      if (event.isMarketBust) bustLeft = 2;
    }

    final newEventHistory = [
      ..._state.eventHistory,
      if (event != null)
        EventRecord(
          title: event.title,
          titleEn: event.titleEn,
          description: event.description,
          descriptionEn: event.descriptionEn,
          type: event.type,
          turn: _state.turn,
        ),
    ];

    final newState = _state.copyWith(
      cash: newCash,
      turn: _state.turn + 1,
      ownedInvestments: activeInvestments,
      eventHistory: newEventHistory,
      marketBoomTurnsLeft: boomLeft,
      marketBustTurnsLeft: bustLeft,
    );

    _state = newState.copyWith(isVictory: newState.canEscape);
    _pendingEvent = event;
    _pendingTroubles = troubles;

    _save();
    notifyListeners();
  }

  void clearPendingEvent() {
    _pendingEvent = null;
    _pendingTroubles = [];
    notifyListeners();
  }

  // ---- 投資購入 ----
  bool buyInvestment(Investment template) {
    if (_state.cash < template.purchasePrice) return false;

    final newInvestment = Investment(
      id: '${template.id}_${DateTime.now().millisecondsSinceEpoch}',
      name: template.name,
      nameEn: template.nameEn,
      purchasePrice: template.purchasePrice,
      monthlyIncome: template.monthlyIncome,
      size: template.size,
      stability: template.stability,
    );

    _state = _state.copyWith(
      cash: _state.cash - template.purchasePrice,
      ownedInvestments: [..._state.ownedInvestments, newInvestment],
    );
    _save();
    notifyListeners();
    return true;
  }

  // ---- 投資売却 ----
  void sellInvestment(String id) {
    final inv = _state.ownedInvestments.firstWhere((e) => e.id == id);
    _state = _state.copyWith(
      cash: _state.cash + inv.sellPrice,
      ownedInvestments: _state.ownedInvestments.where((e) => e.id != id).toList(),
    );
    _save();
    notifyListeners();
  }

  // ---- リセット ----
  void resetGame() {
    _state = GameState.initial();
    _pendingEvent = null;
    _pendingTroubles = [];
    _save();
    notifyListeners();
  }

  // ---- 保存 / 読み込み ----
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('game_state', jsonEncode(_state.toJson()));
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('game_state');
    if (raw != null) {
      try {
        _state = GameState.fromJson(jsonDecode(raw));
        notifyListeners();
      } catch (_) {
        _state = GameState.initial();
      }
    }
  }

  String _fmt(int amount) => amount.abs()
      .toString()
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
  String _yen(int amount) => '${_fmt(amount)}円';
  String _usd(int amount) => '¥${_fmt(amount)}';
}
