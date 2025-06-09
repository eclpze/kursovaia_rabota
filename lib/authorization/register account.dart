import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kursovaia_work/authorization/sign%20in.dart';
import 'package:kursovaia_work/globals.dart';
import 'package:kursovaia_work/main/Main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterAccount extends StatefulWidget {
  const RegisterAccount({super.key});

  @override
  State<RegisterAccount> createState() => _RegisterAccountState();
}

class _RegisterAccountState extends State<RegisterAccount> {
  bool _passwordVis = true;
  bool _isLoading = false;
  bool _termsAccepted = false;
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Необходимо принять условия соглашения')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Регистрация пользователя в Supabase Auth
      final authResponse = await _supabase.auth.signUp(
        email: EmailController.text.trim(),
        password: PasswordController.text.trim(),
        data: {
          'name': NameController.text.trim(),
          'email': EmailController.text.trim(),
        },
      );

      if (authResponse.user != null) {
        // 2. Сохранение дополнительных данных в таблице профилей
        await _supabase.from('profiles').insert({
          'id': authResponse.user!.id,
          'email': EmailController.text.trim(),
          'name': NameController.text.trim(),
          'created_at': DateTime.now().toIso8601String(),
        });

        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => Main()),
        );
      }
    } on AuthException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка регистрации: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 90),
              Text(
                'Регистрация',
                textAlign: TextAlign.center,
                style: AuthorizationTopStyle,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15, bottom: 40),
                child: Text(
                  'Заполните свои данные и\nзарегистрируйтесь',
                  textAlign: TextAlign.center,
                  style: AuthorizationBotStyle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  children: [Text('Имя', style: TopEditStyle), const Spacer()],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  controller: NameController,
                  cursorColor: Colors.black,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите имя';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    fillColor: const Color(0xffEDEEEE),
                    filled: true,
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      borderSide: BorderSide(color: Color(0xffEDEEEE)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      borderSide: BorderSide(color: Color(0xffEDEEEE)),
                    ),
                    hintText: "Введите имя",
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 15,
                    ),
                    hintStyle: TextEditStyle,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  children: [Text('Почта', style: TopEditStyle), const Spacer()],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  controller: EmailController,
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
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      borderSide: BorderSide(color: Color(0xffEDEEEE)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      borderSide: BorderSide(color: Color(0xffEDEEEE)),
                    ),
                    hintText: "Введите почту",
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 15,
                    ),
                    hintStyle: TextEditStyle,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  children: [Text('Пароль', style: TopEditStyle), const Spacer()],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  controller: PasswordController,
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
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      borderSide: BorderSide(color: Color(0xffEDEEEE)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      borderSide: BorderSide(color: Color(0xffEDEEEE)),
                    ),
                    hintText: "Введите пароль",
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 15,
                    ),
                    hintStyle: TextEditStyle,
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
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => SignIn()),
                        );
                      },
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
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: _termsAccepted,
                      onChanged: (value) {
                        setState(() {
                          _termsAccepted = value ?? false;
                        });
                      },
                      activeColor: const Color(0xffFE8160),
                    ),
                    Text(
                      'Даю согласие на обработку\nперсональных данных',
                      style: GoogleFonts.nunitoSans(
                        color: const Color(0xff5B5B5B),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              TextButton(
                onPressed: _isLoading ? null : _signUp,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xffFE8160),
                    borderRadius: BorderRadius.all(Radius.circular(40)),
                  ),
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 55,
                  child: Center(
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                      'Зарегистрироваться',
                      style: GoogleFonts.nunitoSans(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 60),
              RichText(
                text: TextSpan(
                  text: "Есть аккаунт? ",
                  style: GoogleFonts.nunitoSans(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                      text: "Войти",
                      style: GoogleFonts.nunitoSans(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => SignIn()),
                          );
                        },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}