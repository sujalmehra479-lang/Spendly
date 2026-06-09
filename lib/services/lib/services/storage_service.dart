import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spendly/models/transaction.dart';

class StorageService {
  static const String _transactionsKey = 'transactions';
  static const String _budgetsKey = 'budgets';

  // Save transaction
  static Future<void> saveTransaction(Transaction t) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getTransactions();
    list.insert(0, t);
    final encoded = list.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList(_transactionsKey, encoded);
  }

  // Get all transactions
  static Future<List<Transaction>> getTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_transactionsKey) ?? [];
    return list
        .map((e) => Transaction.fromMap(jsonDecode(e)))
        .toList();
  }

  // Delete transaction
  static Future<void> deleteTransaction(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getTransactions();
    list.removeWhere((t) => t.id == id);
    final encoded = list.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList(_transactionsKey, encoded);
  }

  // Save budgets
  static Future<void> saveBudgets(Map<String, double> budgets) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_budgetsKey, jsonEncode(budgets));
  }

  // Get budgets
  static Future<Map<String, double>> getBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_budgetsKey);
    if (data == null) return {};
    final map = jsonDecode(data) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, v.toDouble()));
  }

  // Get monthly stats
  static Future<Map<String, double>> getMonthlyStats() async {
    final transactions = await getTransactions();
    final now = DateTime.now();
    double income = 0;
    double spent = 0;

    for (final t in transactions) {
      if (t.date.month == now.month && t.date.year == now.year) {
        if (t.type == TransactionType.credit) {
          income += t.amount;
        } else {
          spent += t.amount;
        }
      }
    }
    return {'income': income, 'spent': spent};
  }
}
