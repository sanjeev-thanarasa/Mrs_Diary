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

  bool _useNameFilter = false;
  bool _useMobileFilter = false;
  bool _useDishNumberFilter = false;
  bool _useAddressFilter = false;
  bool _useShopFilter = false;
  bool _useDishTypeFilter = false;
  bool _useVillageFilter = false;

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
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                rs.rw(16),
                rs.rh(12),
                rs.rw(16),
                0,
              ),
              child: _buildSearchBar(colorScheme),
            ),
            SizedBox(height: rs.rh(10)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: rs.rw(16)),
              child: _buildFilterChips(colorScheme),
            ),
            SizedBox(height: rs.rh(8)),
            Expanded(
              child: _buildResultsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme) {
    final rs = context.rs;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rs.rw(12), vertical: rs.rh(2)),
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
              style: const TextStyle(color: Colors.black),
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Search users...',
              ),
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

  Widget _buildFilterChips(ColorScheme colorScheme) {
    final rs = context.rs;
    final chips = <Widget>[
      _scopeChoiceChip('All', _UserScope.all),
      SizedBox(width: rs.rw(6)),
      _scopeChoiceChip('Old', _UserScope.old),
      SizedBox(width: rs.rw(6)),
      _scopeChoiceChip('New', _UserScope.newUser),
      SizedBox(width: rs.rw(6)),
      _filterChip(
        label: 'Name',
        selected: _useNameFilter,
        onSelected: (value) => _toggleTextFilter(FilterType.name, value),
      ),
      _filterChip(
        label: 'Mobile',
        selected: _useMobileFilter,
        onSelected: (value) => _toggleTextFilter(FilterType.mobile, value),
      ),
      _filterChip(
        label: 'Address',
        selected: _useAddressFilter,
        onSelected: (value) => _toggleTextFilter(FilterType.address, value),
      ),
      _filterChip(
        label: 'Dish No',
        selected: _useDishNumberFilter,
        onSelected: (value) => _toggleTextFilter(FilterType.dishNumber, value),
      ),
      _filterChip(
        label: 'Dish Type',
        selected: _useDishTypeFilter,
        onSelected: (value) => _toggleTextFilter(FilterType.dishType, value),
      ),
      _filterChip(
        label: 'Area',
        selected: _useVillageFilter,
        onSelected: (value) => _toggleTextFilter(FilterType.village, value),
      ),
      _filterChip(
        label: 'Shop',
        selected: _useShopFilter,
        onSelected: (value) => _toggleTextFilter(FilterType.shop, value),
      ),
      _dateFilterChip(
        label: _dateChipLabel('Register', _registerFrom, _registerTo),
        selected: _registerFrom != null || _registerTo != null,
        onSelected: (value) {
          if (!value) {
            setState(() {
              _registerFrom = null;
              _registerTo = null;
            });
            return;
          }
          _openDateFilterSheet(
            title: 'Register date',
            from: _registerFrom,
            to: _registerTo,
            onFromChanged: (val) => setState(() => _registerFrom = val),
            onToChanged: (val) => setState(() => _registerTo = val),
          );
        },
      ),
      _dateFilterChip(
        label: _dateChipLabel('Expired', _expiredFrom, _expiredTo),
        selected: _expiredFrom != null || _expiredTo != null,
        onSelected: (value) {
          if (!value) {
            setState(() {
              _expiredFrom = null;
              _expiredTo = null;
            });
            return;
          }
          _openDateFilterSheet(
            title: 'Expired date',
            from: _expiredFrom,
            to: _expiredTo,
            onFromChanged: (val) => setState(() => _expiredFrom = val),
            onToChanged: (val) => setState(() => _expiredTo = val),
          );
        },
      ),
      _filterChip(
        label: 'Clear',
        selected: false,
        onSelected: (_) => _clearFilters(),
        backgroundColor: colorScheme.surfaceContainerHighest,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: chips),
        ),
        SizedBox(height: rs.rh(8)),
        _buildInlineFilters(colorScheme),
      ],
    );
  }

  Widget _scopeChoiceChip(String label, _UserScope scope) {
    return ChoiceChip(
      label: Text(label),
      selected: _scope == scope,
      onSelected: (_) => setState(() => _scope = scope),
      labelStyle: const TextStyle(
          fontWeight: FontWeight.w700, fontFamily: 'TamilArima2'),
      selectedColor: kPrimaryColor.withValues(alpha: 0.6),
      showCheckmark: false,
    );
  }

  Widget _filterChip({
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
    Color? backgroundColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label),
        labelStyle: const TextStyle(fontSize: 12, fontFamily: 'TamilArima2'),
        selected: selected,
        onSelected: onSelected,
        backgroundColor: backgroundColor,
        selectedColor: kPrimaryColor.withValues(alpha: 0.3),
        showCheckmark: false,
      ),
    );
  }

  Widget _dateFilterChip({
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label),
        labelStyle: const TextStyle(fontSize: 12, fontFamily: 'TamilArima2'),
        selected: selected,
        onSelected: onSelected,
        avatar: const Icon(Icons.event_rounded, size: 16),
        selectedColor: kPrimaryColor.withValues(alpha: 0.3),
        showCheckmark: false,
      ),
    );
  }

  Widget _buildInlineFilters(ColorScheme colorScheme) {
    final rs = context.rs;
    const hintColor = Color(0xFF4A6572);
    final accent = colorScheme.primary;
    final items = <Widget>[];

    if (_useNameFilter) {
      items.add(CustomTextField(
        controller: _nameController,
        hintText: 'Name',
        leadingIconColor: accent,
        hintTextColor: hintColor,
        icon: Icons.person_rounded,
        keyboardType: TextInputType.text,
      ));
    }
    if (_useMobileFilter) {
      items.add(CustomTextField(
        controller: _mobileController,
        hintText: 'Mobile number',
        leadingIconColor: accent,
        hintTextColor: hintColor,
        icon: Icons.phone_rounded,
        keyboardType: TextInputType.phone,
      ));
    }
    if (_useAddressFilter) {
      items.add(CustomTextField(
        controller: _addressController,
        hintText: 'Address',
        leadingIconColor: accent,
        hintTextColor: hintColor,
        icon: Icons.home_rounded,
        keyboardType: TextInputType.text,
      ));
    }
    if (_useDishNumberFilter) {
      items.add(CustomTextField(
        controller: _dishNumberController,
        hintText: 'Dish number',
        leadingIconColor: accent,
        hintTextColor: hintColor,
        image: 'assets/images/dish.png',
        keyboardType: TextInputType.text,
      ));
    }
    if (_useDishTypeFilter) {
      items.add(SelectDropList(
        itemSelected: _selectedDishType,
        dropListModel: dishDropListModel,
        onOptionSelected: (name) => setState(() => _selectedDishType = name),
        image: 'assets/images/dish.png',
        iconColor: accent,
      ));
    }
    if (_useVillageFilter) {
      items.add(SelectDropList(
        itemSelected: _selectedVillage,
        dropListModel: villageDropListModel,
        onOptionSelected: (name) => setState(() => _selectedVillage = name),
        image: 'assets/images/dish.png',
        iconColor: accent,
      ));
    }
    if (_useShopFilter) {
      items.add(CustomTextField(
        controller: _shopController,
        hintText: 'Shop name',
        leadingIconColor: accent,
        hintTextColor: hintColor,
        icon: Icons.store_rounded,
        keyboardType: TextInputType.text,
      ));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(rs.r(12)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rs.r(14)),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(children: _withSpacing(items, rs.rh(8))),
    );
  }

  List<Widget> _withSpacing(List<Widget> items, double spacing) {
    final spaced = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      spaced.add(items[i]);
      if (i != items.length - 1) {
        spaced.add(SizedBox(height: spacing));
      }
    }
    return spaced;
  }

  String _dateChipLabel(String base, DateTime? from, DateTime? to) {
    if (from == null && to == null) return base;
    final fromText = from == null ? 'Any' : _formatDate(from);
    final toText = to == null ? 'Any' : _formatDate(to);
    return '$base: $fromText-$toText';
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  void _toggleTextFilter(FilterType type, bool value) {
    setState(() {
      switch (type) {
        case FilterType.name:
          _useNameFilter = value;
          if (!value) _nameController.clear();
          break;
        case FilterType.mobile:
          _useMobileFilter = value;
          if (!value) _mobileController.clear();
          break;
        case FilterType.address:
          _useAddressFilter = value;
          if (!value) _addressController.clear();
          break;
        case FilterType.dishNumber:
          _useDishNumberFilter = value;
          if (!value) _dishNumberController.clear();
          break;
        case FilterType.shop:
          _useShopFilter = value;
          if (!value) _shopController.clear();
          break;
        case FilterType.dishType:
          _useDishTypeFilter = value;
          if (!value) _selectedDishType = 'Select Dish Type';
          break;
        case FilterType.village:
          _useVillageFilter = value;
          if (!value) _selectedVillage = 'Select Area';
          break;
      }
    });
  }

  Future<void> _openDateFilterSheet({
    required String title,
    required DateTime? from,
    required DateTime? to,
    required ValueChanged<DateTime?> onFromChanged,
    required ValueChanged<DateTime?> onToChanged,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        final rs = context.rs;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(rs.r(16)),
              ),
            ),
            child: Padding(
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
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: rs.sp(16),
                      fontWeight: FontWeight.w700,
                      fontFamily: 'TamilArima2',
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: rs.rh(8)),
                  _buildDateRow(
                    label: title,
                    from: from,
                    to: to,
                    onFromChanged: onFromChanged,
                    onToChanged: onToChanged,
                  ),
                  SizedBox(height: rs.rh(10)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          onFromChanged(null);
                          onToChanged(null);
                          Navigator.of(context).maybePop();
                        },
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
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
            fontFamily: "TamilArima2",
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
                  fontFamily: 'TamilArima2',
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
                  userId: _field(data['id']).isNotEmpty
                      ? _field(data['id'])
                      : entry.doc.id,
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
    final name =
        _useNameFilter ? _nameController.text.trim().toLowerCase() : '';
    final mobile =
        _useMobileFilter ? _mobileController.text.trim().toLowerCase() : '';
    final dishNumber = _useDishNumberFilter
        ? _dishNumberController.text.trim().toLowerCase()
        : '';
    final address =
        _useAddressFilter ? _addressController.text.trim().toLowerCase() : '';
    final shop =
        _useShopFilter ? _shopController.text.trim().toLowerCase() : '';
    final dishType =
        _useDishTypeFilter && _selectedDishType != 'Select Dish Type'
            ? _selectedDishType.toLowerCase()
            : '';
    final village = _useVillageFilter && _selectedVillage != 'Select Area'
        ? _selectedVillage.toLowerCase()
        : '';

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
    _useNameFilter = false;
    _useMobileFilter = false;
    _useDishNumberFilter = false;
    _useAddressFilter = false;
    _useShopFilter = false;
    _useDishTypeFilter = false;
    _useVillageFilter = false;
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

enum FilterType {
  name,
  mobile,
  dishNumber,
  address,
  shop,
  dishType,
  village,
}
