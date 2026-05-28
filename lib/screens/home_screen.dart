import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import '../providers/locale_provider.dart';
import 'investment_list_screen.dart';
import 'owned_investments_screen.dart';
import 'event_screen.dart';
import 'victory_screen.dart';
import 'event_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _cashController;
  late AnimationController _passiveController;

  int _fromCash = 100;
  int _toCash = 100;
  int _fromPassive = 0;
  int _toPassive = 0;

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _cashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
    _passiveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final state = context.read<GameProvider>().state;
      _fromCash = state.cash;
      _toCash = state.cash;
      _fromPassive = state.passiveIncome;
      _toPassive = state.passiveIncome;
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _cashController.dispose();
    _passiveController.dispose();
    super.dispose();
  }

  void _startAnimation(int fromCash, int fromPassive, int newCash, int newPassive) {
    _fromCash = fromCash;
    _fromPassive = fromPassive;
    _toCash = newCash;
    _toPassive = newPassive;
    _cashController.forward(from: 0);
    _passiveController.forward(from: 0);
  }

  int get _cashDisplay {
    final t = Curves.easeOut.transform(_cashController.value);
    return (_fromCash + (_toCash - _fromCash) * t).round();
  }

  int get _passiveDisplay {
    final t = Curves.easeOut.transform(_passiveController.value);
    return (_fromPassive + (_toPassive - _fromPassive) * t).round();
  }

  Future<void> _handleNextTurn(GameProvider game) async {
    final oldCash = game.state.cash;
    final oldPassive = game.state.passiveIncome;

    game.nextTurn();

    if (!mounted) return;

    if (game.hasPendingEvents) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const EventScreen()),
      );
    }

    if (!mounted) return;

    if (game.state.isVictory) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const VictoryScreen()),
      );
      return;
    }

    _startAnimation(oldCash, oldPassive, game.state.cash, game.state.passiveIncome);
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final locale = context.watch<LocaleProvider>();
    final s = locale.strings;
    final state = game.state;
    final cf = state.monthlyCashFlow;
    final cfColor = cf >= 0 ? Colors.blue[700]! : Colors.red[700]!;

    if (!_cashController.isAnimating) {
      _fromCash = state.cash;
      _toCash = state.cash;
    }
    if (!_passiveController.isAnimating) {
      _fromPassive = state.passiveIncome;
      _toPassive = state.passiveIncome;
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_cashController, _passiveController]),
      builder: (context, _) {
        final cashDisplay = _cashDisplay;
        final passiveDisplay = _passiveDisplay;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          appBar: AppBar(
            title: Text(s.appTitle),
            backgroundColor: Colors.indigo[700],
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 言語切り替え＆ターン表示
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      s.turn(state.turn),
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500),
                    ),
                    _buildLangSelector(locale),
                  ],
                ),
                const SizedBox(height: 12),

                if (state.marketBoomTurnsLeft > 0)
                  _buildBanner(s.marketBoom(state.marketBoomTurnsLeft), Colors.green[700]!),
                if (state.marketBustTurnsLeft > 0)
                  _buildBanner(s.marketBust(state.marketBustTurnsLeft), Colors.orange[700]!),

                // 現金カード（アニメーション）
                _buildCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(s.cashLabel,
                          style: const TextStyle(fontSize: 16, color: Colors.black54)),
                      Text(
                        s.currency(cashDisplay),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: cashDisplay >= 0 ? Colors.black87 : Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // 収支カード
                _buildCard(
                  child: Column(
                    children: [
                      _buildRow(s.salaryLabel, s.currency(state.salary), Colors.blue[700]!),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(s.passiveIncomeLabel,
                              style: const TextStyle(color: Colors.black54)),
                          Text(
                            s.currency(passiveDisplay),
                            style: TextStyle(
                                color: Colors.green[700], fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      _buildRow(s.monthlyTotalLabel,
                          s.currency(state.totalMonthlyIncome), Colors.black87),
                      _buildRow(s.livingCostLabel,
                          '-${s.currency(state.livingCost)}', Colors.red[700]!),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(s.monthlyCashFlowLabel,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(s.currency(cf),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: cfColor)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // 宇宙開発レベル
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.spaceLevelLabel,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      Text(
                        s.spaceLevelText(state.spaceDevelopmentLevel),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo[700],
                        ),
                      ),
                      if (state.spaceDevelopmentLevel == 4) ...[
                        const SizedBox(height: 6),
                        Text(
                          s.colonyProgress(state.spaceColonyCount),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.deepPurple[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                _buildCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(s.ownedCountLabel,
                          style: const TextStyle(color: Colors.black54)),
                      Text(s.ownedCount(state.ownedInvestments.length),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () => _handleNextTurn(game),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: Text(s.nextMonthButton),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) => const InvestmentListScreen())),
                        style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14)),
                        child: Text(s.viewInvestmentsButton),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) => const OwnedInvestmentsScreen())),
                        style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14)),
                        child: Text(s.myInvestmentsButton),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                TextButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const EventHistoryScreen())),
                  child: Text(s.eventHistoryButton),
                ),
                const SizedBox(height: 4),

                TextButton(
                  onPressed: () => _confirmReset(context, game, s),
                  child: Text(s.resetButton,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLangSelector(LocaleProvider locale) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: ['ja', 'en'].map((code) {
        final selected = locale.locale == code;
        return GestureDetector(
          onTap: () => locale.setLocale(code),
          child: Container(
            margin: const EdgeInsets.only(left: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: selected ? Colors.indigo[700] : Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              code == 'ja' ? 'JP' : 'EN',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: selected ? Colors.white : Colors.grey[700],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBanner(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Text(text,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }

  Widget _buildRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(value,
              style:
                  TextStyle(color: valueColor, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, GameProvider game, dynamic s) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(s.resetConfirmTitle),
        content: Text(s.resetConfirmMessage),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(s.cancelButton)),
          TextButton(
            onPressed: () {
              game.resetGame();
              setState(() {
                _fromCash = 100;
                _toCash = 100;
                _fromPassive = 0;
                _toPassive = 0;
              });
              _cashController.reset();
              _passiveController.reset();
              Navigator.pop(context);
            },
            child: Text(s.resetButton,
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
