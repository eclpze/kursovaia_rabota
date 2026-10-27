import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kursovaia_work/authorization/sign.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Экран «Профиль» (вкладка): имя и почта пользователя, кнопка «Выйти»
class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String _name = '';
  String _email = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Читаем имя и почту из SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('user_name') ?? 'Не указано';
      _email = prefs.getString('user_email') ?? 'Не указано';
      _isLoading = false;
    });
  }

  // Выход из аккаунта: удаляем данные пользователя и открываем экран входа
  Future<void> _signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');

    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignIn()));
  }

  @override
  // Построение экрана профиля
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Профиль'),
        centerTitle: true,
        actions: [
          // Кнопка: переход к редактированию профиля
          IconButton(
            icon: SvgPicture.asset('assets/icons/edit.svg', height: 20),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileEdit(initialName: _name, initialEmail: _email, onProfileUpdated: _loadUserData)));
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          SvgPicture.asset('assets/icons/account.svg', height: 100),
                          const SizedBox(height: 30),
                          _buildProfileField(label: 'Имя', value: _name),
                          const SizedBox(height: 20),
                          _buildProfileField(label: 'Почта', value: _email),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        // Кнопка «Выйти»
                        onPressed: _signOut,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xffFE8160), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40))),
                        child: Text('Выйти', style: GoogleFonts.nunitoSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  // Поле профиля только для чтения (заголовок + значение)
  Widget _buildProfileField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.nunitoSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          width: double.infinity,
          decoration: BoxDecoration(color: const Color(0xffEDEEEE), borderRadius: BorderRadius.circular(30)),
          child: Text(value, style: GoogleFonts.nunitoSans(fontSize: 16, color: Colors.black)),
        ),
      ],
    );
  }
}

// Экран «Редактирование» профиля: изменение имени и почты
class ProfileEdit extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  final VoidCallback onProfileUpdated;

  const ProfileEdit({super.key, required this.initialName, required this.initialEmail, required this.onProfileUpdated});

  @override
  State<ProfileEdit> createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Сохраняем новые имя и почту и возвращаемся в профиль
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', _nameController.text.trim());
      await prefs.setString('user_email', _emailController.text.trim());

      widget.onProfileUpdated();
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка обновления: ${e.toString()}')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  // Построение экрана редактирования
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, title: Text('Редактирование', style: GoogleFonts.nunitoSans(fontWeight: FontWeight.bold), textAlign: TextAlign.center), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              SvgPicture.asset('assets/icons/account.svg', height: 100),
              const SizedBox(height: 30),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Имя', border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)), filled: true, fillColor: const Color(0xffEDEEEE)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите имя';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: 'Почта', border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)), filled: true, fillColor: const Color(0xffEDEEEE)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите почту';
                  }
                  if (!value.contains('@')) {
                    return 'Введите корректный email';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      // Кнопка «Сохранить» внизу экрана
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _updateProfile,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xffFE8160), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40))),
            child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text('Сохранить', style: GoogleFonts.nunitoSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
