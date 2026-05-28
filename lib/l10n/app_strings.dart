class AppStrings {
  final String locale;
  const AppStrings(this.locale);
  bool get isJa => locale == 'ja';

  // 通貨フォーマット（億円単位）
  String currency(int amount) {
    if (isJa) {
      final abs = amount.abs();
      final formatted = abs
          .toString()
          .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
      return amount < 0 ? '-${formatted}億円' : '${formatted}億円';
    } else {
      // 億円→十億ドル換算（1B USD ≒ 150億円）
      final abs = amount.abs();
      final formatted = abs
          .toString()
          .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
      return amount < 0 ? '-\$${formatted}B' : '\$${formatted}B';
    }
  }

  // アプリ全般
  String get appTitle => isJa ? 'STAR FRONTIER 投資計画' : 'STAR FRONTIER';
  String get cancelButton => isJa ? 'キャンセル' : 'Cancel';
  String get okButton => 'OK';
  String get resetButton => isJa ? 'リセット' : 'Reset';
  String get resetConfirmTitle => isJa ? 'リセット確認' : 'Confirm Reset';
  String get resetConfirmMessage =>
      isJa ? 'ゲームをリセットしますか？\n進行状況は消えます。' : 'Reset the game?\nAll progress will be lost.';

  // ホーム画面
  String turn(int n) => isJa ? '第 $n 開発期' : 'Period $n';
  String marketBoom(int n) =>
      isJa ? '宇宙産業ブーム中！ 継続収益1.5倍（残り$n開発期）' : 'Space Boom! Income ×1.5 ($n periods left)';
  String marketBust(int n) =>
      isJa ? '開発停滞中… 継続収益0.5倍（残り$n開発期）' : 'Slowdown... Income ×0.5 ($n periods left)';
  String get cashLabel => isJa ? '現在資金' : 'Current Funds';
  String get salaryLabel => isJa ? '基礎予算' : 'Base Budget';
  String get passiveIncomeLabel => isJa ? '継続収益' : 'Recurring Income';
  String get monthlyTotalLabel => isJa ? '収益合計' : 'Total Income';
  String get livingCostLabel => isJa ? '運営コスト' : 'Operating Cost';
  String get monthlyCashFlowLabel => isJa ? '毎期の開発余力' : 'Development Margin';
  String get escapeGoalLabel => isJa ? '宇宙文明レベル到達まで' : 'Path to Space Civilization';
  String passiveProgress(String passive) =>
      isJa ? '継続収益 $passive' : 'Recurring $passive';
  String goalAmount(String amount) => isJa ? '目標 $amount' : 'Goal $amount';

  // 宇宙開発レベル
  String get spaceLevelLabel => isJa ? '宇宙開発レベル' : 'Space Dev Level';
  String spaceLevelText(int level) {
    switch (level) {
      case 2:
        return isJa ? 'レベル2（衛星通信ネットワークを開発）' : 'Level 2 (Satellite Network built)';
      case 3:
        return isJa ? 'レベル3（月面基地アルテミス街区を開発）' : 'Level 3 (Lunar Base built)';
      case 4:
        return isJa ? 'レベル4（火星開発フロンティアを開発）' : 'Level 4 (Mars Frontier built)';
      default:
        return isJa ? 'レベル1' : 'Level 1';
    }
  }
  String colonyProgress(int count) =>
      isJa ? 'スペースコロニー建設: $count / 5基' : 'Space Colonies: $count / 5';
  String get ownedCountLabel => isJa ? '保有プロジェクト' : 'Projects Owned';
  String ownedCount(int n) => isJa ? '$n 件' : '$n project${n == 1 ? '' : 's'}';
  String get nextMonthButton => isJa ? '次の開発期へ' : 'Next Period';
  String get viewInvestmentsButton => isJa ? '開発プロジェクトを見る' : 'View Projects';
  String get myInvestmentsButton => isJa ? '保有プロジェクト' : 'My Projects';
  String get eventHistoryButton => isJa ? 'イベント履歴' : 'Event History';

  // 投資一覧
  String get investmentListTitle => isJa ? '開発プロジェクト一覧' : 'Development Projects';
  String get purchasePriceLabel => isJa ? '開発コスト' : 'Dev Cost';
  String get monthlyIncomeLabel => isJa ? '継続収益' : 'Recurring';
  String get stabilityLabel => isJa ? '安定度' : 'Stability';
  String get buyButton => isJa ? '着手する' : 'Start';
  String get insufficientCash => isJa ? '資金不足' : 'Insufficient Funds';
  String sizeName(String size) {
    if (size == 'small') return isJa ? '小型' : 'Small';
    if (size == 'medium') return isJa ? '中型' : 'Medium';
    return isJa ? '大型' : 'Large';
  }
  String buyDialogTitle(String name) => isJa ? '$nameに着手' : 'Start $name';
  String buyDialogContent(String price, String income) => isJa
      ? '開発コスト：$price\n継続収益：+$income / 開発期\n\n着手しますか？'
      : 'Dev Cost: $price\nRecurring income: +$income / period\n\nConfirm?';
  String buySuccess(String name) => isJa ? '$nameに着手しました！' : 'Started $name!';
  String get insufficientCashSnack => isJa ? '資金が足りません' : 'Not enough funds';

  // 所有投資
  String get myInvestmentsTitle => isJa ? '保有プロジェクト' : 'My Projects';
  String get noInvestmentsMessage => isJa
      ? '保有しているプロジェクトはありません。\n「開発プロジェクトを見る」から着手しましょう。'
      : 'No projects owned.\nGo to "View Projects" to start one.';
  String troubleCount(int n) => isJa ? 'トラブル$n/3' : 'Trouble $n/3';
  String get incomeSuspendedLabel => isJa ? '今期：収益停止中' : 'This period: income suspended';
  String get incomeHalvedLabel => isJa ? '今期：収益半減中' : 'This period: income halved';
  String get sellPriceLabel => isJa ? '撤退回収額' : 'Exit Value';
  String get sellButton => isJa ? '撤退・売却' : 'Exit';
  String sellDialogTitle(String name) => isJa ? '$nameから撤退' : 'Exit $name';
  String sellDialogContent(String price, int pct) => isJa
      ? 'このプロジェクトを縮小・売却しますか？\n回収額：$price（開発コストの$pct%）\n大型開発ほど途中撤退の損失が大きくなります。'
      : 'Sell/exit this project?\nExit value: $price ($pct% of dev cost)\nLarger projects lose more on early exit.';
  String sellSuccess(String name, String price) =>
      isJa ? '$nameから撤退し、$price を回収しました' : 'Exited $name, recovered $price';

  // イベント画面
  String get eventScreenTitle => isJa ? '今期のできごと' : "This Period's Events";
  String get troubleHeading => isJa ? 'プロジェクトトラブル' : 'Project Trouble';
  String get noEventTitle => isJa ? '今期は特にイベントなし' : 'No Events This Period';
  String get noEventMessage =>
      isJa ? '順調な開発期でした。\n引き続きプロジェクトを積み上げましょう。' : 'A smooth period.\nKeep building your projects!';

  // 勝利画面
  String get victoryTitle => isJa ? '宇宙文明レベル到達！' : 'Space Civilization Achieved!';
  String get victoryMessage =>
      isJa ? 'スペースコロニーを5基建設し、宇宙移住文明が誕生しました。\nあなたのチームは、地球の外へ広がる未来文明の第一歩を築きました。'
           : 'Five Space Colonies built — a space-faring civilization is born.\nYour team has laid the foundation for humanity beyond Earth.';
  String get finalCashLabel => isJa ? '最終資金' : 'Final Funds';
  String get ownedInvestmentsLabel => isJa ? '保有プロジェクト数' : 'Projects Owned';
  String get turnsElapsedLabel => isJa ? '到達までの開発期' : 'Periods Elapsed';
  String turnsValue(int n) => isJa ? '$n期' : '$n periods';
  String get playAgainButton => isJa ? 'もう一度プレイ' : 'Play Again';

  // イベント履歴
  String get eventHistoryTitle => isJa ? 'イベント履歴' : 'Event History';
  String get noEventsMessage => isJa ? 'まだイベントはありません' : 'No events yet';
  String turnAt(int n) => isJa ? '第$n開発期' : 'Period $n';
}
