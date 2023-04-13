import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waterly/extensions/HexColor.dart';
import 'package:waterly/screens/list_screen.dart';
import 'package:waterly/screens/profile_screen.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppBar appBar;

  const MyAppBar({super.key, required this.appBar});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 100,
      centerTitle: true,
      backgroundColor: HexColor("#ffffff"),
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Text(
        "Waterly",
        style: GoogleFonts.roboto(
            fontSize: 28,
            color: HexColor("#46436a"),
            fontWeight: FontWeight.bold),
      ),
      leading: GestureDetector(
        onTap: () {
          Navigator.of(context).push(PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const ProfileScreen(),
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
        child: Padding(
          padding: EdgeInsets.only(left: 38),
          child: Icon(
            Icons.person_search_outlined,
            size: 28,
            color: HexColor("#46436a"),
          ),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const ListScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(0.0, 1.0);
                const end = Offset.zero;
                const curve = Curves.ease;

                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            ));
          },
          child: Padding(
            padding: EdgeInsets.only(right: 38),
            child: Icon(
              Icons.list_alt_outlined,
              size: 28,
              color: HexColor("#46436a"),
            ),
          ),
        )
      ],
    );
  }

  @override
  Size get preferredSize => new Size.fromHeight(appBar.preferredSize.height);
}
