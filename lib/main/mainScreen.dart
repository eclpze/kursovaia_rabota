import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kursovaia_work/main/cart.dart';
import 'package:kursovaia_work/main/favorite.dart';
import 'package:kursovaia_work/main/home.dart';
import 'package:kursovaia_work/profile.dart';

// Главный каркас приложения: нижнее меню с 4 вкладками (Главная, Избранное, Профиль, Корзина)
class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  // Индекс текущей вкладки
  int indexPage = 0;

  // Экраны вкладок в порядке меню
  final pages = [const Home(), const Favorite(), const Profile(), const Cart()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[indexPage],
      // Нижнее меню навигации
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        notchMargin: 20,
        shape: const AutomaticNotchedShape(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30)))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 35),
              // Вкладка «Главная»
              child: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                onTap: () {
                  setState(() {
                    indexPage = 0;
                  });
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(padding: const EdgeInsets.all(8.0), child: SvgPicture.asset('assets/icons/home.svg', color: indexPage == 0 ? const Color(0xffFE8160) : const Color(0xff212121))),
                    Text('Главная', style: GoogleFonts.nunitoSans(fontSize: 10, color: indexPage == 0 ? const Color(0xffFE8160) : const Color(0xff212121))),
                  ],
                ),
              ),
            ),
            // Вкладка «Избранное»
            InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              onTap: () {
                setState(() {
                  indexPage = 1;
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(padding: const EdgeInsets.all(8.0), child: SvgPicture.asset('assets/icons/heart.svg', color: indexPage == 1 ? const Color(0xffFE8160) : const Color(0xff212121))),
                  Text('Избранное', style: GoogleFonts.nunitoSans(fontSize: 10, color: indexPage == 1 ? const Color(0xffFE8160) : const Color(0xff212121))),
                ],
              ),
            ),
            const SizedBox(width: 35),
            // Вкладка «Профиль»
            InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              onTap: () {
                setState(() {
                  indexPage = 2;
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(padding: const EdgeInsets.all(8.0), child: SvgPicture.asset('assets/icons/profile.svg', color: indexPage == 2 ? const Color(0xffFE8160) : const Color(0xff212121))),
                  Text('Профиль', style: GoogleFonts.nunitoSans(fontSize: 10, color: indexPage == 2 ? const Color(0xffFE8160) : const Color(0xff212121))),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 35, right: 15),
              // Вкладка «Корзина»
              child: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                onTap: () {
                  setState(() {
                    indexPage = 3;
                  });
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(padding: const EdgeInsets.all(8.0), child: SvgPicture.asset('assets/icons/cart.svg', color: indexPage == 3 ? const Color(0xffFE8160) : const Color(0xff212121))),
                    Text('Корзина', style: GoogleFonts.nunitoSans(fontSize: 10, color: indexPage == 3 ? const Color(0xffFE8160) : const Color(0xff212121))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
