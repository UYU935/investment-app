import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/event.dart';
import '../providers/game_provider.dart';
import '../providers/locale_provider.dart';

class EventHistoryScreen extends StatelessWidget {
  const EventHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final s = localeProvider.strings;
    final locale = localeProvider.locale;
    final history = game.state.eventHistory.reversed.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(s.eventHistoryTitle),
        backgroundColor: Colors.indigo[700],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Text('←', style: TextStyle(color: Colors.white, fontSize: 20)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: history.isEmpty
          ? Center(
              child: Text(s.noEventsMessage,
                  style: const TextStyle(color: Colors.black45)))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final record = history[index];
                return _HistoryTile(record: record, locale: locale, s: s);
              },
            ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final EventRecord record;
  final String locale;
  final dynamic s;

  const _HistoryTile(
      {required this.record, required this.locale, required this.s});

  Color get _color {
    switch (record.type) {
      case EventType.good:
        return Colors.blue[700]!;
      case EventType.expense:
        return Colors.red[700]!;
      case EventType.market:
        return Colors.orange[700]!;
    }
  }

  IconData get _icon {
    switch (record.type) {
      case EventType.good:
        return Icons.star_rounded;
      case EventType.expense:
        return Icons.money_off_rounded;
      case EventType.market:
        return Icons.trending_up_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _color.withValues(alpha: 0.15),
          child: Icon(_icon, color: _color, size: 20),
        ),
        title: Text(record.localizedTitle(locale),
            style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(record.localizedDescription(locale),
            style: const TextStyle(fontSize: 12)),
        trailing: Text(s.turnAt(record.turn),
            style: const TextStyle(color: Colors.black45, fontSize: 11)),
      ),
    );
  }
}
