import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:mrs_dth_diary_v1/scr/providers/village.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/customText.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/homeCard.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/screen_navigation.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'CreateNewUserPage.dart';
import 'DashBoard/DashBoard.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin{
  ScrollController controller=ScrollController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedIndex==0? Home()
      : _selectedIndex ==1 ? DashBoard()
      : _selectedIndex==2? CreateNewUser()
      : Container(),
      bottomNavigationBar: CurvedNavigationBar(
        height: 60.0,
        backgroundColor: _selectedIndex==2? kPrimaryColor.withOpacity(0.7) : Colors.white,
        color: kPrimaryColor,
        items: <Widget>[
          Icon(Icons.home, size: 30,color: white),
          Icon(Icons.dashboard, size: 30,color:white),
          Icon(Icons.person_add_alt, size: 30,color: white),
        ],
        onTap: (index)=>setState(()=>_selectedIndex=index),
      ),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  RefreshController _refreshController =
  RefreshController(initialRefresh: true);

  void _onRefresh() async{
    ///ToDO Update Counter
    setState(() {});
    print("___On Refresh_______________");
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.refreshCompleted();
  }

  void _onLoading() async{
    setState(() {});
    await Future.delayed(Duration(milliseconds: 1000));
    print("___On Loading_______________");
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context)  {
    return SmartRefresher(
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      enablePullDown: true,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: VillageProvider.initialize()),
        ],
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(25.0),
                        bottomLeft: Radius.circular(25.0))
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0,top: 40.0,bottom: 10.0),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/diary.png',
                            height: 100,
                            width: 100,
                          ),
                          SizedBox(width: 20.0,),
                          CText(msg: "My Diary",
                            color: white,
                            textAlign: TextAlign.center,
                            weight: FontWeight.bold,
                            size: 40.0,
                            fontFamily: "ShortBaby",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5.0,),

              HomeCard(context: context),
            ],
          ),
        ),
      ),
    );
  }
}
