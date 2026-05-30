import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import '../providers/locale_provider.dart';
import '../utils/space_assets.dart';
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
  int _lastLevel = 1;

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
      _lastLevel = state.spaceDevelopmentLevel;
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

  Future<void> _showLevelUpOverlay(int level) async {
    if (!mounted) return;
    final s = context.read<LocaleProvider>().strings;
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (_, __, ___) => _LevelUpPage(
        level: level,
        bgAsset: SpaceAssets.bgForLevel(level),
        title: s.levelUpTitle(level),
        subtitle: s.levelUpSubtitle(level),
      ),
      transitionBuilder: (_, anim, __, child) => FadeTransition(
        opacity: anim,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final locale = context.watch<LocaleProvider>();
    final s = locale.strings;
    final state = game.state;
    final cf = state.monthlyCashFlow;

    if (!_cashController.isAnimating) {
      _fromCash = state.cash;
      _toCash = state.cash;
    }
    if (!_passiveController.isAnimating) {
      _fromPassive = state.passiveIncome;
      _toPassive = state.passiveIncome;
    }

    // レベルアップ検知
    final currentLevel = state.spaceDevelopmentLevel;
    if (currentLevel > _lastLevel) {
      _lastLevel = currentLevel;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showLevelUpOverlay(currentLevel);
      });
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_cashController, _passiveController]),
      builder: (context, _) {
        final cashDisplay = _cashDisplay;
        final passiveDisplay = _passiveDisplay;

        return Stack(
          fit: StackFit.expand,
          children: [
            // 背景画像（レベル変化時にアニメーション遷移）
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 1200),
              child: Image.asset(
                SpaceAssets.bgForLevel(state.spaceDevelopmentLevel),
                key: ValueKey(state.spaceDevelopmentLevel),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            // 暗いオーバーレイ
            Container(color: const Color(0x99000000)),
            // メインコンテンツ
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: Text(s.appTitle),
                backgroundColor: Colors.black54,
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
                          style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white60,
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

                    // 現金カード
                    _buildCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(s.cashLabel,
                              style: const TextStyle(fontSize: 16, color: Colors.white60)),
                          Text(
                            s.currency(cashDisplay),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: cashDisplay >= 0 ? Colors.white : Colors.red[300],
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
                          _buildRow(s.salaryLabel, s.currency(state.salary), Colors.lightBlue[300]!),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(s.passiveIncomeLabel,
                                  style: const TextStyle(color: Colors.white60)),
                              Text(
                                s.currency(passiveDisplay),
                                style: TextStyle(
                                    color: Colors.green[300], fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const Divider(height: 16, color: Colors.white12),
                          _buildRow(s.monthlyTotalLabel,
                              s.currency(state.totalMonthlyIncome), Colors.white),
                          _buildRow(s.livingCostLabel,
                              '-${s.currency(state.livingCost)}', Colors.red[300]!),
                          const Divider(height: 16, color: Colors.white12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(s.monthlyCashFlowLabel,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white)),
                              Text(s.currency(cf),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: cf >= 0 ? Colors.lightBlue[300] : Colors.red[300])),
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
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.white70)),
                          const SizedBox(height: 8),
                          Text(
                            s.spaceLevelText(state.spaceDevelopmentLevel),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.amberAccent,
                            ),
                          ),
                          if (state.spaceDevelopmentLevel == 4) ...[
                            const SizedBox(height: 4),
                            Text(
                              s.colonyProgress(state.spaceColonyCount),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.purpleAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          const SizedBox(height: 6),
                          Text(
                            s.nextLevelHint(state.spaceDevelopmentLevel, state.spaceColonyCount),
                            style: const TextStyle(fontSize: 12, color: Colors.white38),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 継続収益バー
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.incomeBarLabel,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.white70)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                s.incomeBarDetail(
                                  s.currency(passiveDisplay),
                                  s.currency(state.livingCost),
                                ),
                                style: TextStyle(
                                    color: Colors.green[300], fontSize: 13),
                              ),
                              Text(
                                '${((passiveDisplay / state.livingCost) * 100).clamp(0, 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                    color: Colors.green[300],
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (passiveDisplay / state.livingCost)
                                  .clamp(0.0, 1.0),
                              minHeight: 10,
                              backgroundColor: Colors.white12,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.green[400]!),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    _buildCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(s.ownedCountLabel,
                              style: const TextStyle(color: Colors.white60)),
                          Text(s.ownedCount(state.ownedInvestments.length),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () => _handleNextTurn(game),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo[500],
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
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white38),
                            ),
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
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white38),
                            ),
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
                      style: TextButton.styleFrom(foregroundColor: Colors.white60),
                      child: Text(s.eventHistoryButton),
                    ),
                    const SizedBox(height: 4),

                    TextButton(
                      onPressed: () => _confirmReset(context, game, s),
                      child: Text(s.resetButton,
                          style: const TextStyle(color: Colors.white30, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
              color: selected ? Colors.indigo[400] : Colors.white12,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              code == 'ja' ? 'JP' : 'EN',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: selected ? Colors.white : Colors.white60,
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
          BoxDecoration(color: color.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(8)),
      child: Text(text,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: const Color(0xBB0d0d1a),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }

  Widget _buildRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60)),
          Text(value,
              style: TextStyle(color: valueColor, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, GameProvider game, dynamic s) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: Text(s.resetConfirmTitle, style: const TextStyle(color: Colors.white)),
        content: Text(s.resetConfirmMessage, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(s.cancelButton, style: const TextStyle(color: Colors.white60))),
          TextButton(
            onPressed: () {
              game.resetGame();
              setState(() {
                _fromCash = 100;
                _toCash = 100;
                _fromPassive = 0;
                _toPassive = 0;
                _lastLevel = 1;
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

// ---- レベルアップ演出オーバーレイ ----
class _LevelUpPage extends StatefulWidget {
  final int level;
  final String bgAsset;
  final String title;
  final String subtitle;

  const _LevelUpPage({
    required this.level,
    required this.bgAsset,
    required this.title,
    required this.subtitle,
  });

  @override
  State<_LevelUpPage> createState() => _LevelUpPageState();
}

class _LevelUpPageState extends State<_LevelUpPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 0.4, curve: Curves.easeIn)),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    // 3秒後に自動で閉じる
    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 新レベルの背景画像
          Image.asset(widget.bgAsset, fit: BoxFit.cover),
          // 暗いオーバーレイ
          Container(color: const Color(0xAA000000)),
          // メッセージ
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 輝くアイコン
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.amber.withValues(alpha: 0.2),
                          border: Border.all(color: Colors.amber, width: 2),
                        ),
                        child: const Icon(
                          Icons.rocket_launch_rounded,
                          size: 54,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(height: 28),
                      // "LEVEL UP" ラベル
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.amber.withValues(alpha: 0.6)),
                        ),
                        child: const Text(
                          'LEVEL UP',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // タイトル（大）
                      Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 12,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // サブタイトル
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          widget.subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      // タップヒント
                      const Text(
                        'TAP TO CONTINUE',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white30,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
