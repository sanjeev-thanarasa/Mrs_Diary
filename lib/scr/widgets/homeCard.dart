import 'package:flutter/material.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/homeProductList.dart';
import 'package:mrs_dth_diary_v1/scr/providers/village.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';
import 'package:provider/provider.dart';

import 'customText.dart';


class HomeCard extends StatefulWidget {
  final BuildContext context;

  const HomeCard({Key key, this.context}) : super(key: key);

  @override
  _HomeCardState createState() => _HomeCardState();
}

class _HomeCardState extends State<HomeCard> {
  var windowWidth;
  var windowHeight;

  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final villageProvider = Provider.of<VillageProvider>(context);
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    return Container(
        margin: EdgeInsets.only(top: 10.0),
        child: ListView(
            controller: _scrollController,
            padding: EdgeInsets.only(top: 0),
            shrinkWrap: true,
            children: _children(villageProvider)
        )
    );
  }

  _children(
      VillageProvider villageProvider,
      ){
    var list = List<Widget>();

    for (var item in homeProductList)
      list.add(Container(
        margin: EdgeInsets.only(left: 10, right: 10,top: 2,bottom: 2),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.only(top: 2,bottom: 2),
            child: _TransitionListTile(
              leadingImage: item.image,
              title: CText(
                msg: "   ${item.text}",
                color: kPrimaryColor,
                size: 20.0,
                textAlign: TextAlign.center,
                fontFamily: "TamilArima",
              ),
              onTap: ()=> item.onTapCard(context),
              count: lengthCounter(item.text, villageProvider),
            ),
          ),
        ),
      ),
      );

    list.add(SizedBox(height: 15,));

    return list;
  }

  lengthCounter(String title ,VillageProvider villageProvider, ){

    if(title == "கிராமங்கள்"){
      if(villageProvider.village.isNotEmpty){
        return villageProvider.village.length;
      }else{return 0;}
    }
    else if(title == "பழைய பயனர்கள்"){
      if(villageProvider.totalOldCustomersCount.isNotEmpty){
        return villageProvider.totalOldCustomersCount.length;
      }else{return 0;}
    }
    else if(title == "புதிய பயனர்கள்"){
      if(villageProvider.totalNewCustomersCount.isNotEmpty){
        return villageProvider.totalNewCustomersCount.length;
      }else{return 0;}
    }
    else if(title == "இன்று பணம் தர வேண்டியவர்கள்"){
      if(villageProvider.todayPaymentCount.isNotEmpty){
        return villageProvider.todayPaymentCount.length;
      }else{return 0;}
    }
    else if(title == "இன்று Recharge முடியும் நபர்கள்"){
      if(villageProvider.todayExpiredCount.isNotEmpty){
        return villageProvider.todayExpiredCount.length;
      }else{return 0;}
    }
    else if(title == "கொடுமதிகள்"){
      if(villageProvider.totalBalanceCount.isNotEmpty){
        return villageProvider.totalBalanceCount.length;
      }else{return 0;}
    }
    else if(title == "தருமதிகள்"){
      if(villageProvider.totalPendingCount.isNotEmpty){
        return villageProvider.totalPendingCount.length;
      }else{return 0;}
    }
    else if(title == "பணம் தந்தவர்கள்"){
      if(villageProvider.totalPaidCount.isNotEmpty){
        return villageProvider.totalPaidCount.length;
      }else{return 0;}
    }


    else{return 0;}
  }


}

class _TransitionListTile extends StatelessWidget {
  const _TransitionListTile({
    this.onTap,
    this.title,
    this.leadingImage,
    this.count=0,
  });

  final GestureTapCallback onTap;
  final Widget title;
  final String leadingImage;
  final int count;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15.0,
      ),
      leading: Stack(
        children: [
          Container(
            width: 80.0,
            height: 80.0,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(leadingImage),
                fit: leadingImage == "assets/images/payment.png" || leadingImage == "assets/images/balance.png" || leadingImage =="assets/images/currency.png"
                    ? BoxFit.fitHeight : BoxFit.cover
              ),
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: Colors.grey,
              ),
            ),
            //child: Image.asset(leadingImage,fit: BoxFit.fitHeight,),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: count == 0 ? Image.asset("assets/images/smily.png",height: 30,width: 30,)
            : Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color:  kPrimaryColor,
              ),
              height: 15,
              width: 40,
              child: CText(
                msg: "$count",
                color: Colors.white,
                size: 12.0,
                textAlign: TextAlign.center,
                weight: FontWeight.bold,),
            ),
          )
        ],
      ),
      onTap: onTap,
      title: title,
    );
  }
}