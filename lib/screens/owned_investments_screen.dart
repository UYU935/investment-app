import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/investment.dart';
import '../providers/game_provider.dart';
import '../utils/format.dart';

class OwnedInvestmentsScreen extends StatelessWidget {
  const OwnedInvestmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, _) {
        final investments = provider.state.ownedInvestments;
        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          appBar: AppBar(
            title: const Text('所有投資'),
            backgroundColor: Colors.indigo[700],
            foregroundColor: Colors.white,
          ),
          body: investments.isEmpty
              ? const Center(
                  child: Text(
                    '所有している投資はありません。\n「投資を見る」から購入しましょう。',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black45, fontSize: 15),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: investments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final inv = investments[index];
                    return _OwnedCard(
                      investment: inv,
                      onSell: () => _onSell(context, provider, inv),
                    );
                  },
                ),
        );
      },
    );
  }

  void _onSell(
      BuildContext context, GameProvider provider, Investment inv) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${inv.name}を売却'),
        content: Text(
          '売却価格：${formatYen(inv.sellPrice)}\n（購入額の${inv.size == InvestmentSize.small ? '80' : inv.size == InvestmentSize.medium ? '70' : '60'}%）\n\n売却しますか？',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
            onPressed: () {
              provider.sellInvestment(inv.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('${inv.name}を${formatYen(inv.sellPrice)}で売却しました'),
                  backgroundColor: Colors.orange[700],
                ),
              );
            },
            child:
                const Text('売却する', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _OwnedCard extends StatelessWidget {
  final Investment investment;
  final VoidCallback onSell;

  const _OwnedCard({required this.investment, required this.onSell});

  @override
  Widget build(BuildContext context) {
    final hasWarning =
        investment.incomeSuspended || investment.incomeHalved;
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(investment.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                if (investment.troubleCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'トラブル${investment.troubleCount}/3',
                      style: TextStyle(
                          color: Colors.red[700], fontSize: 11),
                    ),
                  ),
              ],
            ),
            if (hasWarning) ...[
              const SizedBox(height: 4),
              Text(
                investment.incomeSuspended ? '今月：収入停止中' : '今月：収入半減中',
                style: TextStyle(
                    color: Colors.orange[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _item('購入額', formatYen(investment.purchasePrice)),
                _item('毎月収入',
                    '+${formatYen(investment.monthlyIncome)}',
                    color: Colors.green[700]!),
                _item('売却額', formatYen(investment.sellPrice),
                    color: Colors.orange[700]!),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onSell,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red[700],
                  side: BorderSide(color: Colors.red[700]!),
                ),
                child: const Text('売却する'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.black45)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: color ?? Colors.black87)),
      ],
    );
  }
}
