import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:spendly/models/transaction.dart';
import 'package:spendly/services/storage_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  List<Transaction> _transactions = [];
  int _touchedIndex = -1;

  final Map<Category, Color> _catColors = {
    Category.food: const Color(0xFFFF6B6B),
    Category.travel: const Color(0xFF4ECDC4),
    Category.shopping: const Color(0xFFA78BFA),
    Category.entertainment: const Color(0xFFF59E0B),
    Category.health: const Color(0xFF34D399),
    Category.education: const Color(0xFF60A5FA),
    Category.bills: const Color(0xFFFB923C),
    Category.income: const Color(0xFF4ADE80),
    Category.transfer: const Color(0xFF818CF8),
    Category.other: const Color(0xFF9CA3AF),
  };

  final Map<Category, String> _catIcons = {
    Category.food: '馃崝',
    Category.travel: '馃殫',
    Category.shopping: '馃摝',
    Category.entertainment: '馃幀',
    Category.health: '馃拪',
    Category.education: '馃摎',
    Category.bills: '馃Ь',
    Category.income: '馃捈',
    Category.transfer: '馃捀',
    Category.other: '馃挸',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final t = await StorageService.getTransactions();
    setState(() => _transactions = t);
  }

  Map<Category, double> get _categoryTotals {
    final map = <Category, double>{};
    for (final t in _transactions) {
      if (t.type == TransactionType.debit) {
        map[t.category] = (map[t.category] ?? 0) + t.amount;
      }
    }
    return map;
  }

  // Weekly bar data
  List<double> get _weeklyData {
    final now = DateTime.now();
    final data = List<double>.filled(7, 0);
    for (final t in _transactions) {
      if (t.type == TransactionType.debit) {
        final diff = now.difference(t.date).inDays;
        if (diff < 7) data[6 - diff] += t.amount;
      }
    }
    return data;
  }

  String _insightText() {
    final totals = _categoryTotals;
    if (totals.isEmpty) return 'Add transactions to see insights! 馃挕';
    final top = totals.entries.reduce((a, b) => a.value > b.value ? a : b);
    final formatter = NumberFormat('#,##,###', 'en_IN');
    return 'You spent the most on ${top.key.name} 鈥� 鈧�${formatter.format(top.value)} this month 馃搳';
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##,###', 'en_IN');
    final totals = _categoryTotals;
    final totalSpent = totals.values.fold(0.0, (a, b) => a + b);
    final weekly = _weeklyData;
    final maxWeekly = weekly.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Analytics',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2937))),
              const SizedBox(height: 20),

              // Insight Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Text('馃挕', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _insightText(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Pie Chart
              if (totals.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12)
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text('Spending by Category',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2937))),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 180,
                        child: PieChart(
                          PieChartData(
                            touchData: PieTouchData(
                              touchCallback: (event, response) {
                                setState(() {
                                  _touchedIndex = response
                                          ?.touchedSection
                                          ?.touchedSectionIndex ??
                                      -1;
                                });
                              },
                            ),
                            sections: totals.entries.map((e) {
                              final idx =
                                  totals.keys.toList().indexOf(e.key);
                              final isTouched = idx == _touchedIndex;
                              return PieChartSectionData(
                                value: e.value,
                                color: _catColors[e.key],
                                radius: isTouched ? 65 : 55,
                                title: isTouched
                                    ? '鈧�${formatter.format(e.value)}'
                                    : '',
                                titleStyle: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white),
                              );
                            }).toList(),
                            centerSpaceRadius: 40,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: totals.entries.map((e) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: _catColors[e.key],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_catIcons[e.key]} ${e.key.name}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280)),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // Weekly Bar Chart
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12)
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('This Week',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937))),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 120,
                      child: BarChart(
                        BarChartData(
                          maxY: maxWeekly == 0 ? 100 : maxWeekly * 1.2,
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(
                                sideTitles:
                                    SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(
                                sideTitles:
                                    SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles:
                                    SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (val, meta) {
                                  const days = [
                                    'M', 'T', 'W', 'T', 'F', 'S', 'S'
                                  ];
                                  return Text(
                                    days[val.toInt()],
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF9CA3AF)),
                                  );
                                },
                              ),
                            ),
                          ),
                          barGroups: List.generate(7, (i) {
                            return BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: weekly[i],
                                  color: i == 6
                                      ? const Color(0xFF6366F1)
                                      : const Color(0xFFE5E7EB),
                                  width: 20,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Category breakdown list
              const Text('Category Breakdown',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937))),
              const SizedBox(height: 12),
              ...totals.entries.map((e) {
                final pct = totalSpent > 0 ? e.value / totalSpent : 0.0;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8)
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(_catIcons[e.key] ?? '馃挸',
                              style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              e.key.name[0].toUpperCase() +
                                  e.key.name.substring(1),
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1F2937)),
                            ),
                          ),
                          Text(
                            '鈧�${formatter.format(e.value)}',
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1F2937)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: pct,
                          backgroundColor: const Color(0xFFF3F4F6),
                          valueColor: AlwaysStoppedAnimation<Color>(
                              _catColors[e.key] ??
                                  const Color(0xFF6366F1)),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
