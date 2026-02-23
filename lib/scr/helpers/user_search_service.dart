import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/owner_service.dart';

/// Server-side search for users with indexed fields.
/// Uses Firestore's built-in search to avoid full collection scans.
class UserSearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Search users by name using server-side filtering (indexed).
  /// Much faster than client-side filtering for large datasets.
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> searchByName(
    String nameQuery, {
    String collection = 'OldUser',
  }) async {
    if (nameQuery.trim().isEmpty) {
      return [];
    }

    final ownerId = requireOwnerId();
    final normalized = nameQuery.trim();
    final searchKey = normalized[0].toUpperCase() + normalized.substring(1);

    try {
      final query = _firestore
          .collection(collection)
          .where('ownerId', isEqualTo: ownerId)
          .orderBy('name') // Requires composite index
          .startAt([searchKey]).endAt([searchKey + '\uf8ff']).limit(100);

      final snapshot = await query.get();
      return snapshot.docs;
    } catch (e) {
      print('Error searching users by name: $e');
      return [];
    }
  }

  /// Search users by mobile number (indexed).
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> searchByMobile(
    String mobileQuery, {
    String collection = 'OldUser',
  }) async {
    if (mobileQuery.trim().isEmpty) {
      return [];
    }

    final ownerId = requireOwnerId();

    try {
      final query = _firestore
          .collection(collection)
          .where('ownerId', isEqualTo: ownerId)
          .where('mobileNo', isEqualTo: mobileQuery.trim())
          .limit(100);

      final snapshot = await query.get();
      return snapshot.docs;
    } catch (e) {
      print('Error searching users by mobile: $e');
      return [];
    }
  }

  /// Search users by area/village (indexed).
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> searchByArea(
    String areaQuery, {
    String collection = 'OldUser',
  }) async {
    if (areaQuery.trim().isEmpty) {
      return [];
    }

    final ownerId = requireOwnerId();

    try {
      final query = _firestore
          .collection(collection)
          .where('ownerId', isEqualTo: ownerId)
          .where('area', isEqualTo: areaQuery.trim())
          .limit(100);

      final snapshot = await query.get();
      return snapshot.docs;
    } catch (e) {
      print('Error searching users by area: $e');
      return [];
    }
  }

  /// Combined search: name OR mobile OR area (server-side).
  /// Still filters multiple conditions on client, but each is fast.
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      searchByNameOrMobile(
    String query, {
    String collection = 'OldUser',
  }) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final ownerId = requireOwnerId();
    final normalized = query.trim().toLowerCase();

    try {
      // Get users (unfiltered scope)
      final allDocs = await _firestore
          .collection(collection)
          .where('ownerId', isEqualTo: ownerId)
          .limit(500) // Safety limit
          .get();

      // Client-side filter by name, mobile, or other fields
      final results = allDocs.docs.where((doc) {
        final data = doc.data();
        final name = (data['name'] ?? '').toString().toLowerCase();
        final mobile = (data['mobileNo'] ?? '').toString().toLowerCase();
        final mobile2 = (data['mobileNo2'] ?? '').toString().toLowerCase();
        final area = (data['area'] ?? '').toString().toLowerCase();
        final dishNumber = (data['dishNumber'] ?? '').toString().toLowerCase();
        final dishType = (data['dishType'] ?? '').toString().toLowerCase();

        return name.contains(normalized) ||
            mobile.contains(normalized) ||
            mobile2.contains(normalized) ||
            area.contains(normalized) ||
            dishNumber.contains(normalized) ||
            dishType.contains(normalized);
      }).toList();

      return results;
    } catch (e) {
      print('Error in combined search: $e');
      return [];
    }
  }

  /// Fetch all users for a village with pagination.
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getUsersByVillage(
    String villageName, {
    String collection = 'OldUser',
    int limit = 100,
  }) async {
    if (villageName.trim().isEmpty) {
      return [];
    }

    final ownerId = requireOwnerId();

    try {
      final snap = await _firestore
          .collection(collection)
          .where('ownerId', isEqualTo: ownerId)
          .where('area', isEqualTo: villageName.trim())
          .limit(limit)
          .get();

      return snap.docs;
    } catch (e) {
      print('Error fetching users by village: $e');
      return [];
    }
  }
}
