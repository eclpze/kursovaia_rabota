import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kursovaia_work/authorization/sign.dart';
import 'package:kursovaia_work/main/mainScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Экран «Регистрация»: имя, почта, пароль и согласие на обработку данных
class RegisterAccount extends StatefulWidget {
  const RegisterAccount({super.key});

  @override
  State<RegisterAccount> createState() => _RegisterAccountState();
}

class _RegisterAccountState extends State<RegisterAccount> {
  // Состояние: скрыт ли пароль, идёт ли загрузка, принято ли соглашение
  bool _passwordVis = true;
  bool _isLoading = false;
  bool _termsAccepted = false;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Регистрация: проверка формы и дубликата email, сохранение пользователя локально (SharedPreferences)
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Пожалуйста, примите условия соглашения', style: GoogleFonts.nunitoSans())));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();

      // Проверка существует ли уже пользователь с таким email
      final savedUsers = prefs.getStringList('registered_users') ?? [];
      final emailExists = savedUsers.any((user) => user.split(':')[0] == _emailController.text.trim());

      if (emailExists) {
        throw Exception('Пользователь с таким email уже существует');
      }

      // Генерация "уникальный" ID
      final userId = DateTime.now().millisecondsSinceEpoch.toString();

      // Сохранение данных пользователя
      await prefs.setString('user_id', userId);
      await prefs.setString('user_name', _nameController.text.trim());
      await prefs.setString('user_email', _emailController.text.trim());

      // Сохранение учетных данных
      savedUsers.add('${_emailController.text.trim()}:${_passwordController.text.trim()}');
      await prefs.setStringList('registered_users', savedUsers);

      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Main()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка регистрации: ${e.toString()}', style: GoogleFonts.nunitoSans())));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Если пользователь уже вошёл — сразу открываем главный экран
  Future<void> _checkCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId != null && userId.isNotEmpty) {
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Main()));
    }
  }

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  @override
  // Построение экрана регистрации
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
                            const SizedBox(height: 90),
                            Text('Регистрация', textAlign: TextAlign.center, style: GoogleFonts.nunitoSans(fontSize: 24, fontWeight: FontWeight.bold)),
                            Padding(
                              padding: const EdgeInsets.only(top: 15, bottom: 40),
                              child: Text('Заполните свои данные и\nзарегистрируйтесь', textAlign: TextAlign.center, style: GoogleFonts.nunitoSans(fontSize: 16, color: Colors.grey)),
                            ),
                            // Поле «Имя»
                            _buildTextField(
                              label: 'Имя',
                              controller: _nameController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Пожалуйста, введите имя';
                                }
                                return null;
                              },
                              hintText: "Введите имя",
                            ),
                            // Поле «Почта»
                            _buildTextField(
                              label: 'Почта',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Пожалуйста, введите почту';
                                }
                                if (!value.contains('@')) {
                                  return 'Введите корректный email';
                                }
                                return null;
                              },
                              hintText: "Введите почту",
                            ),
                            // Поле «Пароль» с кнопкой показа пароля
                            _buildTextField(
                              label: 'Пароль',
                              controller: _passwordController,
                              obscureText: _passwordVis,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Пожалуйста, введите пароль';
                                }
                                if (value.length < 6) {
                                  return 'Пароль должен быть не менее 6 символов';
                                }
                                return null;
                              },
                              hintText: "Введите пароль",
                              suffixIcon: IconButton(icon: Icon(_passwordVis ? Icons.visibility_off : Icons.visibility, color: const Color(0xff6A6A6A), size: 22), onPressed: () => setState(() => _passwordVis = !_passwordVis)),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              child: Row(
                                children: [
                                  // Чекбокс согласия на обработку персональных данных
                                  Checkbox(value: _termsAccepted, onChanged: (value) => setState(() => _termsAccepted = value ?? false), activeColor: const Color(0xffFE8160)),
                                  Expanded(child: Text('Даю согласие на обработку персональных данных', style: GoogleFonts.nunitoSans(color: const Color(0xff5B5B5B), fontSize: 16, fontWeight: FontWeight.w500))),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: SizedBox(
                                width: double.infinity,
                                height: 55,
                                // Кнопка «Зарегистрироваться»
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _register,
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xffFE8160), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40))),
                                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text('Зарегистрироваться', style: GoogleFonts.nunitoSans(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      // Ссылка «Войти» — переход на экран входа
                      child: RichText(
                        text: TextSpan(
                          text: "Есть аккаунт? ",
                          style: GoogleFonts.nunitoSans(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
                          children: [
                            TextSpan(
                              text: "Войти",
                              style: GoogleFonts.nunitoSans(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                              recognizer: TapGestureRecognizer()..onTap = () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const SignIn())),
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

  // Универсальное текстовое поле с заголовком и валидацией
  Widget _buildTextField({required String label, required TextEditingController controller, required String? Function(String?) validator, String? hintText, TextInputType? keyboardType, bool obscureText = false, Widget? suffixIcon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.nunitoSans(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            validator: validator,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xffEDEEEE),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xffEDEEEE))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xffEDEEEE))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xffEDEEEE))),
              errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Colors.red)),
              focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xffEDEEEE))),
              hintText: hintText,
              contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              hintStyle: GoogleFonts.nunitoSans(color: Colors.grey),
              suffixIcon: suffixIcon,
            ),
          ),
        ],
      ),
    );
  }
}
