// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/owner_service.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mrs_dth_diary_v1/scr/models/filterUser.dart';
import 'package:mrs_dth_diary_v1/scr/ui/editUserDetail.dart';
import 'package:mrs_dth_diary_v1/scr/ui/userDetails.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CAppBar.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/customText.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/loading.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/noResultFound.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/userDetailsTile.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/screen_navigation.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';

class FilterVillageUser extends StatefulWidget {
  final String villageName;

  const FilterVillageUser({super.key, required this.villageName});
  @override
  _FilterVillageUserState createState() => _FilterVillageUserState();
}

class _FilterVillageUserState extends State<FilterVillageUser> {
  String searchText = '';
  int _radioValue = 0;
  bool searchVisible = false;
  ScrollController _controller = ScrollController();
  String counter = "0";
  Widget pushMe = Image.asset(
    "assets/images/push.png",
    height: 50,
    width: 50,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white.withValues(alpha: .9),
      appBar: CustomAppBar(
        hintText: widget.villageName,
        prefixIcon: Icons.arrow_back,
        iconOnTap: () => Navigator.pop(context),
        onChanged: (text) => _onSearchChanged(text),
        logoOnTap: () => setState(() => searchVisible = !searchVisible),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Visibility(
              visible: searchVisible,
              child: Expanded(
                  flex: 0,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildRadio(value: 0, name: "Name"),
                            _buildRadio(value: 1, name: "DishNumber"),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildRadio(value: 2, name: "Mobile No"),
                            _buildRadio(value: 3, name: "Dish Type"),
                          ],
                        ),
                      ],
                    ),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _oldUsersStream(),
                builder: (context, oldSnapshot) {
                  if (oldSnapshot.connectionState == ConnectionState.waiting) {
                    return const LoadingShimmerList();
                  }

                  final oldDocs = oldSnapshot.data?.docs ?? [];

                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _newUsersStream(),
                    builder: (context, newSnapshot) {
                      if (newSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const LoadingShimmerList();
                      }

                      final newDocs = newSnapshot.data?.docs ?? [];
                      final allDocs = [...oldDocs, ...newDocs];
                      final showResults = _searchResultsList(allDocs);

                      return showResults.isNotEmpty
                          ? ListView.builder(
                              scrollDirection: Axis.vertical,
                              controller: _controller,
                              shrinkWrap: true,
                              itemCount: showResults.length,
                              itemBuilder: (_, index) {
                                final data = showResults[index];
                                final collectionName = data.reference.parent.id;
                                return Slidable(
                                  key: ValueKey(data.id),
                                  endActionPane: ActionPane(
                                    motion: const DrawerMotion(),
                                    children: [
                                      SlidableAction(
                                        onPressed: (_) {
                                          changeScreenAnimated(
                                            context,
                                            EditUserDetail(
                                              userId: data.id,
                                              data: [data],
                                              index: 0,
                                              collectionName: collectionName,
                                            ),
                                          );
                                        },
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(14),
                                          bottomLeft: Radius.circular(14),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        backgroundColor: kPrimaryColor,
                                        foregroundColor: Colors.white,
                                        icon: Icons.edit_rounded,
                                        label: 'Edit',
                                      ),
                                      SlidableAction(
                                        onPressed: (_) => _confirmDelete(
                                          context,
                                          userId: data.id,
                                          collectionName: collectionName,
                                          name: data['name'] ?? '',
                                        ),
                                        backgroundColor: Colors.redAccent,
                                        foregroundColor: Colors.white,
                                        icon: Icons.delete_rounded,
                                        label: 'Delete',
                                      ),
                                    ],
                                  ),
                                  child: UserDetailsTile(
                                    name: data['name'] ?? '',
                                    dishNumber: data['dishNumber'] ?? '',
                                    mobileNo: data['mobileNo'] ?? '',
                                    villageName: data['area'] ?? '',
                                    userId: data['id'] ?? data.id,
                                    onTap: () {
                                      changeScreenAnimated(
                                          context,
                                          UserDetails(
                                            collectionName: collectionName,
                                            userId: data.id,
                                          ));
                                    },
                                  ),
                                );
                              })
                          : SearchNoData();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.red,
      //   shape: _CustomBorder(),
      //   child: pushMe,
      //   onPressed: () {
      //     setState(() {
      //       pushMe = CText(
      //         size: 20.0,
      //         color: Colors.white,
      //         msg: counter,
      //       );
      //     });
      //   },
      // ),
    );
  }

  Widget _buildRadio({required int value, required String name}) {
    return Row(
      children: [
        Radio(
          value: value,
          activeColor: Colors.blue,
          groupValue: _radioValue,
          onChanged: _handleRadioValueChange,
        ),
        CText(
          msg: name,
          color: Colors.black,
          size: 20.0,
        ),
      ],
    );
  }

  void _handleRadioValueChange(int? value) {
    if (value == null) return;
    setState(() {
      _radioValue = value;
    });
  }

  _onSearchChanged(String text) {
    setState(() {
      searchText = text;
      print(searchText);
    });
    // searchResultsList();
    print(searchText);
  }

  _searchResultsList(var snapshots) {
    counter = snapshots.length.toString();
    var showResults = [];
    if (searchText != "") {
      for (var snapshot in snapshots) {
        var title;
        switch (_radioValue) {
          case 0:
            {
              title = FilterUser.fromSnapshot(snapshot).name.toLowerCase();
            }
            break;
          case 1:
            {
              title =
                  FilterUser.fromSnapshot(snapshot).dishNumber.toLowerCase();
            }
            break;
          case 2:
            {
              title = FilterUser.fromSnapshot(snapshot).mobileNo.toLowerCase();
            }
            break;
          case 3:
            {
              title = FilterUser.fromSnapshot(snapshot).dishType.toLowerCase();
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

  Stream<QuerySnapshot<Map<String, dynamic>>> _oldUsersStream() {
    return FirebaseFirestore.instance
        .collection("OldUser")
        .where('ownerId', isEqualTo: requireOwnerId())
        .where('area', isEqualTo: widget.villageName.trim())
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _newUsersStream() {
    return FirebaseFirestore.instance
        .collection("NewUser")
        .where('ownerId', isEqualTo: requireOwnerId())
        .where('area', isEqualTo: widget.villageName.trim())
        .snapshots();
  }

  Future<void> _confirmDelete(
    BuildContext context, {
    required String userId,
    required String collectionName,
    required String name,
  }) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete user?',
          style: TextStyle(fontFamily: 'TamilArima'),
        ),
        content: Text(
          name.isEmpty
              ? 'Are you sure you want to delete this user?'
              : 'Delete $name from $collectionName?',
          style: const TextStyle(fontFamily: 'TamilArima2'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;
    await FirebaseFirestore.instance
        .collection(collectionName)
        .doc(userId)
        .delete();
  }
}
