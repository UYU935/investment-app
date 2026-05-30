import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import '../providers/locale_provider.dart';
import '../utils/space_assets.dart';
import 'home_screen.dart';

class VictoryScreen extends StatefulWidget {
  const VictoryScreen({super.key});

  @override
  State<VictoryScreen> createState() => _VictoryScreenState();
}

class _VictoryScreenState extends State<VictoryScreen> {
  bool _bgVisible = false;
  bool _overlayDark = false; // ロゴ登場と同時に暗くなる

  // 要素ごとの表示フラグ
  // 0: ロゴ  1: タイトル  2: メッセージ説明
  // 3: 最終資金  4: 保有プロジェクト数  5: 到達開発期  6: 継続収益
  // 7: もう一度プレイ
  final List<bool> _visible = List.filled(8, false);

  @override
  void initState() {
    super.initState();
    _startSequence();
  }

  Future<void> _startSequence() async {
    // 背景フェードイン開始（5秒かけて表示）
    if (!mounted) return;
    setState(() => _bgVisible = true);

    // 背景5秒 + 待機3秒
    await Future.delayed(const Duration(seconds: 8));

    // ロゴ登場と同時にオーバーレイを暗くする
    if (!mounted) return;
    setState(() {
      _overlayDark = true;
      _visible[0] = true;
    });
    await Future.delayed(const Duration(seconds: 2));

    // 残り要素を順番に：1秒フェードイン → 1秒待機 → 次へ
    for (int i = 1; i < _visible.length; i++) {
      if (!mounted) return;
      setState(() => _visible[i] = true);
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final s = context.watch<LocaleProvider>().strings;
    final state = game.state;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 背景画像（5秒でフェードイン）
        AnimatedOpacity(
          opacity: _bgVisible ? 1.0 : 0.0,
          duration: const Duration(seconds: 5),
          child: Image.asset(SpaceAssets.bgVictory, fit: BoxFit.cover),
        ),
        // 暗いオーバーレイ：ロゴ登場時に1.5秒かけて暗くなる
        AnimatedOpacity(
          opacity: _overlayDark ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 1500),
          child: Container(color: const Color(0xBB000000)),
        ),
        // コンテンツ
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ① ロゴアイコン
                  _fadeItem(
                    0,
                    Center(
                      child: Container(
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
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ② 宇宙文明レベル到達タイトル
                  _fadeItem(
                    1,
                    Text(s.victoryTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                  color: Colors.black,
                                  blurRadius: 16,
                                  offset: Offset(0, 2))
                            ])),
                  ),
                  const SizedBox(height: 8),

                  // ③ 説明メッセージ
                  _fadeItem(
                    2,
                    Text(s.victoryMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 15, color: Colors.white70, height: 1.6)),
                  ),
                  const SizedBox(height: 32),

                  // ④ 最終資金
                  _fadeItem(
                    3,
                    _resultCard(s.finalCashLabel, s.currency(state.cash),
                        Icons.account_balance_wallet_rounded),
                  ),
                  const SizedBox(height: 12),

                  // ⑤ 保有プロジェクト数
                  _fadeItem(
                    4,
                    _resultCard(
                        s.ownedInvestmentsLabel,
                        s.ownedCount(state.ownedInvestments.length),
                        Icons.business_center_rounded),
                  ),
                  const SizedBox(height: 12),

                  // ⑥ 到達までの開発期
                  _fadeItem(
                    5,
                    _resultCard(s.turnsElapsedLabel,
                        s.turnsValue(state.turn - 1), Icons.calendar_today_rounded),
                  ),
                  const SizedBox(height: 12),

                  // ⑦ 継続収益
                  _fadeItem(
                    6,
                    _resultCard(s.passiveIncomeLabel,
                        s.currency(state.passiveIncome), Icons.trending_up_rounded),
                  ),
                  const SizedBox(height: 40),

                  // ⑧ もう一度プレイ
                  _fadeItem(
                    7,
                    ElevatedButton(
                      onPressed: () {
                        game.resetGame();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.indigo[900],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      child: Text(s.playAgainButton),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // フェードイン + 下から上へのスライド
  Widget _fadeItem(int index, Widget child) {
    return AnimatedOpacity(
      opacity: _visible[index] ? 1.0 : 0.0,
      duration: const Duration(seconds: 1),
      child: AnimatedSlide(
        offset: _visible[index] ? Offset.zero : const Offset(0, 0.08),
        duration: const Duration(seconds: 1),
        curve: Curves.easeOut,
        child: child,
      ),
    );
  }

  Widget _resultCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xBB0d0d1a),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white60, size: 24),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(color: Colors.white60, fontSize: 14)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
        ],
      ),
    );
  }
}
