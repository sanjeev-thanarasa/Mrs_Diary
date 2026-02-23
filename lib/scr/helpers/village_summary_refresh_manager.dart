import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/owner_service.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/village_summary_service.dart';

/// Background task to keep village summaries fresh.
/// Call this after user creation/deletion or payment changes.
class VillageSummaryRefreshManager {
  static const int _refreshDelayMs = 2000; // Wait 2s to batch changes
  static final Map<String, Timer?> _pendingRefresh = {};
  static final VillageSummaryService _summaryService = VillageSummaryService();

  /// Schedule a summary refresh for a village (batches rapid updates).
  static void scheduleRefresh(String villageName) {
    final key = villageName.trim().toLowerCase();
    _pendingRefresh[key]?.cancel();
    _pendingRefresh[key] =
        Timer(const Duration(milliseconds: _refreshDelayMs), () {
      _performRefresh(villageName);
    });
  }

  /// Resolve user's village and schedule a refresh.
  static Future<void> scheduleRefreshForUserId(String userId) async {
    final ownerId = requireOwnerId();
    if (ownerId.isEmpty) return;
    final id = userId.trim();
    if (id.isEmpty) return;

    try {
      final firestore = FirebaseFirestore.instance;
      final oldDoc = await firestore.collection('OldUser').doc(id).get();
      if (oldDoc.exists) {
        final data = oldDoc.data();
        if (data != null && data['ownerId'] == ownerId) {
          final area = data['area']?.toString().trim() ?? '';
          if (area.isNotEmpty) scheduleRefresh(area);
          return;
        }
      }

      final newDoc = await firestore.collection('NewUser').doc(id).get();
      if (newDoc.exists) {
        final data = newDoc.data();
        if (data != null && data['ownerId'] == ownerId) {
          final area = data['area']?.toString().trim() ?? '';
          if (area.isNotEmpty) scheduleRefresh(area);
        }
      }
    } catch (e) {
      print('Error resolving village for user refresh: $e');
    }
  }

  /// Trigger immediate refresh (for important changes).
  static Future<void> refreshNow(String villageName) async {
    final key = villageName.trim().toLowerCase();
    _pendingRefresh[key]?.cancel();
    _pendingRefresh[key] = null;
    await _performRefresh(villageName);
  }

  /// Do the actual refresh work
  static Future<void> _performRefresh(String villageName) async {
    try {
      await _summaryService.updateSummary(villageName);
    } catch (e) {
      print('Error refreshing village summary: $e');
    }
  }

  /// Cancel any pending refresh for a village
  static void cancel(String villageName) {
    final key = villageName.trim().toLowerCase();
    _pendingRefresh[key]?.cancel();
    _pendingRefresh[key] = null;
  }

  /// Cleanup: cancel all pending refreshes
  static void cancelAll() {
    for (final timer in _pendingRefresh.values) {
      timer?.cancel();
    }
    _pendingRefresh.clear();
  }
}
