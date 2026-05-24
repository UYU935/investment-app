import '../models/investment.dart';

final List<Investment> allInvestments = [
  // 小投資
  Investment(
    id: 'small_01',
    name: '駐輪場オーナー',
    purchasePrice: 50000,
    monthlyIncome: 3000,
    size: InvestmentSize.small,
    stability: 3,
  ),
  Investment(
    id: 'small_02',
    name: '自動販売機',
    purchasePrice: 80000,
    monthlyIncome: 5000,
    size: InvestmentSize.small,
    stability: 3,
  ),
  Investment(
    id: 'small_03',
    name: 'フリマ転売',
    purchasePrice: 30000,
    monthlyIncome: 4000,
    size: InvestmentSize.small,
    stability: 2,
  ),
  Investment(
    id: 'small_04',
    name: 'ブログ広告',
    purchasePrice: 20000,
    monthlyIncome: 2000,
    size: InvestmentSize.small,
    stability: 3,
  ),
  Investment(
    id: 'small_05',
    name: '貸し倉庫（小）',
    purchasePrice: 100000,
    monthlyIncome: 7000,
    size: InvestmentSize.small,
    stability: 3,
  ),

  // 中投資
  Investment(
    id: 'mid_01',
    name: 'アパート一室',
    purchasePrice: 300000,
    monthlyIncome: 20000,
    size: InvestmentSize.medium,
    stability: 2,
  ),
  Investment(
    id: 'mid_02',
    name: 'コインランドリー',
    purchasePrice: 250000,
    monthlyIncome: 18000,
    size: InvestmentSize.medium,
    stability: 2,
  ),
  Investment(
    id: 'mid_03',
    name: '太陽光発電',
    purchasePrice: 400000,
    monthlyIncome: 25000,
    size: InvestmentSize.medium,
    stability: 3,
  ),
  Investment(
    id: 'mid_04',
    name: 'EC販売事業',
    purchasePrice: 200000,
    monthlyIncome: 15000,
    size: InvestmentSize.medium,
    stability: 1,
  ),
  Investment(
    id: 'mid_05',
    name: 'カフェ投資',
    purchasePrice: 350000,
    monthlyIncome: 22000,
    size: InvestmentSize.medium,
    stability: 2,
  ),

  // 大投資
  Investment(
    id: 'large_01',
    name: 'ビル一棟',
    purchasePrice: 1000000,
    monthlyIncome: 80000,
    size: InvestmentSize.large,
    stability: 1,
  ),
  Investment(
    id: 'large_02',
    name: 'フランチャイズ店舗',
    purchasePrice: 800000,
    monthlyIncome: 60000,
    size: InvestmentSize.large,
    stability: 1,
  ),
  Investment(
    id: 'large_03',
    name: '工場設備投資',
    purchasePrice: 1200000,
    monthlyIncome: 90000,
    size: InvestmentSize.large,
    stability: 1,
  ),
];
