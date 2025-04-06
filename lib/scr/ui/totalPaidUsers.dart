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

class TotalPaidUsers extends StatefulWidget {
  @override
  _TotalPaidUsersState createState() => _TotalPaidUsersState();
}

class _TotalPaidUsersState extends State<TotalPaidUsers> {
  String searchText = '';
  int _radioValue = 0;
  bool searchVisible = false;
  CollectionReference paymentRecords;
  CollectionReference oldUser;
  ScrollController _controller = ScrollController();

  List paymentDetails=[];
  var userResults = [];
  List searchResults = [];

  @override
  void dispose() {
    searchText = null;
    super.dispose();
  }

  @override
  void initState() {
    getPaymentStreamSnapshots(collectionName: "PaymentRecords");
    paymentRecords = FirebaseFirestore.instance.collection("PaymentRecords");
    oldUser = FirebaseFirestore.instance.collection("OldUser");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white.withOpacity(.9),
      appBar: CustomAppBar(
        hintText: "பணம் தந்தவர்கள்",
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
                  stream: paymentRecords
                      .where("PAID_AMOUNT",  isNotEqualTo: "")
                      .snapshots(),
                  body: (paidTotUsers){
                    if (paidTotUsers.data.docs.length >0) {
                      return ListView.builder(
                          scrollDirection: Axis.vertical,
                          controller: _controller,
                          shrinkWrap: true ,
                          itemCount: paidTotUsers.data.docs.length,
                          itemBuilder: (_,index){
                            var paidTotalUsers = paidTotUsers.data.docs[index];
                            return CustomStreamBuilder(
                              context: context,
                              stream: oldUser
                                  .where("id",  isEqualTo: paidTotalUsers['USER_ID']).snapshots(),
                              body:(snapshot){
                                var showResults = _searchResultsList(snapshot.data.docs);
                               // allResults.add(showResults);
                                return ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    controller: _controller,
                                    shrinkWrap: true ,
                                    itemCount: showResults.length,
                                    itemBuilder: (_,index){
                                      return CListTile(
                                        context: context,
                                        docId: showResults[index].id,
                                        collectionName: "OldUser",
                                        title: showResults[index]['name'],
                                        subtitle: showResults[index]['mobileNo'],
                                        subtitle2: showResults[index]['dishNumber'],
                                        subtitle3: showResults[index]['area'],
                                        subtitleIcon: Icons.phone,
                                        tileOnTap: (){changeScreenAnimated(context, UserDetails(
                                          collectionName: "OldUser",
                                          userId: showResults[index].id,));},
                                        counter: "${showResults[index]['name'].toString().substring(0,1)}",
                                      );
                                    }
                                );
                              },
                            );
                          }
                      );
                    } else {
                      return SearchNoData();
                    }

                  }
              ),
            ),

            // ListView.builder(
            //     scrollDirection: Axis.vertical,
            //     controller: _controller,
            //     shrinkWrap: true,
            //     itemCount: searchResults.length,
            //     itemBuilder: (_, index) {
            //       print(searchResults.length);
            //
            //       print(searchResults[index].runtimeType);
            //       var data = searchResults.asMap();
            //       print(searchResults.getRange(0, 15));
            //       return CText(
            //         msg: "HIIII",
            //       );
            //       // return CListTile(
            //       //   context: context,
            //       //   docId: "searchResults[index].id",
            //       //   collectionName: "OldUser",
            //       //   title: searchResults[index]['name'],
            //       //   subtitle: searchResults[index]['mobileNo'],
            //       //   subtitle2: searchResults[index]['dishNumber'],
            //       //   subtitleIcon: Icons.phone,
            //       //   tileOnTap: () {
            //       //     changeScreenAnimated(
            //       //         context,
            //       //         UserDetails(
            //       //           collectionName: "OldUser",
            //       //           userId: "searchResults[index].id",
            //       //         ));
            //       //   },
            //       //   counter:
            //       //       "${searchResults[index]['name'].toString().substring(0, 1)}",
            //       // );
            //     }),
          ],
        ),
      ),
    );
  }

  getPaymentStreamSnapshots({String collectionName}) async {
    userResults.clear();
    paymentDetails.clear();
    searchResults.clear();
    var firestore = FirebaseFirestore.instance;
    var data = await firestore.collection(collectionName).where("PAID_AMOUNT", isNotEqualTo: "").get();
    setState(()=>paymentDetails=data.docs);

    for(var snap in data.docs){
      var userData = await firestore.collection("OldUser").where("id",  isEqualTo: snap['USER_ID']).get();
      userResults.add(userData.docs);
    }
    setState(()=>searchResults = _searchResultsList(userResults));

    return "complete";
  }

  _buildRadio({int value, String name}) {
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

  _handleRadioValueChange(int value) {
    setState(() {
      _radioValue = value;
    });
  }

  _onSearchChanged(String text) {
    setState(() {
      searchText = text;
      print(searchText);
    });
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
    print(showResults.length);
    return showResults;
  }
}
