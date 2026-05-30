import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import '../providers/locale_provider.dart';
import '../utils/space_assets.dart';
import 'home_screen.dart';

class VictoryScreen extends StatelessWidget {
  const VictoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final s = context.watch<LocaleProvider>().strings;
    final state = game.state;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Stanford Torus 背景
        Image.asset(SpaceAssets.bgVictory, fit: BoxFit.cover),
        // 暗いオーバーレイ
        Container(color: const Color(0xBB000000)),
        // コンテンツ
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  // アイコン
                  Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.symmetric(horizontal: 140),
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
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 8),
                  Text(s.victoryMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15, color: Colors.white70, height: 1.6)),
                  const SizedBox(height: 32),
                  _resultCard(s.finalCashLabel, s.currency(state.cash),
                      Icons.account_balance_wallet_rounded),
                  const SizedBox(height: 12),
                  _resultCard(s.ownedInvestmentsLabel,
                      s.ownedCount(state.ownedInvestments.length),
                      Icons.business_center_rounded),
                  const SizedBox(height: 12),
                  _resultCard(s.turnsElapsedLabel, s.turnsValue(state.turn - 1),
                      Icons.calendar_today_rounded),
                  const SizedBox(height: 12),
                  _resultCard(s.passiveIncomeLabel, s.currency(state.passiveIncome),
                      Icons.trending_up_rounded),
                  const SizedBox(height: 40),
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
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ],
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
