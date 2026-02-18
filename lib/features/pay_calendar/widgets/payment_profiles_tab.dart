import 'package:flutter/material.dart';
import 'package:esca_pay/l10n/app_localizations.dart';

import '../../../shared/storage/payment_profiles_storage.dart';
import '../../../shared/storage/storage.dart';
import '../../../shared/utils/money_format.dart';
import '../models/payment_profile.dart';
import 'payment_profile_dialog.dart';

class PaymentProfilesTab extends StatefulWidget {
  const PaymentProfilesTab({
    super.key,
    required this.storage,
    required this.onProfilesChanged,
  });

  final PaymentProfilesStorage storage;
  final VoidCallback onProfilesChanged;

  @override
  State<PaymentProfilesTab> createState() => _PaymentProfilesTabState();
}

class _PaymentProfilesTabState extends State<PaymentProfilesTab> {
  late List<PaymentProfile> _profiles = [];
  String? _defaultProfileId;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<PaymentProfile> _displayProfiles = <PaymentProfile>[];
  final ScrollController _listController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  Future<void> _loadProfiles() async {
    final profiles = widget.storage.loadAll();
    final defaultId = await widget.storage.getDefaultProfileId();
    if (!mounted) return;
    _applyProfiles(profiles, defaultId);
  }

  List<PaymentProfile> _sortedProfiles(
    List<PaymentProfile> profiles,
    String? defaultId,
  ) {
    final sorted = List<PaymentProfile>.from(profiles);
    sorted.sort((a, b) {
      final aIsDefault = a.id == defaultId;
      final bIsDefault = b.id == defaultId;
      if (aIsDefault == bIsDefault) {
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
      return aIsDefault ? -1 : 1;
    });
    return sorted;
  }

  void _applyProfiles(List<PaymentProfile> profiles, String? defaultId) {
    final sorted = _sortedProfiles(profiles, defaultId);
    setState(() {
      _profiles = profiles;
      _defaultProfileId = defaultId;
    });

    if (_listKey.currentState == null || _displayProfiles.isEmpty) {
      setState(() {
        _displayProfiles = List<PaymentProfile>.from(sorted);
      });
      return;
    }

    final listState = _listKey.currentState!;
    for (var i = _displayProfiles.length - 1; i >= 0; i--) {
      final removed = _displayProfiles.removeAt(i);
      listState.removeItem(
        i,
        (context, animation) =>
            _buildProfileCard(removed, animation: animation),
        duration: const Duration(milliseconds: 180),
      );
    }

    for (var i = 0; i < sorted.length; i++) {
      _displayProfiles.insert(i, sorted[i]);
      listState.insertItem(i, duration: const Duration(milliseconds: 220));
    }
  }

  Future<void> _createProfile() async {
    final result = await showDialog<PaymentProfile>(
      context: context,
      builder: (context) => const PaymentProfileDialog(),
    );

    if (result == null || !mounted) return;

    await widget.storage.createProfile(
      name: result.name,
      hourlyWage: result.hourlyWage,
      perRoomBonus: result.perRoomBonus,
      jumpInRate: result.jumpInRate,
      eventFine: result.eventFine,
    );

    await _loadProfiles();
    widget.onProfilesChanged();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.profileCreated)),
      );
    }
  }

  Future<void> _editProfile(PaymentProfile profile) async {
    final result = await showDialog<PaymentProfile>(
      context: context,
      builder: (context) => PaymentProfileDialog(profile: profile),
    );

    if (result == null || !mounted) return;

    await widget.storage.updateProfile(result);
    await _loadProfiles();
    widget.onProfilesChanged();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.profileUpdated)),
      );
    }
  }

  Future<void> _deleteProfile(PaymentProfile profile) async {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    // Check if profile is in use
    if (dayEntriesStorage.isProfileIdInUse(profile.id)) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.deleteProfile),
          content: Text(l10n.profileInUse),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.ok),
            ),
          ],
        ),
      );
      return;
    }

    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteProfile),
        content: Text(l10n.confirmDeleteProfile),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await widget.storage.deleteProfile(profile.id);
    await _loadProfiles();
    widget.onProfilesChanged();

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.profileDeleted)));
    }
  }

  Future<void> _setDefaultProfile(String profileId) async {
    await widget.storage.setDefaultProfileId(profileId);
    await _loadProfiles();
    widget.onProfilesChanged();
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_listController.hasClients) return;
      _listController.animateTo(
        0,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_profiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.noProfiles),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _createProfile,
              icon: const Icon(Icons.add),
              label: Text(l10n.createProfile),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.paymentProfiles,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              FilledButton.icon(
                onPressed: _createProfile,
                icon: const Icon(Icons.add),
                label: Text(l10n.createProfile),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: AnimatedList(
            key: _listKey,
            controller: _listController,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            initialItemCount: _displayProfiles.length,
            itemBuilder: (context, index, animation) {
              final profile = _displayProfiles[index];
              return _buildProfileCard(profile, animation: animation);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(
    PaymentProfile profile, {
    Animation<double>? animation,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final isDefault = profile.id == _defaultProfileId;
    final borderColor = isDefault
        ? cs.primary.withValues(alpha: 0.45)
        : cs.outlineVariant.withValues(alpha: 0.4);

    Widget card = Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isDefault ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              profile.name,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (isDefault)
                            Chip(
                              label: Text(
                                l10n.defaultProfile,
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: cs.primaryContainer,
                              labelStyle: TextStyle(
                                color: cs.onPrimaryContainer,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _ProfileDetails(profile: profile),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                if (!isDefault)
                  TextButton.icon(
                    onPressed: () => _setDefaultProfile(profile.id),
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text(l10n.setAsDefault),
                  ),
                TextButton.icon(
                  onPressed: () => _editProfile(profile),
                  icon: const Icon(Icons.edit),
                  label: Text(l10n.edit),
                ),
                if (!isDefault)
                  TextButton.icon(
                    onPressed: () => _deleteProfile(profile),
                    icon: const Icon(Icons.delete_outline),
                    label: Text(l10n.delete),
                  ),
              ],
            ),
          ],
        ),
      ),
    );

    if (animation == null) return card;
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(curved);
    return SizeTransition(
      sizeFactor: curved,
      axisAlignment: -1,
      child: FadeTransition(
        opacity: curved,
        child: SlideTransition(position: slide, child: card),
      ),
    );
  }
}

class _ProfileDetails extends StatelessWidget {
  const _ProfileDetails({required this.profile});

  final PaymentProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailRow(
          label: l10n.hourlyWageTitle,
          value: money(profile.hourlyWage),
        ),
        _DetailRow(
          label: l10n.perRoomBonusTitle,
          value: money(profile.perRoomBonus),
        ),
        _DetailRow(
          label: l10n.jumpInRateTitle,
          value: money(profile.jumpInRate),
        ),
        _DetailRow(label: l10n.eventFineTitle, value: money(profile.eventFine)),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
