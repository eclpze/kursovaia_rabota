import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kursovaia_work/authorization/register%20account.dart';
import 'package:kursovaia_work/globals.dart';
import 'package:kursovaia_work/main/Main.dart';


class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool _passwordVis = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 140),
                child: Text(
                  'Ваш сладкий рай\nначинается здесь!',
                  textAlign: TextAlign.center,
                  style: AuthorizationTopStyle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15, bottom: 40),
                child: Text(
                  'Заполните свои данные и\nвойдите в аккаунт',
                  textAlign: TextAlign.center,
                  style: AuthorizationBotStyle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  children: [Text('Почта', style: TopEditStyle), Spacer()],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  controller: EmailController,
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: Colors.black,
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
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 15,
                    ),
                    hintStyle: TextEditStyle,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 15, 25, 0),
                child: Row(
                  children: [Text('Пароль', style: TopEditStyle), Spacer()],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  controller: PasswordController,
                  obscureText: _passwordVis,
                  cursorColor: Colors.black,
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
                    contentPadding: EdgeInsets.symmetric(
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
                    Spacer(),
                    Text(
                      'Восстановить',
                      style: GoogleFonts.nunitoSans(
                        color: Color(0xff5B5B5B),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 45),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => Main()));
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xffFE8160),
                    borderRadius: BorderRadius.all(Radius.circular(40)),
                  ),
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 55,
                  child: Center(
                    child: Text(
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
              Padding(
                padding: const EdgeInsets.only(top: 95),
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
                        recognizer:
                        TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) => const RegisterAccount(),
                              ),
                            );
                          },
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
