import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/createUser.dart';
import 'package:mrs_dth_diary_v1/scr/models/dropDownModel.dart';
import 'package:mrs_dth_diary_v1/scr/ui/userDetails.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CDropDownList.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CTextField.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/noResultFound.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/userDetailsTile.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/datePicker.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/screen_navigation.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/responsive.dart';

class SearchUsersScreen extends StatefulWidget {
  const SearchUsersScreen({super.key});

  @override
  State<SearchUsersScreen> createState() => _SearchUsersScreenState();
}

class _SearchUsersScreenState extends State<SearchUsersScreen> {
  final _queryController = TextEditingController();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _dishNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _shopController = TextEditingController();

  final USerServices _userServices = USerServices();

  DateTime? _registerFrom;
  DateTime? _registerTo;
  DateTime? _expiredFrom;
  DateTime? _expiredTo;

  String _selectedDishType = 'Select Dish Type';
  String _selectedVillage = 'Select Area';
  _UserScope _scope = _UserScope.all;

  @override
  void initState() {
    super.initState();
    _userServices.getVillageName();
  }

  @override
  void dispose() {
    _queryController.dispose();
    _nameController.dispose();
    _mobileController.dispose();
    _dishNumberController.dispose();
    _addressController.dispose();
    _shopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          '  Search Users Details',
          style: TextStyle(
            fontFamily: 'TamilArima',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_alt,
              color: colorScheme.primary,
            ),
            onPressed: () => _openFiltersSheet(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(rs.rw(16), rs.rh(12), rs.rw(16), 0),
            child: _buildSearchBar(colorScheme),
          ),
          SizedBox(height: rs.rh(8)),
          Expanded(
            child: _buildResultsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme) {
    final rs = context.rs;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rs.rw(12), vertical: rs.rh(8)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rs.r(16)),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: rs.r(16),
            offset: Offset(0, rs.rh(6)),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded,
              color: colorScheme.primary, size: rs.r(22)),
          SizedBox(width: rs.rw(8)),
          Expanded(
            child: TextField(
              controller: _queryController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search by name, mobile, dish, village...'),
            ),
          ),
          if (_queryController.text.isNotEmpty)
            IconButton(
              onPressed: () {
                _queryController.clear();
                setState(() {});
              },
              icon: Icon(Icons.close_rounded,
                  color: colorScheme.onSurfaceVariant),
            ),
        ],
      ),
    );
  }

  Widget _buildFiltersCard(ColorScheme colorScheme) {
    final rs = context.rs;
    const hintColor = Color(0xFF4A6572);
    final accent = colorScheme.primary;

    return Container(
      padding: EdgeInsets.all(rs.r(14)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rs.r(16)),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildScopeToggle(),
          SizedBox(height: rs.rh(10)),
          CustomTextField(
            controller: _nameController,
            hintText: 'Name',
            leadingIconColor: accent,
            hintTextColor: hintColor,
            icon: Icons.person_rounded,
            keyboardType: TextInputType.text,
          ),
          CustomTextField(
            controller: _mobileController,
            hintText: 'Mobile number',
            leadingIconColor: accent,
            hintTextColor: hintColor,
            icon: Icons.phone_rounded,
            keyboardType: TextInputType.phone,
          ),
          CustomTextField(
            controller: _addressController,
            hintText: 'Address',
            leadingIconColor: accent,
            hintTextColor: hintColor,
            icon: Icons.home_rounded,
            keyboardType: TextInputType.text,
          ),
          CustomTextField(
            controller: _dishNumberController,
            hintText: 'Dish number',
            leadingIconColor: accent,
            hintTextColor: hintColor,
            image: 'assets/images/dish.png',
            keyboardType: TextInputType.text,
          ),
          SelectDropList(
            itemSelected: _selectedDishType,
            dropListModel: dishDropListModel,
            onOptionSelected: (name) =>
                setState(() => _selectedDishType = name),
            image: 'assets/images/dish.png',
            iconColor: accent,
          ),
          SelectDropList(
            itemSelected: _selectedVillage,
            dropListModel: villageDropListModel,
            onOptionSelected: (name) => setState(() => _selectedVillage = name),
            image: 'assets/images/dish.png',
            iconColor: accent,
          ),
          CustomTextField(
            controller: _shopController,
            hintText: 'Shop name',
            leadingIconColor: accent,
            hintTextColor: hintColor,
            icon: Icons.store_rounded,
            keyboardType: TextInputType.text,
          ),
          SizedBox(height: rs.rh(6)),
          _buildDateRow(
            label: 'Register date',
            from: _registerFrom,
            to: _registerTo,
            onFromChanged: (value) => setState(() => _registerFrom = value),
            onToChanged: (value) => setState(() => _registerTo = value),
          ),
          SizedBox(height: rs.rh(6)),
          _buildDateRow(
            label: 'Expired date',
            from: _expiredFrom,
            to: _expiredTo,
            onFromChanged: (value) => setState(() => _expiredFrom = value),
            onToChanged: (value) => setState(() => _expiredTo = value),
          ),
          SizedBox(height: rs.rh(10)),
          _buildFilterActions(),
        ],
      ),
    );
  }

  Widget _buildFilterActions() {
    final rs = context.rs;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          onPressed: _clearFilters,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Clear'),
        ),
        SizedBox(width: rs.rw(8)),
        ElevatedButton.icon(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.check_circle_rounded),
          label: const Text('Apply'),
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: rs.rw(16),
              vertical: rs.rh(10),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(rs.r(12)),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openFiltersSheet() async {
    final colorScheme = Theme.of(context).colorScheme;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final rs = context.rs;
        return Container(
          margin: EdgeInsets.symmetric(horizontal: rs.rw(12)),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(rs.r(18)),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                rs.rw(16),
                rs.rh(12),
                rs.rw(16),
                rs.rh(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: rs.r(40),
                      height: rs.rh(4),
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(rs.r(12)),
                      ),
                    ),
                  ),
                  SizedBox(height: rs.rh(10)),
                  Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: rs.sp(16),
                      fontWeight: FontWeight.w700,
                      fontFamily: 'TamilArima',
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: rs.rh(8)),
                  _buildFiltersCard(colorScheme),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildScopeToggle() {
    final rs = context.rs;
    return Container(
      padding: EdgeInsets.all(rs.r(4)),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(rs.r(14)),
      ),
      child: Row(
        children: [
          _scopeChip('All', _UserScope.all),
          _scopeChip('Old', _UserScope.old),
          _scopeChip('New', _UserScope.newUser),
        ],
      ),
    );
  }

  Widget _scopeChip(String label, _UserScope scope) {
    final rs = context.rs;
    final active = _scope == scope;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _scope = scope),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: rs.rh(8)),
          decoration: BoxDecoration(
            color: active ? kPrimaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(rs.r(12)),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: rs.sp(13.5),
                color: active ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateRow({
    required String label,
    required DateTime? from,
    required DateTime? to,
    required ValueChanged<DateTime?> onFromChanged,
    required ValueChanged<DateTime?> onToChanged,
  }) {
    final rs = context.rs;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: rs.sp(12.5),
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: rs.rh(6)),
        Row(
          children: [
            Expanded(
              child: _datePickerField(
                hint: 'From',
                value: from,
                onChanged: onFromChanged,
              ),
            ),
            SizedBox(width: rs.rw(8)),
            Expanded(
              child: _datePickerField(
                hint: 'To',
                value: to,
                onChanged: onToChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _datePickerField({
    required String hint,
    required DateTime? value,
    required ValueChanged<DateTime?> onChanged,
  }) {
    final rs = context.rs;
    final text = value == null
        ? hint
        : '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
    return GestureDetector(
      onTap: () {
        showCupertinoModalPopup(
          context: context,
          builder: (_) => DatePicker(
            onDateTimeChanged: (val) => onChanged(val),
          ),
        );
      },
      child: Container(
        padding:
            EdgeInsets.symmetric(horizontal: rs.rw(12), vertical: rs.rh(10)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(rs.r(12)),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            Icon(Icons.event_rounded, size: rs.r(16), color: kBlueColor),
            SizedBox(width: rs.rw(6)),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: rs.sp(12.5),
                  fontWeight: FontWeight.w600,
                  color: value == null ? Colors.black45 : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    final oldStream =
        FirebaseFirestore.instance.collection('OldUser').snapshots();
    final newStream =
        FirebaseFirestore.instance.collection('NewUser').snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: oldStream,
      builder: (context, oldSnapshot) {
        if (oldSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final oldDocs = oldSnapshot.data?.docs ?? [];
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: newStream,
          builder: (context, newSnapshot) {
            if (newSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final newDocs = newSnapshot.data?.docs ?? [];
            final merged = <_UserResult>[];
            if (_scope == _UserScope.all || _scope == _UserScope.old) {
              merged.addAll(oldDocs.map((doc) => _UserResult(doc, 'OldUser')));
            }
            if (_scope == _UserScope.all || _scope == _UserScope.newUser) {
              merged.addAll(newDocs.map((doc) => _UserResult(doc, 'NewUser')));
            }

            final filtered = _applyFilters(merged);
            if (filtered.isEmpty) {
              return const Center(child: SearchNoData());
            }

            return ListView.builder(
              padding: EdgeInsets.fromLTRB(
                  context.rs.rw(12), 0, context.rs.rw(12), context.rs.rh(16)),
              itemCount: filtered.length,
              itemBuilder: (_, index) {
                final entry = filtered[index];
                final data = entry.doc.data();
                return UserDetailsTile(
                  name: _field(data['name']),
                  dishNumber: _field(data['dishNumber']),
                  mobileNo: _field(data['mobileNo']),
                  villageName: _field(data['area']),
                  onTap: () {
                    changeScreenAnimated(
                      context,
                      UserDetails(
                        collectionName: entry.collection,
                        userId: entry.doc.id,
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  List<_UserResult> _applyFilters(List<_UserResult> input) {
    final query = _queryController.text.trim().toLowerCase();
    final name = _nameController.text.trim().toLowerCase();
    final mobile = _mobileController.text.trim().toLowerCase();
    final dishNumber = _dishNumberController.text.trim().toLowerCase();
    final address = _addressController.text.trim().toLowerCase();
    final shop = _shopController.text.trim().toLowerCase();
    final dishType = _selectedDishType == 'Select Dish Type'
        ? ''
        : _selectedDishType.toLowerCase();
    final village =
        _selectedVillage == 'Select Area' ? '' : _selectedVillage.toLowerCase();

    return input.where((entry) {
      final data = entry.doc.data();
      final nameVal = _field(data['name']).toLowerCase();
      final mobileVal = _field(data['mobileNo']).toLowerCase();
      final mobile2Val = _field(data['mobileNo2']).toLowerCase();
      final dishVal = _field(data['dishNumber']).toLowerCase();
      final dishTypeVal = _field(data['dishType']).toLowerCase();
      final addressVal = _field(data['address']).toLowerCase();
      final areaVal = _field(data['area']).toLowerCase();
      final shopVal = _field(data['shopName']).toLowerCase();

      if (query.isNotEmpty) {
        final matches = nameVal.contains(query) ||
            mobileVal.contains(query) ||
            mobile2Val.contains(query) ||
            dishVal.contains(query) ||
            dishTypeVal.contains(query) ||
            addressVal.contains(query) ||
            areaVal.contains(query) ||
            shopVal.contains(query);
        if (!matches) return false;
      }

      if (name.isNotEmpty && !nameVal.contains(name)) return false;
      if (mobile.isNotEmpty &&
          !(mobileVal.contains(mobile) || mobile2Val.contains(mobile))) {
        return false;
      }
      if (dishNumber.isNotEmpty && !dishVal.contains(dishNumber)) return false;
      if (address.isNotEmpty && !addressVal.contains(address)) return false;
      if (shop.isNotEmpty && !shopVal.contains(shop)) return false;
      if (dishType.isNotEmpty && !dishTypeVal.contains(dishType)) return false;
      if (village.isNotEmpty && !areaVal.contains(village)) return false;

      if (!_matchesDateRange(
          data['registerDate'], _registerFrom, _registerTo)) {
        return false;
      }
      if (!_matchesDateRange(data['expiredDate'], _expiredFrom, _expiredTo)) {
        return false;
      }

      return true;
    }).toList();
  }

  bool _matchesDateRange(dynamic value, DateTime? from, DateTime? to) {
    if (from == null && to == null) return true;
    if (value == null) return false;
    DateTime? date;
    if (value is Timestamp) {
      date = value.toDate();
    } else if (value is DateTime) {
      date = value;
    }
    if (date == null) return false;

    final start =
        from != null ? DateTime(from.year, from.month, from.day) : null;
    final end =
        to != null ? DateTime(to.year, to.month, to.day, 23, 59, 59) : null;

    if (start != null && date.isBefore(start)) return false;
    if (end != null && date.isAfter(end)) return false;
    return true;
  }

  void _clearFilters() {
    _nameController.clear();
    _mobileController.clear();
    _dishNumberController.clear();
    _addressController.clear();
    _shopController.clear();
    _selectedDishType = 'Select Dish Type';
    _selectedVillage = 'Select Area';
    _registerFrom = null;
    _registerTo = null;
    _expiredFrom = null;
    _expiredTo = null;
    setState(() {});
  }

  String _field(dynamic value) {
    if (value == null) return '';
    if (value is String) return value.trim();
    return value.toString();
  }
}

class _UserResult {
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  final String collection;

  _UserResult(this.doc, this.collection);
}

enum _UserScope { all, old, newUser }
