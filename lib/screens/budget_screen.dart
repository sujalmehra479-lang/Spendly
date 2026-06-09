import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spendly/models/transaction.dart';
import 'package:spendly/services/storage_service.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  Map<String, double> _budgets = {};
  Map<Category, double> _spent = {};

  final Map<Category, Color> _catColors = {
    Category.food: const Color(0xFFFF6B6B),
    Category.travel: const Color(0xFF4ECDC4),
    Category.shopping: const Color(0xFFA78BFA),
    Category.entertainment: const Color(0xFFF59E0B),
    Category.health: const Color(0xFF34D399),
    Category.bills: const Color(0xFFFB923C),
    Category.education: const Color(0xFF60A5FA),
    Category.other: const Color(0xFF9CA3AF),
  };

  final Map<Category, String> _catIcons = {
    Category.food: '馃崝',
    Category.travel: '馃殫',
    Category.shopping: '馃摝',
    Category.entertainment: '馃幀',
    Category.health: '馃拪',
    Category.bills: '馃Ь',
    Category.education: '馃摎',
    Category.other: '馃挸',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final budgets = await StorageService.getBudgets();
    final transactions = await StorageService.getTransactions();
    final spent = <Category, double>{};
    final now = DateTime.now();
    for (final t in transactions) {
      if (t.type == TransactionType.debit &&
          t.date.month == now.month &&
          t.date.year == now.year) {
        spent[t.category] = (spent[t.category] ?? 0) + t.amount;
      }
    }
    setState(() {
      _budgets = budgets;
      _spent = spent;
    });
  }

  void _editBudget(Category cat) {
    final controller = TextEditingController(
        text: (_budgets[cat.name] ?? 0).toStringAsFixed(0));
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set budget for ${cat.name[0].toUpperCase()}${cat.name.substring(1)}',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                prefixText: '鈧� ',
                hintText: 'Enter monthly budget',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF6366F1)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final val = double.tryParse(controller.text) ?? 0;
                  _budgets[cat.name] = val;
                  await StorageService.saveBudgets(_budgets);
                  Navigator.pop(context);
                  _load();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Save Budget',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##,###', 'en_IN');

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Budget',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2937))),
              const SizedBox(height: 6),
              const Text('Set monthly limits per category',
                  style: TextStyle(
                      fontSize: 13, color: Color(0xFF9CA3AF))),
              const SizedBox(height: 20),
              ..._catColors.keys.map((cat) {
                final budget = _budgets[cat.name] ?? 0;
                final spent = _spent[cat] ?? 0;
                final pct = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
                final over = spent > budget && budget > 0;
                final color = _catColors[cat]!;

                return GestureDetector(
                  onTap: () => _editBudget(cat),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: over
                            ? color.withOpacity(0.4)
                            : Colors.transparent,
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10)
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(_catIcons[cat] ?? '馃挸',
                                    style: const TextStyle(fontSize: 18)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cat.name[0].toUpperCase() +
                                        cat.name.substring(1),
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1F2937)),
                                  ),
                                  Text(
                                    '鈧�${formatter.format(spent)} spent',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF9CA3AF)),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  budget > 0
                                      ? '鈧�${formatter.format(budget)}'
                                      : 'Set limit',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: over
                                        ? color
                                        : const Color(0xFF1F2937),
                                  ),
                                ),
                                if (over)
                                  Text('Over limit!',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: color,
                                          fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ],
                        ),
                        if (budget > 0) ...[
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: pct,
                              backgroundColor: const Color(0xFFF3F4F6),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(color),
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              budget > spent
                                  ? '鈧�${formatter.format(budget - spent)} remaining'
                                  : '鈧�${formatter.format(spent - budget)} over budget',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: over
                                      ? color
                                      : const Color(0xFF9CA3AF)),
                            ),
                          ),
                        ],
                      ],
                    ),
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
