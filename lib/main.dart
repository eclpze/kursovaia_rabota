import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kursovaia_work/globals.dart';
import 'package:kursovaia_work/main/Main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'authorization/register account.dart';
import 'authorization/sign in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
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
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasOnboarded = prefs.getBool('has_onboarded') ?? false;
    final isLoggedIn = prefs.getString('user_id') != null;

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => isLoggedIn
            ? Main()
            : (hasOnboarded ? SignIn() : Onboarding()),
      ),
    );
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
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              children: [
              _buildOnboardingPage(
              image: 'assets/images/onboarding1.png',
              title: 'Бесконечное сладкое наслаждение',
              description: 'Окунитесь в мир восхитительных десертов, которые удовлетворят ваших сладкоежек благодаря нашему широкому выбору тортов, кексов и печенья.',
            ),
            _buildOnboardingPage(
              image: 'assets/images/onboarding2.png',
              title: 'Создайте торт своей мечты',
              description: 'Наши гибкие варианты тортов на заказ позволяют вам персонализировать каждый аспект вашего торта, чтобы сделать его по-настоящему уникальным.',
            ),
            Column(
              children: [
                Image.asset('assets/images/onboarding3.png'),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.95,
                  child: Text(
                    'Заказы без проблем',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.95,
                  child: Text(
                    'Просто листайте каталог, выбирайте понравившийся вариант и оформляйте заказ в пару кликов. Безупречный вкус и праздничное настроение – гарантированы!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: TextButton(
                    onPressed: _completeOnboarding,
                    child: Container(
                      height: 40,
                      width: MediaQuery.of(context).size.width * 0.55,
                      decoration: BoxDecoration(
                        color: const Color(0xffFE8160),
                        borderRadius: BorderRadius.all(Radius.circular(20)),),
                        child: const Padding(
                          padding: EdgeInsets.only(top: 7),
                          child: Text(
                            'Начать покупки',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
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
              controller: _pageController,
              count: 3,
              effect: JumpingDotEffect(
                activeDotColor: const Color(0xffFE8160),
                dotColor: const Color(0xffFFE9E3),
                dotWidth: 90,
                dotHeight: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage({
    required String image,
    required String title,
    required String description,
  }) {
    return Column(
      children: [
        Image.asset(image),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.95,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Text(
              description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_onboarded', true);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const RegisterAccount()),
    );
  }
}