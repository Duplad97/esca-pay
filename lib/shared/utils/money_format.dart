String money(double value) {
  final intValue = value.round();
  final sign = intValue < 0 ? '-' : '';
  final digits = intValue.abs().toString();

  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final indexFromEnd = digits.length - i;
    buf.write(digits[i]);
    if (indexFromEnd > 1 && indexFromEnd % 3 == 1) {
      buf.write(' ');
    }
  }

  return '$sign${buf.toString()} Ft';
}
