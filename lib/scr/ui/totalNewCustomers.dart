// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/owner_service.dart';
import 'package:mrs_dth_diary_v1/scr/models/totalCustomers.dart';
import 'package:mrs_dth_diary_v1/scr/ui/userDetails.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CAppBar.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/loading.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/noResultFound.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/userDetailsTile.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/responsive.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/screen_navigation.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';

class TotalNewCustomers extends StatefulWidget {
  @override
  _TotalNewCustomersState createState() => _TotalNewCustomersState();
}

class _TotalNewCustomersState extends State<TotalNewCustomers> {
  String searchText = '';
  int _radioValue = 0;
  bool searchVisible = false;
  final ScrollController _controller = ScrollController();
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> _docs = [];
  DocumentSnapshot<Map<String, dynamic>>? _lastDoc;
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
    _controller.addListener(_onScroll);
    _fetchInitial();
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
      _docs.clear();
      _lastDoc = null;
    });

    final ownerId = requireOwnerId();
    final query = FirebaseFirestore.instance
        .collection("NewUser")
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('name')
        .limit(_pageSize);

    final snapshot = await query.get();
    if (!mounted) return;

    _docs.addAll(snapshot.docs);
    _lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
    _hasMore = snapshot.docs.length == _pageSize;

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchMore() async {
    if (_lastDoc == null) return;
    setState(() {
      _isLoadingMore = true;
    });

    final ownerId = requireOwnerId();
    final query = FirebaseFirestore.instance
        .collection("NewUser")
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('name')
        .startAfterDocument(_lastDoc!)
        .limit(_pageSize);

    final snapshot = await query.get();
    if (!mounted) return;

    if (snapshot.docs.isNotEmpty) {
      _docs.addAll(snapshot.docs);
      _lastDoc = snapshot.docs.last;
    }

    _hasMore = snapshot.docs.length == _pageSize;

    setState(() {
      _isLoadingMore = false;
    });
  }

  Future<void> _fetchAllForSearch() async {
    if (_isSearchLoading) return;

    setState(() {
      _isSearchLoading = true;
    });

    final ownerId = requireOwnerId();
    final query = FirebaseFirestore.instance
        .collection("NewUser")
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('name');

    final snapshot = await query.get();
    if (!mounted) return;

    _docs
      ..clear()
      ..addAll(snapshot.docs);
    _lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
    _hasMore = false;

    setState(() {
      _isSearchLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    return Scaffold(
      backgroundColor: white.withValues(alpha: .9),
      appBar: CustomAppBar(
        hintText: "புதிய பயனர்கள்",
        prefixIcon: Icons.arrow_back,
        iconOnTap: () => Navigator.pop(context),
        onChanged: (text) => _onSearchChanged(text),
        trailing: InkWell(
          onTap: () => setState(() {
            searchVisible = !searchVisible;
            if (!searchVisible) {
              _radioValue = 0;
            }
          }),
          child: Container(
            height: rs.r(36),
            width: rs.r(36),
            decoration: BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.circular(rs.r(10)),
            ),
            child: const Center(
              child: Icon(
                Icons.tune_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Visibility(
            visible: searchVisible,
            child: SizedBox(
              height: rs.rh(54),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(value: 0, label: "Name"),
                    SizedBox(width: rs.rw(10)),
                    _buildFilterChip(value: 1, label: "DishNumber"),
                    SizedBox(width: rs.rw(10)),
                    _buildFilterChip(value: 2, label: "Mobile No"),
                    SizedBox(width: rs.rw(10)),
                    _buildFilterChip(value: 3, label: "Dish Type"),
                    SizedBox(width: rs.rw(10)),
                    _buildFilterChip(value: 4, label: "Village"),
                  ],
                ),
              ),
            ),
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
    final showResults = _searchResultsList(_docs);

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

        final data = showResults[index];
        return UserDetailsTile(
          name: data['name'],
          dishNumber: data['dishNumber'],
          mobileNo: data['mobileNo'],
          villageName: data['area'],
          userId: data['id'] ?? data.id,
          collectionName: "NewUser",
          onTap: () {
            changeScreenAnimated(
                context,
                UserDetails(
                  collectionName: "NewUser",
                  userId: data.id,
                ));
          },
        );
      },
    );
  }

  Widget _buildFilterChip({required int value, required String label}) {
    final rs = context.rs;
    final bool selected = _radioValue == value;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontFamily: selected ? 'TamilArima2' : 'TamilArima',
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: Colors.black87,
          fontSize: rs.sp(13),
        ),
      ),
      selected: selected,
      selectedColor: kPrimaryColor.withValues(alpha: 0.18),
      backgroundColor: Colors.white,
      side: BorderSide(
        color: selected ? kPrimaryColor.withValues(alpha: 0.5) : Colors.black12,
        width: 1,
      ),
      onSelected: (_) => _handleRadioValueChange(value),
      padding: EdgeInsets.symmetric(horizontal: rs.rw(14), vertical: rs.rh(8)),
      labelPadding:
          EdgeInsets.symmetric(horizontal: rs.rw(6), vertical: rs.rh(3)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Future<void> _onPullRefresh() async {
    if (searchText.trim().isNotEmpty) {
      await _fetchAllForSearch();
      return;
    }
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
      if (!_hasMore || _docs.length > _pageSize) {
        _fetchInitial();
      }
      return;
    }

    _fetchAllForSearch();
    print(searchText);
  }

  _searchResultsList(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> snapshots) {
    var showResults = [];

    if (searchText != "") {
      final effectiveRadioValue = searchVisible ? _radioValue : 0;
      for (var snapshot in snapshots) {
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
          showResults.add(snapshot);
        }
      }
    } else {
      showResults = List.from(snapshots);
    }
    return showResults;
  }
}
