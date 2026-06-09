import 'package:spendly/models/transaction.dart';

class SmsService {
  // Parse UPI SMS and extract transaction
  static Transaction? parseUpiSms(String smsBody, String sender) {
    try {
      final body = smsBody.toLowerCase();

      // Check if it's a UPI transaction
      if (!body.contains('upi') && !body.contains('debited') &&
          !body.contains('credited')) return null;

      // Extract amount
      final amountRegex = RegExp(r'rs\.?\s*(\d+(?:\.\d{1,2})?)');
      final amountMatch = amountRegex.firstMatch(body);
      if (amountMatch == null) return null;
      final amount = double.parse(amountMatch.group(1)!);

      // Debit or Credit
      final isDebit = body.contains('debited') ||
          body.contains('deducted') ||
          body.contains('paid');

      // Extract merchant name
      String name = _extractMerchant(smsBody);

      // Extract UPI ID
      String? upiId;
      final upiRegex = RegExp(r'[\w.-]+@[\w]+');
      final upiMatch = upiRegex.firstMatch(smsBody);
      if (upiMatch != null) upiId = upiMatch.group(0);

      return Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        amount: amount,
        type: isDebit
            ? TransactionType.debit
            : TransactionType.credit,
        category: Transaction.detectCategory(name),
        date: DateTime.now(),
        upiId: upiId,
      );
    } catch (e) {
      return null;
    }
  }

  static String _extractMerchant(String sms) {
    // Try to find merchant after "to" or "from"
    final toRegex = RegExp(
        r'(?:to|from|at)\s+([A-Z][a-zA-Z\s]+?)(?:\s+on|\s+via|\s+ref|\.)',
        caseSensitive: false);
    final match = toRegex.firstMatch(sms);
    if (match != null) return match.group(1)!.trim();

    // Fallback to sender
    return sms.contains('credited') ? 'Income' : 'Payment';
  }
}
