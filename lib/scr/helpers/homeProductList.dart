

import 'package:mrs_dth_diary_v1/scr/models/homeProduct.dart';
import 'package:mrs_dth_diary_v1/scr/ui/VillagesPage.dart';
import 'package:mrs_dth_diary_v1/scr/ui/splashScreen.dart';
import 'package:mrs_dth_diary_v1/scr/ui/todayPackageExpiredUsers.dart';
import 'package:mrs_dth_diary_v1/scr/ui/todayPaymentUsers.dart';
import 'package:mrs_dth_diary_v1/scr/ui/totalBalanceUsers.dart';
import 'package:mrs_dth_diary_v1/scr/ui/totalNewCustomers.dart';
import 'package:mrs_dth_diary_v1/scr/ui/totalOldCustomers.dart';
import 'package:mrs_dth_diary_v1/scr/ui/totalPaidUsers.dart';
import 'package:mrs_dth_diary_v1/scr/ui/totalPendingUsers.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/screen_navigation.dart';
List<HomeProduct> homeProductList = [
  HomeProduct(
      image: "assets/images/villages.png",
      text: "கிராமங்கள்",
      onTapCard: (context) => changeScreenAnimated(context, VillagesList())),
  HomeProduct(
      image: "assets/images/users.png",
      text: "பழைய பயனர்கள்",
      onTapCard: (context) => changeScreenAnimated(context, TotalOldCustomers())),
  HomeProduct(
      image: "assets/images/users1.png",
      text: "புதிய பயனர்கள்",
      onTapCard: (context) => changeScreenAnimated(context, TotalNewCustomers())),

  HomeProduct(
      image: "assets/images/payment.png",
      text: "இன்று பணம் தர வேண்டியவர்கள்",
      onTapCard: (context) => changeScreenAnimated(context, TodayPaymentUsers())),

  HomeProduct(
      image: "assets/images/recharge.png",
      text: "இன்று Recharge முடியும் நபர்கள்",
      onTapCard: (context) => changeScreenAnimated(context, TodayPackageExpiredUsers())),

  HomeProduct(
      image: "assets/images/balance.png",
      text: "கொடுமதிகள்",
      onTapCard: (context) => changeScreenAnimated(context, TotalBalanceUsers())),
  HomeProduct(
      image: "assets/images/currency.png",
      text: "தருமதிகள்",
      onTapCard: (context) => changeScreenAnimated(context, TotalPendingUsers())),
  HomeProduct(
      image: "assets/images/paidMoney.png",
      text: "பணம் தந்தவர்கள்",
      onTapCard: (context) => changeScreenAnimated(context, TotalPaidUsers())),
];