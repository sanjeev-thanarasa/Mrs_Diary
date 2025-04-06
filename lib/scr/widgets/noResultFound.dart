import 'package:flutter/material.dart';

class SearchNoData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height*.5,
      width: MediaQuery.of(context).size.width*.85,
      child: Center(
        child: Image.asset("assets/images/noResults.png")),
    );
  }
}
