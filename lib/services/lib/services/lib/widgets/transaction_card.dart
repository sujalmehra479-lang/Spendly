import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spendly/models/transaction.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onDelete;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.onDelete,
  });

  String get categoryIcon {
    switch (transaction.category) {
      case Category.food: return '🍔';
      case Category.travel: return '🚗';
      case Category.shopping: return '📦';
      case Category.entertainment: return '🎬';
      case Category.health: return '💊';
      case Category.education: return '📚';
      case Category.bills: return '🧾';
      case Category.income: return '💼';
      case Category.transfer: return '💸';
      case Category.other: return '💳';
    }
  }

  Color get categoryColor {
    switch (transaction.category) {
      case Category.food: return const Color(0xFFFF6B6B);
      case Category.travel: return const Color(0xFF4ECDC4);
      case Category.shopping: return const Color(0xFFA78BFA);
      case Category.entertainment: return const Color(0xFFF59E0B);
      case Category.health: return const Color(0xFF34D399);
      case Category.education: return const Color(0xFF60A5FA);
      case Category.bills: return const Color(0xFFFB923C);
      case Category.income: return const Color(0xFF4ADE80);
      case Category.transfer: return const Color(0xFF818CF8);
      case Category.other: return const Color(0xFF9CA3AF);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDebit = transaction.type == TransactionType.debit;
    final formatter = NumberFormat('#,##,###', 'en_IN');
    final dateStr = DateFormat('d MMM, hh:mm a').format(transaction.date);

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded,
            color: Colors.white, size: 24),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(categoryIcon,
                    style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    dateStr,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
            // Amount
            Text(
              '${isDebit ? '-' : '+'}₹${formatter.format(transaction.amount)}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDebit
                    ? const Color(0xFF1F2937)
                    : const Color(0xFF4ADE80),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
