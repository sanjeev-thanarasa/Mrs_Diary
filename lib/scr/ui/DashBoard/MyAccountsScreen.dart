import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/owner_service.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CustomListTile.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/screen_navigation.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';
import 'package:uuid/uuid.dart';

import 'MyAccountsUserDetails.dart';

class MyAccountsScreen extends StatefulWidget {
  @override
  _MyAccountsScreenState createState() => _MyAccountsScreenState();
}

class _MyAccountsScreenState extends State<MyAccountsScreen> {
  final ScrollController _controller = ScrollController();
  late final CollectionReference<Map<String, dynamic>> collectionReference;
  late final CollectionReference<Map<String, dynamic>> paymentsReference;

  @override
  void initState() {
    collectionReference = FirebaseFirestore.instance.collection("DashBoard");
    paymentsReference =
        FirebaseFirestore.instance.collection("DashboardPaymentRecords");
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: paymentsReference
                .where('ownerId', isEqualTo: requireOwnerId())
                .snapshots(),
            builder: (context, snapshot) {
              final docs = snapshot.data?.docs ?? [];
              final totals = docs.isEmpty
                  ? _SummaryTotals.empty
                  : _SummaryTotals.fromDocs(docs);
              final summaries = docs.isEmpty
                  ? <String, _AccountSummary>{}
                  : _AccountSummary.fromDocs(docs);
              final isLoading =
                  snapshot.connectionState == ConnectionState.waiting &&
                      snapshot.data == null;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(
                    totals: totals,
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: 16),
                  _buildAccountsSection(summaries),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 16, bottom: 16),
        child: FloatingActionButton.extended(
          backgroundColor: kPrimaryColor,
          onPressed: _showCreateTopupDialog,
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

  Widget _buildAccountsSection(Map<String, _AccountSummary> summaries) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: collectionReference
          .where('ownerId', isEqualTo: requireOwnerId())
          .snapshots(),
      builder: (context, snap) {
        final colorScheme = Theme.of(context).colorScheme;
        if (snap.hasError) {
          return Center(
            child: Text(
              'Something went wrong!!!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }
        if (snap.connectionState == ConnectionState.waiting || !snap.hasData) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final docs = List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(
          snap.data?.docs ?? [],
        );
        if (docs.isEmpty) {
          return Center(
            child: Text(
              'No results found. Try a different keyword',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }

        docs.sort((a, b) {
          final aDate = _safeDate(a.data()['createAt']);
          final bDate = _safeDate(b.data()['createAt']);
          return bDate.compareTo(aDate);
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "All Accounts (${docs.length})",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              scrollDirection: Axis.vertical,
              controller: _controller,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: docs.length,
              itemBuilder: (_, index) {
                final data = docs[index];
                final map = data.data();
                final id = (map["id"]?.toString().trim().isNotEmpty ?? false)
                    ? map["id"].toString()
                    : data.id;
                final title = map["name"]?.toString().trim();
                final createdAt = _formatCreatedAt(map["createAt"]);
                final summary = summaries[id];
                final pendingChip = _buildPendingChipText(summary);

                return CListTile(
                  context: context,
                  docId: id,
                  collectionName: "DashBoard",
                  tileOnTap: () => changeScreenAnimated(
                    context,
                    MyAccountsUserDetails(data: data),
                  ),
                  onEdit: () => _showRenameDialog(
                    context,
                    id,
                    title ?? "",
                  ),
                  title: title?.isNotEmpty == true ? title! : 'Topup',
                  subtitle: createdAt,
                  subtitleIcon: Icons.access_time,
                  counter: "${index + 1}",
                  pendingAmount: pendingChip,
                );
              },
            ),
          ],
        );
      },
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Overall analysis",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: white,
            ),
          ),
          const SizedBox(height: 12),
          _buildHeaderStats(totals, isLoading),
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
                label: "இதுவரை பெறப்பட்ட தொகை",
                value: paid,
                icon: Icons.call_made_rounded,
                color: const Color(0xff1B5E20),
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _HeaderStatChip(
                label: "மீதமுள்ள நிலுவைத் தொகை",
                value: pending,
                icon: Icons.schedule_rounded,
                color: const Color(0xffAD1457),
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _HeaderStatChip(
                label: "மொத்த தருமதி தொகை",
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

  String _formatCreatedAt(dynamic value) {
    final date = _safeDate(value);
    if (date == DateTime.fromMillisecondsSinceEpoch(0)) {
      return 'Unknown date';
    }
    return DateFormat.yMMMd().add_jm().format(date);
  }

  DateTime _safeDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  String? _buildPendingChipText(_AccountSummary? summary) {
    if (summary == null) return null;
    if (summary.pending > 0) {
      return 'கொடுமதி ${_formatAmount(summary.pending)}';
    }
    if (summary.balance > 0) {
      return 'கொடுமதி ${_formatAmount(summary.balance)}';
    }
    return null;
  }

  bool _canEditSummary(_AccountSummary? summary) {
    if (summary == null) return true;
    return summary.pending > 0 || summary.balance > 0;
  }

  void _showCreateTopupDialog() {
    final controller = TextEditingController();
    String? errorText;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: "TopUp Name",
                    labelText: "Create New TopUP",
                    errorText: errorText,
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    final name = controller.text.trim();
                    if (name.isEmpty) {
                      setLocalState(() {
                        errorText = 'Please enter a name';
                      });
                      return;
                    }
                    final id = const Uuid().v1();
                    collectionReference.doc(id).set({
                      "id": id,
                      "ownerId": requireOwnerId(),
                      "name": name,
                      "createAt": DateTime.now(),
                    });
                    Navigator.pop(dialogContext);
                  },
                  child: const Text(
                    'CREATE',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
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
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'TamilArima',
            ),
            decoration: const InputDecoration(
              hintText: "TopUp Name",
              labelText: "Edit TopUP",
              labelStyle: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontFamily: 'TamilArima',
                fontWeight: FontWeight.w600,
              ),
              floatingLabelStyle: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontFamily: 'TamilArima',
                fontWeight: FontWeight.w600,
              ),
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

class _AccountSummary {
  double paid;
  double pending;
  double balance;

  _AccountSummary({
    required this.paid,
    required this.pending,
    required this.balance,
  });

  static Map<String, _AccountSummary> fromDocs(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    final map = <String, _AccountSummary>{};

    for (final doc in docs) {
      final dbId = (doc.data()['DB_ID'] ?? '').toString();
      if (dbId.isEmpty) continue;
      final summary = map.putIfAbsent(
        dbId,
        () => _AccountSummary(paid: 0, pending: 0, balance: 0),
      );
      summary.paid += _SummaryTotals._parseAmount(doc['PAID_AMOUNT']);
      summary.pending += _SummaryTotals._parseAmount(doc['PENDING_AMOUNT']);
      summary.balance += _SummaryTotals._parseAmount(doc['BALANCE_AMOUNT']);
    }

    return map;
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
