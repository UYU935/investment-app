import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/event.dart';
import '../providers/game_provider.dart';
import '../providers/locale_provider.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  List<bool> _visible = [];
  bool _buttonVisible = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<GameProvider>();
    final troubleCount = provider.pendingTroubles.length;
    final totalItems = troubleCount + 1;
    _visible = List.filled(totalItems, false);

    for (int i = 0; i < totalItems; i++) {
      Future.delayed(Duration(milliseconds: 200 + i * 350), () {
        if (mounted) setState(() => _visible[i] = true);
      });
    }
    Future.delayed(Duration(milliseconds: 200 + totalItems * 350 + 200), () {
      if (mounted) setState(() => _buttonVisible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final s = context.watch<LocaleProvider>().strings;
    final locale = context.watch<LocaleProvider>().locale;
    final event = game.pendingEvent;
    final troubles = game.pendingTroubles;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(s.eventScreenTitle),
        backgroundColor: Colors.indigo[700],
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (troubles.isNotEmpty) ...[
              Text(s.troubleHeading,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.red)),
              const SizedBox(height: 8),
              ...troubles.asMap().entries.map((entry) {
                final i = entry.key;
                final msg = entry.value;
                return AnimatedOpacity(
                  opacity: (i < _visible.length && _visible[i]) ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeIn,
                  child: AnimatedSlide(
                    offset: (i < _visible.length && _visible[i])
                        ? Offset.zero
                        : const Offset(0, 0.15),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    child: _troubleItem(msg.localized(locale)),
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],

            AnimatedOpacity(
              opacity: _visible.isNotEmpty && _visible.last ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeIn,
              child: AnimatedSlide(
                offset: _visible.isNotEmpty && _visible.last
                    ? Offset.zero
                    : const Offset(0, 0.12),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
                child: event != null
                    ? _eventCard(event, locale)
                    : _noEventCard(s),
              ),
            ),

            const Spacer(),

            AnimatedOpacity(
              opacity: _buttonVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 400),
              child: ElevatedButton(
                onPressed: _buttonVisible
                    ? () {
                        game.clearPendingEvent();
                        Navigator.pop(context);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: Text(s.okButton),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _troubleItem(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red[700], size: 18),
          const SizedBox(width: 8),
          Expanded(
              child: Text(message,
                  style: TextStyle(color: Colors.red[800], fontSize: 13))),
        ],
      ),
    );
  }

  Widget _eventCard(GameEvent event, String locale) {
    Color bgColor;
    Color borderColor;
    IconData icon;

    switch (event.type) {
      case EventType.good:
        bgColor = Colors.blue[50]!;
        borderColor = Colors.blue[300]!;
        icon = Icons.star_rounded;
        break;
      case EventType.expense:
        bgColor = Colors.red[50]!;
        borderColor = Colors.red[300]!;
        icon = Icons.money_off_rounded;
        break;
      case EventType.market:
        bgColor = Colors.yellow[50]!;
        borderColor = Colors.yellow[700]!;
        icon = Icons.trending_up_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: borderColor),
          const SizedBox(height: 12),
          Text(event.localizedTitle(locale),
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(height: 12),
          Text(event.localizedDescription(locale),
              style: const TextStyle(fontSize: 15),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _noEventCard(dynamic s) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          const Icon(Icons.calendar_month_rounded, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text(s.noEventTitle,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black54)),
          const SizedBox(height: 8),
          Text(s.noEventMessage,
              style: const TextStyle(fontSize: 14, color: Colors.black45),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
