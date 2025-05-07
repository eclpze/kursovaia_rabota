import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kursovaia_work/main/action.dart';
import 'package:kursovaia_work/main/categories.dart';
import 'package:kursovaia_work/main/popular.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: 30),
                      Text(
                        'Здравствуй!',
                        style: GoogleFonts.nunitoSans(
                          color: Color(0xff212121),
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'Что вы ищете сегодня?',
                        style: GoogleFonts.nunitoSans(
                          color: Color(0xff212121),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                ],
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Text(
                    'Акции',
                    style: GoogleFonts.nunitoSans(
                      color: Color(0xff212121),
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      _showPromotionsDialog(context);
                    },
                    child: SvgPicture.asset('assets/icons/arrow-right.svg'),
                  ),
                ],
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.95,
                child: DayOfWeekImage(),
              ),
              Row(
                children: [
                  Text(
                    'Популярное',
                    style: GoogleFonts.nunitoSans(
                      color: Color(0xff212121),
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Spacer(),
                  GestureDetector(onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => PopularProducts()));
                  },
                      child: SvgPicture.asset('assets/icons/arrow-right.svg')),
                ],
              ),
              Popular(),
              SizedBox(height: 25),
              Row(
                children: [
                  Text(
                    'Категории',
                    style: GoogleFonts.nunitoSans(
                      color: Color(0xff212121),
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Spacer(),
                  SvgPicture.asset('assets/icons/arrow-right.svg'),
                ],
              ),
              Categories(),
            ],
          ),
        ),
      ),
    );
  }
}

void _showPromotionsDialog(BuildContext context) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Текущие акции',
            style: GoogleFonts.nunitoSans(
              fontWeight: FontWeight.w800,
              fontSize: 24,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/promotion.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _buildPromotionDay('Понедельник, среда, пятница'),
                _buildPromotionItem('Тирамису'),
                Divider(height: 12, color: Colors.grey),
                _buildPromotionDay('Вторник, четверг'),
                _buildPromotionItem('Латте'),
                Divider(height: 12, color: Colors.grey),
                _buildPromotionDay('По выходным'),
                _buildPromotionItem('Торт с клубникой'),
              ],
            ),
          ),
        );
      }
  );
}

Widget _buildPromotionDay(String day) {
  return Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Text(
      day,
      style: GoogleFonts.nunitoSans(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: Colors.grey[700],
      ),
    ),
  );
}

Widget _buildPromotionItem(String item) {
  return Padding(
    padding: const EdgeInsets.only(top: 2, bottom: 4),
    child: Text(
      item,
      style: GoogleFonts.nunitoSans(
        fontWeight: FontWeight.w700,
        fontSize: 15, color: Color(0xffB95B43)
      ),
    ),
  );
}

