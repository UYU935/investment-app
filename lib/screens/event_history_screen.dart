import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/event.dart';
import '../providers/game_provider.dart';

class EventHistoryScreen extends StatelessWidget {
  const EventHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, _) {
        final history = provider.state.eventHistory.reversed.toList();
        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          appBar: AppBar(
            title: const Text('イベント履歴'),
            backgroundColor: Colors.indigo[700],
            foregroundColor: Colors.white,
          ),
          body: history.isEmpty
              ? const Center(
                  child: Text('まだイベントはありません',
                      style: TextStyle(color: Colors.black45)))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: history.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final record = history[index];
                    return _HistoryTile(record: record);
                  },
                ),
        );
      },
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final dynamic record;
  const _HistoryTile({required this.record});

  Color get _color {
    switch (record.type as EventType) {
      case EventType.good:
        return Colors.blue[700]!;
      case EventType.expense:
        return Colors.red[700]!;
      case EventType.market:
        return Colors.orange[700]!;
    }
  }

  IconData get _icon {
    switch (record.type as EventType) {
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
        title: Text(record.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(record.description,
            style: const TextStyle(fontSize: 12)),
        trailing: Text('${record.turn}ターン目',
            style: const TextStyle(color: Colors.black45, fontSize: 11)),
      ),
    );
  }
}
