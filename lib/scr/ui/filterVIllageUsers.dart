import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mrs_dth_diary_v1/scr/models/filterUser.dart';
import 'package:mrs_dth_diary_v1/scr/ui/userDetails.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CAppBar.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CustomListTile.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CustomStreamBuilder.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/customText.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/noResultFound.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/screen_navigation.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';


class FilterVillageUser extends StatefulWidget {
  final String villageName;

  const FilterVillageUser({Key key, this.villageName}) : super(key: key);
  @override
  _FilterVillageUserState createState() => _FilterVillageUserState();
}

class _FilterVillageUserState extends State<FilterVillageUser> {
  String searchText='';
  int _radioValue=0;
  bool searchVisible=false;
  ScrollController _controller = ScrollController();
  String counter="0";
  Widget pushMe=Image.asset("assets/images/push.png",height: 50,width: 50,);

  @override
  void dispose() {
    searchText=null;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white.withOpacity(.9),
      appBar: CustomAppBar(
        hintText: widget.villageName,
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
                      ],
                    ),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: CustomStreamBuilder(
                  context: context,
                  stream: stream(),
                  body: (snapshot){
                    var showResults = _searchResultsList(snapshot.data.docs);
                    return showResults.length >0
                        ? ListView.builder(
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
                            counter: "${index+1}",
                          );
                        }
                    )
                        : SearchNoData();
                  }
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        shape: _CustomBorder(),
        child: pushMe,
        onPressed: (){
          setState(() {
            pushMe=CText(
              size: 20.0,
              color: Colors.white,
              msg: counter,
            );
          });
        },
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
    counter=snapshots.length.toString();
    var showResults = [];
    if(searchText != "") {
      for(var snapshot in snapshots){
        var title;
        switch(_radioValue){
          case 0 :
            {title = FilterUser.fromSnapshot(snapshot).name.toLowerCase();}
            break;
          case 1:
            {title = FilterUser.fromSnapshot(snapshot).dishNumber.toLowerCase();}
            break;
          case 2:
            {title = FilterUser.fromSnapshot(snapshot).mobileNo.toLowerCase();}
            break;
          case 3:
            {title = FilterUser.fromSnapshot(snapshot).dishType.toLowerCase();}
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

  Stream<QuerySnapshot> stream() async* {
    var firestore = FirebaseFirestore.instance;
    var _stream = firestore
        .collection("OldUser")
        .where('area', isEqualTo: widget.villageName)
        .snapshots();
    yield* _stream;
  }
}

class _CustomBorder extends ShapeBorder {
  const _CustomBorder();

  @override
  EdgeInsetsGeometry get dimensions {
    return const EdgeInsets.only();
  }

  @override
  Path getInnerPath(Rect rect, { TextDirection textDirection }) {
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, { TextDirection textDirection }) {
    return Path()
      ..moveTo(rect.left + rect.width / 2.0, rect.top)
      ..lineTo(rect.right - rect.width / 3, rect.top + rect.height / 3)
      ..lineTo(rect.right, rect.top + rect.height / 2.0)
      ..lineTo(rect.right - rect.width / 3, rect.top + 2*rect.height / 3)
      ..lineTo(rect.left + rect.width  / 2.0, rect.bottom)
      ..lineTo(rect.left + rect.width / 3, rect.top + 2*rect.height / 3)
      ..lineTo(rect.left, rect.top + rect.height / 2.0)
      ..lineTo(rect.left + rect.width / 3, rect.top + rect.height / 3)
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, { TextDirection textDirection }) {}

  // This border doesn't support scaling.
  @override
  ShapeBorder scale(double t) {
    return null;
  }
}
