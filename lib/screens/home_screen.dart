import 'dart:io';
import 'dart:math';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:waterly/components/MyAppBar.dart';
import 'package:waterly/controllers/AppController.dart';
import 'package:waterly/database/AppDatabase.dart';
import 'package:waterly/extensions/HexColor.dart';
import 'package:waterly/screens/get_premium_screen.dart';
import 'package:waterly/screens/stats_screen.dart';
import 'package:waterly/screens/water_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AppController controller = Get.find();

  AppDatabase appDatabase = AppDatabase();

  var data = [];
  var user = {};

  num totalAmount = 0;
  num remainingAmount = 0;
  num completedRate = 0;

  updateData() {
    setState(() {
      totalAmount = 0;
      data = appDatabase.loadData(DateTime.now());
      for (var element in data) {
        totalAmount += element['value'];
      }
      remainingAmount = (double.parse(user['needwater']) * 1000) - totalAmount;
      if ((double.parse(user['needwater']) * 1000) < totalAmount) {
        remainingAmount =
            totalAmount - (double.parse(user['needwater']) * 1000);
      }
      completedRate =
          (totalAmount * 100) / (double.parse(user['needwater']) * 1000);
      if (completedRate >= 100) {
        completedRate = 100;
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      user = appDatabase.loadUser();
    });
    updateData();
  }

  @override
  Widget build(BuildContext context) {
    controller.count.listen((value) {
      updateData();
    });
    return Scaffold(
      backgroundColor: HexColor("#ffffff"),
      appBar: MyAppBar(appBar: AppBar()),
      body: body(),
      bottomNavigationBar: bottomNavigation(),
    );
  }

  body() {
    return SafeArea(
        child: Stack(
      children: [
        Stack(
          children: [
            ListView(
              children: [
                SizedBox(height: 100),
                circle(),
                SizedBox(height: 80),
                buttons(),
              ],
            ),
          ],
        ),
      ],
    ));
  }

  bottomNavigation() {
    return Padding(
      padding: EdgeInsets.only(left: 40, right: 40, bottom: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          bottomNavigationItem(
              1,
              HexColor("#ffffff"),
              Icon(
                Icons.water_drop_outlined,
                color: HexColor("#323163"),
              )),
          bottomNavigationItem(
              2,
              HexColor("#323163"),
              Icon(
                Icons.circle_outlined,
                color: HexColor("#ffffff"),
              )),
          bottomNavigationItem(
              3,
              HexColor("#ffffff"),
              Icon(
                Icons.list_alt_rounded,
                color: HexColor("#323163"),
              )),
        ],
      ),
    );
  }

  bottomNavigationItem(int id, Color backgroundColor, Icon icon) {
    return GestureDetector(
      onTap: () {
        if (id == 1) {
          Navigator.of(context).push(PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const WaterScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.ease;

              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          ));
        }
        if (id == 3) {
          Navigator.of(context).push(PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const StatsScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.ease;

              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          ));
        }
      },
      child: Container(
          width: 80,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade400,
                offset: Offset(0.0, 1.0), //(x,y)
                blurRadius: 6.0,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: icon,
          )),
    );
  }

  circle() {
    return CircularPercentIndicator(
      radius: 100.0,
      lineWidth: 9,
      percent: completedRate / 100,
      center: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(
          "${completedRate.toStringAsFixed(0)} %",
          style: GoogleFonts.roboto(
              fontSize: 34,
              color: HexColor("#46436a"),
              fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 6),
        Text(
          "${totalAmount} ml",
          style: GoogleFonts.roboto(
              fontSize: 18,
              color: HexColor("#7b7892"),
              fontWeight: FontWeight.w400),
        ),
        SizedBox(height: 6),
        Text(
          (double.parse(user['needwater']) * 1000) > totalAmount
              ? "- ${remainingAmount} ml"
              : "+ ${remainingAmount} ml",
          style: GoogleFonts.roboto(
              fontSize: 14,
              color: (double.parse(user['needwater']) * 1000) > totalAmount
                  ? HexColor("#e7e6eb")
                  : Colors.green,
              fontWeight: FontWeight.w400),
        ),
      ]),
      backgroundColor: HexColor("#f3f7ff"),
      progressColor: HexColor("#7671fe"),
      animation: true,
      animateFromLastPercent: true,
    );
  }

  buttons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              button(
                HexColor("#eeeeff"),
                Icon(
                  Icons.water_drop_outlined,
                  color: HexColor("#46436a"),
                ),
                180,
                "",
              ),
              button(
                HexColor("#f8f8f8"),
                Icon(
                  Icons.home,
                  color: HexColor("#46436a"),
                ),
                250,
                "assets/icons/glass_icon.png",
              )
            ],
          ),
          SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              button(
                HexColor("#fff8ed"),
                Icon(
                  Icons.coffee_outlined,
                  color: HexColor("#46436a"),
                ),
                330,
                "",
              ),
              button(
                HexColor("#f9e9e5"),
                Icon(
                  Icons.home,
                  color: HexColor("#46436a"),
                ),
                500,
                "assets/icons/bottle_icon.png",
              )
            ],
          ),
        ],
      ),
    );
  }

  button(Color backgroundColor, Icon icon, int value, String asset) {
    return GestureDetector(
      onTap: () {
        var findData = appDatabase.loadData(DateTime.now());
        findData.add({"value": value, "date": DateTime.now()});
        appDatabase.updateDatabase(DateTime.now(), findData);
        updateData();
        _showSnackBar(value);
      },
      child: Container(
          width: (MediaQuery.of(context).size.width / 2) - 40,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade400,
                offset: Offset(0.0, 1.0), //(x,y)
                blurRadius: 6.0,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                asset.length == 0
                    ? icon
                    : Image(
                        width: 26,
                        height: 26,
                        fit: BoxFit.cover,
                        image: AssetImage(asset)),
                SizedBox(width: 10),
                Text(
                  "${value.toString()} ml",
                  style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: HexColor("#46436a"),
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )),
    );
  }

  _showSnackBar(int ml) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: tr("home_screen_water_add_title", args: [ml.toString()]),
        message: tr("home_screen_water_add_desc", args: [ml.toString()]),
        contentType: ContentType.help,
        inMaterialBanner: true,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  getPremiumBanner() {
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => GetPremiumScreen(),
                  transitionDuration: Duration(milliseconds: 300),
                  transitionsBuilder: (_, a, __, c) =>
                      FadeTransition(opacity: a, child: c),
                ),
              );
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.workspace_premium),
                  SizedBox(width: 8),
                  Text(
                    "premium_homeheader",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ).tr(),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
