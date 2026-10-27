import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:kursovaia_work/globals.dart';
import 'package:kursovaia_work/main/action.dart';
import 'package:kursovaia_work/main/categories.dart';
import 'package:kursovaia_work/main/popular.dart';

// Главный экран (вкладка «Главная»): приветствие, погода, акции, популярное, категории
class Home extends StatelessWidget {
  const Home({super.key});

  @override
  // Построение главного экрана
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Text('Здравствуй!', style: GoogleFonts.nunitoSans(color: const Color(0xff212121), fontSize: 24, fontWeight: FontWeight.w900)),
                        Text('Что вы ищете сегодня?', style: GoogleFonts.nunitoSans(color: const Color(0xff212121), fontSize: 14, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const Spacer(),
                    // Виджет погоды справа в шапке
                    WeatherWidget(),
                  ],
                ),
                const SizedBox(height: 20),
                // Блок «Акции»: картинка по дню недели, по стрелке — окно со всеми акциями
                _buildSectionHeader(title: 'Акции', onTap: () => _showPromotionsDialog(context)),
                const SizedBox(height: 10),
                SizedBox(width: double.infinity, child: DayOfWeekImage()),
                const SizedBox(height: 20),
                // Блок «Популярное»: горизонтальный список, по стрелке — экран всех популярных
                _buildSectionHeader(title: 'Популярное', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PopularProducts()))),
                const SizedBox(height: 10),
                const Popular(),
                const SizedBox(height: 20),
                // Блок «Категории»: сетка категорий, по стрелке — экран категорий
                _buildSectionHeader(title: 'Категории', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoriesPage()))),
                const SizedBox(height: 10),
                const Categories(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Заголовок раздела со стрелкой справа
  Widget _buildSectionHeader({required String title, required VoidCallback onTap}) {
    return Row(
      children: [Text(title, style: GoogleFonts.nunitoSans(color: const Color(0xff212121), fontSize: 20, fontWeight: FontWeight.w800)), const Spacer(), GestureDetector(onTap: onTap, child: SvgPicture.asset('assets/icons/arrow-right.svg'))],
    );
  }

  // Диалог со списком акций по дням недели
  void _showPromotionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Ваши акции', style: GoogleFonts.nunitoSans(fontWeight: FontWeight.w800, fontSize: 24)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset('assets/images/promotion.png', fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.error)))),
                ),
                const SizedBox(height: 8),
                _buildPromotionDay('Понедельник, среда, пятница'),
                _buildPromotionItem('Тирамису'),
                const Divider(height: 12, color: Colors.grey),
                _buildPromotionDay('Вторник, четверг'),
                _buildPromotionItem('Латте'),
                const Divider(height: 12, color: Colors.grey),
                _buildPromotionDay('По выходным'),
                _buildPromotionItem('Торт с клубникой'),
              ],
            ),
          ),
        );
      },
    );
  }

  // Строка с днями недели в диалоге акций
  Widget _buildPromotionDay(String day) {
    return Padding(padding: const EdgeInsets.only(top: 4), child: Text(day, style: GoogleFonts.nunitoSans(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey[700])));
  }

  // Название акционного товара в диалоге
  Widget _buildPromotionItem(String item) {
    return Padding(padding: const EdgeInsets.only(top: 2, bottom: 4), child: Text(item, style: GoogleFonts.nunitoSans(fontWeight: FontWeight.w700, fontSize: 15, color: const Color(0xffB95B43))));
  }
}

// Виджет для отображения погоды
class WeatherWidget extends StatefulWidget {
  @override
  _WeatherWidgetState createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  // Данные погоды, состояние загрузки и текст ошибки
  WeatherData? _weatherData;
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  // Запрос текущей погоды в Сургуте через OpenWeatherMap API
  Future<void> _fetchWeather() async {
    const apiKey = 'ec64846b64ac2e1601e1018c59bebd50';
    const city = 'Surgut';
    const countryCode = 'RU';
    const lang = 'ru';

    final url = Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=$city,$countryCode&appid=$apiKey&units=metric&lang=$lang');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _weatherData = WeatherData(temperature: data['main']['temp'].round(), description: data['weather'][0]['description'], iconCode: data['weather'][0]['icon'], city: data['name']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Не удалось получить данные о погоде';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Ошибка подключения';
        _isLoading = false;
      });
    }
  }

  @override
  // Плашка с иконкой и температурой (или индикатор загрузки / ошибка)
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
      child:
          _isLoading
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
              : _error.isNotEmpty
              ? Tooltip(message: _error, child: const Icon(Icons.error_outline, size: 24))
              : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.network('https://openweathermap.org/img/wn/${_weatherData!.iconCode}@2x.png', width: 32, height: 32),
                  const SizedBox(width: 4),
                  Text('${_weatherData!.temperature}°C', style: GoogleFonts.nunitoSans(fontWeight: FontWeight.w700, fontSize: 16)),
                ],
              ),
    );
  }
}
