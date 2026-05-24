String formatYen(int amount) {
  final abs = amount.abs();
  final formatted =
      abs.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
  return amount < 0 ? '-$formatted円' : '$formatted円';
}
