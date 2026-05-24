class AppStrings {
  final String locale;
  const AppStrings(this.locale);
  bool get isJa => locale == 'ja';

  // 通貨フォーマット
  String currency(int amount) {
    if (isJa) {
      final abs = amount.abs();
      final formatted = abs
          .toString()
          .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
      return amount < 0 ? '-$formatted円' : '$formatted円';
    } else {
      // 円→ドル換算（1USD=158円）、10ドル単位で切り上げ
      final usd = (amount / 158 / 10).ceil() * 10;
      final abs = usd.abs();
      final formatted = abs
          .toString()
          .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
      return amount < 0 ? '-\$$formatted' : '\$$formatted';
    }
  }

  // アプリ全般
  String get appTitle => isJa ? '余裕設計ゲーム' : 'Financial Freedom Game';
  String get cancelButton => isJa ? 'キャンセル' : 'Cancel';
  String get okButton => 'OK';
  String get resetButton => isJa ? 'リセット' : 'Reset';
  String get resetConfirmTitle => isJa ? 'リセット確認' : 'Confirm Reset';
  String get resetConfirmMessage =>
      isJa ? 'ゲームをリセットしますか？\n進行状況は消えます。' : 'Reset the game?\nAll progress will be lost.';

  // ホーム画面
  String turn(int n) => isJa ? '第 $n ターン' : 'Month $n';
  String marketBoom(int n) =>
      isJa ? '好景気中！ 投資収入1.5倍（残り$nターン）' : 'Boom! Passive income ×1.5 ($n turns left)';
  String marketBust(int n) =>
      isJa ? '不景気中… 投資収入0.5倍（残り$nターン）' : 'Recession... Passive income ×0.5 ($n turns left)';
  String get cashLabel => isJa ? '現在の現金' : 'Current Cash';
  String get salaryLabel => isJa ? '給料' : 'Salary';
  String get passiveIncomeLabel => isJa ? '投資収入（パッシブ）' : 'Passive Income';
  String get monthlyTotalLabel => isJa ? '月収合計' : 'Total Income';
  String get livingCostLabel => isJa ? '生活費' : 'Living Cost';
  String get monthlyCashFlowLabel => isJa ? '毎月の余裕' : 'Monthly Cash Flow';
  String get escapeGoalLabel => isJa ? '経済的自由達成まで' : 'Path to Financial Freedom';
  String passiveProgress(String passive) =>
      isJa ? '投資収入 $passive' : 'Passive $passive';
  String goalAmount(String amount) => isJa ? '目標 $amount' : 'Goal $amount';
  String get ownedCountLabel => isJa ? '所有投資数' : 'Investments Owned';
  String ownedCount(int n) => isJa ? '$n 件' : '$n item${n == 1 ? '' : 's'}';
  String get nextMonthButton => isJa ? '次の月へ進む' : 'Next Month';
  String get viewInvestmentsButton => isJa ? '投資を見る' : 'View Investments';
  String get myInvestmentsButton => isJa ? '所有投資' : 'My Investments';
  String get eventHistoryButton => isJa ? 'イベント履歴' : 'Event History';

  // 投資一覧
  String get investmentListTitle => isJa ? '投資一覧' : 'Investments';
  String get purchasePriceLabel => isJa ? '購入額' : 'Price';
  String get monthlyIncomeLabel => isJa ? '毎月収入' : 'Monthly';
  String get stabilityLabel => isJa ? '安定度' : 'Stability';
  String get buyButton => isJa ? '購入する' : 'Buy';
  String get insufficientCash => isJa ? '現金不足' : 'Not Enough Cash';
  String sizeName(String size) {
    if (size == 'small') return isJa ? '小投資' : 'Small';
    if (size == 'medium') return isJa ? '中投資' : 'Medium';
    return isJa ? '大投資' : 'Large';
  }
  String buyDialogTitle(String name) => isJa ? '$nameを購入' : 'Buy $name';
  String buyDialogContent(String price, String income) => isJa
      ? '購入額：$price\n毎月収入：+$income\n\n購入しますか？'
      : 'Price: $price\nMonthly income: +$income\n\nConfirm purchase?';
  String buySuccess(String name) => isJa ? '$nameを購入しました！' : 'Purchased $name!';
  String get insufficientCashSnack => isJa ? '現金が足りません' : 'Not enough cash';

  // 所有投資
  String get myInvestmentsTitle => isJa ? '所有投資' : 'My Investments';
  String get noInvestmentsMessage => isJa
      ? '所有している投資はありません。\n「投資を見る」から購入しましょう。'
      : 'No investments owned.\nGo to "View Investments" to buy some.';
  String troubleCount(int n) => isJa ? 'トラブル$n/3' : 'Trouble $n/3';
  String get incomeSuspendedLabel => isJa ? '今月：収入停止中' : 'This month: income suspended';
  String get incomeHalvedLabel => isJa ? '今月：収入半減中' : 'This month: income halved';
  String get sellPriceLabel => isJa ? '売却額' : 'Sell Price';
  String get sellButton => isJa ? '売却する' : 'Sell';
  String sellDialogTitle(String name) => isJa ? '$nameを売却' : 'Sell $name';
  String sellDialogContent(String price, int pct) => isJa
      ? '売却価格：$price\n（購入額の$pct%）\n\n売却しますか？'
      : 'Sell price: $price\n($pct% of purchase price)\n\nConfirm sale?';
  String sellSuccess(String name, String price) =>
      isJa ? '$nameを$price で売却しました' : 'Sold $name for $price';

  // イベント画面
  String get eventScreenTitle => isJa ? '今月のできごと' : "This Month's Events";
  String get troubleHeading => isJa ? '投資トラブル' : 'Investment Trouble';
  String get noEventTitle => isJa ? '今月は特にイベントなし' : 'No Events This Month';
  String get noEventMessage =>
      isJa ? '平和な月でした。\n引き続き投資を積み上げましょう。' : 'A peaceful month.\nKeep building your investments!';

  // 勝利画面
  String get victoryTitle => isJa ? '経済的自由を達成！' : 'Financial Freedom Achieved!';
  String get victoryMessage =>
      isJa ? '投資収入が生活費を超えました！\nおめでとうございます！' : 'Passive income exceeds living costs!\nCongratulations!';
  String get finalCashLabel => isJa ? '最終現金' : 'Final Cash';
  String get ownedInvestmentsLabel => isJa ? '所有投資数' : 'Investments Owned';
  String get turnsElapsedLabel => isJa ? '経過ターン' : 'Months Elapsed';
  String turnsValue(int n) => isJa ? '$nヶ月' : '$n months';
  String get playAgainButton => isJa ? 'もう一度プレイ' : 'Play Again';

  // イベント履歴
  String get eventHistoryTitle => isJa ? 'イベント履歴' : 'Event History';
  String get noEventsMessage => isJa ? 'まだイベントはありません' : 'No events yet';
  String turnAt(int n) => isJa ? '$nターン目' : 'Month $n';
}
