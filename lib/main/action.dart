import 'package:flutter/material.dart';

// Виджет акции дня: на главном экране показывает картинку акции в зависимости от дня недели
class DayOfWeekImage extends StatefulWidget {
  const DayOfWeekImage({super.key});

  @override
  _DayOfWeekImageState createState() => _DayOfWeekImageState();
}

class _DayOfWeekImageState extends State<DayOfWeekImage> {
  // Путь к картинке акции: пн/ср/пт — тирамису, вт/чт — латте, сб/вс — торт
  String getImageForDayOfWeek(int dayOfWeek) {
    switch (dayOfWeek) {
      case DateTime.monday || DateTime.wednesday || DateTime.friday:
        return 'assets/images/action-tiramisu.png';
      case DateTime.tuesday || DateTime.thursday:
        return 'assets/images/action-latte.png';
      case DateTime.saturday || DateTime.sunday:
        return 'assets/images/action-tort.png';
      default:
        return 'assets/images/action-default.png';
    }
  }

  @override
  // Определяем текущий день недели и выводим нужную картинку
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dayOfWeek = now.weekday;
    final imagePath = getImageForDayOfWeek(dayOfWeek);

    return Image.asset(imagePath);
  }
}
