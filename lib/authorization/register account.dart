import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kursovaia_work/globals.dart';
import 'package:kursovaia_work/main/Main.dart';
import 'package:kursovaia_work/main/home.dart';
import 'sign in.dart';

class RegisterAccount extends StatefulWidget {
  const RegisterAccount({super.key});

  @override
  State<RegisterAccount> createState() => _RegisterAccountState();
}

class _RegisterAccountState extends State<RegisterAccount> {
  bool _passwordVis = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 120),
              Text(
                'Регистрация',
                textAlign: TextAlign.center,
                style: AuthorizationTopStyle,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15, bottom: 50),
                child: Text(
                  'Заполните свои данные и\nзарегистрируйтесь',
                  textAlign: TextAlign.center,
                  style: AuthorizationBotStyle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  children: [Text('Имя', style: TopEditStyle), Spacer()],
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
                    hintText: "xxxxxxxx",
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 15,
                    ),
                    hintStyle: TextEditStyle,
                  ),
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
                    hintText: "xyz@gmail.com",
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 15,
                    ),
                    hintStyle: TextEditStyle,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
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
                    hintText: "••••••••",
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 15,
                    ),
                    hintStyle: TextEditStyle,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVis ? Icons.visibility_off : Icons.visibility,
                        color: const Color(0xff6A6A6A),
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
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                child: Row(
                  children: [
                    Text(
                      'Даю согласие на обработку\nперсональных данных',
                      style: GoogleFonts.nunitoSans(
                        color: Color(0xff5B5B5B),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Main()));
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xffFE8160),
                    borderRadius: BorderRadius.all(Radius.circular(40)),
                  ),
                  width: MediaQuery.of(context).size.width * 0.95,
                  height: 65,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      'Зарегистрироваться',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunitoSans(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 160),
              RichText(
                text: TextSpan(
                  text: "Есть аккаунт? ",
                  style: GoogleFonts.nunitoSans(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                      text: "Войти",
                      style: GoogleFonts.nunitoSans(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer:
                          TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.of(context).push(
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
