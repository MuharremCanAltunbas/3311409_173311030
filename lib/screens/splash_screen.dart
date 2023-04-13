import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:waterly/database/AppDatabase.dart';
import 'package:waterly/extensions/HexColor.dart';
import 'package:waterly/screens/get_premium_screen.dart';
import 'package:waterly/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final introKey = GlobalKey<IntroductionScreenState>();

  AppDatabase appDatabase = AppDatabase();

  TextEditingController txtName = TextEditingController();

  String selectedGender = "Male";
  String selectedHeight = "170 cm";
  String selectedWeight = "65 kg";

  List<String> heights = [];
  List<String> weights = [];

  final _formKey = GlobalKey<FormState>();

  num needWater1 = 1.8;
  num needWater2 = 2.0;
  num needWater3 = 2.3;
  num needWater4 = 2.8;
  String selectedNeedWater = "2.3";

  changeGender() {
    setState(() {
      selectedGender = selectedGender == 'Male' ? 'Female' : 'Male';
    });
  }

  fillDropdowns() {
    setState(() {
      for (var i = 100; i <= 230; i++) {
        heights.add(i.toString() + " cm");
      }
      for (var i = 30; i <= 200; i++) {
        weights.add(i.toString() + " kg");
      }
    });
  }

  void _onIntroEnd(context, locale) {
    if (_formKey.currentState!.validate()) {
      var user = {
        "name": txtName.text,
        "height": selectedHeight,
        "weight": selectedWeight,
        "gender": selectedGender,
        "needwater": selectedNeedWater,
        "country": locale
      };

      print(user);
      appDatabase.updateUser(user);

      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => GetPremiumScreen()),
          (Route<dynamic> route) => false);
    }
  }

  Widget _buildImage(String assetName, [double width = 350]) {
    return Image.asset('assets/images/$assetName', width: width);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fillDropdowns();
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);

    const pageDecoration = const PageDecoration(
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: Colors.white,
      pages: [
        PageViewModel(
          title: "splash_screen1_title".tr(),
          bodyWidget: Text(
            "splash_screen1_desc".tr(),
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
                fontSize: 18.0,
                letterSpacing: 1.1,
                fontWeight: FontWeight.w400),
          ),
          image: _buildImage('img01.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "splash_screen2_title".tr(),
          bodyWidget: Text(
            "splash_screen2_desc".tr(),
            style: GoogleFonts.roboto(
              fontSize: 18.0,
            ),
          ),
          image: _buildImage('img02.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "splash_screen3_title".tr(),
          bodyWidget: Text(
            "splash_screen3_desc".tr(),
            style: GoogleFonts.roboto(
              fontSize: 18.0,
            ),
          ),
          image: _buildImage('img03.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "",
          bodyWidget: myForm(),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context, context.locale.toString()),
      //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
      showSkipButton: false,
      skipOrBackFlex: 0,
      nextFlex: 0,
      showBackButton: true,
      //rtl: true, // Display as right-to-left
      back: const Icon(
        Icons.arrow_back,
        color: Colors.black,
      ),
      skip: Text('Skip',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          )),
      next: const Icon(
        Icons.arrow_forward,
        color: Colors.black,
      ),
      done: Text('splash_screen4_done'.tr(),
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          )),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Colors.grey,
        activeSize: Size(22.0, 10.0),
        activeColor: Colors.black,
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      dotsContainerDecorator: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
    );
  }

  myForm() {
    return Column(
      children: [
        Image(
            width: 180,
            height: 180,
            image: AssetImage("assets/images/img04.png")),
        Text(
          "splash_screen4_title".tr(),
          style:
              GoogleFonts.roboto(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        Form(
            key: _formKey,
            child: TextFormField(
              controller: txtName,
              decoration: InputDecoration(
                hintText: tr('splash_screen4_entername'),
                labelText: tr('splash_screen4_name'),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Colors.grey.shade500,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return tr('splash_screen4_nameerror');
                }
              },
            )),
        SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  selectedGender = 'Male';
                });
              },
              child: Container(
                  width: 150,
                  decoration: BoxDecoration(
                    color: selectedGender == 'Male'
                        ? HexColor("#46436a")
                        : Colors.white,
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
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.male_outlined,
                          color: selectedGender == 'Male'
                              ? Colors.white
                              : HexColor("#46436a"),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "splash_screen4_male".tr(),
                          style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: selectedGender == 'Male'
                                  ? Colors.white
                                  : HexColor("#46436a"),
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  selectedGender = 'Female';
                });
              },
              child: Container(
                  width: 150,
                  decoration: BoxDecoration(
                    color: selectedGender == 'Female'
                        ? HexColor("#46436a")
                        : Colors.white,
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
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.female_outlined,
                          color: selectedGender == 'Female'
                              ? Colors.white
                              : HexColor("#46436a"),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "splash_screen4_female".tr(),
                          style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: selectedGender == 'Female'
                                  ? Colors.white
                                  : HexColor("#46436a"),
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )),
            )
          ],
        ),
        SizedBox(height: 20),
        heightweight(),
        SizedBox(height: 25),
        needWater()
      ],
    );
  }

  heightweight() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: 10),
            child: Column(
              children: [
                Text(
                  "splash_screen4_height".tr(),
                  style: GoogleFonts.roboto(
                    fontSize: 14.0,
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.only(right: 0),
                  child: DropdownButtonFormField(
                    value: selectedHeight,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedHeight = newValue!;
                      });
                    },
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.grey.shade500, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.grey.shade600, width: 1),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: heights.length > 0
                        ? heights.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList()
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
            child: Padding(
          padding: EdgeInsets.only(left: 10),
          child: Column(
            children: [
              Text(
                "splash_screen4_weight".tr(),
                style: GoogleFonts.roboto(
                  fontSize: 14.0,
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.only(left: 0),
                child: DropdownButtonFormField(
                  value: selectedWeight,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedWeight = newValue!;
                      num weight = double.parse(newValue.split(' ')[0]);
                      needWater3 = weight * 0.03;
                      needWater4 = needWater3 + 0.4;
                      needWater2 = needWater3 - 0.2;
                      needWater1 = needWater3 - 0.4;
                      selectedNeedWater = needWater3.toString().substring(0, 3);
                    });
                  },
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.grey.shade500, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.grey.shade600, width: 1),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: weights.length > 0
                      ? weights.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList()
                      : null,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  needWater() {
    return Column(
      children: [
        Text(
          "splash_screen4_needwater".tr(),
          style: GoogleFonts.roboto(
              fontSize: 14,
              color: HexColor("#46436a"),
              fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            needWaterItem(needWater1),
            needWaterItem(needWater2),
            needWaterItem(needWater3),
            needWaterItem(needWater4),
          ],
        )
      ],
    );
  }

  needWaterItem(num value) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedNeedWater = value.toString().substring(0, 3);
        });
      },
      child: Container(
          decoration: BoxDecoration(
            color: selectedNeedWater == value.toString().substring(0, 3)
                ? HexColor("#46436a")
                : Colors.white,
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
            child: Text(
              value.toString().substring(0, 3) + " L",
              style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: selectedNeedWater == value.toString().substring(0, 3)
                      ? Colors.white
                      : HexColor("#46436a"),
                  fontWeight: FontWeight.bold),
            ),
          )),
    );
  }
}
