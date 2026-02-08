import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CustomListTile.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CustomStreamBuilder.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/ShowPopUpAlertBox.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/screen_navigation.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';
import 'package:uuid/uuid.dart';

import 'MyAccountsUserDetails.dart';

class MyAccountsScreen extends StatefulWidget {
  @override
  _MyAccountsScreenState createState() => _MyAccountsScreenState();
}

class _MyAccountsScreenState extends State<MyAccountsScreen> {
  ScrollController _controller = ScrollController();
  late final CollectionReference collectionReference;
  late final CollectionReference paymentsReference;

  @override
  void initState() {
    collectionReference = FirebaseFirestore.instance.collection("DashBoard");
    paymentsReference =
        FirebaseFirestore.instance.collection("DashboardPaymentRecords");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: white,
        elevation: 0,
        foregroundColor: kIndigoDark,
        title: const Text(
          "எனது கணக்கு விபரங்கள்",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: paymentsReference.snapshots()
                    as Stream<QuerySnapshot<Map<String, dynamic>>>,
                builder: (context, snapshot) {
                  final docs = snapshot.data?.docs;
                  final totals = docs == null
                      ? _SummaryTotals.empty
                      : _SummaryTotals.fromDocs(docs);
                  final isLoading =
                      snapshot.connectionState == ConnectionState.waiting &&
                          docs == null;
                  return _buildHeaderCard(
                    totals: totals,
                    isLoading: isLoading,
                  );
                },
              ),
              const SizedBox(height: 16),
              const Text(
                "All Accounts",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              CustomStreamBuilder(
                  context: context,
                  stream: collectionReference.snapshots()
                      as Stream<QuerySnapshot<Map<String, dynamic>>>,
                  body: (snap) {
                    final docs = snap.data?.docs ?? [];
                    return ListView.builder(
                      scrollDirection: Axis.vertical,
                      controller: _controller,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: docs.length,
                      itemBuilder: (_, index) {
                        var data = docs[index];
                        return CListTile(
                          context: context,
                          docId: data["id"].toString(),
                          collectionName: "DashBoard",
                          tileOnTap: () => changeScreenAnimated(
                              context,
                              MyAccountsUserDetails(
                                data: data,
                              )),
                          onEdit: () => _showRenameDialog(
                            context,
                            data["id"].toString(),
                            data["name"]?.toString() ?? "",
                          ),
                          title: data["name"],
                          subtitle:
                              "${DateFormat.yMMMd().add_jm().format(data["createAt"].toDate()).toString()}",
                          subtitleIcon: Icons.access_time,
                          counter: "${index + 1}",
                        );
                      },
                    );
                  })
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 16, bottom: 16),
        child: FloatingActionButton.extended(
          backgroundColor: kPrimaryColor,
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return SimpleDialog(
                    backgroundColor: Colors.transparent,
                    elevation: 0.0,
                    children: <Widget>[
                      PopUpBox(
                        hintText: "TopUp Name",
                        labelText: "Create New TopUP",
                        btnText: "CREATE",
                        bthFunction: (text) {
                          String id = Uuid().v1();
                          collectionReference.doc(id).set({
                            "id": id,
                            "name": text,
                            "createAt": DateTime.now(),
                          });
                        },
                        context: context,
                      )
                    ],
                  );
                });
          },
          icon: const Icon(Icons.add, color: white),
          label: const Text(
            "New Topup",
            style: TextStyle(color: white, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  Widget _buildHeaderCard({
    required _SummaryTotals totals,
    required bool isLoading,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [kPrimaryColor, kPrimaryColor.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.account_balance_wallet_outlined,
                color: white, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "எனது கணக்கு விபரங்கள்",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: white,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Topup பதிவுகள் மற்றும் கட்டண விவரங்கள்",
                  style: TextStyle(color: white, fontSize: 13),
                ),
                const SizedBox(height: 12),
                _buildHeaderStats(totals, isLoading),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStats(_SummaryTotals totals, bool isLoading) {
    final paid = isLoading ? '...' : _formatAmount(totals.paid);
    final pending = isLoading ? '...' : _formatAmount(totals.pending);
    final balance = isLoading ? '...' : _formatAmount(totals.balance);
    const spacing = 8.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final columns = maxWidth > 820
            ? 3
            : maxWidth > 520
                ? 2
                : 1;
        final itemWidth = (maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: itemWidth,
              child: _HeaderStatChip(
                label: "மொத்த கொடுத்த பணம்",
                value: paid,
                icon: Icons.call_made_rounded,
                color: const Color(0xff1B5E20),
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _HeaderStatChip(
                label: "மொத்த கொடுமதி பணம்",
                value: pending,
                icon: Icons.schedule_rounded,
                color: const Color(0xffAD1457),
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _HeaderStatChip(
                label: "மொத்த தருமதி பணம்",
                value: balance,
                icon: Icons.account_balance_wallet_outlined,
                color: const Color(0xff0D47A1),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatAmount(double value) {
    final formatter = NumberFormat.decimalPattern();
    return 'Rs.${formatter.format(value.round())}';
  }

  void _showRenameDialog(
    BuildContext context,
    String docId,
    String currentName,
  ) {
    final controller = TextEditingController(text: currentName);
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: "TopUp Name",
              labelText: "Edit TopUP",
              labelStyle: TextStyle(
                fontSize: 16,
                fontFamily: 'TamilArima',
                fontWeight: FontWeight.w600,
              ),
            ),
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'TamilArima',
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CANCEL',
              style: TextStyle(
                fontFamily: 'TamilArima',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final nextName = controller.text.trim();
              if (nextName.isNotEmpty) {
                collectionReference.doc(docId).update({"name": nextName});
              }
              Navigator.pop(context);
            },
            child: const Text(
              'UPDATE',
              style: TextStyle(
                fontFamily: 'TamilArima',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryTotals {
  final double paid;
  final double pending;
  final double balance;

  const _SummaryTotals({
    required this.paid,
    required this.pending,
    required this.balance,
  });

  static const empty = _SummaryTotals(paid: 0, pending: 0, balance: 0);

  factory _SummaryTotals.fromDocs(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    double paid = 0;
    double pending = 0;
    double balance = 0;

    for (final doc in docs) {
      paid += _parseAmount(doc['PAID_AMOUNT']);
      pending += _parseAmount(doc['PENDING_AMOUNT']);
      balance += _parseAmount(doc['BALANCE_AMOUNT']);
    }

    return _SummaryTotals(paid: paid, pending: pending, balance: balance);
  }

  static double _parseAmount(dynamic value) {
    if (value == null) {
      return 0;
    }
    if (value is num) {
      return value.toDouble();
    }
    final text = value
        .toString()
        .replaceAll('Rs.', '')
        .replaceAll('Rs', '')
        .replaceAll(',', '')
        .trim();
    return double.tryParse(text) ?? 0;
  }
}

class _HeaderStatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _HeaderStatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: white.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: kIndigoLight,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: kIndigoDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
