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
    final cfColor = cf >= 0 ? Colors.lightBlue[300]! : Colors.red[300]!;

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
            // 背景画像
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
            // グラデーションオーバーレイ（上は透明→下は暗く）
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x22000000), // 上部：画像が見える
                    Color(0xBB000000), // 下部：テキスト読みやすく
                  ],
                  stops: [0.0, 0.35],
                ),
              ),
            ),
            // メインUI
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.black45,
                foregroundColor: Colors.white,
                elevation: 0,
                title: Text(s.appTitle,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _buildLangSelector(locale),
                  ),
                ],
              ),
              body: Column(
                children: [
                  // 背景画像が見えるエリア
                  const SizedBox(height: 60),
                  // コンテンツパネル
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ターン & マーケット状況
                          Row(
                            children: [
                              Text(s.turn(state.turn),
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white60,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(width: 8),
                              if (state.marketBoomTurnsLeft > 0)
                                _buildInlineBanner(
                                    s.marketBoom(state.marketBoomTurnsLeft), Colors.green[600]!),
                              if (state.marketBustTurnsLeft > 0)
                                _buildInlineBanner(
                                    s.marketBust(state.marketBustTurnsLeft), Colors.orange[700]!),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // ── 資金カード（2カラム） ──
                          _buildCard(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // 左: 現在資金
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(s.cashLabel,
                                          style: const TextStyle(
                                              fontSize: 11, color: Colors.white54)),
                                      const SizedBox(height: 2),
                                      Text(
                                        s.currency(cashDisplay),
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: cashDisplay >= 0
                                              ? Colors.white
                                              : Colors.red[300],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                    width: 1,
                                    height: 56,
                                    color: Colors.white12,
                                    margin: const EdgeInsets.symmetric(horizontal: 12)),
                                // 右: 予算 / 収益 / コスト / 余力
                                Expanded(
                                  flex: 6,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          _miniStat(s.salaryLabel,
                                              s.currency(state.salary), Colors.lightBlue[300]!),
                                          _miniStat(s.passiveIncomeLabel,
                                              s.currency(passiveDisplay), Colors.green[300]!),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          _miniStat(s.livingCostLabel,
                                              '-${s.currency(state.livingCost)}',
                                              Colors.red[300]!),
                                          _miniStat(s.monthlyCashFlowLabel,
                                              s.currency(cf), cfColor),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),

                          // ── 宇宙開発レベル + 進捗バー ──
                          _buildCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.rocket_launch_rounded,
                                        color: Colors.amberAccent, size: 14),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        s.spaceLevelText(state.spaceDevelopmentLevel),
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.amberAccent),
                                      ),
                                    ),
                                    if (state.spaceDevelopmentLevel == 4)
                                      Text(s.colonyProgress(state.spaceColonyCount),
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.purpleAccent,
                                              fontWeight: FontWeight.w600)),
                                    const SizedBox(width: 6),
                                    Text(s.ownedCount(state.ownedInvestments.length),
                                        style: const TextStyle(
                                            fontSize: 11, color: Colors.white38)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(3),
                                        child: LinearProgressIndicator(
                                          value: (passiveDisplay / state.livingCost)
                                              .clamp(0.0, 1.0),
                                          minHeight: 6,
                                          backgroundColor: Colors.white12,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                              Colors.green[400]!),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${((passiveDisplay / state.livingCost) * 100).clamp(0, 100).toStringAsFixed(0)}%',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.green[300],
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  s.nextLevelHint(
                                      state.spaceDevelopmentLevel, state.spaceColonyCount),
                                  style: const TextStyle(fontSize: 10, color: Colors.white30),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ── ボタン群 ──
                          ElevatedButton(
                            onPressed: () => _handleNextTurn(game),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo[500],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              textStyle: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            child: Text(s.nextMonthButton),
                          ),
                          const SizedBox(height: 8),

                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.push(context,
                                      MaterialPageRoute(
                                          builder: (_) => const InvestmentListScreen())),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 11),
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(color: Colors.white38),
                                  ),
                                  child: Text(s.viewInvestmentsButton, style: const TextStyle(fontSize: 13)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.push(context,
                                      MaterialPageRoute(
                                          builder: (_) => const OwnedInvestmentsScreen())),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 11),
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(color: Colors.white38),
                                  ),
                                  child: Text(s.myInvestmentsButton, style: const TextStyle(fontSize: 13)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.push(context,
                                    MaterialPageRoute(
                                        builder: (_) => const EventHistoryScreen())),
                                style: TextButton.styleFrom(foregroundColor: Colors.white38),
                                child: Text(s.eventHistoryButton,
                                    style: const TextStyle(fontSize: 12)),
                              ),
                              const Text('·', style: TextStyle(color: Colors.white24)),
                              TextButton(
                                onPressed: () => _confirmReset(context, game, s),
                                style: TextButton.styleFrom(foregroundColor: Colors.white24),
                                child: Text(s.resetButton,
                                    style: const TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white38, fontSize: 10, height: 1.2)),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildInlineBanner(String text, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration:
            BoxDecoration(color: color.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(6)),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis),
      ),
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: selected ? Colors.indigo[400] : Colors.white12,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              code == 'ja' ? 'JP' : 'EN',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: selected ? Colors.white : Colors.white60,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xCC0d0d1a),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      padding: const EdgeInsets.all(12),
      child: child,
    );
  }

  void _confirmReset(BuildContext context, GameProvider game, dynamic s) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: Text(s.resetConfirmTitle,
            style: const TextStyle(color: Colors.white)),
        content: Text(s.resetConfirmMessage,
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(s.cancelButton,
                  style: const TextStyle(color: Colors.white60))),
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
            child:
                Text(s.resetButton, style: const TextStyle(color: Colors.red)),
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
          Image.asset(widget.bgAsset, fit: BoxFit.cover),
          Container(color: const Color(0xAA000000)),
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
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.amber.withValues(alpha: 0.2),
                          border: Border.all(color: Colors.amber, width: 2),
                        ),
                        child: const Icon(Icons.rocket_launch_rounded,
                            size: 54, color: Colors.amber),
                      ),
                      const SizedBox(height: 28),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.amber.withValues(alpha: 0.6)),
                        ),
                        child: const Text('LEVEL UP',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                                letterSpacing: 4)),
                      ),
                      const SizedBox(height: 16),
                      Text(widget.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                    color: Colors.black,
                                    blurRadius: 12,
                                    offset: Offset(0, 2))
                              ])),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(widget.subtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                                height: 1.5)),
                      ),
                      const SizedBox(height: 40),
                      const Text('TAP TO CONTINUE',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.white30,
                              letterSpacing: 2)),
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
