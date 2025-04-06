import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mrs_dth_diary_v1/scr/models/totalCustomers.dart';
import 'package:mrs_dth_diary_v1/scr/ui/userDetails.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CAppBar.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CustomListTile.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CustomStreamBuilder.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/customText.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/noResultFound.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/screen_navigation.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';

class TodayPaymentUsers extends StatefulWidget {
  @override
  _TodayPaymentUsersState createState() => _TodayPaymentUsersState();
}

class _TodayPaymentUsersState extends State<TodayPaymentUsers> {

  String searchText='';
  int _radioValue=0;
  bool searchVisible=false;
  DateTime _dateTodayStart;
  DateTime _dateTodayEnd;
  String formattedDateStart = "${DateFormat('yyyyMMdd').format(DateTime.now())}T000000";
  String formattedDateEnd = "${DateFormat('yyyyMMdd').format(DateTime.now())}T235959";
  CollectionReference paymentRecords;
  CollectionReference oldUser;
  ScrollController _controller = ScrollController();


  @override
  void dispose() {
    searchText=null;
    super.dispose();
  }

  @override
  void initState() {
    _dateTodayStart = DateTime.parse(formattedDateStart);
    _dateTodayEnd = DateTime.parse(formattedDateEnd);
    paymentRecords = FirebaseFirestore.instance.collection("PaymentRecords");
    oldUser = FirebaseFirestore.instance.collection("OldUser");
    
    print(formattedDateStart+"Started Date >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    print(formattedDateEnd+"Ended Date >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
  
    super.initState();
  }

  /// _dateTime = DateTime.parse('20210205T000000'); this is a timestamp format
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white.withOpacity(.9),
      appBar: CustomAppBar(
        hintText: "இன்று பணம் தர வேண்டியவர்கள்",
        prefixIcon: Icons.arrow_back,
        iconOnTap : ()=> Navigator.pop(context),
        onChanged: (text)=>_onSearchChanged(text),
        logoOnTap: ()=>setState(()=>searchVisible=!searchVisible),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Visibility(
              visible: searchVisible,
              child: Expanded(
                  flex: 0,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15.0,bottom: 15.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildRadio(value: 0,name: "Name"),
                            _buildRadio(value: 1,name: "DishNumber"),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildRadio(value: 2,name: "Mobile No"),
                            _buildRadio(value: 3,name: "Dish Type"),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildRadio(value: 4,name: "Village"),
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
                      .where("PENDING_DATE",  isGreaterThan:_dateTodayStart)
                     .where("PENDING_DATE",  isLessThanOrEqualTo:_dateTodayEnd)
                      .snapshots(),
                  body: (todayPayTotUsers){
                    print("todayPayTotUsers>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>${todayPayTotUsers.data.docs.length}");
                    return todayPayTotUsers.data.docs.length > 0
                        ? ListView.builder(
                        scrollDirection: Axis.vertical,
                        controller: _controller,
                        shrinkWrap: true ,
                        itemCount: todayPayTotUsers.data.docs.length,
                        itemBuilder: (_,index){
                          var todayPayTotalUsers = todayPayTotUsers.data.docs[index];
                        return CustomStreamBuilder(
                            context: context,
                            stream: oldUser
                                .where("id",  isEqualTo: todayPayTotalUsers['USER_ID']).snapshots(),
                            body:(snapshot){
                              var showResults = _searchResultsList(snapshot.data.docs);
                              print(showResults.length);
                              print("showResults.length>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>${showResults.length}");
                              return showResults.length > 0
                                  ? ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  controller: _controller,
                                  shrinkWrap: true ,
                                  itemCount: showResults.length,
                                  itemBuilder: (_,index){
                                    print('${showResults[index].id}  QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ');
                                    print( '${showResults[index]['id']}  QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ');
                                    print( '${showResults.length}  QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ');
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
                                      counter: "${index+1}",
                                    );
                                  }
                              )
                              : SearchNoData();
                            },
                        );
                      }
                    )
                        :SearchNoData();
                  }
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildRadio({int value, String name}){
    return Row(
      children: [
        Radio(
          value: value,
          activeColor: Colors.blue,
          groupValue: _radioValue,
          onChanged: _handleRadioValueChange,
        ),
        CText(msg: name,color: Colors.black,size: 20.0,),
      ],
    );
  }

  _handleRadioValueChange(int value){
    setState(() {
      _radioValue=value;
    });
  }

  _onSearchChanged(String text) {
    setState(() {
      searchText=text;
      print(searchText);
    });
    // searchResultsList();
    print(searchText);
  }

  _searchResultsList(var snapshots) {
    var showResults = [];

    if(searchText != "") {
      for(var snapshot in snapshots){
        var title;
        switch(_radioValue){
          case 0 :
            {title = TotalCustomersFilterize.fromSnapshot(snapshot).name.toLowerCase();}
            break;
          case 1:
            {title = TotalCustomersFilterize.fromSnapshot(snapshot).dishNumber.toLowerCase();}
            break;
          case 2:
            {title = TotalCustomersFilterize.fromSnapshot(snapshot).mobileNo.toLowerCase();}
            break;
          case 3:
            {title = TotalCustomersFilterize.fromSnapshot(snapshot).dishType.toLowerCase();}
            break;
          case 4:
            {title = TotalCustomersFilterize.fromSnapshot(snapshot).villageName.toLowerCase();}
            break;
          default: {_radioValue=0;}
          break;
        }

        if(title.contains(searchText.toLowerCase())) {
          showResults.add(snapshot);
        }
      }
    } else {
      showResults = List.from(snapshots);
    }
    return showResults;
  }
}
