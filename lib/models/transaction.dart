enum TransactionType { debit, credit }

enum Category {
  food,
  travel,
  shopping,
  entertainment,
  health,
  education,
  bills,
  income,
  transfer,
  other,
}

class Transaction {
  final String id;
  final String name;
  final double amount;
  final TransactionType type;
  final Category category;
  final DateTime date;
  final String? note;
  final String? upiId;

  Transaction({
    required this.id,
    required this.name,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note,
    this.upiId,
  });

  // Auto detect category from name
  static Category detectCategory(String name) {
    final n = name.toLowerCase();
    if (n.contains('swiggy') || n.contains('zomato') ||
        n.contains('food') || n.contains('restaurant'))
      return Category.food;
    if (n.contains('ola') || n.contains('uber') ||
        n.contains('rapido') || n.contains('metro'))
      return Category.travel;
    if (n.contains('amazon') || n.contains('flipkart') ||
        n.contains('myntra') || n.contains('meesho'))
      return Category.shopping;
    if (n.contains('netflix') || n.contains('hotstar') ||
        n.contains('spotify') || n.contains('youtube'))
      return Category.entertainment;
    if (n.contains('salary') || n.contains('credit'))
      return Category.income;
    if (n.contains('electricity') || n.contains('water') ||
        n.contains('bill') || n.contains('recharge'))
      return Category.bills;
    if (n.contains('hospital') || n.contains('pharmacy') ||
        n.contains('medical') || n.contains('doctor'))
      return Category.health;
    return Category.other;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'type': type.index,
      'category': category.index,
      'date': date.millisecondsSinceEpoch,
      'note': note,
      'upiId': upiId,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      name: map['name'],
      amount: map['amount'],
      type: TransactionType.values[map['type']],
      category: Category.values[map['category']],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      note: map['note'],
      upiId: map['upiId'],
    );
  }
}
