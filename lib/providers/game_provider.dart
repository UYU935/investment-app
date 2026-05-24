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
  List<String> _pendingTroubleMessages = [];

  GameState get state => _state;
  GameEvent? get pendingEvent => _pendingEvent;
  List<String> get pendingTroubleMessages => _pendingTroubleMessages;

  GameProvider() {
    _load();
  }

  // ---- 月送り ----
  void nextTurn() {
    final rng = Random();
    int newCash = _state.cash;
    final List<Investment> updatedInvestments =
        _state.ownedInvestments.map((inv) => inv.copyWith()).toList();
    final List<String> troubles = [];

    // 市況ターン数減算
    int boomLeft = max(0, _state.marketBoomTurnsLeft - 1);
    int bustLeft = max(0, _state.marketBustTurnsLeft - 1);

    // ① 投資トラブル判定 & フラグリセット
    for (int i = 0; i < updatedInvestments.length; i++) {
      final inv = updatedInvestments[i];
      // 前ターンのフラグをリセット
      updatedInvestments[i] = inv.copyWith(
        incomeSuspended: false,
        incomeHalved: false,
      );
    }

    // ② 月収計算（市況はこのターンの残りを使う）
    final tempState = _state.copyWith(
      ownedInvestments: updatedInvestments,
      marketBoomTurnsLeft: boomLeft,
      marketBustTurnsLeft: bustLeft,
    );
    final income = tempState.totalMonthlyIncome;
    final livingCost = tempState.livingCost;
    newCash += income - livingCost;

    // ③ トラブル判定（各投資）
    for (int i = 0; i < updatedInvestments.length; i++) {
      final inv = updatedInvestments[i];
      // トラブル確率: 安定度3→10%, 2→20%, 1→30%
      final troubleChance = (4 - inv.stability) * 10;
      if (rng.nextInt(100) < troubleChance) {
        // トラブル発生
        final troubleType = rng.nextInt(4);
        int newTroubleCount = inv.troubleCount + 1;
        bool suspended = false;
        bool halved = false;

        if (newTroubleCount >= 3) {
          // 強制売却
          newCash += inv.sellPrice;
          troubles.add('「${inv.name}」が3回トラブル！強制売却（${_yen(inv.sellPrice)}）');
          updatedInvestments[i] = inv.copyWith(
            active: false,
            troubleCount: newTroubleCount,
          );
        } else {
          switch (troubleType) {
            case 0:
              final cost = 10000 + rng.nextInt(5) * 5000;
              newCash -= cost;
              troubles.add('「${inv.name}」修理費が発生（-${_yen(cost)}）');
              break;
            case 1:
              halved = true;
              troubles.add('「${inv.name}」今月の収入が半減');
              break;
            case 2:
              suspended = true;
              troubles.add('「${inv.name}」今月の収入が停止');
              break;
            case 3:
              final reduced = (inv.monthlyIncome * 0.2).round();
              newCash -= reduced;
              troubles.add('「${inv.name}」収入の一部が損失（-${_yen(reduced)}）');
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

    // 強制売却済みを除外
    final activeInvestments =
        updatedInvestments.where((inv) => inv.active).toList();

    // ④ イベント抽選
    GameEvent? event;
    final eventRoll = rng.nextInt(4); // 0〜3、0なら無し
    if (eventRoll != 0) {
      final typeRoll = rng.nextInt(3);
      List<GameEvent> pool;
      if (typeRoll == 0) {
        pool = goodEvents;
      } else if (typeRoll == 1) {
        pool = expenseEvents;
      } else {
        pool = marketEvents;
      }
      event = pool[rng.nextInt(pool.length)];

      // イベント効果
      newCash += event.cashEffect;
      if (event.isMarketBoom) boomLeft = 2;
      if (event.isMarketBust) bustLeft = 2;
    }

    // ⑤ 現金下限（マイナスになりすぎたら即終了はしない）
    final newEventHistory = [
      ..._state.eventHistory,
      if (event != null)
        EventRecord(
          title: event.title,
          description: event.description,
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

    // ⑥ 勝利判定
    final isVictory = newState.canEscape;

    _state = newState.copyWith(isVictory: isVictory);
    _pendingEvent = event;
    _pendingTroubleMessages = troubles;

    _save();
    notifyListeners();
  }

  void clearPendingEvent() {
    _pendingEvent = null;
    _pendingTroubleMessages = [];
    notifyListeners();
  }

  // ---- 投資購入 ----
  bool buyInvestment(Investment template) {
    if (_state.cash < template.purchasePrice) return false;

    final newInvestment = Investment(
      id: '${template.id}_${DateTime.now().millisecondsSinceEpoch}',
      name: template.name,
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
    final newOwned =
        _state.ownedInvestments.where((e) => e.id != id).toList();

    _state = _state.copyWith(
      cash: _state.cash + inv.sellPrice,
      ownedInvestments: newOwned,
    );
    _save();
    notifyListeners();
  }

  // ---- リセット ----
  void resetGame() {
    _state = GameState.initial();
    _pendingEvent = null;
    _pendingTroubleMessages = [];
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

  String _yen(int amount) =>
      '${amount < 0 ? '-' : ''}${amount.abs().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}円';
}
