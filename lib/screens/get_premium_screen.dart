import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/models/customer_info_wrapper.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:waterly/extensions/HexColor.dart';
import 'package:waterly/screens/home_screen.dart';

class GetPremiumScreen extends StatefulWidget {
  const GetPremiumScreen({super.key});

  @override
  State<GetPremiumScreen> createState() => _GetPremiumScreenState();
}

class _GetPremiumScreenState extends State<GetPremiumScreen> {
  bool userIsPremium = false;
  late CustomerInfo customerInfo;
  StoreProduct? currentMonthlyProduct;
  late Offerings offerings;
  String monthlyPrice = "";

  Future<void> initPlatformStateForSubscription() async {
    await Purchases.setDebugLogsEnabled(true);
    await Purchases.setup("goog_jYhcXfxjwBFrvfwMCKjvrtpSCRr");
    customerInfo = await Purchases.getCustomerInfo();

    // User premium check
    if (customerInfo.entitlements.all["premium"] != null &&
        customerInfo.entitlements.all["premium"]!.isActive) {
      setState(() {
        userIsPremium = true;
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => HomeScreen()),
            (Route<dynamic> route) => false);
      });
    } else {
      userIsPremium = false;
    }

    offerings = await Purchases.getOfferings();

    setState(() {
      currentMonthlyProduct = offerings.current!.monthly!.storeProduct;
      monthlyPrice = currentMonthlyProduct!.priceString;
    });
  }

  Future<void> makePurchases(Package package) async {
    try {
      customerInfo = await Purchases.purchasePackage(package);
      if (customerInfo.entitlements.all["premium"] != null &&
          customerInfo.entitlements.all["premium"]!.isActive) {
        setState(() {
          userIsPremium = true;
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => HomeScreen()),
              (Route<dynamic> route) => false);
        });
      } else {
        userIsPremium = false;
      }
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message.toString())));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    initPlatformStateForSubscription();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "premium_header".tr(),
                  textAlign: TextAlign.left,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                        (Route<dynamic> route) => false);
                  },
                  child: Icon(
                    Icons.close,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              "premium_subheader".tr(),
              textAlign: TextAlign.left,
              style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
            SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                "assets/images/premiumimg01.png",
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20),
            feature(
                Icon(
                  Icons.ads_click,
                  color: Colors.blue,
                  size: 44,
                ),
                "premium_feature_header_1".tr(),
                "premium_feature_subheader_1".tr()),
            feature(
                Icon(
                  Icons.calendar_month_outlined,
                  color: Colors.blue,
                  size: 44,
                ),
                "premium_feature_header_2".tr(),
                "premium_feature_subheader_2".tr()),
            feature(
                Icon(
                  Icons.list,
                  color: Colors.blue,
                  size: 44,
                ),
                "premium_feature_header_3".tr(),
                "premium_feature_subheader_3".tr()),
            feature(
                Icon(
                  Icons.access_alarm,
                  color: Colors.blue,
                  size: 44,
                ),
                "premium_feature_header_4".tr(),
                "premium_feature_subheader_4".tr()),
            SizedBox(height: 20),
            pricing(),
            SizedBox(height: 20),
            button(),
            SizedBox(height: 20),
            skipnow(),
          ],
        ),
      ),
    );
  }

  feature(Icon icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            icon,
          ],
        ),
        SizedBox(width: 20),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.left,
              style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
            SizedBox(height: 20),
          ],
        )
      ],
    );
  }

  pricing() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Text(
              monthlyPrice,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ],
        )
      ],
    );
  }

  button() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: () async {
            Package? package = offerings.current!.monthly;
            await makePurchases(package!);
          },
          child: Container(
            decoration: BoxDecoration(
                color: HexColor("#7671fe"),
                borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
              child: Text(
                "premium_getpremium".tr(),
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
        )
      ],
    );
  }

  skipnow() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => HomeScreen()),
            (Route<dynamic> route) => false);
      },
      child: Text(
        "premium_skip".tr(),
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14, color: Colors.grey),
      ),
    );
  }
}
