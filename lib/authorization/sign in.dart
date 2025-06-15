import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kursovaia_work/authorization/register%20account.dart';
import 'package:kursovaia_work/main/Main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool _passwordVis = true;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUsers = prefs.getStringList('registered_users') ?? [];

      final user = savedUsers.firstWhere(
            (user) => user.split(':')[0] == _emailController.text.trim(),
        orElse: () => '',
      );

      if (user.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Пользователь с таким email не найден', style: GoogleFonts.nunitoSans())),
        );
      }

      final savedPassword = user.split(':')[1];
      if (savedPassword != _passwordController.text.trim()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Неверный пароль', style: GoogleFonts.nunitoSans())),
        );
      }

      await prefs.setString('user_id', user.split(':')[0]);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Main()),
      );
    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка входа: ${e.toString()}', style: GoogleFonts.nunitoSans())),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Функция восстановления пароля недоступна в этом режиме', style: GoogleFonts.nunitoSans())),
    );
  }

  Future<void> _checkCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId != null && userId.isNotEmpty) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Main()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Expanded(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 140),
                              child: Text(
                                'Ваш сладкий рай\nначинается здесь!',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15, bottom: 40),
                              child: Text(
                                'Заполните свои данные и\nвойдите в аккаунт',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 25),
                              child: Row(
                                children: [
                                  Text('Почта', style: GoogleFonts.nunitoSans(fontWeight: FontWeight.bold)),
                                  const Spacer(),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15),
                              child: TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                cursorColor: Colors.black,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Пожалуйста, введите почту';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Введите корректный email';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  fillColor: const Color(0xffEDEEEE),
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: const BorderSide(color: Color(0xffEDEEEE)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: const BorderSide(color: Color(0xffEDEEEE)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: const BorderSide(color: Color(0xffEDEEEE)),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: const BorderSide(color: Color(0xffEDEEEE)),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: const BorderSide(color: Color(0xffEDEEEE)),
                                  ),
                                  hintText: "Введите почту",
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                    horizontal: 15,
                                  ),
                                  hintStyle: GoogleFonts.nunitoSans(color: Colors.grey),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(25, 15, 25, 0),
                              child: Row(
                                children: [
                                  Text('Пароль', style: GoogleFonts.nunitoSans(fontWeight: FontWeight.bold)),
                                  const Spacer(),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15),
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: _passwordVis,
                                cursorColor: Colors.black,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Пожалуйста, введите пароль';
                                  }
                                  if (value.length < 6) {
                                    return 'Пароль должен быть не менее 6 символов';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xffEDEEEE),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: const BorderSide(color: Color(0xffEDEEEE)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: const BorderSide(color: Color(0xffEDEEEE)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: const BorderSide(color: Color(0xffEDEEEE)),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: const BorderSide(color: Colors.red),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: const BorderSide(color: Color(0xffEDEEEE)),
                                  ),
                                  hintText: "Введите пароль",
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                    horizontal: 15,
                                  ),
                                  hintStyle: GoogleFonts.nunitoSans(color: Colors.grey),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _passwordVis ? Icons.visibility_off : Icons.visibility,
                                      color: const Color(0xff6A6A6A),
                                      size: 22,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _passwordVis = !_passwordVis;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 25),
                              child: Row(
                                children: [
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: _resetPassword,
                                    child: Text(
                                      'Восстановить',
                                      style: GoogleFonts.nunitoSans(
                                        color: const Color(0xff5B5B5B),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 45),
                            TextButton(
                              onPressed: _isLoading ? null : _signIn,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xffFE8160),
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                width: MediaQuery.of(context).size.width * 0.9,
                                height: 55,
                                child: Center(
                                  child: _isLoading
                                      ? const CircularProgressIndicator(color: Colors.white)
                                      : Text(
                                    'Войти',
                                    style: GoogleFonts.nunitoSans(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20, top: 20),
                      child: RichText(
                        text: TextSpan(
                          text: "Вы впервые? ",
                          style: GoogleFonts.nunitoSans(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(
                              text: "Создать пользователя",
                              style: GoogleFonts.nunitoSans(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const RegisterAccount(),
                                    ),
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}