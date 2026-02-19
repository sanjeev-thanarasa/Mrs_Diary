// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

class TodayPaymentUsers extends StatefulWidget {
  @override
  _TodayPaymentUsersState createState() => _TodayPaymentUsersState();
}

class _TodayPaymentUsersState extends State<TodayPaymentUsers> {
  String searchText = '';
  int _radioValue = 0;
  bool searchVisible = false;
  late DateTime _dateTodayStart;
  late DateTime _dateTodayEnd;
  String formattedDateStart =
      "${DateFormat('yyyyMMdd').format(DateTime.now())}T000000";
  String formattedDateEnd =
      "${DateFormat('yyyyMMdd').format(DateTime.now())}T235959";
  late CollectionReference paymentRecords;
  late CollectionReference oldUser;
  final ScrollController _controller = ScrollController();

  final List<_UserEntry> _entries = [];
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
    _dateTodayStart = DateTime.parse(formattedDateStart);
    _dateTodayEnd = DateTime.parse(formattedDateEnd);
    paymentRecords = FirebaseFirestore.instance.collection("PaymentRecords");
    oldUser = FirebaseFirestore.instance.collection("OldUser");

    _controller.addListener(_onScroll);
    _fetchInitial();

    print(formattedDateStart +
        "Started Date >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    print(formattedDateEnd +
        "Ended Date >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");

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
      _lastPaymentDoc = null;
    });

    final ownerId = requireOwnerId();
    final query = paymentRecords
        .where('ownerId', isEqualTo: ownerId)
        .where("PENDING_DATE", isGreaterThanOrEqualTo: _dateTodayStart)
        .where("PENDING_DATE", isLessThanOrEqualTo: _dateTodayEnd)
        .orderBy("PENDING_DATE")
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
        .where("PENDING_DATE", isGreaterThanOrEqualTo: _dateTodayStart)
        .where("PENDING_DATE", isLessThanOrEqualTo: _dateTodayEnd)
        .orderBy("PENDING_DATE")
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
      _lastPaymentDoc = null;
    });

    final ownerId = requireOwnerId();
    final query = paymentRecords
        .where('ownerId', isEqualTo: ownerId)
        .where("PENDING_DATE", isGreaterThanOrEqualTo: _dateTodayStart)
        .where("PENDING_DATE", isLessThanOrEqualTo: _dateTodayEnd)
        .orderBy("PENDING_DATE");

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

    final ids = paymentDocs
        .map((doc) => (doc.data() as Map<String, dynamic>)["USER_ID"])
        .whereType<String>()
        .toSet()
        .toList();

    final userMap = await _fetchUsersByIds(ids);

    for (final payment in paymentDocs) {
      final paymentData = payment.data() as Map<String, dynamic>;
      final userId = paymentData["USER_ID"];
      final userDoc = userId is String ? userMap[userId] : null;
      if (userDoc != null) {
        _entries.add(_UserEntry(
          userDoc,
          pendingAmount: paymentData["PENDING_AMOUNT"],
          collectionName: "OldUser",
        ));
      }
    }
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

  /// _dateTime = DateTime.parse('20210205T000000'); this is a timestamp format

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white.withValues(alpha: .9),
      appBar: CustomAppBar(
        trailing: Container(),
        hintText: "இன்று பணம் தர வேண்டியவர்கள்",
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
                      _buildRadio(value: 4, name: "Village"),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: _buildTodayPendingTotalCard(),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onPullRefresh,
              child: _isLoading || _isSearchLoading
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 180),
                        Center(child: LoadingCircle()),
                      ],
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
          amountLabel: 'தருமதி',
          amountValue: showResults[index].pendingAmount,
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

  Widget _buildTodayPendingTotalCard() {
    return StreamBuilder<QuerySnapshot<Object?>>(
      stream: paymentRecords
          .where('ownerId', isEqualTo: requireOwnerId())
          .where('PENDING_DATE', isGreaterThanOrEqualTo: _dateTodayStart)
          .where('PENDING_DATE', isLessThanOrEqualTo: _dateTodayEnd)
          .orderBy('PENDING_DATE')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        double totalPending = 0;
        for (final doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          totalPending += _parseAmount(data['PENDING_AMOUNT']);
        }

        final amountText = _formatAmountText(totalPending);
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
                    'இன்று பெற வேண்டிய தொகை',
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
  final dynamic pendingAmount;
  final String collectionName;

  _UserEntry(this.user, {this.pendingAmount, required this.collectionName});
}
