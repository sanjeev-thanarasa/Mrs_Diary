

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamond_notched_fab/diamond_notched_fab.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CToast.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CustomListTile.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CustomStreamBuilder.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/ShowPopUpAlertBox.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/customText.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/screen_navigation.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';
import 'package:uuid/uuid.dart';

import 'dashBoardUserDetails.dart';

class DashBoard extends StatefulWidget {
  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  ScrollController _controller = ScrollController();
  CollectionReference collectionReference;

  @override
  void initState() {
    collectionReference = FirebaseFirestore.instance.collection("DashBoard");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: CText(
          msg: "   எனது கணக்கு விபரங்கள் ",
          size: 20.0,
          color: white,
        ),
        centerTitle: true,
        elevation: 5.0,
        leading: Padding(
          padding: EdgeInsets.only(left: 5.0),
          child: Icon(Icons.dashboard),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 15.0,
            ),
            CustomStreamBuilder(
                context: context,
                stream: collectionReference.snapshots(),
                body: (snap) {
                  return ListView.builder(
                    scrollDirection: Axis.vertical,
                    controller: _controller,
                    shrinkWrap: true ,
                    itemCount: snap.data.docs.length,
                    itemBuilder: (_, index) {
                      var data = snap.data.docs[index];
                      print("${data["id"]}>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
                      return CListTile(
                        context: context,
                        docId: data["id"].toString(),
                        collectionName: "DashBoard",
                        tileOnTap: ()=> changeScreenAnimated(context, DashBoardUserDetails(data: data,)),
                        title: data["name"],
                        subtitle: "${DateFormat.yMMMd().add_jm().format(data["createAt"].toDate()).toString()}",
                        subtitleIcon: Icons.access_time,
                        counter: "${index+1}",
                      );

                    },
                  );
                }

            )
            // CustomStreamBuilder(
            //   context: context,
            //   stream: collectionReference.snapshots(),
            //   scrollController: _controller,
            //   titleField: "name",
            //   collectionName: "DashBoard",
            //   subtitleIcon: Icons.double_arrow,
            // )
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 16,bottom: 16),
        child: Container(
          height: 45,
          width: 45,
          child: DiamondNotchedFab(
            onPressed:(){
              showDialog(context: context, builder: (context) {
                return new SimpleDialog(
                    backgroundColor: Colors.transparent,
                    elevation: 0.0,
                    children: <Widget>[
                      new PopUpBox(
                        hintText: "TopUp Name",
                        labelText: "Create New TopUP",
                        btnText: "CREATE",
                        bthFunction: (text) {
                          String id = Uuid().v1();
                          collectionReference.doc(id).set({
                            "id": id,
                            "name": text,
                            "createAt" : DateTime.now(),

                          });
                        },
                        context: context,
                      )]);
              });
            },
            backgroundColor: kPrimaryColor,
            child: Icon(Icons.add,color: Colors.white,),
            borderRadius:10,
            highlightElevation: 0,
            mini: true,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
