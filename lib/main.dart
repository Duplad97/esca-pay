import 'package:flutter/material.dart';

import 'app/esca_pay_app.dart';
import 'shared/storage/storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initStorage();
  runApp(const EscaPayApp());
}
