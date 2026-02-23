import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/owner_service.dart';

/// Denormalized village summary cache for fast queries.
/// Keeps counts and amount totals updated automatically.
class VillageSummaryService {
  static const String _collectionPath = 'VillageSummaries';
  static const Duration _cacheTtl = Duration(minutes: 5);
  static final Map<String, _VillageSummaryCacheEntry> _cache = {};

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch a cached village summary (fast, from denormalized doc).
  Future<_VillageSummaryData?> getSummary(String villageName) async {
    try {
      final ownerId = requireOwnerId();
      if (ownerId.isEmpty) return null;

      final cacheKey = _cacheKey(ownerId, villageName);
      final cached = _cache[cacheKey];
      if (cached != null && !cached.isExpired(_cacheTtl)) {
        return cached.data;
      }

      final docId = _generateSummaryDocId(ownerId, villageName);
      final doc = await _firestore.collection(_collectionPath).doc(docId).get();

      if (!doc.exists) return null;

      final data = doc.data();
      if (data == null) return null;

      final summary = _VillageSummaryData(
        userCount: (data['userCount'] ?? 0) as int,
        pendingTotal: _parseDouble(data['pendingTotal']),
        balanceTotal: _parseDouble(data['balanceTotal']),
        lastUpdated:
            (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

      _cache[cacheKey] = _VillageSummaryCacheEntry(summary, DateTime.now());
      return summary;
    } catch (e) {
      print('Error fetching village summary: $e');
      return null;
    }
  }

  /// Refresh and update a village summary (background job).
  /// Call this after user changes or periodically.
  Future<void> updateSummary(String villageName) async {
    try {
      final ownerId = requireOwnerId();
      if (ownerId.isEmpty) return;

      // Count users in this village
      final oldCount = await _firestore
          .collection('OldUser')
          .where('ownerId', isEqualTo: ownerId)
          .where('area', isEqualTo: villageName.trim())
          .count()
          .get();

      final newCount = await _firestore
          .collection('NewUser')
          .where('ownerId', isEqualTo: ownerId)
          .where('area', isEqualTo: villageName.trim())
          .count()
          .get();

      final userCount = (oldCount.count ?? 0) + (newCount.count ?? 0);

      // Calculate totals from payment records
      final oldUsers = await _firestore
          .collection('OldUser')
          .where('ownerId', isEqualTo: ownerId)
          .where('area', isEqualTo: villageName.trim())
          .get();

      final newUsers = await _firestore
          .collection('NewUser')
          .where('ownerId', isEqualTo: ownerId)
          .where('area', isEqualTo: villageName.trim())
          .get();

      final userIds = <String>{};
      for (final doc in oldUsers.docs) {
        final id = doc.data()['id'] ?? doc.id;
        if (id is String && id.trim().isNotEmpty) {
          userIds.add(id);
        }
      }
      for (final doc in newUsers.docs) {
        final id = doc.data()['id'] ?? doc.id;
        if (id is String && id.trim().isNotEmpty) {
          userIds.add(id);
        }
      }

      double pendingTotal = 0;
      double balanceTotal = 0;

      if (userIds.isNotEmpty) {
        const chunkSize = 10;
        final ids = userIds.toList();
        for (var i = 0; i < ids.length; i += chunkSize) {
          final chunk = ids.sublist(
            i,
            i + chunkSize > ids.length ? ids.length : i + chunkSize,
          );
          final paymentDocs = await _firestore
              .collection('PaymentRecords')
              .where('ownerId', isEqualTo: ownerId)
              .where('USER_ID', whereIn: chunk)
              .get();

          for (final doc in paymentDocs.docs) {
            final data = doc.data();
            pendingTotal += _parseDouble(data['PENDING_AMOUNT']);
            balanceTotal += _parseDouble(data['BALANCE_AMOUNT']);
          }
        }
      }

      // Save summary to denormalized collection
      final docId = _generateSummaryDocId(ownerId, villageName);
      await _firestore.collection(_collectionPath).doc(docId).set({
        'ownerId': ownerId,
        'villageName': villageName.trim(),
        'userCount': userCount,
        'pendingTotal': pendingTotal,
        'balanceTotal': balanceTotal,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final cacheKey = _cacheKey(ownerId, villageName);
      _cache[cacheKey] = _VillageSummaryCacheEntry(
        _VillageSummaryData(
          userCount: userCount,
          pendingTotal: pendingTotal,
          balanceTotal: balanceTotal,
          lastUpdated: DateTime.now(),
        ),
        DateTime.now(),
      );
    } catch (e) {
      print('Error updating village summary: $e');
    }
  }

  /// Delete summary when village is deleted.
  Future<void> deleteSummary(String villageName) async {
    try {
      final ownerId = requireOwnerId();
      if (ownerId.isEmpty) return;

      final docId = _generateSummaryDocId(ownerId, villageName);
      await _firestore.collection(_collectionPath).doc(docId).delete();
      _cache.remove(_cacheKey(ownerId, villageName));
    } catch (e) {
      print('Error deleting village summary: $e');
    }
  }

  String _cacheKey(String ownerId, String villageName) {
    return '$ownerId|${villageName.trim().toLowerCase()}';
  }

  String _generateSummaryDocId(String ownerId, String villageName) {
    return '$ownerId|${villageName.trim().toLowerCase()}';
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    final text = value
        .toString()
        .replaceAll('Rs.', '')
        .replaceAll('Rs', '')
        .replaceAll(',', '')
        .trim();
    return double.tryParse(text) ?? 0;
  }
}

class _VillageSummaryCacheEntry {
  final _VillageSummaryData data;
  final DateTime cachedAt;

  const _VillageSummaryCacheEntry(this.data, this.cachedAt);

  bool isExpired(Duration ttl) {
    return DateTime.now().difference(cachedAt) > ttl;
  }
}

class _VillageSummaryData {
  final int userCount;
  final double pendingTotal;
  final double balanceTotal;
  final DateTime lastUpdated;

  _VillageSummaryData({
    required this.userCount,
    required this.pendingTotal,
    required this.balanceTotal,
    required this.lastUpdated,
  });
}
