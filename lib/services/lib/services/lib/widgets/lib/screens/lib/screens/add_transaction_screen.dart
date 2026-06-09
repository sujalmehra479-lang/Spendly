import 'package:flutter/material.dart';
import 'package:spendly/models/transaction.dart';
import 'package:spendly/services/storage_service.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();
  TransactionType _type = TransactionType.debit;
  Category _category = Category.food;

  final List<Map<String, dynamic>> _categories = [
    {'cat': Category.food, 'icon': '馃崝', 'label': 'Food'},
    {'cat': Category.travel, 'icon': '馃殫', 'label': 'Travel'},
    {'cat': Category.shopping, 'icon': '馃摝', 'label': 'Shopping'},
    {'cat': Category.entertainment, 'icon': '馃幀', 'label': 'Fun'},
    {'cat': Category.health, 'icon': '馃拪', 'label': 'Health'},
    {'cat': Category.bills, 'icon': '馃Ь', 'label': 'Bills'},
    {'cat': Category.education, 'icon': '馃摎', 'label': 'Education'},
    {'cat': Category.income, 'icon': '馃捈', 'label': 'Income'},
    {'cat': Category.other, 'icon': '馃挸', 'label': 'Other'},
  ];

  Future<void> _save() async {
    if (_amountController.text.isEmpty || _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill amount and name')),
      );
      return;
    }
    final t = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      amount: double.parse(_amountController.text),
      type: _type,
      category: _category,
      date: DateTime.now(),
      note: _noteController.text.trim(),
    );
    await StorageService.saveTransaction(t);
    _amountController.clear();
    _nameController.clear();
    _noteController.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction saved! 鉁�'),
          backgroundColor: Color(0xFF4ADE80),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Transaction',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2937))),
              const SizedBox(height: 28),

              // Amount
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('鈧�',
                            style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF6366F1))),
                        const SizedBox(width: 4),
                        SizedBox(
                          width: 180,
                          child: TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1F2937)),
                            decoration: const InputDecoration(
                              hintText: '0',
                              hintStyle: TextStyle(color: Color(0xFFD1D5DB)),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Color(0xFFEEF2FF)),
                    const SizedBox(height: 12),

                    // Type Toggle
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          _TypeButton(
                            label: 'Expense',
                            selected: _type == TransactionType.debit,
                            onTap: () => setState(
                                () => _type = TransactionType.debit),
                          ),
                          _TypeButton(
                            label: 'Income',
                            selected: _type == TransactionType.credit,
                            onTap: () => setState(
                                () => _type = TransactionType.credit),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Name & Note
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10)
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'Transaction name (e.g. Swiggy)',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                      ),
                    ),
                    const Divider(color: Color(0xFFF3F4F6)),
                    TextField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        hintText: 'Add a note... (optional)',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Categories
              const Text('Category',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280))),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((c) {
                  final selected = _category == c['cat'];
                  return GestureDetector(
                    onTap: () => setState(() => _category = c['cat']),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF6366F1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 6)
                        ],
                      ),
                      child: Text(
                        '${c['icon']} ${c['label']}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? Colors.white
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    shadowColor:
                        const Color(0xFF6366F1).withOpacity(0.4),
                  ),
                  child: const Text('Save Transaction',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TypeButton(
      {required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF6366F1) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: selected
                    ? Colors.white
                    : const Color(0xFF9CA3AF),
              )),
        ),
      ),
    );
  }
}
