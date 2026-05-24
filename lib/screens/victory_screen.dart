import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import '../providers/locale_provider.dart';
import 'home_screen.dart';

class VictoryScreen extends StatelessWidget {
  const VictoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final s = context.watch<LocaleProvider>().strings;
    final state = game.state;

    return Scaffold(
      backgroundColor: Colors.indigo[700],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.emoji_events_rounded,
                  size: 80, color: Colors.amber),
              const SizedBox(height: 20),
              Text(s.victoryTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 8),
              Text(s.victoryMessage,
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(fontSize: 16, color: Colors.white70)),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _resultCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 24),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
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
