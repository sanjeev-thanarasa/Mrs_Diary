import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/owner_service.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/customText.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';
  String _filterBy = 'all'; // all, paid, pending
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Default to all time so users can see records immediately
    _startDate = null;
    _endDate = null;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'Records & Reports',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 0,
        backgroundColor: white,
        foregroundColor: kIndigoDark,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                white,
                kPrimaryLightColor.withValues(alpha: 0.35),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: kPrimaryColor,
          indicatorWeight: 3,
          labelColor: kIndigoDark,
          unselectedLabelColor: kIndigoDark.withValues(alpha: 0.6),
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(icon: Icon(Icons.calendar_month), text: 'Monthly'),
            Tab(icon: Icon(Icons.calendar_today), text: 'Daily'),
            Tab(icon: Icon(Icons.history), text: 'All Transactions'),
          ],
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              _buildFilterSection(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMonthlyReportView(),
                    _buildDailyReportView(),
                    _buildAllTransactionsView(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 360;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                kPrimaryLightColor.withValues(alpha: 0.3),
                Colors.white,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: kPrimaryColor.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Date range selector
              Container(
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kPrimaryLightColor, width: 1.5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _selectDateRange(context),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                Icon(Icons.date_range,
                                    color: kPrimaryColor, size: 22),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _startDate != null && _endDate != null
                                        ? '${DateFormat('MMM d').format(_startDate!)} - ${DateFormat('MMM d, y').format(_endDate!)}'
                                        : 'All time',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: kIndigoDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 40,
                      width: 1,
                      color: kPrimaryLightColor,
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          final now = DateTime.now();
                          _startDate = DateTime(now.year, now.month, 1);
                          _endDate = DateTime(now.year, now.month + 1, 0);
                        });
                      },
                      icon: Icon(Icons.refresh, color: kPrimaryColor),
                      tooltip: 'Reset to current month',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Search and filter
              if (isNarrow)
                Column(
                  children: [
                    _buildSearchField(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildFilterButton(),
                        const SizedBox(width: 8),
                        _buildResetButton(),
                      ],
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(child: _buildSearchField()),
                    const SizedBox(width: 8),
                    _buildFilterButton(),
                    const SizedBox(width: 8),
                    _buildResetButton(),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kPrimaryLightColor, width: 1.5),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(
          color: kIndigoDark,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: 'Search by name or ID...',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Icon(Icons.search, color: kPrimaryColor),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          isDense: true,
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildFilterButton() {
    return Container(
      decoration: BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: PopupMenuButton<String>(
        initialValue: _filterBy,
        icon: const Icon(Icons.filter_list, color: white),
        color: white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onSelected: (value) => setState(() => _filterBy = value),
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'all',
            child: Row(
              children: [
                Icon(Icons.list_alt, size: 20),
                SizedBox(width: 12),
                Text('All Records'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'paid',
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 20),
                SizedBox(width: 12),
                Text('Paid Only'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'pending',
            child: Row(
              children: [
                Icon(Icons.pending, color: Colors.orange, size: 20),
                SizedBox(width: 12),
                Text('Pending Only'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton() {
    return Container(
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kPrimaryLightColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        tooltip: 'Show all records',
        icon: const Icon(Icons.refresh_rounded, color: kPrimaryColor),
        onPressed: () {
          setState(() {
            _searchController.clear();
            _searchQuery = '';
            _filterBy = 'all';
            _startDate = null;
            _endDate = null;
          });
        },
      ),
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    await _showDateRangeSheet(context);
  }

  Future<void> _showDateRangeSheet(BuildContext context) async {
    DateTime? tempStart = _startDate;
    DateTime? tempEnd = _endDate;
    final now = DateTime.now();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Date Range',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: kIndigoDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateField(
                          label: 'Start date',
                          date: tempStart,
                          onTap: () async {
                            final picked = await _pickSingleDate(
                              context,
                              initial: tempStart ?? now,
                              firstDate: DateTime(2020),
                              lastDate: tempEnd ?? now,
                            );
                            if (picked != null) {
                              setSheetState(() {
                                tempStart = picked;
                                if (tempEnd != null &&
                                    tempEnd!.isBefore(tempStart!)) {
                                  tempEnd = tempStart;
                                }
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDateField(
                          label: 'End date',
                          date: tempEnd,
                          onTap: () async {
                            final picked = await _pickSingleDate(
                              context,
                              initial: tempEnd ?? tempStart ?? now,
                              firstDate: tempStart ?? DateTime(2020),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                            );
                            if (picked != null) {
                              setSheetState(() {
                                tempEnd = picked;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Quick ranges',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: kIndigoDark.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildQuickChip(
                        label: 'This month',
                        onTap: () {
                          setSheetState(() {
                            tempStart = DateTime(now.year, now.month, 1);
                            tempEnd = DateTime(now.year, now.month + 1, 0);
                          });
                        },
                      ),
                      _buildQuickChip(
                        label: 'Last 30 days',
                        onTap: () {
                          setSheetState(() {
                            tempEnd = now;
                            tempStart = now.subtract(const Duration(days: 29));
                          });
                        },
                      ),
                      _buildQuickChip(
                        label: 'This year',
                        onTap: () {
                          setSheetState(() {
                            tempStart = DateTime(now.year, 1, 1);
                            tempEnd = DateTime(now.year, 12, 31);
                          });
                        },
                      ),
                      _buildQuickChip(
                        label: 'All time',
                        onTap: () {
                          setSheetState(() {
                            tempStart = null;
                            tempEnd = null;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: kPrimaryColor,
                            side: BorderSide(color: kPrimaryLightColor),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _startDate = tempStart;
                              _endDate = tempEnd;
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<DateTime?> _pickSingleDate(
    BuildContext context, {
    required DateTime initial,
    required DateTime firstDate,
    required DateTime lastDate,
  }) async {
    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: kPrimaryColor,
              onPrimary: white,
              surface: white,
              onSurface: kIndigoDark,
            ),
            dialogBackgroundColor: white,
          ),
          child: child!,
        );
      },
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kPrimaryLightColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: kPrimaryColor.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: kIndigoDark.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              date != null
                  ? DateFormat('MMM d, y').format(date)
                  : 'Select date',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: kIndigoDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickChip({
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: kPrimaryLightColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kPrimaryLightColor),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: kIndigoDark,
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyReportView() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('DashboardPaymentRecords')
          .where('ownerId', isEqualTo: requireOwnerId())
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final filteredDocs = _filterDocuments(snapshot.data!.docs);
        final monthlyData = _aggregateByMonth(filteredDocs);

        if (monthlyData.isEmpty) {
          return _buildEmptyState('No records found for selected period');
        }

        return ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(16),
          children: [
            _buildSummaryCards(filteredDocs),
            const SizedBox(height: 16),
            ...monthlyData.entries.map((entry) {
              return _buildMonthlyCard(entry.key, entry.value);
            }),
          ],
        );
      },
    );
  }

  Widget _buildDailyReportView() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('DashboardPaymentRecords')
          .where('ownerId', isEqualTo: requireOwnerId())
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final filteredDocs = _filterDocuments(snapshot.data!.docs);
        final dailyData = _aggregateByDay(filteredDocs);

        if (dailyData.isEmpty) {
          return _buildEmptyState('No records found for selected period');
        }

        return ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(16),
          children: [
            _buildSummaryCards(filteredDocs),
            const SizedBox(height: 16),
            ...dailyData.entries.map((entry) {
              return _buildDailyCard(entry.key, entry.value);
            }),
          ],
        );
      },
    );
  }

  Widget _buildAllTransactionsView() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('DashboardPaymentRecords')
          .where('ownerId', isEqualTo: requireOwnerId())
          .orderBy('CREATE_AT', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final filteredDocs = _filterDocuments(snapshot.data!.docs);

        if (filteredDocs.isEmpty) {
          return _buildEmptyState('No transactions found');
        }

        return ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(16),
          children: [
            _buildSummaryCards(filteredDocs),
            const SizedBox(height: 16),
            Text(
              '${filteredDocs.length} Transactions',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: kIndigoDark,
              ),
            ),
            const SizedBox(height: 12),
            ...filteredDocs.map((doc) => _buildTransactionTile(doc)),
          ],
        );
      },
    );
  }

  List<QueryDocumentSnapshot> _filterDocuments(
      List<QueryDocumentSnapshot> docs) {
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;

      // Date filter
      if (_startDate != null && _endDate != null) {
        final docDate = _getRecordDate(data);
        if (docDate == null ||
            docDate.isBefore(_startDate!) ||
            docDate.isAfter(_endDate!.add(const Duration(days: 1)))) {
          return false;
        }
      }

      // Search filter
      if (_searchQuery.isNotEmpty) {
        final name = _getRecordName(data).toLowerCase();
        final dbId = (data['DB_ID'] ?? '').toString().toLowerCase();
        if (!name.contains(_searchQuery.toLowerCase()) &&
            !dbId.contains(_searchQuery.toLowerCase())) {
          return false;
        }
      }

      // Status filter
      if (_filterBy != 'all') {
        final paidAmount = _getPaidAmount(data);
        final amount = _getTotalAmount(data);
        final balance = amount - paidAmount;

        if (_filterBy == 'paid' && balance != 0) return false;
        if (_filterBy == 'pending' && balance == 0) return false;
      }

      return true;
    }).toList();
  }

  Map<String, List<QueryDocumentSnapshot>> _aggregateByMonth(
      List<QueryDocumentSnapshot> docs) {
    final Map<String, List<QueryDocumentSnapshot>> grouped = {};

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final date = _getRecordDate(data);
      if (date != null) {
        final monthKey = DateFormat('MMMM yyyy').format(date);
        grouped.putIfAbsent(monthKey, () => []).add(doc);
      }
    }

    // Sort by date descending
    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) {
        final dateA = DateFormat('MMMM yyyy').parse(a.key);
        final dateB = DateFormat('MMMM yyyy').parse(b.key);
        return dateB.compareTo(dateA);
      });

    return Map.fromEntries(sortedEntries);
  }

  Map<String, List<QueryDocumentSnapshot>> _aggregateByDay(
      List<QueryDocumentSnapshot> docs) {
    final Map<String, List<QueryDocumentSnapshot>> grouped = {};

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final date = _getRecordDate(data);
      if (date != null) {
        final dayKey = DateFormat('EEEE, MMM d, yyyy').format(date);
        grouped.putIfAbsent(dayKey, () => []).add(doc);
      }
    }

    // Sort by date descending
    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) {
        final dateA = DateFormat('EEEE, MMM d, yyyy').parse(a.key);
        final dateB = DateFormat('EEEE, MMM d, yyyy').parse(b.key);
        return dateB.compareTo(dateA);
      });

    return Map.fromEntries(sortedEntries);
  }

  Widget _buildSummaryCards(List<QueryDocumentSnapshot> docs) {
    double totalAmount = 0;
    double totalPaid = 0;
    int totalRecords = docs.length;

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      totalAmount += _getTotalAmount(data);
      totalPaid += _getPaidAmount(data);
    }

    final balance = totalAmount - totalPaid;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Amount',
            totalAmount,
            Icons.account_balance_wallet,
            kPrimaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Paid',
            totalPaid,
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Balance',
            balance,
            Icons.pending,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label, double amount, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color.withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            FittedBox(
              child: Text(
                'Rs. ${_formatAmount(amount)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyCard(String month, List<QueryDocumentSnapshot> docs) {
    double totalAmount = 0;
    double totalPaid = 0;

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      totalAmount += _getTotalAmount(data);
      totalPaid += _getPaidAmount(data);
    }

    final balance = totalAmount - totalPaid;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            white,
            kPrimaryLightColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: kPrimaryLightColor.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kPrimaryColor, kPrimaryColor.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: kPrimaryColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              DateFormat('MMM').format(DateFormat('MMMM yyyy').parse(month)),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: white,
              ),
            ),
          ),
          title: Text(
            month,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: kIndigoDark,
            ),
          ),
          subtitle: Text(
            '${docs.length} transactions',
            style: TextStyle(color: kIndigoDark.withValues(alpha: 0.6)),
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kPrimaryLightColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Total Amount', totalAmount, kPrimaryColor),
                  const Divider(height: 20),
                  _buildDetailRow('Paid', totalPaid, Colors.green),
                  const Divider(height: 20),
                  _buildDetailRow('Balance', balance, Colors.orange),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...docs.map((doc) => _buildTransactionTile(doc)),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyCard(String day, List<QueryDocumentSnapshot> docs) {
    double totalAmount = 0;
    double totalPaid = 0;

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      totalAmount += _getTotalAmount(data);
      totalPaid += _getPaidAmount(data);
    }

    final balance = totalAmount - totalPaid;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            white,
            kPrimaryLightColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: kPrimaryLightColor.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kPrimaryColor, kPrimaryColor.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: kPrimaryColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              DateFormat('d')
                  .format(DateFormat('EEEE, MMM d, yyyy').parse(day)),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: white,
              ),
            ),
          ),
          title: Text(
            DateFormat('EEEE, MMM d')
                .format(DateFormat('EEEE, MMM d, yyyy').parse(day)),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: kIndigoDark,
            ),
          ),
          subtitle: Text(
            '${docs.length} transactions',
            style: TextStyle(color: kIndigoDark.withValues(alpha: 0.6)),
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kPrimaryLightColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Total Amount', totalAmount, kPrimaryColor),
                  const Divider(height: 20),
                  _buildDetailRow('Paid', totalPaid, Colors.green),
                  const Divider(height: 20),
                  _buildDetailRow('Balance', balance, Colors.orange),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...docs.map((doc) => _buildTransactionTile(doc)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTile(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final name = _getRecordName(data);
    final dbId = data['DB_ID'] ?? '';
    final amount = _getTotalAmount(data);
    final paidAmount = _getPaidAmount(data);
    final balance = amount - paidAmount;
    final date = _getRecordDate(data);
    final status = data['status'] ?? '';

    final isPaid = balance == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            white,
            isPaid
                ? Colors.green.withValues(alpha: 0.03)
                : Colors.orange.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPaid
              ? Colors.green.withValues(alpha: 0.2)
              : Colors.orange.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isPaid
                ? Colors.green.withValues(alpha: 0.08)
                : Colors.orange.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isPaid
                  ? [Colors.green, Colors.green.withValues(alpha: 0.8)]
                  : [Colors.orange, Colors.orange.withValues(alpha: 0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: isPaid
                    ? Colors.green.withValues(alpha: 0.3)
                    : Colors.orange.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            isPaid ? Icons.check_circle : Icons.pending_actions,
            color: white,
            size: 20,
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: kIndigoDark,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'ID: $dbId',
              style: TextStyle(
                fontSize: 11,
                color: kIndigoDark.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (date != null)
              Text(
                DateFormat('MMM d, y • h:mm a').format(date),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Rs. ${_formatAmount(amount)}',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: kIndigoDark,
              ),
            ),
            const SizedBox(height: 4),
            if (balance > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_formatAmount(balance)}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'PAID',
                  style: TextStyle(
                    fontSize: 10,
                    color: white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, double amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: kIndigoDark,
                ),
              ),
            ],
          ),
          Text(
            'Rs. ${_formatAmount(amount)}',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    kPrimaryLightColor.withValues(alpha: 0.2),
                    kPrimaryLightColor.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.folder_open_rounded,
                size: 80,
                color: kPrimaryColor.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: kIndigoDark.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _parseAmount(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0;
  }

  DateTime? _getRecordDate(Map<String, dynamic> data) {
    final dateValue = data['CREATE_AT'] ??
        data['PAID_DATE'] ??
        data['dateTime'] ??
        data['DATE'] ??
        data['createAt'];
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is DateTime) return dateValue;
    return null;
  }

  double _getTotalAmount(Map<String, dynamic> data) {
    return _parseAmount(
      data['RECHARGE_AMOUNT'] ?? data['AMOUNT'] ?? data['amount'],
    );
  }

  double _getPaidAmount(Map<String, dynamic> data) {
    return _parseAmount(
      data['PAID_AMOUNT'] ?? data['paidAmount'] ?? data['PAID'],
    );
  }

  String _getRecordName(Map<String, dynamic> data) {
    return (data['RECHARGE_PLACE'] ??
            data['name'] ??
            data['USER_NOTE'] ??
            'Unknown')
        .toString();
  }

  String _formatAmount(double amount) {
    final formatter = NumberFormat('#,##,##0.00', 'en_US');
    return formatter.format(amount);
  }
}
