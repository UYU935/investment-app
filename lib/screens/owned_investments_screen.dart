import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/investment.dart';
import '../providers/game_provider.dart';
import '../providers/locale_provider.dart';

class OwnedInvestmentsScreen extends StatelessWidget {
  const OwnedInvestmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final s = localeProvider.strings;
    final locale = localeProvider.locale;
    final investments = game.state.ownedInvestments;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(s.myInvestmentsTitle),
        backgroundColor: Colors.indigo[700],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Text('←', style: TextStyle(color: Colors.white, fontSize: 20)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: investments.isEmpty
          ? Center(
              child: Text(s.noInvestmentsMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black45, fontSize: 15)),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: investments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final inv = investments[index];
                return _OwnedCard(
                  investment: inv,
                  locale: locale,
                  s: s,
                  onSell: () => _onSell(context, game, inv, s, locale),
                );
              },
            ),
    );
  }

  void _onSell(BuildContext context, GameProvider game, Investment inv,
      dynamic s, String locale) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(s.sellDialogTitle(inv.localizedName(locale))),
        content: Text(s.sellDialogContent(
            s.currency(inv.sellPrice), inv.sellPercent)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(s.cancelButton)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
            onPressed: () {
              game.sellInvestment(inv.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(s.sellSuccess(
                    inv.localizedName(locale), s.currency(inv.sellPrice))),
                backgroundColor: Colors.orange[700],
              ));
            },
            child: Text(s.sellButton,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _OwnedCard extends StatelessWidget {
  final Investment investment;
  final String locale;
  final dynamic s;
  final VoidCallback onSell;

  const _OwnedCard({
    required this.investment,
    required this.locale,
    required this.s,
    required this.onSell,
  });

  @override
  Widget build(BuildContext context) {
    final hasWarning = investment.incomeSuspended || investment.incomeHalved;
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
                  child: Text(investment.localizedName(locale),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                if (investment.troubleCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(4)),
                    child: Text(s.troubleCount(investment.troubleCount),
                        style:
                            TextStyle(color: Colors.red[700], fontSize: 11)),
                  ),
              ],
            ),
            if (hasWarning) ...[
              const SizedBox(height: 4),
              Text(
                investment.incomeSuspended
                    ? s.incomeSuspendedLabel
                    : s.incomeHalvedLabel,
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
                _item(s.purchasePriceLabel, s.currency(investment.purchasePrice)),
                _item(s.monthlyIncomeLabel,
                    '+${s.currency(investment.monthlyIncome)}',
                    color: Colors.green[700]!),
                _item(s.sellPriceLabel, s.currency(investment.sellPrice),
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
                    side: BorderSide(color: Colors.red[700]!)),
                child: Text(s.sellButton),
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
