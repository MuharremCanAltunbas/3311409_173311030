import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:waterly/components/MyAppBar.dart';
import 'package:waterly/controllers/AppController.dart';
import 'package:waterly/database/AppDatabase.dart';
import 'package:waterly/extensions/HexColor.dart';
import 'package:waterly/screens/get_premium_screen.dart';
import 'package:waterly/screens/home_screen.dart';
import 'package:waterly/screens/water_screen.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final AppController controller = Get.find();
  AppDatabase appDatabase = AppDatabase();

  var user = {};

  var weekData = [];
  var monthData = [];
  var yearData = [];

  num averageData = 0.0;

  String selectedFilter = "Week";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      user = appDatabase.loadUser();
    });
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor("#ffffff"),
      appBar: MyAppBar(appBar: AppBar()),
      body: body(),
      bottomNavigationBar: bottomNavigation(),
    );
  }

  body() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          SizedBox(height: 30),
          tabBarSelect(),
          SizedBox(height: 30),
          averageStats(),
          SizedBox(height: 30),
          change_stats_type(),
        ],
      ),
    );
  }

  change_stats_type() {
    if (selectedFilter == 'Week') {
      return week_stats();
    } else if (selectedFilter == 'Month') {
      return month_stats();
    } else {
      return year_stats();
    }
  }

  getData() {
    if (selectedFilter == 'Week') {
      setState(() {
        weekData = appDatabase.getWeekData();
        weekData = weekData.reversed.toList();
      });
    } else if (selectedFilter == 'Month') {
      setState(() {
        monthData = appDatabase.getMonthData();
      });
    } else {
      setState(() {
        yearData = appDatabase.getYearData();
      });
    }
    getAverageData();
  }

  getAverageData() {
    if (selectedFilter == 'Week') {
      num totalSum = 0;
      num days = 0;
      for (List<dynamic> element in weekData) {
        if (element.length > 0) {
          num todaySum = 0;
          days += 1;
          for (var x in element) {
            todaySum += x["value"];
          }
          totalSum += todaySum;
        }
      }
      setState(() {
        averageData = (totalSum / days) / 1000;
      });
    } else if (selectedFilter == 'Month') {
      num sum = 0;
      num days = 0;
      for (var element in monthData) {
        if (element != 0) {
          sum += element;
          days += 1;
        }
      }
      setState(() {
        averageData = sum / days;
      });
    } else {
      num sum = 0;
      num months = 0;
      for (var element in yearData) {
        if (element != 0) {
          sum += element;
          months += 1;
        }
      }
      setState(() {
        averageData = sum / months;
      });
    }
    if (averageData.isNaN) {
      setState(() {
        averageData = 0.0;
      });
    }
  }

  week_stats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: _createWeekItems(),
    );
  }

  List<Widget> _createWeekItems() {
    return new List<Widget>.generate(weekData.length, (int index) {
      var total = 0.0;
      for (var element in weekData[index]) {
        if (element != null) {
          total += element['value'];
        }
      }

      var needwater = double.parse(user['needwater']);

      return stats_bar(
          total / 1000,
          selectDay(index).toString().substring(0, 2),
          needwater <= (total / 1000) ? true : false,
          (MediaQuery.of(context).size.width / 10),
          12);
    });
  }

  month_stats() {
    DateTime datetime = DateTime.now();
    return Stack(
      children: [
        Container(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GridView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6),
                itemCount: DateTime(datetime.year, datetime.month + 1, 0).day,
                itemBuilder: (BuildContext ctx, index) {
                  return Container(
                    alignment: Alignment.center,
                    color: double.parse(user['needwater']) <= monthData[index]
                        ? Colors.blue.shade300
                        : Colors.white,
                    child: Column(
                      children: [
                        Text(
                          (index + 1).toString(),
                          style: GoogleFonts.roboto(
                              color: double.parse(user['needwater']) <=
                                      monthData[index]
                                  ? Colors.white
                                  : HexColor("#46436a"),
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Text(
                          monthData[index] != 0
                              ? monthData[index].toString()
                              : '',
                          style: GoogleFonts.roboto(
                              color: double.parse(user['needwater']) <=
                                      monthData[index]
                                  ? Colors.white
                                  : Colors.blue,
                              fontWeight: FontWeight.bold),
                        ),
                        double.parse(user['needwater']) <= monthData[index]
                            ? SizedBox(height: 4)
                            : SizedBox(height: 0),
                        double.parse(user['needwater']) <= monthData[index]
                            ? Icon(
                                Icons.done,
                                color: Colors.white,
                                size: 10,
                              )
                            : SizedBox(height: 0)
                      ],
                    ),
                  );
                }),
          ],
        )),
      ],
    );
  }

  year_stats() {
    return Stack(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: _createYearItems(),
        ),
      ],
    );
  }

  List<Widget> _createYearItems() {
    return new List<Widget>.generate(yearData.length, (int index) {
      var needwater = double.parse(user['needwater']);

      return stats_bar(
          yearData[index],
          selectMonth(index + 1).toString().substring(0, 2),
          needwater <= yearData[index] ? true : false,
          (MediaQuery.of(context).size.width / 23),
          10);
    });
  }

  stats_bar(
      num value, String day, bool isCompleted, double size, double fontSize) {
    return SafeArea(
        child: Padding(
      padding: EdgeInsets.only(right: 10),
      child: Column(
        children: [
          Container(
              width: size,
              height: value >= 0.5 ? value * 70 : 30,
              decoration: BoxDecoration(
                color: isCompleted ? HexColor("#7671ff") : Colors.white,
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
                padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      value.toStringAsFixed(1),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                          fontSize: value >= 0.5 ? fontSize : 8,
                          color:
                              isCompleted ? Colors.white : HexColor("#46436a"),
                          fontWeight: FontWeight.bold),
                    ),
                    isCompleted
                        ? Icon(
                            Icons.done,
                            size: 16,
                            color: Colors.white,
                          )
                        : SizedBox(height: 0)
                  ],
                ),
              )),
          SizedBox(height: 10),
          Text(
            day.substring(0, 2),
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
                fontSize: 14,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.bold),
          )
        ],
      ),
    ));
  }

  tabBarSelect() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        tabBarItem("Week", tr("stats_screen_week")),
        tabBarItem("Month", tr("stats_screen_month")),
        tabBarItem("Year", tr("stats_screen_year"))
      ],
    );
  }

  tabBarItem(String id, String title) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = id;
          getData();
        });
      },
      child: Container(
          width: 110,
          height: 50,
          decoration: BoxDecoration(
            color: selectedFilter == id
                ? HexColor("#46436a")
                : HexColor("#ffffff"),
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
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Center(
                child: Text(
              "$title",
              style: GoogleFonts.roboto(
                  fontSize: 18,
                  color: selectedFilter == id
                      ? HexColor("#ffffff")
                      : HexColor("#46436a"),
                  fontWeight: FontWeight.bold),
            )),
          )),
    );
  }

  averageStats() {
    return Row(
      children: [
        Icon(
          Icons.water_drop_outlined,
          color: HexColor("#46436a"),
          size: 60,
        ),
        SizedBox(
          height: 14,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "stats_screen_average",
              style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: HexColor("#46436a"),
                  fontWeight: FontWeight.w400),
            ).tr(),
            SizedBox(height: 4),
            Text(
              "${averageData.toStringAsFixed(2)} L",
              style: GoogleFonts.roboto(
                  fontSize: 26,
                  color: HexColor("#46436a"),
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
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
              HexColor("#ffffff"),
              Icon(
                Icons.circle_outlined,
                color: HexColor("#323163"),
              )),
          bottomNavigationItem(
              3,
              HexColor("#323163"),
              Icon(
                Icons.list_alt_rounded,
                color: HexColor("#ffffff"),
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
        } else if (id == 2) {
          Navigator.of(context).push(PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomeScreen(),
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

  selectDay(int index) {
    if (index == 0) {
      return tr('monday');
    } else if (index == 1) {
      return tr('tuesday');
    } else if (index == 2) {
      return tr('wednesday');
    } else if (index == 3) {
      return tr('thursday');
    } else if (index == 4) {
      return tr('friday');
    } else if (index == 5) {
      return tr('saturday');
    } else if (index == 6) {
      return tr('sunday');
    } else {
      return tr('monday');
    }
  }

  selectMonth(int index) {
    if (index == 1) {
      return tr('january');
    } else if (index == 2) {
      return tr('february');
    } else if (index == 3) {
      return tr('march');
    } else if (index == 4) {
      return tr('april');
    } else if (index == 5) {
      return tr('may');
    } else if (index == 6) {
      return tr('june');
    } else if (index == 7) {
      return tr('july');
    } else if (index == 8) {
      return tr('august');
    } else if (index == 9) {
      return tr('september');
    } else if (index == 10) {
      return tr('october');
    } else if (index == 11) {
      return tr('november');
    } else if (index == 12) {
      return tr('december');
    } else {
      return tr('january');
    }
  }
}
