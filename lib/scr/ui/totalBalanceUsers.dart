// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/owner_service.dart';
import 'package:mrs_dth_diary_v1/scr/models/totalCustomers.dart';
import 'package:mrs_dth_diary_v1/scr/ui/userDetails.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CAppBar.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/customText.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/loading.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/noResultFound.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/userDetailsTile.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/screen_navigation.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';

class TotalBalanceUsers extends StatefulWidget {
  @override
  _TotalBalanceUsersState createState() => _TotalBalanceUsersState();
}

class _TotalBalanceUsersState extends State<TotalBalanceUsers> {
  String searchText = '';
  int _radioValue = 0;
  bool searchVisible = false;
  late CollectionReference paymentRecords;
  late CollectionReference oldUser;
  final ScrollController _controller = ScrollController();

  final List<_UserEntry> _entries = [];
  final Set<String> _seenUserIds = {};
  QueryDocumentSnapshot<Object?>? _lastPaymentDoc;
  bool _isLoading = true;
  bool _isSearchLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  final int _pageSize = 50;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    paymentRecords = FirebaseFirestore.instance.collection("PaymentRecords");
    oldUser = FirebaseFirestore.instance.collection("OldUser");
    _controller.addListener(_onScroll);
    _fetchInitial();
    super.initState();
  }

  void _onScroll() {
    if (searchText.trim().isNotEmpty) return;
    if (_controller.position.pixels >=
            _controller.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _fetchMore();
    }
  }

  Future<void> _fetchInitial() async {
    setState(() {
      _isLoading = true;
      _hasMore = true;
      _entries.clear();
      _seenUserIds.clear();
      _lastPaymentDoc = null;
    });

    final ownerId = requireOwnerId();
    final query = paymentRecords
        .where('ownerId', isEqualTo: ownerId)
        .where("BALANCE_AMOUNT", isNotEqualTo: "")
        .orderBy("BALANCE_AMOUNT")
        .limit(_pageSize);

    final snapshot = await query.get();
    if (!mounted) return;

    await _appendEntries(snapshot.docs);
    _lastPaymentDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
    _hasMore = snapshot.docs.length == _pageSize;

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchMore() async {
    if (_lastPaymentDoc == null) return;
    setState(() {
      _isLoadingMore = true;
    });

    final ownerId = requireOwnerId();
    final query = paymentRecords
        .where('ownerId', isEqualTo: ownerId)
        .where("BALANCE_AMOUNT", isNotEqualTo: "")
        .orderBy("BALANCE_AMOUNT")
        .startAfterDocument(_lastPaymentDoc!)
        .limit(_pageSize);

    final snapshot = await query.get();
    if (!mounted) return;

    await _appendEntries(snapshot.docs);
    if (snapshot.docs.isNotEmpty) {
      _lastPaymentDoc = snapshot.docs.last;
    }
    _hasMore = snapshot.docs.length == _pageSize;

    setState(() {
      _isLoadingMore = false;
    });
  }

  Future<void> _fetchAllForSearch() async {
    if (_isSearchLoading || !_hasMore) return;

    setState(() {
      _isSearchLoading = true;
      _entries.clear();
      _seenUserIds.clear();
      _lastPaymentDoc = null;
    });

    final ownerId = requireOwnerId();
    final query = paymentRecords
        .where('ownerId', isEqualTo: ownerId)
        .where("BALANCE_AMOUNT", isNotEqualTo: "")
        .orderBy("BALANCE_AMOUNT");

    final snapshot = await query.get();
    if (!mounted) return;

    await _appendEntries(snapshot.docs);
    _lastPaymentDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
    _hasMore = false;

    setState(() {
      _isSearchLoading = false;
    });
  }

  Future<void> _appendEntries(
      List<QueryDocumentSnapshot<Object?>> paymentDocs) async {
    if (paymentDocs.isEmpty) return;

    final List<String> orderedUserIds = [];

    for (final payment in paymentDocs) {
      final paymentData = payment.data() as Map<String, dynamic>;
      final userId = paymentData["USER_ID"];
      if (userId is! String) {
        continue;
      }
      if (!orderedUserIds.contains(userId)) {
        orderedUserIds.add(userId);
      }
    }

    final userMap = await _fetchUsersByIds(orderedUserIds);
    final balanceTotals = await _fetchBalanceTotalsByUserIds(orderedUserIds);

    for (final userId in orderedUserIds) {
      if (_seenUserIds.contains(userId)) {
        continue;
      }
      final userDoc = userMap[userId];
      if (userDoc != null) {
        _seenUserIds.add(userId);
        _entries.add(_UserEntry(
          userDoc,
          balanceAmount: balanceTotals[userId] ?? 0,
          collectionName: "OldUser",
        ));
      }
    }
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

  Widget _buildBalanceTotalCard() {
    return StreamBuilder<QuerySnapshot<Object?>>(
      stream: paymentRecords
          .where('ownerId', isEqualTo: requireOwnerId())
          .where('BALANCE_AMOUNT', isNotEqualTo: '')
          .orderBy('BALANCE_AMOUNT')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        double totalBalance = 0;
        for (final doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          totalBalance += _parseAmount(data['BALANCE_AMOUNT']);
        }

        final amountText = _formatAmountText(totalBalance);
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
                const Expanded(
                  child: Text(
                    'மொத்த கொடுமதி',
                    style: TextStyle(
                      fontFamily: 'TamilArima',
                      fontWeight: FontWeight.w700,
                      color: kIndigoDark,
                    ),
                  ),
                ),
                Text(
                  'Rs.$amountText',
                  style: const TextStyle(
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

  Future<Map<String, double>> _fetchBalanceTotalsByUserIds(
      List<String> ids) async {
    final Map<String, double> totals = {};
    if (ids.isEmpty) return totals;
    final ownerId = requireOwnerId();
    const chunkSize = 10;
    for (var i = 0; i < ids.length; i += chunkSize) {
      final chunk = ids.sublist(
          i, i + chunkSize > ids.length ? ids.length : i + chunkSize);
      final snapshot = await paymentRecords
          .where('ownerId', isEqualTo: ownerId)
          .where('USER_ID', whereIn: chunk)
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final userId = data['USER_ID'];
        if (userId is! String) {
          continue;
        }
        totals[userId] =
            (totals[userId] ?? 0) + _parseAmount(data['BALANCE_AMOUNT']);
      }
    }
    return totals;
  }

  Future<Map<String, QueryDocumentSnapshot<Object?>>> _fetchUsersByIds(
      List<String> ids) async {
    final Map<String, QueryDocumentSnapshot<Object?>> result = {};
    final ownerId = requireOwnerId();
    const chunkSize = 10;
    for (var i = 0; i < ids.length; i += chunkSize) {
      final chunk = ids.sublist(
          i, i + chunkSize > ids.length ? ids.length : i + chunkSize);
      final snapshot = await oldUser
          .where('ownerId', isEqualTo: ownerId)
          .where('id', whereIn: chunk)
          .get();
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final id = data['id'];
        if (id is String) {
          result[id] = doc;
        }
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white.withValues(alpha: .9),
      appBar: CustomAppBar(
        hintText: "கொடுமதிகள்",
        prefixIcon: Icons.arrow_back,
        iconOnTap: () => Navigator.pop(context),
        onChanged: (text) => _onSearchChanged(text),
        logoOnTap: () => setState(() {
          searchVisible = !searchVisible;
          if (!searchVisible) {
            _radioValue = 0;
          }
        }),
      ),
      body: Column(
        children: [
          Visibility(
            visible: searchVisible,
            child: Padding(
              padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildRadio(value: 0, name: "Name"),
                      _buildRadio(value: 1, name: "DishNumber"),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildRadio(value: 2, name: "Mobile No"),
                      _buildRadio(value: 3, name: "Dish Type"),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildRadio(value: 3, name: "Village"),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: _buildBalanceTotalCard(),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onPullRefresh,
              child: _isLoading || _isSearchLoading
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [LoadingShimmerList()],
                    )
                  : _buildList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    final showResults = _searchResultsList(_entries);
    if (showResults.isEmpty) {
      return SearchNoData();
    }

    return ListView.builder(
      controller: _controller,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: showResults.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (_, index) {
        if (index >= showResults.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: LoadingCircle(),
          );
        }
        final entry = showResults[index];
        final data = entry.user;
        return UserDetailsTile(
          name: data['name'],
          dishNumber: data['dishNumber'],
          mobileNo: data['mobileNo'],
          villageName: data['area'],
          userId: data['id'] ?? data.id,
          collectionName: showResults[index].collectionName,
          amountLabel: 'கொடுமதி',
          amountValue: showResults[index].balanceAmount,
          onTap: () {
            changeScreenAnimated(
                context,
                UserDetails(
                  collectionName: showResults[index].collectionName,
                  userId: data.id,
                ));
          },
        );
      },
    );
  }

  Widget _buildRadio({required int value, required String name}) {
    return Row(
      children: [
        Radio(
          value: value,
          activeColor: Colors.blue,
          groupValue: _radioValue,
          onChanged: _handleRadioValueChange,
        ),
        CText(
          msg: name,
          color: Colors.black,
          size: 20.0,
        ),
      ],
    );
  }

  Future<void> _onPullRefresh() async {
    await _fetchInitial();
  }

  void _handleRadioValueChange(int? value) {
    if (value == null) return;
    setState(() {
      _radioValue = value;
    });
  }

  _onSearchChanged(String text) {
    final trimmed = text.trim();
    setState(() {
      searchText = trimmed;
      print(searchText);
    });

    if (trimmed.isEmpty) {
      if (!_hasMore || _entries.length > _pageSize) {
        _fetchInitial();
      }
      return;
    }

    _fetchAllForSearch();
    print(searchText);
  }

  _searchResultsList(List<_UserEntry> entries) {
    var showResults = [];

    if (searchText != "") {
      final effectiveRadioValue = searchVisible ? _radioValue : 0;
      for (var entry in entries) {
        final snapshot = entry.user;
        var title;
        switch (effectiveRadioValue) {
          case 0:
            {
              title = TotalCustomersFilterize.fromSnapshot(snapshot)
                  .name
                  .toLowerCase();
            }
            break;
          case 1:
            {
              title = TotalCustomersFilterize.fromSnapshot(snapshot)
                  .dishNumber
                  .toLowerCase();
            }
            break;
          case 2:
            {
              title = TotalCustomersFilterize.fromSnapshot(snapshot)
                  .mobileNo
                  .toLowerCase();
            }
            break;
          case 3:
            {
              title = TotalCustomersFilterize.fromSnapshot(snapshot)
                  .dishType
                  .toLowerCase();
            }
            break;
          case 4:
            {
              title = TotalCustomersFilterize.fromSnapshot(snapshot)
                  .villageName
                  .toLowerCase();
            }
            break;
          default:
            {
              _radioValue = 0;
            }
            break;
        }

        if (title.contains(searchText.toLowerCase())) {
          showResults.add(entry);
        }
      }
    } else {
      showResults = List.from(entries);
    }
    return showResults;
  }
}

class _UserEntry {
  final QueryDocumentSnapshot<Object?> user;
  final dynamic balanceAmount;
  final String collectionName;

  _UserEntry(this.user, {this.balanceAmount, required this.collectionName});
}
