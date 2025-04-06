import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'customText.dart';
import 'loading.dart';

class CustomStreamBuilder extends StatelessWidget {
  final BuildContext context;
  final Stream stream;
  final Function body;

  const CustomStreamBuilder({Key key,
    @required this.context,
    @required this.stream,
    @required this.body,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          return snapshot.hasData
              ? body(snapshot)
          : snapshot.connectionState == ConnectionState.waiting ? SizedBox(
            height: MediaQuery.of(context).size.height/2 + 100,
              child: Center(child: LoadingCircle()))
              : snapshot.error ? Center(child: CText(msg: "Something went wrong!!!",color: Colors.black,size: 30.0,))
              : snapshot.data.docs.length == 0 ? Center(child: CText(msg: "No Records Found!!!",color: Colors.black,size: 30.0,))
              : Center(child: LoadingCircle());
        },
      );
    }
  }
