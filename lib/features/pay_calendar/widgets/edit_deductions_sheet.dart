import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:esca_pay/l10n/app_localizations.dart';

import '../models/deduction.dart';

class EditDeductionsSheet extends StatefulWidget {
  const EditDeductionsSheet({super.key, required this.initialDeductions});

  final List<Deduction> initialDeductions;

  @override
  State<EditDeductionsSheet> createState() => _EditDeductionsSheetState();
}

class _EditDeductionsSheetState extends State<EditDeductionsSheet> {
  late List<Deduction> _deductions;
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _deductions = widget.initialDeductions.toList(growable: true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _addDeduction() {
    final name = _nameController.text.trim();
    final amountText = _amountController.text.trim();

    if (name.isEmpty || amountText.isEmpty) {
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null) {
      return;
    }

    setState(() {
      _deductions.add(Deduction(name: name, amount: amount));
      _nameController.clear();
      _amountController.clear();
    });
  }

  void _removeDeduction(int index) {
    setState(() {
      _deductions.removeAt(index);
    });
  }

  double get _totalDeductions {
    return _deductions.fold<double>(0.0, (sum, d) => sum + d.amount);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.remove_circle_outline, color: cs.error),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.deductions,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              IconButton(
                tooltip: l10n.close,
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l10n.deductionsSubtitle(_deductions.length, _totalDeductions),
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: _deductions.isEmpty
                ? Center(
                    child: Text(
                      l10n.deductionsSheetEmpty,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _deductions.length,
                    itemBuilder: (context, i) {
                      final deduction = _deductions[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(deduction.name),
                          subtitle: Text(
                            l10n.deductionAmount(deduction.amount),
                            style: TextStyle(
                              color: cs.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _removeDeduction(i),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: l10n.deductionName,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        isDense: true,
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: l10n.amount,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        isDense: true,
                        suffixText: 'Ft',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _addDeduction(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _addDeduction,
                icon: const Icon(Icons.add),
                label: Text(l10n.add),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(_deductions),
              child: Text(l10n.save),
            ),
          ),
        ],
      ),
    );
  }
}
