import 'dart:ui';

import 'package:blur/blur.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:waterly/controllers/AppController.dart';
import 'package:waterly/database/AppDatabase.dart';
import 'package:waterly/extensions/GetMonthName.dart';
import 'package:waterly/extensions/HexColor.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:ui' as ui;

import 'package:waterly/screens/get_premium_screen.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final AppController controller = Get.find();

  AppDatabase appDatabase = AppDatabase();

  var days = [
    DateTime.now(),
    DateTime.now().subtract(Duration(days: 1)),
    DateTime.now().subtract(Duration(days: 2)),
    DateTime.now().subtract(Duration(days: 3)),
    DateTime.now().subtract(Duration(days: 4)),
    DateTime.now().subtract(Duration(days: 5)),
    DateTime.now().subtract(Duration(days: 6)),
    DateTime.now().subtract(Duration(days: 7)),
  ];

  var data = [];

  loadData() {
    for (var i = 0; i < days.length; i++) {
      setState(() {
        data.add(appDatabase.loadData(days[i]));
      });
    }
  }

  bool userIsPremium = false;
  late CustomerInfo customerInfo;
  Future<void> initPlatformStateForSubscription() async {
    await Purchases.setDebugLogsEnabled(true);
    await Purchases.setup("goog_jYhcXfxjwBFrvfwMCKjvrtpSCRr");
    customerInfo = await Purchases.getCustomerInfo();

    // User premium check
    if (customerInfo.entitlements.all["premium"] != null &&
        customerInfo.entitlements.all["premium"]!.isActive) {
      setState(() {
        userIsPremium = true;
      });
    } else {
      userIsPremium = false;
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
    initPlatformStateForSubscription();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          backgroundColor: HexColor("#ffffff"),
          appBar: appBar(),
          body: body(),
        ),
        onWillPop: () async {
          controller.updateData();
          return true;
        });
  }

  appBar() {
    return AppBar(
      foregroundColor: HexColor("#46436a"),
      toolbarHeight: 100,
      centerTitle: true,
      backgroundColor: HexColor("#ffffff"),
      elevation: 0,
      title: Text(
        "Waterly",
        style: GoogleFonts.roboto(
            fontSize: 28,
            color: HexColor("#46436a"),
            fontWeight: FontWeight.bold),
      ),
      actions: [
        GestureDetector(
          onTap: () {
            showDialog(
                context: context,
                builder: (_) => AlertDialog(
                      content: infoModal(),
                    ));
          },
          child: Padding(
            padding: EdgeInsets.only(right: 38),
            child: Icon(
              Icons.info_outline,
              size: 28,
              color: HexColor("#46436a"),
            ),
          ),
        )
      ],
    );
  }

  body() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        itemCount: 7,
        itemBuilder: (context, index) {
          return userIsPremium == true
              ? dayBuilder(
                  days[index].day.toString() +
                      " " +
                      GetMonthName().find(days[index].month),
                  data[index])
              : unvisiblelist(
                  index,
                  days[index].day.toString() +
                      " " +
                      GetMonthName().find(days[index].month),
                  data[index]);
        },
      ),
    );
  }

  dayBuilder(String date, List<dynamic> data) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$date",
            style: GoogleFonts.roboto(
                fontSize: 21,
                color: HexColor("#46436a"),
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10,
          ),
          data.length > 0
              ? ListView.builder(
                  itemCount: data.length,
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return card(data[index]['value'], data[index]['date']);
                  },
                )
              : Text(
                  "",
                  style: GoogleFonts.roboto(),
                )
        ],
      ),
    );
  }

  unvisiblelist(int index, String date, List<dynamic> data) {
    if (index == 0) {
      return dayBuilder(date, data);
    } else if (index == 3) {
      return Stack(
        children: [
          blurWidget(dayBuilder(date, data)),
          Row(
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
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.workspace_premium),
                      SizedBox(width: 6),
                      Text(
                        "premium_listheader",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ).tr(),
                      SizedBox(width: 6),
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
        ],
      );
    } else {
      return blurWidget(dayBuilder(date, data));
    }
  }

  blurWidget(Widget widget) {
    return Blur(blur: 4.5, child: widget);
  }

  getPremium() {
    return ListView(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      children: [],
    );
  }

  deleteHabit(int index) {
    /*
    setState(() {
      todoList = db.loadData(_singleDatePickerValueWithDefaultValue[0]!);
      db.updateDatabase(_singleDatePickerValueWithDefaultValue[0]!, todoList);
      todoList.removeAt(index);
    });
    db.updateDatabase(_singleDatePickerValueWithDefaultValue[0]!, todoList);
    */
  }

  card(int value, DateTime time) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: Slidable(
          endActionPane: ActionPane(
            motion: const StretchMotion(),
            children: [
              SlidableAction(
                onPressed: (context) {
                  appDatabase.removeData(time);
                  loadData();
                },
                backgroundColor: Colors.red.shade400,
                icon: Icons.delete,
                borderRadius: BorderRadius.circular(12),
              )
            ],
          ),
          child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: HexColor("#ffffff"),
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
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      iconFinder(value),
                      SizedBox(
                        width: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${value.toString()} ml",
                            style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: HexColor("#46436a"),
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "${time.hour.toString() + ":" + time.minute.toString()}",
                            style: GoogleFonts.roboto(
                                fontSize: 13,
                                color: HexColor("#46436a"),
                                fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ]),
                    Icon(
                      Icons.arrow_forward_outlined,
                      size: 24,
                      color: HexColor("#46436a"),
                    ),
                  ],
                ),
              ))),
    );
  }

  iconFinder(int value) {
    if (value == 180) {
      return Icon(
        Icons.water_drop_outlined,
        size: 34,
        color: HexColor("#46436a"),
      );
    } else if (value == 250) {
      return Image(
          width: 30,
          height: 30,
          fit: BoxFit.cover,
          image: AssetImage("assets/icons/glass_icon.png"));
    } else if (value == 330) {
      return Icon(
        Icons.coffee_outlined,
        size: 34,
        color: HexColor("#46436a"),
      );
    } else {
      return Image(
          width: 30,
          height: 30,
          fit: BoxFit.cover,
          image: AssetImage("assets/icons/bottle_icon.png"));
    }
  }

  infoModal() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.info_outline_rounded,
          color: HexColor("#46436a"),
          size: 38,
        ),
        SizedBox(
          height: 20,
        ),
        Text(
          "info_modal_1",
          style: GoogleFonts.roboto(
              fontSize: 16,
              color: HexColor("#46436a"),
              fontWeight: FontWeight.bold),
        ).tr(),
        SizedBox(
          height: 20,
        ),
        Text(
          "info_modal_2",
          style: GoogleFonts.roboto(
              fontSize: 16,
              color: HexColor("#46436a"),
              fontWeight: FontWeight.bold),
        ).tr(),
        SizedBox(
          height: 20,
        ),
        Text(
          "info_modal_3",
          style: GoogleFonts.roboto(
              fontSize: 14,
              color: HexColor("#46436a"),
              fontWeight: FontWeight.bold),
        ).tr(),
      ],
    );
  }
}
