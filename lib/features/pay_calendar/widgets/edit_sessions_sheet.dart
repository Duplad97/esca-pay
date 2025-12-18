import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/game_session.dart';
import '../models/room_constants.dart';

class EditSessionsSheet extends StatefulWidget {
  const EditSessionsSheet({
    super.key,
    required this.initialSessions,
    required this.onSessionsChanged,
  });

  final List<GameSession> initialSessions;
  final ValueChanged<List<GameSession>> onSessionsChanged;

  @override
  State<EditSessionsSheet> createState() => _EditSessionsSheetState();
}

class _EditSessionsSheetState extends State<EditSessionsSheet> {
  late final List<_SessionItem> _sessions;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldMessengerState> _messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _sessions = widget.initialSessions
        .map(
          (s) => _SessionDraft(
            roomName: s.roomName,
            timeSlot: s.timeSlot,
            guests: s.guests,
            paymentMethod: s.paymentMethod,
            satisfactionYes: s.satisfactionYes,
          ),
        )
        .map((d) => _SessionItem(draft: d, isSaved: true))
        .toList(growable: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (final s in _sessions) {
      s.draft.dispose();
    }
    super.dispose();
  }

  void _scrollToIndex(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final target = _scrollController.position.maxScrollExtent;
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _emitSavedSessions() {
    final sessions = _sessions
        .where((s) => s.isSaved)
        .map((s) => s.draft.toSession())
        .toList(growable: false);
    widget.onSessionsChanged(sessions);
  }

  void _showSingleEditorMessage() {
    _showSnackBar('Finish the current session first');
  }

  void _showSaveError(String message) {
    _showSnackBar(message);
  }

  void _showSnackBar(String message) {
    final messenger = _messengerKey.currentState ?? ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ScaffoldMessenger(
      key: _messengerKey,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(Icons.badge, color: cs.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Sessions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _sessions.isEmpty
                    ? Center(
                        child: Text(
                          'No sessions yet.\nTap “Add session”.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      )
                    : ListView.separated(
                        controller: _scrollController,
                        itemCount: _sessions.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = _sessions[index];
                          return _SessionItemView(
                            index: index,
                            item: item,
                            onRemove: () {
                              HapticFeedback.lightImpact();
                              setState(() {
                                _sessions[index].draft.dispose();
                                _sessions.removeAt(index);
                              });
                              _emitSavedSessions();
                            },
                            onChanged: () => setState(() {}),
                            onSaveToggle: (bool isSaved) {
                              HapticFeedback.lightImpact();
                              setState(() {
                                _sessions[index] = item.copyWith(isSaved: isSaved);
                              });
                              _emitSavedSessions();
                            },
                            onSaveRequested: () {
                              final draft = _sessions[index].draft;
                              if (draft.roomNameController.text.trim().isEmpty) {
                                HapticFeedback.selectionClick();
                                _showSaveError('Pick a room name to save this session');
                                _scrollToIndex(index);
                                return;
                              }
                              if (draft.timeSlotController.text.trim().isEmpty) {
                                HapticFeedback.selectionClick();
                                _showSaveError('Pick a time to save this session');
                                _scrollToIndex(index);
                                return;
                              }
                              HapticFeedback.lightImpact();
                              setState(() {
                                _sessions[index] = item.copyWith(isSaved: true);
                              });
                              _emitSavedSessions();
                            },
                            onEditRequested: () {
                              final openIndex =
                                  _sessions.indexWhere((s) => s.isSaved == false);
                              if (openIndex != -1 && openIndex != index) {
                                _showSingleEditorMessage();
                                _scrollToIndex(openIndex);
                                return;
                              }
                              HapticFeedback.lightImpact();
                              setState(() {
                                _sessions[index] = item.copyWith(isSaved: false);
                              });
                              _scrollToIndex(index);
                            },
                          );
                        },
                      ),
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  FilledButton.tonalIcon(
                    onPressed: () {
                      final openIndex =
                          _sessions.indexWhere((s) => s.isSaved == false);
                      if (openIndex != -1) {
                        HapticFeedback.selectionClick();
                        _showSingleEditorMessage();
                        _scrollToIndex(openIndex);
                        return;
                      }
                      HapticFeedback.lightImpact();
                      setState(() {
                        _sessions.add(
                          _SessionItem(
                            draft: _SessionDraft.defaultValue(),
                            isSaved: false,
                          ),
                        );
                      });
                      _scrollToIndex(_sessions.length - 1);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add session'),
                  ),
                  const Spacer(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.index,
    required this.draft,
    required this.onRemove,
    required this.onChanged,
    required this.onSave,
  });

  final int index;
  final _SessionDraft draft;
  final VoidCallback onRemove;
  final VoidCallback onChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Colors.white.withValues(alpha: 0.96),
            cs.primaryContainer.withValues(alpha: 0.18),
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  'Session #${index + 1}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Remove',
                  onPressed: onRemove,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: draft.roomNameController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Room name',
                suffixIcon: Icon(Icons.search),
              ),
              onTap: () async {
                HapticFeedback.selectionClick();
                final picked = await showModalBottomSheet<String>(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  showDragHandle: true,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  builder: (BuildContext context) {
                    return const _RoomPickerSheet();
                  },
                );
                if (!context.mounted || picked == null) return;
                draft.roomNameController.text = picked;
                onChanged();
              },
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: DropdownMenu<String>(
                    controller: draft.timeSlotController,
                    initialSelection: draft.timeSlotController.text.isEmpty
                        ? null
                        : draft.timeSlotController.text,
                    requestFocusOnTap: true,
                    expandedInsets: EdgeInsets.zero,
                    inputDecorationTheme: _dropdownInputTheme(context),
                    label: const Text('Time'),
                    onSelected: (String? v) {
                      draft.timeSlotController.text = v ?? '';
                      onChanged();
                    },
                    dropdownMenuEntries: timeSlots
                        .map((t) => DropdownMenuEntry<String>(value: t, label: t))
                        .toList(growable: false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: draft.guestsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Guests'),
                    onChanged: (_) => onChanged(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _SegmentedPicker<PaymentMethod>(
              label: 'Payment',
              value: draft.paymentMethod,
              items: const <PaymentMethod, String>{
                PaymentMethod.cash: 'Cash',
                PaymentMethod.card: 'Card',
                PaymentMethod.transfer: 'Transfer',
              },
              icons: const <PaymentMethod, IconData>{
                PaymentMethod.cash: Icons.payments_outlined,
                PaymentMethod.card: Icons.credit_card,
                PaymentMethod.transfer: Icons.account_balance_outlined,
              },
              onChanged: (v) {
                draft.paymentMethod = v;
                onChanged();
              },
            ),
            const SizedBox(height: 10),
            _SegmentedPicker<bool>(
              label: 'Satisfaction',
              value: draft.satisfactionYes,
              items: const <bool, String>{true: 'Yes', false: 'No'},
              icons: const <bool, IconData>{
                true: Icons.sentiment_satisfied_alt,
                false: Icons.sentiment_dissatisfied,
              },
              onChanged: (v) {
                draft.satisfactionYes = v;
                onChanged();
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                const Spacer(),
                FilledButton(
                  onPressed: onSave,
                  child: const Text('Save session'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionItemView extends StatelessWidget {
  const _SessionItemView({
    required this.index,
    required this.item,
    required this.onRemove,
    required this.onChanged,
    required this.onSaveToggle,
    required this.onSaveRequested,
    required this.onEditRequested,
  });

  final int index;
  final _SessionItem item;
  final VoidCallback onRemove;
  final VoidCallback onChanged;
  final ValueChanged<bool> onSaveToggle;
  final VoidCallback onSaveRequested;
  final VoidCallback onEditRequested;

  @override
  Widget build(BuildContext context) {
    if (!item.isSaved) {
      return _SessionCard(
        index: index,
        draft: item.draft,
        onRemove: onRemove,
        onChanged: onChanged,
        onSave: onSaveRequested,
      );
    }

    return _SavedSessionTile(
      index: index,
      session: item.draft.toSession(),
      onEdit: onEditRequested,
      onRemove: onRemove,
    );
  }
}

class _SavedSessionTile extends StatelessWidget {
  const _SavedSessionTile({
    required this.index,
    required this.session,
    required this.onEdit,
    required this.onRemove,
  });

  final int index;
  final GameSession session;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final room = session.roomName.isEmpty ? 'Room name' : session.roomName;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant),
        color: Colors.white.withValues(alpha: 0.95),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  'Session #${index + 1}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Edit',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                ),
                IconButton(
                  tooltip: 'Remove',
                  onPressed: onRemove,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              room,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _Chip(icon: Icons.schedule, label: session.timeSlot),
                _Chip(icon: Icons.group_outlined, label: '${session.guests} guests'),
                _Chip(icon: _paymentIcon(session.paymentMethod), label: _paymentLabel(session.paymentMethod)),
                _Chip(
                  icon: session.satisfactionYes
                      ? Icons.sentiment_satisfied_alt
                      : Icons.sentiment_dissatisfied,
                  label: session.satisfactionYes ? 'Satisfied' : 'Not satisfied',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _paymentIcon(PaymentMethod m) {
    return switch (m) {
      PaymentMethod.cash => Icons.payments_outlined,
      PaymentMethod.card => Icons.credit_card,
      PaymentMethod.transfer => Icons.account_balance_outlined,
    };
  }

  String _paymentLabel(PaymentMethod m) {
    return switch (m) {
      PaymentMethod.cash => 'Cash',
      PaymentMethod.card => 'Card',
      PaymentMethod.transfer => 'Transfer',
    };
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant),
        color: Colors.white.withValues(alpha: 0.85),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 16, color: cs.primary),
            const SizedBox(width: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentedPicker<T> extends StatelessWidget {
  const _SegmentedPicker({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.icons,
  });

  final String label;
  final T value;
  final Map<T, String> items;
  final ValueChanged<T> onChanged;
  final Map<T, IconData>? icons;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final segments = items.entries
        .map(
          (e) => ButtonSegment<T>(
            value: e.key,
            label: _SegmentLabel(
              text: e.value,
              icon: icons?[e.key],
            ),
          ),
        )
        .toList(growable: false);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
        color: Colors.white.withValues(alpha: 0.75),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<T>(
              showSelectedIcon: false,
              segments: segments,
              selected: <T>{value},
              onSelectionChanged: (Set<T> selection) {
                final next = selection.isEmpty ? null : selection.first;
                if (next != null) onChanged(next);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentLabel extends StatelessWidget {
  const _SegmentLabel({required this.text, required this.icon});

  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w800,
        );

    if (icon == null) return Text(text, style: labelStyle);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 16),
        const SizedBox(width: 4),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.visible,
              style: labelStyle,
            ),
          ),
        ),
      ],
    );
  }
}

InputDecorationTheme _dropdownInputTheme(BuildContext context) {
  final cs = Theme.of(context).colorScheme;
  final radius = BorderRadius.circular(16);
  return InputDecorationTheme(
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.88),
    border: OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: cs.outlineVariant),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: cs.outlineVariant),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: cs.primary, width: 2),
    ),
  );
}

class _RoomPickerSheet extends StatefulWidget {
  const _RoomPickerSheet();

  @override
  State<_RoomPickerSheet> createState() => _RoomPickerSheetState();
}

class _RoomPickerSheetState extends State<_RoomPickerSheet> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final q = _searchController.text.trim().toLowerCase();
    final filtered = q.isEmpty
        ? roomNames
        : roomNames.where((r) => r.toLowerCase().contains(q)).toList(growable: false);

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
              Icon(Icons.search, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                'Pick a room',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Close',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Search',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: cs.outlineVariant),
                color: Colors.white.withValues(alpha: 0.85),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: filtered.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (BuildContext context, int index) {
                  final room = filtered[index];
                  return ListTile(
                    title: Text(room),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop(room);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionDraft {
  _SessionDraft({
    required String roomName,
    required String timeSlot,
    required int guests,
    required this.paymentMethod,
    required this.satisfactionYes,
  })  : roomNameController = TextEditingController(text: roomName),
        timeSlotController = TextEditingController(text: timeSlot),
        guestsController = TextEditingController(text: guests.toString());

  factory _SessionDraft.defaultValue() {
    return _SessionDraft(
      roomName: '',
      timeSlot: timeSlots.first,
      guests: 2,
      paymentMethod: PaymentMethod.cash,
      satisfactionYes: true,
    );
  }

  final TextEditingController roomNameController;
  final TextEditingController timeSlotController;
  final TextEditingController guestsController;
  PaymentMethod paymentMethod;
  bool satisfactionYes;

  void dispose() {
    roomNameController.dispose();
    timeSlotController.dispose();
    guestsController.dispose();
  }

  GameSession toSession() {
    final guests = int.tryParse(guestsController.text.trim()) ?? 0;
    return GameSession(
      roomName: roomNameController.text.trim(),
      timeSlot: timeSlotController.text.trim(),
      guests: guests.clamp(0, 999),
      paymentMethod: paymentMethod,
      satisfactionYes: satisfactionYes,
    );
  }
}

class _SessionItem {
  const _SessionItem({required this.draft, required this.isSaved});

  final _SessionDraft draft;
  final bool isSaved;

  _SessionItem copyWith({bool? isSaved}) {
    return _SessionItem(draft: draft, isSaved: isSaved ?? this.isSaved);
  }
}
