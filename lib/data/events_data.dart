import '../models/event.dart';

const List<GameEvent> goodEvents = [
  GameEvent(
    title: '臨時ボーナス！',
    description: '会社から臨時ボーナスが出た。現金+3万円。',
    type: EventType.good,
    cashEffect: 30000,
  ),
  GameEvent(
    title: '節約成功！',
    description: '今月は節約を頑張った。現金+1万円。',
    type: EventType.good,
    cashEffect: 10000,
  ),
  GameEvent(
    title: '副業依頼',
    description: '知人から仕事の依頼が来た。現金+2万円。',
    type: EventType.good,
    cashEffect: 20000,
  ),
  GameEvent(
    title: '支援者出現',
    description: 'メンターが投資ノウハウを教えてくれた。現金+5000円。',
    type: EventType.good,
    cashEffect: 5000,
  ),
  GameEvent(
    title: 'フリマ大成功',
    description: '不用品をフリマで売った。現金+8000円。',
    type: EventType.good,
    cashEffect: 8000,
  ),
];

const List<GameEvent> expenseEvents = [
  GameEvent(
    title: '家電が壊れた',
    description: '冷蔵庫が壊れて修理が必要。現金-2万円。',
    type: EventType.expense,
    cashEffect: -20000,
  ),
  GameEvent(
    title: '医療費',
    description: '体調を崩して病院へ。現金-1万5千円。',
    type: EventType.expense,
    cashEffect: -15000,
  ),
  GameEvent(
    title: '趣味に使いすぎ',
    description: '欲しいものを買いすぎた。現金-1万円。',
    type: EventType.expense,
    cashEffect: -10000,
  ),
  GameEvent(
    title: '車の修理',
    description: 'タイヤがパンクした。現金-3万円。',
    type: EventType.expense,
    cashEffect: -30000,
  ),
  GameEvent(
    title: '食費増加',
    description: '物価が上がって食費がかさんだ。現金-8000円。',
    type: EventType.expense,
    cashEffect: -8000,
  ),
];

const List<GameEvent> marketEvents = [
  GameEvent(
    title: '好景気到来！',
    description: '景気が良くなり、投資収入が2ターン間1.5倍になる。',
    type: EventType.market,
    isMarketBoom: true,
  ),
  GameEvent(
    title: '不景気に突入',
    description: '景気が悪化。投資収入が2ターン間半分になる。',
    type: EventType.market,
    isMarketBust: true,
  ),
  GameEvent(
    title: '消費ブーム',
    description: 'みんなが買い物をする季節。投資収入が1ターン間1.5倍。',
    type: EventType.market,
    isMarketBoom: true,
  ),
  GameEvent(
    title: '規制強化',
    description: '政府の規制で一部事業に影響。現金-1万円。',
    type: EventType.market,
    cashEffect: -10000,
  ),
  GameEvent(
    title: '金利上昇',
    description: '借入コストが上がる。今月の投資収入が減少。',
    type: EventType.market,
    isMarketBust: true,
  ),
];
