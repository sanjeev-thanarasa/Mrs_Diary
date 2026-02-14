import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/owner_service.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/operations.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CAppBar.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CustomStreamBuilder.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/noResultFound.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/responsive.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';
import 'package:uuid/uuid.dart';

class DishTypesPage extends StatefulWidget {
  const DishTypesPage({super.key});

  @override
  State<DishTypesPage> createState() => _DishTypesPageState();
}

class _DishTypesPageState extends State<DishTypesPage> {
  final ScrollController _controller = ScrollController();
  late final CollectionReference collectionReference;
  String searchText = '';
  final List<String> _defaultDishTypes = const [
    'sun',
    'dish tv',
    'videocon',
    'airtel',
    'dialog',
    'tata sky',
  ];

  @override
  void initState() {
    collectionReference = FirebaseFirestore.instance.collection('DishTypes');
    super.initState();
    _ensureDefaultDishTypes();
  }

  Future<void> _ensureDefaultDishTypes() async {
    final ownerId = requireOwnerId();
    if (ownerId.isEmpty) return;

    final existing = await collectionReference
        .where('ownerId', isEqualTo: ownerId)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) return;

    final batch = FirebaseFirestore.instance.batch();
    for (final name in _defaultDishTypes) {
      final id = const Uuid().v1();
      batch.set(collectionReference.doc(id), {
        'id': id,
        'ownerId': ownerId,
        'name': name,
        'createAt': DateTime.now(),
      });
    }
    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    return Scaffold(
      backgroundColor: Colors.white.withValues(alpha: 0.9),
      appBar: CustomAppBar(
        prefixIcon: Icons.arrow_back,
        trailing: InkWell(
          onTap: _showCreateDishTypeDialog,
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
        hintText: 'Dish types',
      ),
      body: RefreshIndicator(
        onRefresh: _onPullRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: rs.rh(15)),
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
                          final name = (doc.data()['name'] ?? '')
                              .toString()
                              .toLowerCase();
                          return name.contains(query);
                        }).toList();

                  filtered.sort((a, b) {
                    final aName =
                        (a.data()['name'] ?? '').toString().toLowerCase();
                    final bName =
                        (b.data()['name'] ?? '').toString().toLowerCase();
                    return aName.compareTo(bName);
                  });

                  return filtered.isNotEmpty
                      ? ListView.separated(
                          scrollDirection: Axis.vertical,
                          controller: _controller,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              SizedBox(height: rs.rh(4)),
                          itemBuilder: (_, index) {
                            final data = filtered[index];
                            final dishName = data['name'] ?? '';
                            final dishId = data.id;
                            return _DishTypeTile(
                              dishId: dishId,
                              dishName: dishName,
                              onEdit: () => _showEditDialog(
                                dishId: dishId,
                                currentName: dishName,
                              ),
                              onDelete: () => _confirmDelete(dishId, dishName),
                            );
                          },
                        )
                      : const SearchNoData();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onPullRefresh() async {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _showCreateDishTypeDialog() async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create dish type'),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.black),
          decoration: const InputDecoration(
            labelText: 'Dish type',
            hintText: 'Enter dish type',
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
                _showDishTypeMessage('Dish type is required');
                return;
              }
              if (await _isDishTypeNameTaken(name)) {
                _showDishTypeMessage('Dish type already exists');
                return;
              }
              final id = const Uuid().v1();
              await collectionReference.doc(id).set({
                'id': id,
                'ownerId': requireOwnerId(),
                'name': name,
                'createAt': DateTime.now(),
              });
              if (mounted) {
                Navigator.pop(context);
                showSnackbar(
                  'Dish type created',
                  'Dish type has been successfully created',
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog({
    required String dishId,
    required String currentName,
  }) async {
    final hasUsers = await _checkDishTypeHasUsers(currentName);
    if (hasUsers) {
      if (mounted) {
        await _showInUseAlert('Cannot edit dish type');
      }
      return;
    }

    final controller = TextEditingController(text: currentName);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit dish type'),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.black),
          decoration: const InputDecoration(
            labelText: 'Dish type',
            hintText: 'Enter dish type',
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
                _showDishTypeMessage('Dish type is required');
                return;
              }
              if (name == currentName) {
                if (mounted) {
                  Navigator.pop(context);
                }
                return;
              }
              if (await _isDishTypeNameTaken(name, excludeId: dishId)) {
                _showDishTypeMessage('Dish type already exists');
                return;
              }
              await updateProduct(
                collectionName: 'DishTypes',
                id: dishId,
                updateData: {'name': name},
              );
              if (mounted) {
                Navigator.pop(context);
                showSnackbar(
                  'Dish type updated',
                  'Dish type has been successfully updated',
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(String dishId, String dishName) async {
    final hasUsers = await _checkDishTypeHasUsers(dishName);

    if (hasUsers) {
      if (mounted) {
        await _showInUseAlert('Cannot delete dish type');
      }
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete dish type'),
        content: const Text('Do you want to delete this dish type?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await deleteProduct(
                id: dishId,
                collectionName: 'DishTypes',
              );
              if (mounted) {
                Navigator.pop(context);
                showSnackbar(
                  'Dish type deleted',
                  'Dish type has been successfully deleted',
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<bool> _checkDishTypeHasUsers(String dishType) async {
    final firestore = FirebaseFirestore.instance;
    final ownerId = requireOwnerId();
    final normalized = dishType.trim();

    final oldUsersQuery = await firestore
        .collection('OldUser')
        .where('ownerId', isEqualTo: ownerId)
        .where('dishType', isEqualTo: normalized)
        .limit(1)
        .get();

    if (oldUsersQuery.docs.isNotEmpty) {
      return true;
    }

    final newUsersQuery = await firestore
        .collection('NewUser')
        .where('ownerId', isEqualTo: ownerId)
        .where('dishType', isEqualTo: normalized)
        .limit(1)
        .get();

    return newUsersQuery.docs.isNotEmpty;
  }

  Future<bool> _isDishTypeNameTaken(String name, {String? excludeId}) async {
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

  Future<void> _showInUseAlert(String title) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'TamilArima',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'This dish type has users. Please delete all users from this dish type first, then you can edit or delete it.',
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

  void _showDishTypeMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

class _DishTypeTile extends StatelessWidget {
  final String dishId;
  final String dishName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DishTypeTile({
    required this.dishId,
    required this.dishName,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final rs = context.rs;
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
            padding:
                EdgeInsets.symmetric(horizontal: rs.rw(12), vertical: rs.rh(8)),
          ),
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: Colors.red.shade600,
            foregroundColor: Colors.white,
            icon: Icons.delete_rounded,
            label: 'Delete',
            padding:
                EdgeInsets.symmetric(horizontal: rs.rw(12), vertical: rs.rh(8)),
          ),
        ],
      ),
      child: Card(
        elevation: 2,
        margin: EdgeInsets.symmetric(horizontal: rs.rw(16)),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(rs.r(16))),
        child: ListTile(
          title: Text(
            dishName,
            style: TextStyle(
              fontSize: rs.sp(16),
              color: colorScheme.onSurface,
              fontFamily: 'TamilArima',
            ),
          ),
          trailing: Container(
            padding: EdgeInsets.symmetric(
              horizontal: rs.rw(10),
              vertical: rs.rh(4),
            ),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(rs.r(20)),
            ),
            child: Text(
              'Type',
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: rs.sp(11),
                fontFamily: 'TamilArima2',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
