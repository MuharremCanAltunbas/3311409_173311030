import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waterly/components/MyAppBar.dart';
import 'package:waterly/controllers/AppController.dart';
import 'package:waterly/database/AppDatabase.dart';
import 'package:waterly/extensions/HexColor.dart';
import 'package:waterly/screens/home_screen.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:waterly/screens/stats_screen.dart';

class WaterScreen extends StatefulWidget {
  const WaterScreen({super.key});

  @override
  State<WaterScreen> createState() => _WaterScreenState();
}

class _WaterScreenState extends State<WaterScreen>
    with TickerProviderStateMixin {
  final AppController controller = Get.find();

  late AnimationController firstController;
  late Animation<double> firstAnimation;

  late AnimationController secondController;
  late Animation<double> secondAnimation;

  late AnimationController thirdController;
  late Animation<double> thirdAnimation;

  late AnimationController fourthController;
  late Animation<double> fourthAnimation;

  var data = [];
  var user = {};

  num totalAmount = 0;
  num remainingAmount = 0;
  num completedRate = 0;

  AppDatabase appDatabase = AppDatabase();

  updateStatistics() {
    setState(() {
      totalAmount = 0;
      data = appDatabase.loadData(DateTime.now());
      for (var element in data) {
        print(element);
        totalAmount += element['value'];
      }
      remainingAmount = (double.parse(user['needwater']) * 1000) - totalAmount;
      if ((double.parse(user['needwater']) * 1000) < totalAmount) {
        remainingAmount = 0;
      }
      completedRate =
          (totalAmount * 100) / (double.parse(user['needwater']) * 1000);
      if (completedRate >= 100) {
        completedRate = 100;
      }
      print(completedRate);
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      user = appDatabase.loadUser();
    });
    updateStatistics();
    firstController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    firstAnimation = Tween<double>(begin: 1.9, end: 2.1).animate(
        CurvedAnimation(parent: firstController, curve: Curves.easeInOut))
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          firstController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          firstController.forward();
        }
      });

    secondController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));
    secondAnimation = Tween<double>(begin: 1.8, end: 2.4).animate(
        CurvedAnimation(parent: secondController, curve: Curves.easeInOut))
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          secondController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          secondController.forward();
        }
      });

    thirdController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));
    thirdAnimation = Tween<double>(begin: 1.8, end: 2.4).animate(
        CurvedAnimation(parent: thirdController, curve: Curves.easeInOut))
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          thirdController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          thirdController.forward();
        }
      });

    fourthController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));
    fourthAnimation = Tween<double>(begin: 1.9, end: 2.1).animate(
        CurvedAnimation(parent: fourthController, curve: Curves.easeInOut))
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          fourthController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          fourthController.forward();
        }
      });

    Timer(Duration(seconds: 2), () {
      firstController.forward();
    });

    Timer(Duration(milliseconds: 1600), () {
      secondController.forward();
    });

    Timer(Duration(milliseconds: 800), () {
      thirdController.forward();
    });

    fourthController.forward();
  }

  @override
  void dispose() {
    firstController.dispose();
    secondController.dispose();
    thirdController.dispose();
    fourthController.dispose();
    super.dispose();
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
    Size size = MediaQuery.of(context).size;

    return ListView(
      children: [
        Stack(
          children: [
            CustomPaint(
              painter: MyPainter(
                firstAnimation.value,
                secondAnimation.value,
                thirdAnimation.value,
                fourthAnimation.value,
                1000 - (completedRate * 10),
              ),
              child: SizedBox(
                height: size.height,
                width: size.width,
              ),
            ),
            Center(
              child: Column(
                children: [
                  SizedBox(
                    height: 70,
                  ),
                  Text(
                    "${totalAmount} ml",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                        fontSize: 32,
                        color: completedRate > 85
                            ? Colors.white
                            : HexColor("#46436a"),
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    remainingAmount > 0 ? 'water_screen_remaining' : '',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                        fontSize: 18,
                        color: completedRate > 80
                            ? Colors.white
                            : HexColor("#46436a"),
                        fontWeight: FontWeight.w500),
                  ).tr(args: [remainingAmount.toStringAsFixed(0)]),
                  SizedBox(
                    height: 40,
                  ),
                  Text(
                    "${completedRate.toStringAsFixed(0)}%",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                        fontSize: 36,
                        color: completedRate > 60
                            ? Colors.white
                            : HexColor("#46436a"),
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Icon(
                    Icons.water_drop_outlined,
                    color:
                        completedRate > 50 ? Colors.white : HexColor("#46436a"),
                    size: 72,
                  ),
                  SizedBox(
                    height: 150,
                  ),
                  addWater()
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  addWater() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: GestureDetector(
        onTap: () {
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
        },
        child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: HexColor("#ffffff"),
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
                child: Icon(
                  Icons.add_outlined,
                  size: 34,
                  color: HexColor("#46436a"),
                ))),
      ),
    );
  }

  bottomNavigation() {
    return Container(
      color: HexColor("#7671fe"),
      child: Padding(
        padding: EdgeInsets.only(left: 40, right: 40, bottom: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            bottomNavigationItem(
                1,
                HexColor("#323163"),
                Icon(
                  Icons.water_drop_outlined,
                  color: HexColor("#ffffff"),
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
                HexColor("#ffffff"),
                Icon(
                  Icons.list_alt_rounded,
                  color: HexColor("#323163"),
                )),
          ],
        ),
      ),
    );
  }

  bottomNavigationItem(int id, Color backgroundColor, Icon icon) {
    return GestureDetector(
      onTap: () {
        if (id == 2) {
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
}

class MyPainter extends CustomPainter {
  final double firstValue;
  final double secondValue;
  final double thirdValue;
  final double fourthValue;
  final double successValue;

  MyPainter(
    this.firstValue,
    this.secondValue,
    this.thirdValue,
    this.fourthValue,
    this.successValue,
  );

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = HexColor("#7671fe")
      ..style = PaintingStyle.fill;

    /*
var path = Path()
      ..moveTo(0, size.height / firstValue)
      ..cubicTo(size.width * .4, size.height / secondValue, size.width * .7,
          size.height / thirdValue, size.width, size.height / fourthValue)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height);
    */

    var path = Path()
      ..moveTo(0, successValue / firstValue)
      ..cubicTo(size.width * .4, successValue / secondValue, size.width * .7,
          successValue / thirdValue, size.width, successValue / fourthValue)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
