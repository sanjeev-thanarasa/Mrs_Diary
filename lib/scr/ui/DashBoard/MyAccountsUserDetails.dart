import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mrs_dth_diary_v1/scr/ui/DashBoard/createMyAccountsPayment.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/dashBoardPaymentContainerListTile.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/screen_navigation.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MyAccountsUserDetails extends StatefulWidget {
  final DocumentSnapshot data;

  const MyAccountsUserDetails({super.key, required this.data});

  @override
  _MyAccountsUserDetailsState createState() => _MyAccountsUserDetailsState();
}

class _MyAccountsUserDetailsState extends State<MyAccountsUserDetails> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  late String dbID;
  late Map<String, dynamic> _data;

  void _onRefresh() async {
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.loadComplete();
  }

  @override
  void initState() {
    _data = (widget.data.data() as Map<String, dynamic>?) ?? {};
    final rawId = _data['id']?.toString().trim();
    dbID = (rawId != null && rawId.isNotEmpty) ? rawId : widget.data.id;
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
        title: Text(
          "${_data["name"] ?? ''} விவரங்கள்",
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          Image.asset(
            "assets/images/mrslogo.png",
            height: 50.0,
            width: 50.0,
            color: kIndigoDark,
          )
        ],
      ),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        enablePullDown: true,
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: filterStream(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildMessage(context, 'Something went wrong!!!');
            }

            if (snapshot.connectionState == ConnectionState.waiting ||
                !snapshot.hasData) {
              return const SizedBox.shrink();
            }

            final docs = snapshot.data?.docs ?? [];
            final totals = _SummaryTotals.fromDocs(docs);
            final itemCount = docs.isEmpty ? 4 : docs.length + 3;
            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: itemCount,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildHeaderSection(context);
                }

                if (index == 1) {
                  return _buildSummarySection(context, totals);
                }

                if (index == 2) {
                  return _buildRecordsHeader(context);
                }

                if (docs.isEmpty) {
                  return _buildMessage(
                      context, 'No results found. Try a different keyword');
                }

                final data = docs[index - 3];
                return DashBoardPaymentContainerListTile(snapshot: data);
              },
            );
          },
        ),
      ),
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> filterStream() async* {
    var firestore = FirebaseFirestore.instance;
    var _stream = firestore
        .collection('DashboardPaymentRecords')
        .where('DB_ID', isEqualTo: dbID)
        .orderBy('CREATE_AT', descending: true)
        .snapshots();

    yield* _stream;
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: [kPrimaryColor, kPrimaryColor.withValues(alpha: 0.78)],
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
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                color: white,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${_data["name"] ?? ''} விவரங்கள்",
                    style: const TextStyle(
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
                ],
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: white,
                foregroundColor: kPrimaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => changeScreen(
                context,
                CreateMyAccountsPayment(dbId: dbID),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text(
                "New",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, _SummaryTotals totals) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'சுருக்கம்',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: kIndigoDark,
                ),
          ),
          const SizedBox(height: 10),
          _buildSummaryCards(context, totals),
        ],
      ),
    );
  }

  Widget _buildRecordsHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'கட்டண பதிவுகள்',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: kIndigoDark,
                  ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: kPrimaryLightColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              DateFormat.MMM().format(DateTime.now()),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: kIndigoDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, _SummaryTotals totals) {
    final colorScheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final columns = maxWidth > 900
            ? 3
            : maxWidth > 560
                ? 3
                : maxWidth > 380
                    ? 2
                    : 1;
        const spacing = 10.0;
        final itemWidth = (maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: itemWidth,
              child: _SummaryStatCard(
                title: 'கொடுத்த பணம்',
                subtitle: 'கொடுத்தது',
                amount: totals.paid,
                icon: Icons.call_made_rounded,
                accentColor: const Color(0xff2E7D32),
                background: const Color(0xffE8F5E9),
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _SummaryStatCard(
                title: 'கொடுக்க வேண்டியது',
                subtitle: 'கொடுமதி/நிலுவை',
                amount: totals.pending,
                icon: Icons.schedule_rounded,
                accentColor: const Color(0xffAD1457),
                background: const Color(0xffFCE4EC),
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _SummaryStatCard(
                title: 'பெற வேண்டியது',
                subtitle: 'தருமதி',
                amount: totals.balance,
                icon: Icons.account_balance_wallet_outlined,
                accentColor: colorScheme.primary,
                background: const Color(0xffE3F2FD),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMessage(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, left: 16, right: 16),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
            fontFamily: 'TamilArima2',
          ),
          textAlign: TextAlign.center,
        ),
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

class _SummaryStatCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double amount;
  final IconData icon;
  final Color accentColor;
  final Color background;

  const _SummaryStatCard({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.icon,
    required this.accentColor,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = NumberFormat.decimalPattern();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: kIndigoDark,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Rs.${formatter.format(amount.round())}',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: accentColor,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: kIndigoLight,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
