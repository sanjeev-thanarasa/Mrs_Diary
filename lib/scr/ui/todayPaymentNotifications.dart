import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/customText.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/loading.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/noResultFound.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/responsive.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';

class TodayPaymentNotifications extends StatefulWidget {
  const TodayPaymentNotifications({super.key});

  @override
  State<TodayPaymentNotifications> createState() =>
      _TodayPaymentNotificationsState();
}

class _TodayPaymentNotificationsState extends State<TodayPaymentNotifications> {
  late DateTime _dateTodayStart;
  late DateTime _dateTodayEnd;
  String formattedDateStart =
      "${DateFormat('yyyyMMdd').format(DateTime.now())}T000000";
  String formattedDateEnd =
      "${DateFormat('yyyyMMdd').format(DateTime.now())}T235959";

  late CollectionReference paymentRecords;
  late CollectionReference oldUser;
  final ScrollController _controller = ScrollController();

  final List<_NotificationEntry> _entries = [];
  QueryDocumentSnapshot<Object?>? _lastPaymentDoc;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  final int _pageSize = 50;

  @override
  void initState() {
    _dateTodayStart = DateTime.parse(formattedDateStart);
    _dateTodayEnd = DateTime.parse(formattedDateEnd);
    paymentRecords = FirebaseFirestore.instance.collection("PaymentRecords");
    oldUser = FirebaseFirestore.instance.collection("OldUser");
    _controller.addListener(_onScroll);
    _fetchInitial();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
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

    final query = paymentRecords
        .where("PENDING_DATE", isGreaterThan: _dateTodayStart)
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

    final query = paymentRecords
        .where("PENDING_DATE", isGreaterThan: _dateTodayStart)
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
        _entries.add(_NotificationEntry(
          user: userDoc,
          paymentId: payment.id,
          payment: paymentData,
        ));
      }
    }
  }

  Future<Map<String, QueryDocumentSnapshot<Object?>>> _fetchUsersByIds(
      List<String> ids) async {
    final Map<String, QueryDocumentSnapshot<Object?>> result = {};
    const chunkSize = 10;
    for (var i = 0; i < ids.length; i += chunkSize) {
      final chunk = ids.sublist(
          i, i + chunkSize > ids.length ? ids.length : i + chunkSize);
      final snapshot = await oldUser.where('id', whereIn: chunk).get();
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
    final rs = context.rs;
    return Scaffold(
      backgroundColor: white.withValues(alpha: 0.95),
      appBar: AppBar(
        titleSpacing: 11,
        title: Text(
          "Today's payment notifications",
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const LoadingShimmerList()
          : _entries.isEmpty
              ? SearchNoData()
              : ListView.builder(
                  controller: _controller,
                  padding: EdgeInsets.fromLTRB(
                    rs.rw(12),
                    rs.rh(8),
                    rs.rw(12),
                    rs.rh(16),
                  ),
                  itemCount: _entries.length + (_isLoadingMore ? 1 : 0),
                  itemBuilder: (_, index) {
                    if (index >= _entries.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: LoadingCircle(),
                      );
                    }

                    final entry = _entries[index];
                    return Dismissible(
                      key: ValueKey(
                          "${entry.user.id}-${entry.paymentId}-$index"),
                      direction: DismissDirection.endToStart,
                      background: _DismissBackground(),
                      confirmDismiss: (_) => _confirmRemove(context),
                      onDismissed: (_) {
                        setState(() {
                          _entries.removeAt(index);
                        });
                      },
                      child: _NotificationTile(entry: entry),
                    );
                  },
                ),
    );
  }

  Future<bool?> _confirmRemove(BuildContext context) {
    return showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Remove notification?'),
        content: const Text('Do you want to remove this notification?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Remove'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }
}

class _NotificationEntry {
  final QueryDocumentSnapshot<Object?> user;
  final String paymentId;
  final Map<String, dynamic> payment;

  _NotificationEntry({
    required this.user,
    required this.paymentId,
    required this.payment,
  });
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.entry});

  final _NotificationEntry entry;

  String _field(dynamic value) {
    if (value == null) return '';
    if (value is String) return value.trim();
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    final user = entry.user;
    final name = _field(user['name']);
    final mobile = _field(user['mobileNo']);
    final village = _field(user['area']);
    final dishNumber = _field(user['dishNumber']);

    final pendingAmount = _field(entry.payment['PENDING_AMOUNT']);
    final amount = pendingAmount.isNotEmpty
        ? pendingAmount
        : _field(entry.payment['AMOUNT']).isNotEmpty
            ? _field(entry.payment['AMOUNT'])
            : '0';

    return Card(
      elevation: rs.r(1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(rs.r(16)),
      ),
      margin: EdgeInsets.symmetric(vertical: rs.rh(6)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          rs.rw(14),
          rs.rh(12),
          rs.rw(14),
          rs.rh(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: rs.r(22),
              backgroundColor: kPrimaryColor.withValues(alpha: 0.12),
              child: Text(
                name.isNotEmpty ? name.characters.first : '?',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: kPrimaryColor,
                  fontSize: rs.sp(16),
                ),
              ),
            ),
            SizedBox(width: rs.rw(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CText(
                    msg: name.isEmpty ? 'Unknown user' : name,
                    size: rs.sp(16),
                    weight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                  SizedBox(height: rs.rh(4)),
                  Row(
                    children: [
                      Icon(Icons.phone, size: rs.r(14), color: kBlueColor),
                      SizedBox(width: rs.rw(4)),
                      Expanded(
                        child: CText(
                          msg: mobile,
                          size: rs.sp(13),
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: rs.rh(2)),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: rs.r(14), color: kBlueColor),
                      SizedBox(width: rs.rw(4)),
                      Expanded(
                        child: CText(
                          msg: village,
                          size: rs.sp(13),
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: rs.rh(2)),
                  Row(
                    children: [
                      Icon(Icons.satellite_alt,
                          size: rs.r(14), color: kBlueColor),
                      SizedBox(width: rs.rw(4)),
                      Expanded(
                        child: CText(
                          msg: dishNumber,
                          size: rs.sp(13),
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: rs.rw(10),
                vertical: rs.rh(6),
              ),
              decoration: BoxDecoration(
                color: kPrimaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(rs.r(12)),
              ),
              child: Column(
                children: [
                  CText(
                    msg: 'Due',
                    size: rs.sp(11),
                    color: kPrimaryColor,
                  ),
                  CText(
                    msg: 'Rs.$amount',
                    size: rs.sp(13),
                    weight: FontWeight.w700,
                    color: kPrimaryColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DismissBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: rs.rw(20)),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(rs.r(16)),
      ),
      child: Icon(
        Icons.delete_rounded,
        color: Colors.redAccent,
        size: rs.r(22),
      ),
    );
  }
}
