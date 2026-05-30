class SpaceAssets {
  static String bgForLevel(int level) {
    switch (level) {
      case 2:
        return 'assets/images/bg_level2.jpeg';
      case 3:
        return 'assets/images/bg_level3.jpeg';
      case 4:
        return 'assets/images/bg_level4.jpeg';
      default:
        return 'assets/images/bg_level1.jpeg';
    }
  }

  static const String bgVictory = 'assets/images/bg_victory.jpeg';
}
