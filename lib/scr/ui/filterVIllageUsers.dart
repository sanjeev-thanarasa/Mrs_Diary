// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/owner_service.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mrs_dth_diary_v1/scr/models/filterUser.dart';
import 'package:mrs_dth_diary_v1/scr/ui/editUserDetail.dart';
import 'package:mrs_dth_diary_v1/scr/ui/userDetails.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CAppBar.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/customText.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/loading.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/noResultFound.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/userDetailsTile.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/screen_navigation.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/responsive.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';

class FilterVillageUser extends StatefulWidget {
  final String villageName;

  const FilterVillageUser({super.key, required this.villageName});
  @override
  _FilterVillageUserState createState() => _FilterVillageUserState();
}

class _FilterVillageUserState extends State<FilterVillageUser> {
  String searchText = '';
  int _radioValue = 0;
  bool searchVisible = false;
  int _paymentFilterValue = 0;
  bool _isStatusLoading = false;
  final Map<String, _UserPaymentStatus> _statusCache = {};
  ScrollController _controller = ScrollController();
  String counter = "0";
  Future<_VillageAmountSummary>? _amountSummaryFuture;
  Widget pushMe = Image.asset(
    "assets/images/push.png",
    height: 50,
    width: 50,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _amountSummaryFuture = _fetchVillageAmountSummary();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white.withValues(alpha: .9),
      appBar: CustomAppBar(
        hintText: widget.villageName,
        prefixIcon: Icons.arrow_back,
        iconOnTap: () => Navigator.pop(context),
        onChanged: (text) => _onSearchChanged(text),
        trailing: IconButton(
          icon: const Icon(Icons.filter_list_rounded, color: kPrimaryColor),
          onPressed: () => setState(() {
            searchVisible = !searchVisible;
            if (!searchVisible) {
              _radioValue = 0;
              _paymentFilterValue = 0;
            }
          }),
        ),
        logoOnTap: () => setState(() {
          searchVisible = !searchVisible;
          if (!searchVisible) {
            _radioValue = 0;
            _paymentFilterValue = 0;
          }
        }),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: _buildVillagePendingCard(),
            ),
            Visibility(
              visible: searchVisible,
              child: Expanded(
                  flex: 0,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                    child: Column(
                      children: [
                        _buildSearchFilterChips(),
                        const SizedBox(height: 10),
                        _buildPaymentFilterChips(),
                        if (_isStatusLoading)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                      ],
                    ),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _oldUsersStream(),
                builder: (context, oldSnapshot) {
                  if (oldSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: LoadingCircle());
                  }

                  final oldDocs = oldSnapshot.data?.docs ?? [];

                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _newUsersStream(),
                    builder: (context, newSnapshot) {
                      if (newSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: LoadingCircle());
                      }

                      final newDocs = newSnapshot.data?.docs ?? [];
                      final allDocs = [...oldDocs, ...newDocs];
                      if (_paymentFilterValue != 0) {
                        _ensureStatusCache(allDocs);
                      }
                      final showResults = _searchResultsList(allDocs);

                      return showResults.isNotEmpty
                          ? ListView.builder(
                              scrollDirection: Axis.vertical,
                              controller: _controller,
                              shrinkWrap: true,
                              itemCount: showResults.length,
                              itemBuilder: (_, index) {
                                final data = showResults[index];
                                final collectionName = data.reference.parent.id;
                                return UserDetailsTile(
                                  name: data['name'] ?? '',
                                  dishNumber: data['dishNumber'] ?? '',
                                  mobileNo: data['mobileNo'] ?? '',
                                  villageName: data['area'] ?? '',
                                  userId: data['id'] ?? data.id,
                                  collectionName: collectionName,
                                  onTap: () {
                                    changeScreenAnimated(
                                        context,
                                        UserDetails(
                                          collectionName: collectionName,
                                          userId: data.id,
                                        ));
                                  },
                                );
                              })
                          : SearchNoData();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.red,
      //   shape: _CustomBorder(),
      //   child: pushMe,
      //   onPressed: () {
      //     setState(() {
      //       pushMe = CText(
      //         size: 20.0,
      //         color: Colors.white,
      //         msg: counter,
      //       );
      //     });
      //   },
      // ),
    );
  }

  Widget _buildSearchFilterChips() {
    final rs = context.rs;
    return SizedBox(
      height: rs.rh(54),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildSearchChip(value: 0, label: 'பெயர்'),
            SizedBox(width: rs.rw(10)),
            _buildSearchChip(value: 1, label: 'டிஷ் நம்பர்'),
            SizedBox(width: rs.rw(10)),
            _buildSearchChip(value: 2, label: 'மொபைல்'),
            SizedBox(width: rs.rw(10)),
            _buildSearchChip(value: 3, label: 'டிஷ் வகை'),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchChip({required int value, required String label}) {
    return _buildFilterChip(
      label: label,
      selected: _radioValue == value,
      onSelected: () => _handleRadioValueChange(value),
    );
  }

  Widget _buildPaymentFilterChips() {
    final rs = context.rs;
    return SizedBox(
      height: rs.rh(50),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              label: 'தருமதி',
              selected: _paymentFilterValue == 1,
              onSelected: () => setState(() {
                _paymentFilterValue = _paymentFilterValue == 1 ? 0 : 1;
              }),
            ),
            SizedBox(width: rs.rw(10)),
            _buildFilterChip(
              label: 'கொடுமதி',
              selected: _paymentFilterValue == 2,
              onSelected: () => setState(() {
                _paymentFilterValue = _paymentFilterValue == 2 ? 0 : 2;
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    final rs = context.rs;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontFamily: selected ? 'TamilArima2' : 'TamilArima',
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: Colors.black87,
          fontSize: rs.sp(13),
        ),
      ),
      selected: selected,
      selectedColor: kPrimaryColor.withValues(alpha: 0.18),
      backgroundColor: Colors.white,
      side: BorderSide(
        color: selected ? kPrimaryColor.withValues(alpha: 0.5) : Colors.black12,
        width: 1,
      ),
      onSelected: (_) => onSelected(),
      padding: EdgeInsets.symmetric(horizontal: rs.rw(14), vertical: rs.rh(8)),
      labelPadding: EdgeInsets.symmetric(
        horizontal: rs.rw(6),
        vertical: rs.rh(3),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  void _handleRadioValueChange(int value) {
    setState(() {
      _radioValue = value;
    });
  }

  _onSearchChanged(String text) {
    setState(() {
      searchText = text;
      print(searchText);
    });
    // searchResultsList();
    print(searchText);
  }

  _searchResultsList(var snapshots) {
    counter = snapshots.length.toString();
    var showResults = [];
    if (searchText != "") {
      final effectiveRadioValue = searchVisible ? _radioValue : 0;
      for (var snapshot in snapshots) {
        var title;
        switch (effectiveRadioValue) {
          case 0:
            {
              title = FilterUser.fromSnapshot(snapshot).name.toLowerCase();
            }
            break;
          case 1:
            {
              title =
                  FilterUser.fromSnapshot(snapshot).dishNumber.toLowerCase();
            }
            break;
          case 2:
            {
              title = FilterUser.fromSnapshot(snapshot).mobileNo.toLowerCase();
            }
            break;
          case 3:
            {
              title = FilterUser.fromSnapshot(snapshot).dishType.toLowerCase();
            }
            break;
          default:
            {
              _radioValue = 0;
            }
            break;
        }

        if (title.contains(searchText.toLowerCase())) {
          showResults.add(snapshot);
        }
      }
    } else {
      showResults = List.from(snapshots);
    }

    if (_paymentFilterValue != 0 &&
        !(_isStatusLoading && _statusCache.isEmpty)) {
      showResults = showResults.where((snapshot) {
        final userId = _resolveUserId(snapshot);
        final status = _statusCache[userId];
        if (status == null) return false;
        if (_paymentFilterValue == 1) return status.hasPending;
        if (_paymentFilterValue == 2) return status.hasBalance;
        return true;
      }).toList();
    }
    return showResults;
  }

  String _resolveUserId(QueryDocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    final id = data['id'] ?? snapshot.id;
    return id.toString();
  }

  Future<void> _ensureStatusCache(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> snapshots) async {
    if (_isStatusLoading) return;
    final missing = <String>{};
    for (final doc in snapshots) {
      final userId = _resolveUserId(doc);
      if (!_statusCache.containsKey(userId)) {
        missing.add(userId);
      }
    }
    if (missing.isEmpty) return;

    setState(() => _isStatusLoading = true);
    try {
      final result = await _fetchUserStatusMap(missing);
      setState(() {
        _statusCache.addAll(result);
        _isStatusLoading = false;
      });
    } catch (_) {
      setState(() => _isStatusLoading = false);
    }
  }

  Future<Map<String, _UserPaymentStatus>> _fetchUserStatusMap(
      Set<String> userIds) async {
    final firestore = FirebaseFirestore.instance;
    final ownerId = requireOwnerId();
    final statusMap = <String, _UserPaymentStatus>{};
    const chunkSize = 10;
    final queryIds = <dynamic>[];
    for (final id in userIds) {
      queryIds.add(id);
      final parsed = int.tryParse(id);
      if (parsed != null) {
        queryIds.add(parsed);
      }
    }

    for (var i = 0; i < queryIds.length; i += chunkSize) {
      final chunk = queryIds.sublist(
        i,
        i + chunkSize > queryIds.length ? queryIds.length : i + chunkSize,
      );
      final paymentSnapshot = await firestore
          .collection('PaymentRecords')
          .where('ownerId', isEqualTo: ownerId)
          .where('USER_ID', whereIn: chunk)
          .get();

      for (final doc in paymentSnapshot.docs) {
        final data = doc.data();
        final userId = data['USER_ID']?.toString();
        if (userId == null || userId.trim().isEmpty) continue;
        final pending = _parseAmount(data['PENDING_AMOUNT']);
        final balance = _parseAmount(data['BALANCE_AMOUNT']);
        final current = statusMap[userId] ?? const _UserPaymentStatus.zero();
        statusMap[userId] = _UserPaymentStatus(
          pending: current.pending + pending,
          balance: current.balance + balance,
        );
      }
    }

    return statusMap;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _oldUsersStream() {
    return FirebaseFirestore.instance
        .collection("OldUser")
        .where('ownerId', isEqualTo: requireOwnerId())
        .where('area', isEqualTo: widget.villageName.trim())
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _newUsersStream() {
    return FirebaseFirestore.instance
        .collection("NewUser")
        .where('ownerId', isEqualTo: requireOwnerId())
        .where('area', isEqualTo: widget.villageName.trim())
        .snapshots();
  }

  Widget _buildVillagePendingCard() {
    return FutureBuilder<_VillageAmountSummary>(
      future: _amountSummaryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            elevation: 1.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: const [
                  Icon(Icons.account_balance_wallet_rounded,
                      color: kPrimaryColor),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'மொத்த தருமதி',
                      style: TextStyle(
                        fontFamily: 'TamilArima2',
                        color: kIndigoDark,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(kPrimaryColor),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final summary = snapshot.data ?? const _VillageAmountSummary.zero();
        final amountText = _formatAmountText(summary.value);
        return Card(
          elevation: 1.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet_rounded,
                    color: kPrimaryColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.villageName,
                        style: const TextStyle(
                          fontFamily: 'TamilArima',
                          fontWeight: FontWeight.w700,
                          color: kIndigoDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        summary.labelText,
                        style: const TextStyle(
                          fontFamily: 'TamilArima2',
                          color: kIndigoDark,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Rs.$amountText',
                  style: TextStyle(
                    fontFamily: 'TamilArima2',
                    fontWeight: FontWeight.w700,
                    color: kPrimaryColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<_VillageAmountSummary> _fetchVillageAmountSummary() async {
    final firestore = FirebaseFirestore.instance;
    final ownerId = requireOwnerId();
    final normalized = widget.villageName.trim();

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

  String _formatAmountText(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  Future<void> _confirmDelete(
    BuildContext context, {
    required String userId,
    required String collectionName,
    required String name,
  }) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete user?',
          style: TextStyle(fontFamily: 'TamilArima'),
        ),
        content: Text(
          name.isEmpty
              ? 'Are you sure you want to delete this user?'
              : 'Delete $name from $collectionName?',
          style: const TextStyle(fontFamily: 'TamilArima2'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;
    await FirebaseFirestore.instance
        .collection(collectionName)
        .doc(userId)
        .delete();
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
    if (hasPending) return 'மொத்த தருமதி';
    if (hasBalance) return 'மொத்த கொடுமதி';
    return 'மொத்த தருமதி';
  }
}

class _UserPaymentStatus {
  final double pending;
  final double balance;

  const _UserPaymentStatus({required this.pending, required this.balance});
  const _UserPaymentStatus.zero()
      : pending = 0,
        balance = 0;

  bool get hasPending => pending > 0;
  bool get hasBalance => balance > 0;
}
