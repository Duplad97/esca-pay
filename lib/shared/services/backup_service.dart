import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../features/pay_calendar/models/benefit.dart';
import '../../features/pay_calendar/models/event.dart';
import '../../features/pay_calendar/models/game_session.dart';
import '../storage/day_entries_storage.dart';

class BackupService {
  BackupService(this._storage);

  final DayEntriesStorage _storage;

  /// Export all day entries to a JSON file in the downloads/documents folder
  Future<File?> exportBackup() async {
    try {
      // Get all entries from storage
      final entries = _storage.loadAll();

      // Convert to JSON-serializable format with metadata
      final backup = {
        'version': 1,
        'exportDate': DateTime.now().toIso8601String(),
        'entries': {
          for (final entry in entries.entries)
            entry.key: {
              'hours': entry.value.hours,
              'rooms': entry.value.rooms,
              'sessions': entry.value.sessions.map((s) => s.toJson()).toList(),
              'events': entry.value.events.map((e) => e.toJson()).toList(),
              'benefits': entry.value.benefits.map((b) => b.toJson()).toList(),
            },
        },
      };

      // Create file in documents directory
      final documentsDir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now()
          .toString()
          .split('.')[0]
          .replaceAll(':', '-')
          .replaceAll(' ', '_');
      final fileName = 'esca_pay_backup_$timestamp.json';
      final file = File('${documentsDir.path}/$fileName');

      // Write to file
      await file.writeAsString(jsonEncode(backup), flush: true);

      return file;
    } catch (e) {
      throw 'Error exporting backup: $e';
    }
  }

  /// Share the backup file
  /// Optional: pass [sharePositionOrigin] for iOS popover positioning
  Future<void> shareBackup(File file, {Rect? sharePositionOrigin}) async {
    try {
      await Share.shareXFiles([
        XFile(file.path),
      ], sharePositionOrigin: sharePositionOrigin);
    } catch (e) {
      throw 'Error sharing backup: $e';
    }
  }

  /// Import a backup file and restore data
  /// Returns true on success
  Future<bool> importBackup() async {
    try {
      // Pick a file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null) {
        return false; // User cancelled
      }

      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final backup = jsonDecode(content) as Map<String, dynamic>;

      // Validate backup structure
      if (backup['version'] != 1) {
        throw 'Unsupported backup version: ${backup['version']}';
      }

      if (backup['entries'] == null) {
        throw 'Invalid backup format: missing entries';
      }

      // Clear existing data and import new entries
      await _storage.clearAll();

      final entries = backup['entries'] as Map<String, dynamic>;
      for (final entry in entries.entries) {
        final dayKey = entry.key;
        final data = entry.value as Map<String, dynamic>;

        final sessions =
            (data['sessions'] as List<dynamic>?)
                ?.map((s) => GameSession.fromJson(s as Map<String, dynamic>))
                .whereType<GameSession>()
                .toList() ??
            [];

        final events =
            (data['events'] as List<dynamic>?)
                ?.map((e) => Event.fromJson(e as Map<String, dynamic>))
                .whereType<Event>()
                .toList() ??
            [];

        final benefits =
            (data['benefits'] as List<dynamic>?)
                ?.map((b) => Benefit.fromJson(b as Map<String, dynamic>))
                .whereType<Benefit>()
                .toList() ??
            [];

        await _storage.setEntry(
          dayKey: dayKey,
          hours: (data['hours'] as num?)?.toDouble() ?? 0.0,
          rooms: (data['rooms'] as num?)?.toInt() ?? 0,
          sessions: sessions,
          events: events,
          benefits: benefits,
        );
      }

      return true;
    } catch (e) {
      throw 'Error importing backup: $e';
    }
  }
}
