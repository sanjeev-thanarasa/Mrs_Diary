import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/owner_service.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/operations.dart';
import 'package:mrs_dth_diary_v1/scr/providers/village.dart';
import 'package:mrs_dth_diary_v1/scr/ui/filterVIllageUsers.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CAppBar.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CustomStreamBuilder.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/ShowPopUpAlertBox.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/noResultFound.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/responsive.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/screen_navigation.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class VillagesList extends StatefulWidget {
  @override
  _VillagesListState createState() => _VillagesListState();
}

class _VillagesListState extends State<VillagesList> {
  ScrollController _controller = ScrollController();
  late final CollectionReference collectionReference;
  String searchText = '';
  final Map<String, Future<int>> _countFutureCache = {};
  final Map<String, Future<_VillageAmountSummary>> _amountFutureCache = {};

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    collectionReference = FirebaseFirestore.instance.collection("Villages");
    super.initState();
  }

  Future<int> _loadVillageUserCount(String villageName) {
    final key = villageName.trim().toLowerCase();
    if (_countFutureCache.containsKey(key)) {
      return _countFutureCache[key]!;
    }

    final future = _fetchVillageUserCount(villageName);
    _countFutureCache[key] = future;
    return future;
  }

  Future<_VillageAmountSummary> _loadVillageAmountSummary(String villageName) {
    final key = villageName.trim().toLowerCase();
    if (_amountFutureCache.containsKey(key)) {
      return _amountFutureCache[key]!;
    }

    final future = _fetchVillageAmountSummary(villageName);
    _amountFutureCache[key] = future;
    return future;
  }

  Future<int> _fetchVillageUserCount(String villageName) async {
    final firestore = FirebaseFirestore.instance;
    final ownerId = requireOwnerId();
    final oldUserCount = await firestore
        .collection("OldUser")
        .where('ownerId', isEqualTo: ownerId)
        .where("area", isEqualTo: villageName)
        .count()
        .get();
    final newUserCount = await firestore
        .collection("NewUser")
        .where('ownerId', isEqualTo: ownerId)
        .where("area", isEqualTo: villageName)
        .count()
        .get();

    return (oldUserCount.count ?? 0) + (newUserCount.count ?? 0);
  }

  Future<_VillageAmountSummary> _fetchVillageAmountSummary(
      String villageName) async {
    final firestore = FirebaseFirestore.instance;
    final ownerId = requireOwnerId();
    final normalized = villageName.trim();

    final oldSnapshot = await firestore
        .collection('OldUser')
        .where('ownerId', isEqualTo: ownerId)
        .where('area', isEqualTo: normalized)
        .get();
    final newSnapshot = await firestore
        .collection('NewUser')
        .where('ownerId', isEqualTo: ownerId)
        .where('area', isEqualTo: normalized)
        .get();

    final userIds = <String>{};
    for (final doc in oldSnapshot.docs) {
      final data = doc.data();
      final id = data['id'] ?? doc.id;
      if (id is String && id.trim().isNotEmpty) {
        userIds.add(id);
      }
    }
    for (final doc in newSnapshot.docs) {
      final data = doc.data();
      final id = data['id'] ?? doc.id;
      if (id is String && id.trim().isNotEmpty) {
        userIds.add(id);
      }
    }

    if (userIds.isEmpty) {
      return const _VillageAmountSummary.zero();
    }

    double totalPending = 0;
    double totalBalance = 0;
    const chunkSize = 10;
    final ids = userIds.toList();
    for (var i = 0; i < ids.length; i += chunkSize) {
      final chunk = ids.sublist(
        i,
        i + chunkSize > ids.length ? ids.length : i + chunkSize,
      );
      final paymentSnapshot = await firestore
          .collection('PaymentRecords')
          .where('ownerId', isEqualTo: ownerId)
          .where('USER_ID', whereIn: chunk)
          .get();

      for (final doc in paymentSnapshot.docs) {
        final data = doc.data();
        totalPending += _parseAmount(data['PENDING_AMOUNT']);
        totalBalance += _parseAmount(data['BALANCE_AMOUNT']);
      }
    }

    return _VillageAmountSummary(
      pending: totalPending,
      balance: totalBalance,
    );
  }

  double _parseAmount(dynamic value) {
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

  Future<void> _confirmDelete(String villageId, String villageName) async {
    // Check if village has any users before allowing deletion
    final hasUsers = await _checkVillageHasUsers(villageName);

    if (hasUsers) {
      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(
              'Cannot delete village',
              style: TextStyle(
                fontFamily: 'TamilArima',
                fontWeight: FontWeight.w700,
              ),
            ),
            content: const Text(
              'This village has users. Please delete all users from this village first, then you can delete the village.',
              style: TextStyle(
                fontFamily: 'TamilArima2',
                fontSize: 14,
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete village'),
        content: const Text('Do you want to delete this village?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await deleteProduct(
                id: villageId,
                collectionName: 'Villages',
              );
              if (mounted) {
                Navigator.pop(context);
                showSnackbar(
                  'Village deleted',
                  'Village has been successfully deleted',
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<bool> _checkVillageHasUsers(String villageName) async {
    final firestore = FirebaseFirestore.instance;
    final ownerId = requireOwnerId();

    // Check OldUser collection
    final oldUsersQuery = await firestore
        .collection('OldUser')
        .where('ownerId', isEqualTo: ownerId)
        .where('area', isEqualTo: villageName.trim())
        .limit(1)
        .get();

    if (oldUsersQuery.docs.isNotEmpty) {
      return true;
    }

    // Check NewUser collection
    final newUsersQuery = await firestore
        .collection('NewUser')
        .where('ownerId', isEqualTo: ownerId)
        .where('area', isEqualTo: villageName.trim())
        .limit(1)
        .get();

    return newUsersQuery.docs.isNotEmpty;
  }

  Future<void> _showEditDialog({
    required String villageId,
    required String currentName,
  }) async {
    // Check if village has any users before allowing edit
    final hasUsers = await _checkVillageHasUsers(currentName);

    if (hasUsers) {
      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(
              'Cannot edit village',
              style: TextStyle(
                fontFamily: 'TamilArima',
                fontWeight: FontWeight.w700,
              ),
            ),
            content: const Text(
              'This village has users. Please delete all users from this village first, then you can edit the village.',
              style: TextStyle(
                fontFamily: 'TamilArima2',
                fontSize: 14,
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      return;
    }

    final controller = TextEditingController(text: currentName);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit village'),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.black),
          decoration: const InputDecoration(
            labelText: 'Village name',
            hintText: 'Enter village name',
            labelStyle: TextStyle(color: Colors.black),
            floatingLabelStyle: TextStyle(color: Colors.black),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) {
                _showVillageMessage('Village name is required');
                return;
              }
              if (name == currentName) {
                if (mounted) {
                  Navigator.pop(context);
                }
                return;
              }
              if (await _isVillageNameTaken(name, excludeId: villageId)) {
                _showVillageMessage('Village already exists');
                return;
              }
              if (name.isNotEmpty) {
                await updateProduct(
                  collectionName: 'Villages',
                  id: villageId,
                  updateData: {'name': name},
                );

                await _renameVillageUsers(
                  oldName: currentName,
                  newName: name,
                );

                _countFutureCache.remove(currentName.trim().toLowerCase());
                _countFutureCache.remove(name.trim().toLowerCase());
                _amountFutureCache.remove(currentName.trim().toLowerCase());
                _amountFutureCache.remove(name.trim().toLowerCase());
              }
              if (mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _renameVillageUsers({
    required String oldName,
    required String newName,
  }) async {
    await _updateAreaForCollection(
      collectionName: 'OldUser',
      oldName: oldName,
      newName: newName,
    );
    await _updateAreaForCollection(
      collectionName: 'NewUser',
      oldName: oldName,
      newName: newName,
    );
  }

  Future<void> _updateAreaForCollection({
    required String collectionName,
    required String oldName,
    required String newName,
  }) async {
    final firestore = FirebaseFirestore.instance;
    DocumentSnapshot? lastDoc;

    while (true) {
      Query query = firestore
          .collection(collectionName)
          .where('ownerId', isEqualTo: requireOwnerId())
          .where('area', isEqualTo: oldName)
          .orderBy(FieldPath.documentId)
          .limit(400);

      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }

      final snapshot = await query.get();
      if (snapshot.docs.isEmpty) break;

      final batch = firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'area': newName});
      }
      await batch.commit();

      lastDoc = snapshot.docs.last;
      if (snapshot.docs.length < 400) break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final villageProvider = Provider.of<VillageProvider>(context);
    final rs = context.rs;
    return Scaffold(
      backgroundColor: Colors.white.withValues(alpha: .9),
      appBar: CustomAppBar(
        prefixIcon: Icons.arrow_back,
        trailing: InkWell(
          onTap: () => _showCreateVillageDialog(villageProvider),
          child: Container(
            height: rs.r(36),
            width: rs.r(36),
            decoration: BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.circular(rs.r(10)),
            ),
            child: const Center(
              child: Icon(
                Icons.add,
                size: 22,
                color: Colors.white,
              ),
            ),
          ),
        ),
        iconOnTap: () => Navigator.pop(context),
        onChanged: (text) => setState(() => searchText = text.trim()),
        hintText: "கிராமங்கள்",
      ),
      body: RefreshIndicator(
        onRefresh: _onPullRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              SizedBox(
                height: rs.rh(15),
              ),
              CustomStreamBuilder(
                context: context,
                stream: collectionReference
                    .where('ownerId', isEqualTo: requireOwnerId())
                    .snapshots() as Stream<QuerySnapshot<Map<String, dynamic>>>,
                body: (snap) {
                  final docs = snap.data?.docs ?? [];
                  final query = searchText.trim().toLowerCase();
                  final filtered = query.isEmpty
                      ? docs
                      : docs.where((doc) {
                          final name = (doc.data()["name"] ?? "")
                              .toString()
                              .toLowerCase();
                          return name.contains(query);
                        }).toList();

                  return filtered.isNotEmpty
                      ? ListView.separated(
                          scrollDirection: Axis.vertical,
                          controller: _controller,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              SizedBox(height: rs.rh(8)),
                          itemBuilder: (_, index) {
                            final data = filtered[index];
                            final villageName = data["name"] ?? "";
                            final villageId = data.id;
                            return _VillageTile(
                              villageId: villageId,
                              villageName: villageName,
                              onTap: () => changeScreenAnimated(
                                context,
                                FilterVillageUser(villageName: villageName),
                              ),
                              onEdit: () => _showEditDialog(
                                villageId: villageId,
                                currentName: villageName,
                              ),
                              onDelete: () =>
                                  _confirmDelete(villageId, villageName),
                              countFuture: _loadVillageUserCount(villageName),
                              amountFuture:
                                  _loadVillageAmountSummary(villageName),
                            );
                          },
                        )
                      : SearchNoData();
                },
              )
            ],
          ),
        ),
      ),
      floatingActionButton: null,
      floatingActionButtonLocation: null,
    );
  }

  void _showCreateVillageDialog(VillageProvider villageProvider) {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            children: <Widget>[
              PopUpBox(
                hintText: "Enter Village Name",
                labelText: "Create New Village",
                btnText: "CREATE",
                bthFunction: (text) async {
                  final name = text.trim();
                  if (name.isEmpty) {
                    _showVillageMessage('Village name is required');
                    return;
                  }
                  if (await _isVillageNameTaken(name)) {
                    _showVillageMessage('Village already exists');
                    return;
                  }
                  villageProvider.editControllerName.text = name;
                  final id = Uuid().v1();
                  final success = await villageProvider.uploadVillage(id: id);
                  if (!mounted) return;
                  final messenger = ScaffoldMessenger.of(context);
                  messenger.hideCurrentSnackBar();
                  if (success) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('$name village created'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    villageProvider.clear();
                  } else {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Failed to create village'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                context: context,
              )
            ],
          );
        });
  }

  Future<bool> _isVillageNameTaken(String name, {String? excludeId}) async {
    final snapshot = await collectionReference
        .where('ownerId', isEqualTo: requireOwnerId())
        .where('name', isEqualTo: name)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) {
      return false;
    }
    if (excludeId == null) {
      return true;
    }
    return snapshot.docs.any((doc) => doc.id != excludeId);
  }

  void _showVillageMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _onPullRefresh() async {
    _countFutureCache.clear();
    _amountFutureCache.clear();
    if (!mounted) return;
    setState(() {});
  }
}

class _VillageTile extends StatelessWidget {
  final String villageId;
  final String villageName;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Future<int> countFuture;
  final Future<_VillageAmountSummary> amountFuture;

  const _VillageTile({
    required this.villageId,
    required this.villageName,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.countFuture,
    required this.amountFuture,
  });

  String _formatAmountText(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final rs = context.rs;
    return FutureBuilder<_VillageAmountSummary>(
      future: amountFuture,
      builder: (context, snapshot) {
        final summary = snapshot.data ?? const _VillageAmountSummary.zero();

        return Slidable(
          endActionPane: ActionPane(
            extentRatio: 0.44,
            motion: const DrawerMotion(),
            children: [
              SlidableAction(
                onPressed: (_) => onEdit(),
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                icon: Icons.edit_rounded,
                label: 'Edit',
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(rs.r(14)),
                  bottomLeft: Radius.circular(rs.r(14)),
                ),
                padding: EdgeInsets.symmetric(
                    horizontal: rs.rw(12), vertical: rs.rh(8)),
              ),
              SlidableAction(
                onPressed: (_) => onDelete(),
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                icon: Icons.delete_rounded,
                label: 'Delete',
                padding: EdgeInsets.symmetric(
                    horizontal: rs.rw(12), vertical: rs.rh(8)),
              ),
            ],
          ),
          child: Card(
            elevation: 2,
            margin: EdgeInsets.symmetric(horizontal: rs.rw(16)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(rs.r(16))),
            child: ListTile(
              onTap: onTap,
              title: Text(
                villageName,
                style: TextStyle(
                  fontSize: rs.sp(16),
                  color: colorScheme.onSurface,
                  fontFamily: "TamilArima",
                ),
              ),
              subtitle: Container(
                margin: EdgeInsets.only(top: rs.rh(6)),
                padding: EdgeInsets.symmetric(
                    horizontal: rs.rw(10), vertical: rs.rh(4)),
                decoration: BoxDecoration(
                  color: summary.value > 0
                      ? Colors.blue.shade50
                      : Colors.green.shade100,
                  border: Border.all(
                    color: summary.value > 0
                        ? Colors.blue.shade50
                        : Colors.green.shade50,
                  ),
                  borderRadius: BorderRadius.circular(rs.r(16)),
                ),
                child: Text(
                  '${summary.labelText}: Rs.${_formatAmountText(summary.value)}',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    fontSize: rs.sp(11),
                    fontFamily: 'TamilArima2',
                  ),
                ),
              ),
              trailing: FutureBuilder<int>(
                future: countFuture,
                builder: (context, snapshot) {
                  final count = snapshot.data ?? 0;
                  return Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: rs.rw(12), vertical: rs.rh(6)),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(rs.r(20)),
                    ),
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: rs.sp(12),
                        fontFamily: "Lobster",
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _VillageAmountSummary {
  final double pending;
  final double balance;

  const _VillageAmountSummary({required this.pending, required this.balance});
  const _VillageAmountSummary.zero()
      : pending = 0,
        balance = 0;

  bool get hasPending => pending > 0;
  bool get hasBalance => balance > 0;

  double get value {
    if (hasPending) return pending;
    if (hasBalance) return balance;
    return 0;
  }

  String get labelText {
    if (hasPending) return 'மொத்த நிலுவை';
    if (hasBalance) return 'மொத்த கொடுமதி';
    return 'மொத்த நிலுவை';
  }
}
