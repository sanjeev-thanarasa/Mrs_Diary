import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/fcm_service.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/owner_service.dart';
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
  String? _ownerId;
  String formattedDateStart =
      "${DateFormat('yyyyMMdd').format(DateTime.now())}T000000";
  String formattedDateEnd =
      "${DateFormat('yyyyMMdd').format(DateTime.now())}T235959";

  late CollectionReference paymentRecords;
  late CollectionReference oldUser;
  final ScrollController _controller = ScrollController();

  final List<_NotificationEntry> _entries = [];
  final List<_NotificationEntry> _expiredEntries = [];
  QueryDocumentSnapshot<Object?>? _lastPaymentDoc;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  final int _pageSize = 50;

  @override
  void initState() {
    _dateTodayStart = DateTime.parse(formattedDateStart);
    _dateTodayEnd = DateTime.parse(formattedDateEnd);
    _ownerId = currentOwnerId();
    FcmService.clearBadge();
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
    if (_ownerId == null) return;
    setState(() {
      _isLoading = true;
      _hasMore = true;
      _entries.clear();
      _expiredEntries.clear();
      _lastPaymentDoc = null;
    });

    final query = paymentRecords
        .where('ownerId', isEqualTo: _ownerId)
        .where("PENDING_DATE", isGreaterThanOrEqualTo: _dateTodayStart)
        .where("PENDING_DATE", isLessThanOrEqualTo: _dateTodayEnd)
        .orderBy("PENDING_DATE")
        .limit(_pageSize);

    final snapshot = await query.get();
    if (!mounted) return;

    await _appendEntries(snapshot.docs, _entries, badgeLabel: 'Due');
    _lastPaymentDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
    _hasMore = snapshot.docs.length == _pageSize;

    final expiredQuery = paymentRecords
        .where('ownerId', isEqualTo: _ownerId)
        .where("EXPIRED_AT", isGreaterThanOrEqualTo: _dateTodayStart)
        .where("EXPIRED_AT", isLessThanOrEqualTo: _dateTodayEnd)
        .orderBy("EXPIRED_AT")
        .limit(_pageSize);

    final expiredSnapshot = await expiredQuery.get();
    if (!mounted) return;

    await _appendEntries(expiredSnapshot.docs, _expiredEntries,
        badgeLabel: 'Ends');

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchMore() async {
    if (_lastPaymentDoc == null) return;
    if (_ownerId == null) return;
    setState(() {
      _isLoadingMore = true;
    });

    final query = paymentRecords
        .where('ownerId', isEqualTo: _ownerId)
        .where("PENDING_DATE", isGreaterThanOrEqualTo: _dateTodayStart)
        .where("PENDING_DATE", isLessThanOrEqualTo: _dateTodayEnd)
        .orderBy("PENDING_DATE")
        .startAfterDocument(_lastPaymentDoc!)
        .limit(_pageSize);

    final snapshot = await query.get();
    if (!mounted) return;

    await _appendEntries(snapshot.docs, _entries, badgeLabel: 'Due');
    if (snapshot.docs.isNotEmpty) {
      _lastPaymentDoc = snapshot.docs.last;
    }
    _hasMore = snapshot.docs.length == _pageSize;

    setState(() {
      _isLoadingMore = false;
    });
  }

  Future<void> _appendEntries(
    List<QueryDocumentSnapshot<Object?>> paymentDocs,
    List<_NotificationEntry> target, {
    required String badgeLabel,
  }) async {
    if (paymentDocs.isEmpty) return;
    if (_ownerId == null) return;

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
        target.add(_NotificationEntry(
          user: userDoc,
          paymentId: payment.id,
          payment: paymentData,
          badgeLabel: badgeLabel,
        ));
      }
    }
  }

  Future<Map<String, QueryDocumentSnapshot<Object?>>> _fetchUsersByIds(
      List<String> ids) async {
    final Map<String, QueryDocumentSnapshot<Object?>> result = {};
    if (_ownerId == null) return result;
    const chunkSize = 10;
    for (var i = 0; i < ids.length; i += chunkSize) {
      final chunk = ids.sublist(
          i, i + chunkSize > ids.length ? ids.length : i + chunkSize);
      final snapshot = await oldUser
          .where('ownerId', isEqualTo: _ownerId)
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
    final rs = context.rs;
    return Scaffold(
      backgroundColor: white.withValues(alpha: 0.95),
      appBar: AppBar(
        titleSpacing: 11,
        title: Text(
          "Notifications",
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const LoadingShimmerList()
          : _entries.isEmpty && _expiredEntries.isEmpty
              ? SearchNoData()
              : ListView(
                  controller: _controller,
                  padding: EdgeInsets.fromLTRB(
                    rs.rw(12),
                    rs.rh(8),
                    rs.rw(12),
                    rs.rh(16),
                  ),
                  children: [
                    _SectionHeader(title: "இன்று பணம் தர வேண்டியவர்கள்"),
                    if (_entries.isEmpty)
                      _EmptyNotice(text: "No due payments today")
                    else
                      ..._entries.asMap().entries.map((item) {
                        final index = item.key;
                        final entry = item.value;
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
                      }),
                    if (_isLoadingMore)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: LoadingCircle(),
                      ),
                    SizedBox(height: rs.rh(8)),
                    _SectionHeader(
                        title: "இன்று ரீசார்ஜ் முடியும் வாடிக்கையாளர்கள்"),
                    if (_expiredEntries.isEmpty)
                      _EmptyNotice(text: "No expiries today")
                    else
                      ..._expiredEntries.asMap().entries.map((item) {
                        final index = item.key;
                        final entry = item.value;
                        return Dismissible(
                          key: ValueKey(
                              "expired-${entry.user.id}-${entry.paymentId}-$index"),
                          direction: DismissDirection.endToStart,
                          background: _DismissBackground(),
                          confirmDismiss: (_) => _confirmRemove(context),
                          onDismissed: (_) {
                            setState(() {
                              _expiredEntries.removeAt(index);
                            });
                          },
                          child: _NotificationTile(entry: entry),
                        );
                      }),
                  ],
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
  final String badgeLabel;

  _NotificationEntry({
    required this.user,
    required this.paymentId,
    required this.payment,
    required this.badgeLabel,
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
                    msg: entry.badgeLabel,
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

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    return Padding(
      padding: EdgeInsets.only(bottom: rs.rh(6), top: rs.rh(10)),
      child: Text(
        title,
        style: TextStyle(
          fontSize: rs.sp(14),
          fontWeight: FontWeight.w700,
          color: kIndigoDark,
          fontFamily: 'TamilArima',
        ),
      ),
    );
  }
}

class _EmptyNotice extends StatelessWidget {
  final String text;

  const _EmptyNotice({required this.text});

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    return Padding(
      padding: EdgeInsets.only(bottom: rs.rh(8)),
      child: Text(
        text,
        style: TextStyle(
          fontSize: rs.sp(12),
          color: Colors.black54,
          fontFamily: 'TamilArima2',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
