class Benefit {
  const Benefit({required this.name, required this.amount});

  final String name;
  final double amount;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'amount': amount,
  };

  static Benefit? fromJson(dynamic raw) {
    if (raw is! Map) return null;
    final name = raw['name'];
    final amount = raw['amount'];
    if (name is! String) return null;
    if (amount is! num) return null;
    return Benefit(name: name, amount: amount.toDouble());
  }
}
