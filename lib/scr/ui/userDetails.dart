import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/owner_service.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:intl/intl.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/operations.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/SimpleCalc.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/customText.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/loading.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/paymentTile.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/gap.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/screen_navigation.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'createPayment.dart';
import 'editUserDetail.dart';

class UserDetails extends StatefulWidget {
  final String userId;
  final String collectionName;

  const UserDetails({
    super.key,
    required this.collectionName,
    required this.userId,
  });

  @override
  _UserDetailsState createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  final _key = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    getUsersStreamSnapshots(
      collectionName:
          widget.collectionName.isNotEmpty ? widget.collectionName : "OldUser",
    );
  }

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool black = false;
  bool note = false;
  List _result = [];

  void _onRefresh() async {
    print("___On Refresh_______________");
    getUsersStreamSnapshots(collectionName: widget.collectionName);
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(Duration(milliseconds: 1000));
    print("___On Loading_______________");
    _refreshController.loadComplete();
  }

  String userName = '';
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(
          "User details",
          style: const TextStyle(
            fontFamily: 'TamilArima',
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calculate_rounded),
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                backgroundColor: Colors.transparent,
                builder: (BuildContext context) {
                  return SimpleCalc();
                },
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        // enablePullDown: true,
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: filterStream(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: CText(
                  msg: "Something went wrong!!!",
                  color: Colors.black,
                  size: 30.0,
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: MediaQuery.of(context).size.height / 2 + 100,
                child: const Center(child: LoadingShimmerList()),
              );
            }

            final docs = snapshot.data?.docs ?? [];

            return DefaultTextStyle(
              style: const TextStyle(color: kIndigoDark),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  _buildUserHeaderCard(context),
                  const SizedBox(height: 12),
                  _buildUserQuickActions(context),
                  const SizedBox(height: 12),
                  _buildUserInfoCard(),
                  const SizedBox(height: 12),
                  _buildPaymentSummaryCard(docs),
                  const SizedBox(height: 12),
                  _buildSectionTitle(
                    title: "Payment history",
                    subtitle: docs.isEmpty
                        ? "No payment records yet"
                        : "${docs.length} records",
                  ),
                  const SizedBox(height: 8),
                  if (docs.isEmpty)
                    _buildEmptyState()
                  else
                    ...docs.map(
                      (doc) => PaymentContainerListTile(snapshot: doc),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> filterStream() async* {
    var firestore = FirebaseFirestore.instance;
    var stream = firestore
        .collection('PaymentRecords')
        .where('ownerId', isEqualTo: requireOwnerId())
        .where('USER_ID', isEqualTo: widget.userId)
        .orderBy('CREATE_AT', descending: true)
        .snapshots(includeMetadataChanges: false);

    yield* stream;
  }

  // getPaymentStreamSnapshots() async {
  //   var firestore = FirebaseFirestore.instance;
  //   var data = await firestore
  //       .collection('PaymentRecords')
  //       .where('USER_ID', isEqualTo: widget.userId)
  //       .orderBy('CREATE_AT',descending: true)
  //       .get();
  //   setState(() {
  //     _results = data.docs;
  //   });
  //   return "complete";
  // }

  Widget _buildUserHeaderCard(BuildContext context) {
    final data = _result.isNotEmpty ? _result[0] : null;
    final name = data != null ? data['name'] ?? '' : '';
    final dish = data != null ? data['dishNumber'] ?? '' : '';
    final area = data != null ? data['area'] ?? '' : '';
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: kPrimaryColor.withValues(alpha: 0.12),
              child: const Icon(Icons.person_rounded, color: kPrimaryColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: kIndigoDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'TamilArima',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.tv_rounded, size: 16, color: kBlueColor),
                      const SizedBox(width: 6),
                      Text(
                        dish.toString(),
                        style: const TextStyle(
                          color: kIndigoDark,
                          fontSize: 13,
                          fontFamily: 'Lobster',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.location_on_rounded,
                          size: 16, color: kBlueColor),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          area,
                          style: const TextStyle(
                            color: kIndigoDark,
                            fontFamily: 'TamilArima2',
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => changeScreenAnimated(
              context,
              CreatePayment(userId: widget.userId),
            ),
            icon: const Icon(Icons.add_card_rounded),
            label: const Text(
              'Add Payment',
              style: TextStyle(fontFamily: 'TamilArima'),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _openEditUser,
            icon: const Icon(Icons.edit_rounded),
            label: const Text(
              'Edit User',
              style: TextStyle(fontFamily: 'TamilArima'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfoCard() {
    final data = _result.isNotEmpty ? _result[0] : null;
    if (data == null) {
      return const Center(child: LoadingShimmerList());
    }

    final map = _docMap(data);
    final userTypeLabel =
        widget.collectionName == 'NewUser' ? 'New User' : 'Old User';

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              'Name',
              _safeField(map, 'name'),
            ),
            _buildInfoRow('User Type', userTypeLabel),
            _buildInfoRow(
              'Mobile',
              _safeField(map, 'mobileNo'),
            ),
            if (_safeField(map, 'mobileNo2').isNotEmpty)
              _buildInfoRow('Mobile 2', _safeField(map, 'mobileNo2')),
            _buildInfoRow(
              'Dish Number',
              _safeField(map, 'dishNumber'),
            ),
            _buildInfoRow('Dish Type', _safeField(map, 'dishType')),
            _buildInfoRow('Area', _safeField(map, 'area')),
            if (_safeField(map, 'address').isNotEmpty)
              _buildInfoRow('Address', _safeField(map, 'address')),
            if (_safeField(map, 'shopName').isNotEmpty)
              _buildInfoRow('Shop', _safeField(map, 'shopName')),
            const Divider(height: 24),
            Row(
              children: [
                _buildToggleChip(
                  label: 'Noted',
                  value: note,
                  updateField: 'NoteList',
                  toast: 'Noted',
                  ContainerColor: Colors.white,
                ),
                const SizedBox(width: 12),
                _buildToggleChip(
                  label: 'Black List',
                  value: black,
                  updateField: 'BlackList',
                  toast: 'Black',
                  ContainerColor: Colors.orange.shade100,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleChip({
    required String label,
    required bool value,
    required String updateField,
    required String toast,
    required Color ContainerColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: ContainerColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'TamilArima',
              fontWeight: FontWeight.w600,
              color: kIndigoDark,
            ),
          ),
          const SizedBox(width: 8),
          FlutterSwitch(
            height: 18,
            width: 34,
            padding: 3,
            toggleSize: 14,
            borderRadius: 12,
            activeColor: Colors.green,
            value: value,
            onToggle: (val) => _handleToggle(updateField, val, toast),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummaryCard(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    double totalPaid = 0;
    double totalPending = 0;
    double totalBalance = 0;

    for (final doc in docs) {
      final data = doc.data();
      totalPaid += _toDouble(data['PAID_AMOUNT']);
      totalPending += _toDouble(data['PENDING_AMOUNT']);
      totalBalance += _toDouble(data['BALANCE_AMOUNT']);
    }

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'TamilArima',
                color: kIndigoDark,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildSummaryTile('செலுத்தியது', totalPaid, Colors.green),
                const SizedBox(width: 8),
                _buildSummaryTile('நிலுவை', totalPending, Colors.orange),
                const SizedBox(width: 8),
                _buildSummaryTile('கொடுமதி', totalBalance, Colors.redAccent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryTile(String label, double value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value.toStringAsFixed(0),
              style: TextStyle(
                fontFamily: 'Lobster',
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'TamilArima2',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: kIndigoDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle({required String title, required String subtitle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: 'TamilArima',
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            fontFamily: 'TamilArima2',
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text(
          'No payment records yet',
          style: TextStyle(
            fontFamily: 'TamilArima2',
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontFamily: 'TamilArima2',
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(
                fontFamily: 'TamilArima',
                fontWeight: FontWeight.w600,
                color: kIndigoDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _docMap(dynamic doc) {
    try {
      return (doc.data() as Map<String, dynamic>?) ?? {};
    } catch (_) {
      return {};
    }
  }

  String _safeField(Map<String, dynamic> map, String key) {
    final value = map.containsKey(key) ? map[key] : '';
    return value == null ? '' : value.toString();
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  Future<void> _openEditUser() async {
    if (_result.isEmpty) {
      return;
    }

    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => EditUserDetail(
          data: _result,
          index: 0,
          userId: widget.userId,
          collectionName: widget.collectionName,
        ),
      ),
    );

    if (updated == true) {
      await getUsersStreamSnapshots(collectionName: widget.collectionName);
      if (mounted) {
        setState(() {});
      }
    }
  }

  Widget _buildToggleCard({
    required IconData icon,
    required String title,
    required bool value,
    required String updateField,
    required String toast,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: kPrimaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'TamilArima',
                fontWeight: FontWeight.w600,
                color: kIndigoDark,
              ),
            ),
          ),
          FlutterSwitch(
            height: 18.0,
            width: 36.0,
            padding: 3.0,
            toggleSize: 14.0,
            borderRadius: 10.0,
            activeColor: Colors.green,
            value: value,
            onToggle: (val) => _handleToggle(updateField, val, toast),
          ),
        ],
      ),
    );
  }

  void _handleToggle(String updateField, bool val, String toast) {
    if (val) {
      updateSingleProduct(
              collectionName: widget.collectionName,
              id: widget.userId,
              updateField: updateField,
              updateData: true)
          .whenComplete(() => showToast(
                "Successfully Added to $toast List",
                gravity: ToastGravity.BOTTOM,
                toastLength: Toast.LENGTH_LONG,
              ));
    } else {
      updateSingleProduct(
              collectionName: widget.collectionName,
              id: widget.userId,
              updateField: updateField,
              updateData: false)
          .whenComplete(() => showToast(
                "Successfully Removed to $toast List",
                gravity: ToastGravity.BOTTOM,
                toastLength: Toast.LENGTH_LONG,
              ));
    }
    setState(() {
      if (updateField == "NoteList") {
        note = val;
      } else if (updateField == "BlackList") {
        black = val;
      }
    });
  }

  Widget _buildInfoSection(Map<String, dynamic> map) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _infoRow("Name", _safeField(map, 'name')),
          _infoRow("Area", _safeField(map, 'area')),
          if (_safeField(map, 'address').isNotEmpty)
            _infoRow("Address", _safeField(map, 'address')),
          _infoRow("Dish Number", _safeField(map, 'dishNumber')),
          _infoRow("Dish Type", _safeField(map, 'dishType')),
          _infoRow("User Type", "${widget.collectionName}"),
          if (_safeField(map, 'shopName').isNotEmpty)
            _infoRow("Shop", _safeField(map, 'shopName')),
          _infoRow("Mobile", _safeField(map, 'mobileNo')),
          if (_safeField(map, 'mobileNo2').isNotEmpty)
            _infoRow("Mobile 2", _safeField(map, 'mobileNo2')),
          _infoRow(
            "Register Date",
            map['registerDate'] != null
                ? DateFormat('dd-MM-yyyy').format(map['registerDate'].toDate())
                : "No Data",
          ),
          _infoRow(
            "Expired Date",
            map['expiredDate'] != null
                ? DateFormat('dd-MM-yyyy').format(map['expiredDate'].toDate())
                : "No Data",
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'TamilArima2',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 6,
            child: Text(
              value.isEmpty ? "-" : value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'TamilArima',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNewUserFields(
      {required String collectionName, required int index}) {
    if (collectionName == 'OldUser') {
      return const SizedBox();
    } else if (collectionName == 'NewUser') {
      final map = _docMap(_result[index]);
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildUserDetail(
            text1: "Shop Name :",
            text2:
                "${widget.collectionName == "NewUser" ? _safeField(map, 'shopName') : "No Data"}",
          ),
          const Gap(h: 3.0),
          buildUserDetail(
            text1: "Register Date :",
            text2: map['registerDate'] != null
                ? "${DateFormat('dd-MM-yyyy hh:mm a').format(map['registerDate'].toDate())}"
                : "No Data",
            size: 16.0,
          ),
          const Gap(h: 3.0),
          buildUserDetail(
            text1: "Expired Date :",
            text2: map['expiredDate'] != null
                ? "${DateFormat('dd-MM-yyyy hh:mm a').format(map['expiredDate'].toDate())}"
                : "No Data",
            size: 16.0,
          ),
          const Gap(h: 3.0),
        ],
      );
    } else {
      return const SizedBox();
    }
  }

  FlutterSwitch buildFlutterSwitch({
    required bool value,
    required String updateField,
    required String toast,
  }) {
    return FlutterSwitch(
      height: 20.0,
      width: 40.0,
      padding: 4.0,
      toggleSize: 15.0,
      borderRadius: 10.0,
      activeColor: Colors.green,
      value: value,
      onToggle: (val) {
        if (val) {
          updateSingleProduct(
                  collectionName: widget.collectionName,
                  id: widget.userId,
                  updateField: updateField,
                  updateData: true)
              .whenComplete(() => showToast(
                    "Successfully Added to $toast List",
                    gravity: ToastGravity.BOTTOM,
                    toastLength: Toast.LENGTH_LONG,
                  ));
        } else {
          updateSingleProduct(
                  collectionName: widget.collectionName,
                  id: widget.userId,
                  updateField: updateField,
                  updateData: false)
              .whenComplete(() => showToast(
                    "Successfully Removed to $toast List",
                    gravity: ToastGravity.BOTTOM,
                    toastLength: Toast.LENGTH_LONG,
                  ));
        }
        setState(() {
          if (updateField == "NoteList") {
            note = val;
          } else if (updateField == "BlackList") {
            black = val;
          }
        });
      },
    );
  }

  void showToast(
    String msg, {
    Toast toastLength = Toast.LENGTH_SHORT,
    ToastGravity gravity = ToastGravity.BOTTOM,
  }) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: toastLength,
      gravity: gravity,
    );
  }

  Future<String> getUsersStreamSnapshots(
      {required String collectionName}) async {
    var firestore = FirebaseFirestore.instance;
    var data = await firestore
        .collection(collectionName)
        .where('ownerId', isEqualTo: requireOwnerId())
        .where('id', isEqualTo: widget.userId)
        .get();
    setState(() {
      _result = data.docs;
      print("LLLLLLLLLLLLLLLLLLLLLLLLLLL" + _result.length.toString());
      if (_result.isNotEmpty) {
        userName = _result[0]['name'];
        black = _result[0]['BlackList'] ?? false;
        note = _result[0]['NoteList'] ?? false;
      }
    });
    return "Complete";
  }

  Widget buildUserDetail({
    required String text1,
    required String text2,
    double? size,
    double? topPadding,
    Widget? anyOtherWidget,
    double? gapHeight,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
            flex: 0,
            child: Row(
              children: [
                //Icon(Icons.person,color: Colors.grey,),
                Image.asset(
                  "assets/images/star.png",
                  height: 20,
                  width: 20,
                  color: Colors.blue,
                ),
                SizedBox(
                  width: 5.0,
                ),
                CText(msg: text1, size: 16.0, color: Colors.grey),
              ],
            )),
        SizedBox(height: gapHeight ?? 5.0),
        Flexible(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(top: topPadding ?? 0.0),
              child: anyOtherWidget ??
                  CText(
                      msg: text2,
                      size: size ?? 20,
                      textAlign: TextAlign.end,
                      color: Colors.blue),
            )),
      ],
    );
  }
}
