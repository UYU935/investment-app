import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/investments_data.dart';
import '../models/investment.dart';
import '../providers/game_provider.dart';
import '../providers/locale_provider.dart';

class InvestmentListScreen extends StatelessWidget {
  const InvestmentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final s = context.watch<LocaleProvider>().strings;
    final locale = context.watch<LocaleProvider>().locale;
    final cash = game.state.cash;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(s.investmentListTitle),
        backgroundColor: Colors.indigo[700],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Text('←', style: TextStyle(color: Colors.white, fontSize: 20)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.indigo[50],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(s.cashLabel, style: const TextStyle(color: Colors.black54)),
                Text(s.currency(cash),
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
                return _InvestmentCard(
                  investment: inv,
                  locale: locale,
                  canBuy: cash >= inv.purchasePrice,
                  s: s,
                  onBuy: () => _onBuy(context, game, inv, s, locale),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onBuy(BuildContext context, GameProvider game, Investment inv,
      dynamic s, String locale) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(s.buyDialogTitle(inv.localizedName(locale))),
        content: Text(s.buyDialogContent(
            s.currency(inv.purchasePrice), s.currency(inv.monthlyIncome))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(s.cancelButton)),
          ElevatedButton(
            onPressed: () {
              final ok = game.buyInvestment(inv);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(ok
                    ? s.buySuccess(inv.localizedName(locale))
                    : s.insufficientCashSnack),
                backgroundColor: ok ? Colors.green[700] : Colors.red[700],
              ));
            },
            child: Text(s.buyButton),
          ),
        ],
      ),
    );
  }
}

class _InvestmentCard extends StatelessWidget {
  final Investment investment;
  final String locale;
  final bool canBuy;
  final dynamic s;
  final VoidCallback onBuy;

  const _InvestmentCard({
    required this.investment,
    required this.locale,
    required this.canBuy,
    required this.s,
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
                      borderRadius: BorderRadius.circular(4)),
                  child: Text(s.sizeName(investment.sizeKey),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(investment.localizedName(locale),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _stat(s.purchasePriceLabel, s.currency(investment.purchasePrice),
                    Colors.black87),
                _stat(s.monthlyIncomeLabel,
                    '+${s.currency(investment.monthlyIncome)}',
                    Colors.green[700]!),
                _stat(s.stabilityLabel, _stabilityText(investment.stability),
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
                child: Text(canBuy ? s.buyButton : s.insufficientCash),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.black45)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: color)),
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
