import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mrs_dth_diary_v1/scr/providers/village.dart';
import 'package:mrs_dth_diary_v1/scr/ui/filterVIllageUsers.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CAppBar.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CustomListTile.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CustomStreamBuilder.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/ShowPopUpAlertBox.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/noResultFound.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/screen_navigation.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class VillagesList extends StatefulWidget {
  @override
  _VillagesListState createState() => _VillagesListState();
}

class _VillagesListState extends State<VillagesList> {
  ScrollController _controller = ScrollController();
  late final CollectionReference collectionReference;
  String searchText = '';

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    collectionReference = FirebaseFirestore.instance.collection("Villages");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final villageProvider = Provider.of<VillageProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white.withValues(alpha: .9),
      appBar: CustomAppBar(
        prefixIcon: Icons.arrow_back,
        logoOnTap: () {},
        iconOnTap: () => Navigator.pop(context),
        onChanged: (text) => setState(() => searchText = text),
        hintText: "கிராமங்கள்",
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 15.0,
            ),
            CustomStreamBuilder(
                context: context,
                stream: searchText.isEmpty
                    ? collectionReference.snapshots()
                        as Stream<QuerySnapshot<Map<String, dynamic>>>
                    : collectionReference
                            .orderBy("name")
                            .startAt([searchText]).endAt(
                                [searchText + '\uf8ff']).snapshots()
                        as Stream<QuerySnapshot<Map<String, dynamic>>>,
                body: (snap) {
                  final docs = snap.data?.docs ?? [];
                  // print("${snap.data.docs.length}QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ");
                  // print("${snap.data.docs.runtimeType}QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ");
                  return docs.isNotEmpty
                      ? ListView.builder(
                          scrollDirection: Axis.vertical,
                          controller: _controller,
                          shrinkWrap: true,
                          itemCount: docs.length,
                          itemBuilder: (_, index) {
                            var data = docs[index];

                            ///TODO load more date with in 10 of 10

                            // print(data["id"]);
                            return CListTile(
                              context: context,
                              docId: data["id"].toString(),
                              collectionName: "Villages",
                              tileOnTap: () => changeScreenAnimated(context,
                                  FilterVillageUser(villageName: data["name"])),
                              title: data["name"],
                              subtitle:
                                  "${DateFormat.yMMMd().add_jm().format(data["createAt"].toDate()).toString()}",
                              subtitleIcon: Icons.access_time,
                              counter: "${index + 1}",
                            );
                          },
                        )
                      : SearchNoData();
                })
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 16, bottom: 16),
        child: FloatingActionButton(
          mini: true,
          backgroundColor: kPrimaryColor,
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return SimpleDialog(
                    elevation: 0.0,
                    backgroundColor: Colors.transparent,
                    children: <Widget>[
                      PopUpBox(
                        hintText: "Enter Village Name",
                        labelText: "Create New Village",
                        btnText: "CREATE",
                        bthFunction: (text) {
                          villageProvider.editControllerName.text = text;
                          String id = Uuid().v1();
                          villageProvider.uploadVillage(id: id);
                        },
                        context: context,
                      )
                    ],
                  );
                });
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
