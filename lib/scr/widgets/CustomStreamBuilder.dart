import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'customText.dart';
import 'loading.dart';

class CustomStreamBuilder extends StatelessWidget {
  final BuildContext context;
  final Stream<QuerySnapshot<Map<String, dynamic>>> stream;
  final Widget Function(
      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) body;

  const CustomStreamBuilder({
    super.key,
    required this.context,
    required this.stream,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: CText(
              msg: "Something went wrong!!!",
              color: Colors.black,
              size: 30.0,
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting ||
            !snapshot.hasData) {
          return SizedBox(
            height: MediaQuery.of(context).size.height / 2 + 100,
            child: const LoadingShimmerList(),
          );
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(
            child: CText(
              msg: "No Records Found!!!",
              color: Colors.black,
              size: 30.0,
            ),
          );
        }

        return body(snapshot);
      },
    );
  }
}
