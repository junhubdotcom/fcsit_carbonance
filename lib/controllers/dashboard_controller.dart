import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/period_counters.dart';
import '../services/period_counters_service.dart';

class DashboardController extends ChangeNotifier {
  final PeriodCountersService _periodCountersService = PeriodCountersService();

  // Period counters for real-time dashboard
  PeriodCounters? _todayCounters;
  PeriodCounters? _weekCounters;
  PeriodCounters? _monthCounters;

  bool _isLoading = false;
  String? _error;
  String _currentUserId = 'default_user'; // TODO: Get from auth service

  // Stream subscriptions for real-time updates
  StreamSubscription<PeriodCounters?>? _todaySubscription;
  StreamSubscription<PeriodCounters?>? _weekSubscription;
  StreamSubscription<PeriodCounters?>? _monthSubscription;

  // Getters
  PeriodCounters? get todayCounters => _todayCounters;
  PeriodCounters? get weekCounters => _weekCounters;
  PeriodCounters? get monthCounters => _monthCounters;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentUserId => _currentUserId;

  // Computed properties for dashboard
  double get todayExpense => _todayCounters?.totals.expense ?? 0;
  double get todayIncome => _todayCounters?.totals.income ?? 0;
  double get todayCO2 => _todayCounters?.totals.co2Kg ?? 0;
  double get todayBalance => _todayCounters?.totals.balance ?? 0;

  double get weekExpense => _weekCounters?.totals.expense ?? 0;
  double get weekIncome => _weekCounters?.totals.income ?? 0;
  double get weekCO2 => _weekCounters?.totals.co2Kg ?? 0;
  double get weekBalance => _weekCounters?.totals.balance ?? 0;

  double get monthExpense => _monthCounters?.totals.expense ?? 0;
  double get monthIncome => _monthCounters?.totals.income ?? 0;
  double get monthCO2 => _monthCounters?.totals.co2Kg ?? 0;
  double get monthBalance => _monthCounters?.totals.balance ?? 0;

  // Carbon intensity (kg CO₂ per MYR)
  double get todayIntensity => todayExpense > 0 ? todayCO2 / todayExpense : 0;
  double get weekIntensity => weekExpense > 0 ? weekCO2 / weekExpense : 0;
  double get monthIntensity => monthExpense > 0 ? monthCO2 / monthExpense : 0;

  // Category breakdowns - separate for income, expense, and CO2
  Map<String, double> get todayExpenseCategories =>
      _todayCounters?.breakdowns.expenseByCategory ?? {};
  Map<String, double> get todayIncomeCategories =>
      _todayCounters?.breakdowns.incomeByCategory ?? {};
  Map<String, double> get todayCO2Categories =>
      _todayCounters?.breakdowns.co2ByCategory ?? {};

  Map<String, double> get weekExpenseCategories =>
      _weekCounters?.breakdowns.expenseByCategory ?? {};
  Map<String, double> get weekIncomeCategories =>
      _weekCounters?.breakdowns.incomeByCategory ?? {};
  Map<String, double> get weekCO2Categories =>
      _weekCounters?.breakdowns.co2ByCategory ?? {};

  Map<String, double> get monthExpenseCategories =>
      _monthCounters?.breakdowns.expenseByCategory ?? {};
  Map<String, double> get monthIncomeCategories =>
      _monthCounters?.breakdowns.incomeByCategory ?? {};
  Map<String, double> get monthCO2Categories =>
      _monthCounters?.breakdowns.co2ByCategory ?? {};

  // Top categories
  String get todayTopExpenseCategory =>
      _todayCounters?.breakdowns.topExpenseCategory ?? 'N/A';
  String get todayTopIncomeCategory =>
      _todayCounters?.breakdowns.topIncomeCategory ?? 'N/A';
  String get todayTopCO2Category =>
      _todayCounters?.breakdowns.topCO2Category ?? 'N/A';

  String get weekTopExpenseCategory =>
      _weekCounters?.breakdowns.topExpenseCategory ?? 'N/A';
  String get weekTopIncomeCategory =>
      _weekCounters?.breakdowns.topIncomeCategory ?? 'N/A';
  String get weekTopCO2Category =>
      _weekCounters?.breakdowns.topCO2Category ?? 'N/A';

  String get monthTopExpenseCategory =>
      _monthCounters?.breakdowns.topExpenseCategory ?? 'N/A';
  String get monthTopIncomeCategory =>
      _monthCounters?.breakdowns.topIncomeCategory ?? 'N/A';
  String get monthTopCO2Category =>
      _monthCounters?.breakdowns.topCO2Category ?? 'N/A';

  // Insights
  List<String> get todayInsights => _todayCounters?.insights['spending'] ?? [];
  List<String> get weekInsights => _weekCounters?.insights['spending'] ?? [];
  List<String> get monthInsights => _monthCounters?.insights['spending'] ?? [];

  // Initialize real-time streams
  void initializeStreams({String? userId}) {
    final user = userId ?? _currentUserId;
    _currentUserId = user;
    _cancelSubscriptions();

    print('🔄 Initializing dashboard streams for user: $user');

    // Today
    _todaySubscription =
        _periodCountersService.getDailyCounterStream(userId: user).listen(
      (counters) {
        _todayCounters = counters;
        _error = null;
        print('✅ Today counters updated: ${counters?.totals.expense ?? 0}');
        notifyListeners();
      },
      onError: (error) {
        _error = 'Failed to load today\'s data: $error';
        print('❌ Today counters stream error: $error');
        notifyListeners();
      },
    );

    // This week
    _weekSubscription =
        _periodCountersService.getWeeklyCounterStream(userId: user).listen(
      (counters) {
        _weekCounters = counters;
        print('✅ Week counters updated: ${counters?.totals.expense ?? 0}');
        notifyListeners();
      },
      onError: (error) {
        print('❌ Week counters stream error: $error');
      },
    );

    // This month
    _monthSubscription =
        _periodCountersService.getMonthlyCounterStream(userId: user).listen(
      (counters) {
        _monthCounters = counters;
        print('✅ Month counters updated: ${counters?.totals.expense ?? 0}');
        notifyListeners();
      },
      onError: (error) {
        print('❌ Month counters stream error: $error');
      },
    );

    print('✅ Dashboard streams initialized');
  }

  // Load period counters manually (fallback)
  Future<void> loadDashboardData({String? userId}) async {
    _setLoading(true);
    try {
      final user = userId ?? _currentUserId;
      final currentPeriodIds = _periodCountersService.getCurrentPeriodIds();

      final futures = await Future.wait([
        _periodCountersService.getPeriodCounter(
          userId: user,
          period: 'daily',
          periodId: currentPeriodIds['daily']!,
        ),
        _periodCountersService.getPeriodCounter(
          userId: user,
          period: 'weekly',
          periodId: currentPeriodIds['weekly']!,
        ),
        _periodCountersService.getPeriodCounter(
          userId: user,
          period: 'monthly',
          periodId: currentPeriodIds['monthly']!,
        ),
      ]);

      _todayCounters = futures[0];
      _weekCounters = futures[1];
      _monthCounters = futures[2];
      _error = null;

      print('✅ Dashboard data loaded manually');
    } catch (e) {
      _error = 'Failed to load dashboard data: $e';
      print('❌ Error loading dashboard data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get period-specific data
  PeriodCounters? getPeriodCounters(String period) {
    switch (period) {
      case 'daily':
        return _todayCounters;
      case 'weekly':
        return _weekCounters;
      case 'monthly':
        return _monthCounters;
      default:
        return null;
    }
  }

  // Get period-specific totals
  Map<String, dynamic> getPeriodTotals(String period) {
    final counters = getPeriodCounters(period);
    if (counters == null) {
      return {
        'totalSpent': 0.0,
        'totalIncome': 0.0,
        'totalCarbon': 0.0,
        'balance': 0.0,
        'carbonIntensity': 0.0,
      };
    }

    return {
      'totalSpent': counters.totals.expense,
      'totalIncome': counters.totals.income,
      'totalCarbon': counters.totals.co2Kg,
      'balance': counters.totals.balance,
      'carbonIntensity': counters.totals.carbonIntensity,
    };
  }

  // Get period-specific categories - separate for income, expense, and CO2
  Map<String, double> getPeriodExpenseCategories(String period) {
    final counters = getPeriodCounters(period);
    return counters?.breakdowns.expenseByCategory ?? {};
  }

  Map<String, double> getPeriodIncomeCategories(String period) {
    final counters = getPeriodCounters(period);
    return counters?.breakdowns.incomeByCategory ?? {};
  }

  Map<String, double> getPeriodCO2Categories(String period) {
    final counters = getPeriodCounters(period);
    return counters?.breakdowns.co2ByCategory ?? {};
  }

  // Get period-specific insights
  List<String> getPeriodInsights(String period, String insightType) {
    final counters = getPeriodCounters(period);
    return counters?.insights[insightType] ?? [];
  }

  // Refresh data for a specific period
  Future<void> refreshPeriodData(String period) async {
    try {
      final user = _currentUserId;
      final currentPeriodIds = _periodCountersService.getCurrentPeriodIds();
      final periodId = currentPeriodIds[period]!;

      final counter = await _periodCountersService.getPeriodCounter(
        userId: user,
        period: period,
        periodId: periodId,
      );

      switch (period) {
        case 'daily':
          _todayCounters = counter;
          break;
        case 'weekly':
          _weekCounters = counter;
          break;
        case 'monthly':
          _monthCounters = counter;
          break;
      }

      notifyListeners();
      print('✅ Refreshed $period data');
    } catch (e) {
      print('❌ Error refreshing $period data: $e');
    }
  }

  // Update user ID (when user logs in/out)
  void updateUserId(String newUserId) {
    if (_currentUserId != newUserId) {
      _currentUserId = newUserId;
      initializeStreams(userId: newUserId);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _cancelSubscriptions() {
    _todaySubscription?.cancel();
    _weekSubscription?.cancel();
    _monthSubscription?.cancel();
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }
}
