import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/investments_data.dart';
import '../models/investment.dart';
import '../providers/game_provider.dart';
import '../utils/format.dart';

class InvestmentListScreen extends StatelessWidget {
  const InvestmentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, _) {
        final cash = provider.state.cash;
        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          appBar: AppBar(
            title: const Text('投資一覧'),
            backgroundColor: Colors.indigo[700],
            foregroundColor: Colors.white,
          ),
          body: Column(
            children: [
              Container(
                color: Colors.indigo[50],
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('現在の現金',
                        style: TextStyle(color: Colors.black54)),
                    Text(formatYen(cash),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: allInvestments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final inv = allInvestments[index];
                    final canBuy = cash >= inv.purchasePrice;
                    return _InvestmentCard(
                      investment: inv,
                      canBuy: canBuy,
                      onBuy: () => _onBuy(context, provider, inv),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onBuy(
      BuildContext context, GameProvider provider, Investment inv) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${inv.name}を購入'),
        content: Text(
          '購入額：${formatYen(inv.purchasePrice)}\n毎月収入：+${formatYen(inv.monthlyIncome)}\n\n購入しますか？',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル')),
          ElevatedButton(
            onPressed: () {
              final ok = provider.buyInvestment(inv);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      ok ? '${inv.name}を購入しました！' : '現金が足りません'),
                  backgroundColor: ok ? Colors.green[700] : Colors.red[700],
                ),
              );
            },
            child: const Text('購入'),
          ),
        ],
      ),
    );
  }
}

class _InvestmentCard extends StatelessWidget {
  final Investment investment;
  final bool canBuy;
  final VoidCallback onBuy;

  const _InvestmentCard({
    required this.investment,
    required this.canBuy,
    required this.onBuy,
  });

  Color get _sizeColor {
    switch (investment.size) {
      case InvestmentSize.small:
        return Colors.teal;
      case InvestmentSize.medium:
        return Colors.orange;
      case InvestmentSize.large:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _sizeColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${investment.sizeName}投資',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(investment.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statItem('購入額', formatYen(investment.purchasePrice),
                    Colors.black87),
                _statItem('毎月収入',
                    '+${formatYen(investment.monthlyIncome)}', Colors.green[700]!),
                _statItem('安定度', _stabilityText(investment.stability),
                    Colors.blue[700]!),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canBuy ? onBuy : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo[700],
                  disabledBackgroundColor: Colors.grey[300],
                  foregroundColor: Colors.white,
                ),
                child: Text(canBuy ? '購入する' : '現金不足'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.black45)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor)),
      ],
    );
  }

  String _stabilityText(int stability) {
    switch (stability) {
      case 3:
        return '★★★';
      case 2:
        return '★★☆';
      default:
        return '★☆☆';
    }
  }
}
