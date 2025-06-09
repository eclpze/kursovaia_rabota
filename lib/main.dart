import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kursovaia_work/globals.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'authorization/sign in.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://dzqvgirkmftcrtlfolee.supabase.co',
    anonKey:'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR6cXZnaXJrbWZ0Y3J0bGZvbGVlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDAxMzgwMDMsImV4cCI6MjA1NTcxNDAwM30.GIiPuXo_GVX37kEtGmxNg4lKRImKh9a1XKThn2uQV1k',

  );
  runApp(MaterialApp(home: Splash()));
}


class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    {
      Timer(const Duration(seconds: 2), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Onboarding()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: Image.asset('assets/images/splash.png', width: 190)),
    );
  }
}

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: SmoothController,
              children: [
                Column(
                  children: [
                    Image.asset('assets/images/onboarding1.png'),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.95,
                      child: Text(
                        'Бесконечное сладкое наслаждение',
                        textAlign: TextAlign.center,
                        style: OnboardingTopStyle,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Text(
                          'Окунитесь в мир восхитительных десертов, которые удовлетворят ваших сладкоежек благодаря нашему широкому выбору тортов, кексов и печенья.',
                          style: OnboardingBotStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Image.asset('assets/images/onboarding2.png'),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.95,
                      child: Text(
                        'Создайте торт своей мечты',
                        textAlign: TextAlign.center,
                        style: OnboardingTopStyle,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Text(
                          'Наши гибкие варианты тортов на заказ позволяют вам персонализировать каждый аспект вашего торта, чтобы сделать его по-настоящему уникальным.',
                          style: OnboardingBotStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Image.asset('assets/images/onboarding3.png'),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.95,
                      child: Text(
                        'Заказы без проблем',
                        textAlign: TextAlign.center,
                        style: OnboardingTopStyle,
                      ),
                    ),
                    SizedBox(height: 8),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.95,
                      child: Text(
                        'Просто листайте каталог, выбирайте понравившийся вариант и оформляйте заказ в пару кликов. Безупречный вкус и праздничное настроение – гарантированы!',
                        style: OnboardingBotStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => SignIn()),
                          );
                        },
                        child: Container(
                          height: 40,
                          width: MediaQuery.of(context).size.width * 0.55,
                          decoration: BoxDecoration(
                            color: Color(0xffFE8160),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 7),
                            child: Text(
                              'Начать покупки',
                              style: ButtonTextStyle,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: SmoothPageIndicator(
              controller: SmoothController,
              count: 3,
              effect: JumpingDotEffect(
                activeDotColor: Color(0xffFE8160),
                dotColor: Color(0xffFFE9E3),
                dotWidth: 90,
                dotHeight: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
