import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/operations.dart';
import 'package:mrs_dth_diary_v1/scr/providers/village.dart';
import 'package:mrs_dth_diary_v1/scr/ui/filterVIllageUsers.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CAppBar.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CustomStreamBuilder.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/ShowPopUpAlertBox.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/noResultFound.dart';
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

  Future<int> _fetchVillageUserCount(String villageName) async {
    final firestore = FirebaseFirestore.instance;
    final oldUserCount = await firestore
        .collection("OldUser")
        .where("area", isEqualTo: villageName)
        .count()
        .get();
    final newUserCount = await firestore
        .collection("NewUser")
        .where("area", isEqualTo: villageName)
        .count()
        .get();

    return (oldUserCount.count ?? 0) + (newUserCount.count ?? 0);
  }

  Future<void> _confirmDelete(String villageId) async {
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
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog({
    required String villageId,
    required String currentName,
  }) async {
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
    return Scaffold(
      backgroundColor: Colors.white.withValues(alpha: .9),
      appBar: CustomAppBar(
        prefixIcon: Icons.arrow_back,
        trailing: InkWell(
          onTap: () => _showCreateVillageDialog(villageProvider),
          child: Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.circular(10),
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
        onChanged: (text) => setState(() => searchText = text),
        hintText: "கிராமங்கள்",
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 15.0,
            ),
            CustomStreamBuilder(
                context: context,
                stream: searchText.isEmpty
                    ? collectionReference.snapshots()
                        as Stream<QuerySnapshot<Map<String, dynamic>>>
                    : collectionReference
                            .orderBy("name")
                            .startAt([searchText]).endAt(
                                [searchText + '\uf8ff']).snapshots()
                        as Stream<QuerySnapshot<Map<String, dynamic>>>,
                body: (snap) {
                  final docs = snap.data?.docs ?? [];
                  return docs.isNotEmpty
                      ? ListView.separated(
                          scrollDirection: Axis.vertical,
                          controller: _controller,
                          shrinkWrap: true,
                          itemCount: docs.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (_, index) {
                            final data = docs[index];
                            final villageName = data["name"] ?? "";
                            final villageId = data.id;
                            return _VillageTile(
                              villageId: villageId,
                              villageName: villageName,
                              createdAt: data["createAt"],
                              onTap: () => changeScreenAnimated(
                                context,
                                FilterVillageUser(villageName: villageName),
                              ),
                              onEdit: () => _showEditDialog(
                                villageId: villageId,
                                currentName: villageName,
                              ),
                              onDelete: () => _confirmDelete(villageId),
                              countFuture: _loadVillageUserCount(villageName),
                            );
                          },
                        )
                      : SearchNoData();
                })
          ],
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
    final snapshot =
        await collectionReference.where('name', isEqualTo: name).limit(1).get();
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
}

class _VillageTile extends StatelessWidget {
  final String villageId;
  final String villageName;
  final dynamic createdAt;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Future<int> countFuture;

  const _VillageTile({
    required this.villageId,
    required this.villageName,
    required this.createdAt,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.countFuture,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final createdText = createdAt != null
        ? DateFormat.yMMMd().add_jm().format(createdAt.toDate()).toString()
        : '';

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
              topLeft: Radius.circular(14),
              bottomLeft: Radius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: Colors.red.shade600,
            foregroundColor: Colors.white,
            icon: Icons.delete_rounded,
            label: 'Delete',
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ],
      ),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          onTap: onTap,
          title: Text(
            villageName,
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurface,
              fontFamily: "TamilArima",
            ),
          ),
          subtitle: createdText.isNotEmpty
              ? Text(
                  createdText,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                    fontFamily: "TamilArima2",
                  ),
                )
              : null,
          trailing: FutureBuilder<int>(
            future: countFuture,
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    fontFamily: "Lobster",
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
