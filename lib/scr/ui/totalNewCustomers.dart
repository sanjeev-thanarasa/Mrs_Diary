// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mrs_dth_diary_v1/scr/models/totalCustomers.dart';
import 'package:mrs_dth_diary_v1/scr/ui/userDetails.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CAppBar.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CustomListTile.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CustomStreamBuilder.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/customText.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/noResultFound.dart';
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
  late CollectionReference newUsers;
  ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    newUsers = FirebaseFirestore.instance.collection("NewUser");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white.withValues(alpha: .9),
      appBar: CustomAppBar(
        hintText: "புதிய பயனர்கள்",
        prefixIcon: Icons.arrow_back,
        iconOnTap: () => Navigator.pop(context),
        onChanged: (text) => _onSearchChanged(text),
        logoOnTap: () => setState(() => searchVisible = !searchVisible),
      ),
      body: Column(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildRadio(value: 4, name: "Village"),
                        ],
                      ),
                    ],
                  ),
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: CustomStreamBuilder(
                context: context,
                stream: newUsers.orderBy('name').snapshots()
                    as Stream<QuerySnapshot<Map<String, dynamic>>>,
                body: (snapshot) {
                  final docs = snapshot.data?.docs ?? [];
                  var showResults = _searchResultsList(docs);
                  return showResults.length > 0
                      ? ListView.builder(
                          scrollDirection: Axis.vertical,
                          controller: _controller,
                          shrinkWrap: true,
                          itemCount: showResults.length,
                          itemBuilder: (_, index) {
                            var data = showResults[index];
                            return CListTile(
                              context: context,
                              docId: data.id,
                              collectionName: "NewUser",
                              title: data['name'],
                              subtitle: data['mobileNo'],
                              subtitle2: data['dishNumber'],
                              subtitle3: data['area'],
                              subtitleIcon: Icons.phone,
                              tileOnTap: () {
                                changeScreenAnimated(
                                    context,
                                    UserDetails(
                                      collectionName: "NewUser",
                                      userId: data.id,
                                    ));
                              },
                              counter: "${index + 1}",
                            );
                          })
                      : SearchNoData();
                }),
          ),
        ],
      ),
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
    var showResults = [];

    if (searchText != "") {
      for (var snapshot in snapshots) {
        var title;
        switch (_radioValue) {
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
