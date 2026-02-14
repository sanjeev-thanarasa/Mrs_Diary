import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/responsive.dart';
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
    final rs = context.rs;
    final colorScheme = Theme.of(context).colorScheme;
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Center(
              child: Text(
                'Something went wrong!!!',
                style: TextStyle(
                  fontSize: rs.sp(16),
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                  fontFamily: 'TamilArima2',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting ||
            !snapshot.hasData) {
          return SizedBox(
            height: MediaQuery.of(context).size.height / 2 + 100,
            child: const Center(child: LoadingCircle()),
          );
        }

        if (snapshot.data!.docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Center(
              child: Text(
                'No results found. Try a different keyword',
                style: TextStyle(
                  fontSize: rs.sp(16),
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                  fontFamily: 'TamilArima2',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return body(snapshot);
      },
    );
  }
}
