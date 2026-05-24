import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import '../utils/format.dart';
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

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _cashController;
  late AnimationController _passiveController;

  // アニメーションの現在値（表示用）
  int _cashDisplay = 100000;
  int _passiveDisplay = 0;
  // アニメーションの終端値
  int _cashTarget = 100000;
  int _passiveTarget = 0;

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _cashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..addListener(() => setState(() {}));

    _passiveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..addListener(() => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final state = context.read<GameProvider>().state;
      _cashDisplay = state.cash;
      _cashTarget = state.cash;
      _passiveDisplay = state.passiveIncome;
      _passiveTarget = state.passiveIncome;
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _cashController.dispose();
    _passiveController.dispose();
    super.dispose();
  }

  // イベント画面から戻った後にカウントアップ開始
  void _animateTo(int newCash, int newPassive) {
    final fromCash = _cashTarget;
    final fromPassive = _passiveTarget;
    _cashTarget = newCash;
    _passiveTarget = newPassive;

    _cashController.reset();
    _passiveController.reset();

    _cashController.addListener(() {
      setState(() {
        _cashDisplay = (fromCash +
                (_cashTarget - fromCash) *
                    CurvedAnimation(
                            parent: _cashController, curve: Curves.easeOut)
                        .value)
            .round();
      });
    });
    _passiveController.addListener(() {
      setState(() {
        _passiveDisplay = (fromPassive +
                (_passiveTarget - fromPassive) *
                    CurvedAnimation(
                            parent: _passiveController, curve: Curves.easeOut)
                        .value)
            .round();
      });
    });

    _cashController.forward();
    _passiveController.forward();
  }

  Future<void> _handleNextTurn(GameProvider provider) async {
    // ターン前の値を保存
    final oldCash = provider.state.cash;
    final oldPassive = provider.state.passiveIncome;

    provider.nextTurn();

    if (!mounted) return;

    // イベント画面を表示して待機
    if (provider.pendingEvent != null ||
        provider.pendingTroubleMessages.isNotEmpty) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const EventScreen()),
      );
    }

    if (!mounted) return;

    // 勝利判定
    if (provider.state.isVictory) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const VictoryScreen()),
      );
      return;
    }

    // イベント画面から戻った後にアニメーション開始
    _cashDisplay = oldCash;
    _passiveDisplay = oldPassive;
    _animateTo(provider.state.cash, provider.state.passiveIncome);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, _) {
        final state = provider.state;
        final cf = state.monthlyCashFlow;
        final cfColor = cf >= 0 ? Colors.blue[700]! : Colors.red[700]!;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          appBar: AppBar(
            title: const Text('キャッシュフロー学習'),
            backgroundColor: Colors.indigo[700],
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ターン表示
                Center(
                  child: Text(
                    '第 ${state.turn} ターン',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 市況バナー
                if (state.marketBoomTurnsLeft > 0)
                  _buildBanner(
                    '好景気中！ 投資収入1.5倍（残り${state.marketBoomTurnsLeft}ターン）',
                    Colors.green[700]!,
                  ),
                if (state.marketBustTurnsLeft > 0)
                  _buildBanner(
                    '不景気中… 投資収入0.5倍（残り${state.marketBustTurnsLeft}ターン）',
                    Colors.orange[700]!,
                  ),

                // 現金カード（カウントアップアニメーション）
                _buildCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('現在の現金',
                          style: TextStyle(
                              fontSize: 16, color: Colors.black54)),
                      Text(
                        formatYen(_cashDisplay),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _cashDisplay >= 0
                              ? Colors.black87
                              : Colors.red[700],
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
                      _buildRow(
                          '給料', formatYen(state.salary), Colors.blue[700]!),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('投資収入（パッシブ）',
                              style: TextStyle(color: Colors.black54)),
                          Text(
                            formatYen(_passiveDisplay),
                            style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      _buildRow('月収合計',
                          formatYen(state.totalMonthlyIncome), Colors.black87),
                      _buildRow('生活費',
                          '-${formatYen(state.livingCost)}', Colors.red[700]!),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('毎月の余裕',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(
                            formatYen(cf),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: cfColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // 目標進捗
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ラットレース脱出まで',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('投資収入 ${formatYen(state.passiveIncome)}',
                              style: const TextStyle(
                                  color: Colors.green, fontSize: 13)),
                          Text('目標 ${formatYen(state.livingCost)}',
                              style: const TextStyle(
                                  color: Colors.black54, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (state.passiveIncome / state.livingCost)
                              .clamp(0.0, 1.0),
                          minHeight: 10,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.green[600]!),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // 所有投資数
                _buildCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('所有投資数',
                          style: TextStyle(color: Colors.black54)),
                      Text(
                        '${state.ownedInvestments.length} 件',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 次の月へボタン
                ElevatedButton(
                  onPressed: () => _handleNextTurn(provider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('次の月へ進む'),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const InvestmentListScreen()),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('投資を見る'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const OwnedInvestmentsScreen()),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('所有投資'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const EventHistoryScreen()),
                  ),
                  child: const Text('イベント履歴'),
                ),
                const SizedBox(height: 4),

                TextButton(
                  onPressed: () => _confirmReset(context, provider),
                  child: Text('リセット',
                      style: TextStyle(
                          color: Colors.grey[500], fontSize: 12)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBanner(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
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
              style: TextStyle(
                  color: valueColor, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, GameProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('リセット確認'),
        content: const Text('ゲームをリセットしますか？\n進行状況は消えます。'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル')),
          TextButton(
            onPressed: () {
              provider.resetGame();
              setState(() {
                _cashDisplay = 100000;
                _cashTarget = 100000;
                _passiveDisplay = 0;
                _passiveTarget = 0;
              });
              Navigator.pop(context);
            },
            child: const Text('リセット',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
