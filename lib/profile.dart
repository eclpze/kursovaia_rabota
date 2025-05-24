import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kursovaia_work/authorization/sign%20in.dart';
import 'package:kursovaia_work/globals.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic>? _profile;

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:
          Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 50, bottom: 5),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 135, right: 110),
                          child: Text(
                            'Профиль',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) => ProfileEdit(
                                      initialName: _profile?['name'],
                                      initialEmail: _profile?['email'],
                                    ),
                              ),
                            );
                          },
                          child: SvgPicture.asset(
                            'assets/icons/edit.svg',
                            height: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SvgPicture.asset('assets/icons/account.svg'),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 5,
                    ),
                    child: Row(
                      children: [
                        Text('Имя', style: TopEditStyle),
                        const Spacer(),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Container(
                      height: 60,
                      width: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        color: const Color(0xffEDEEEE),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(30),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _profile?['name'] ?? '',
                            style: TopEditStyle,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      children: [
                        Text('Почта', style: TopEditStyle),
                        const Spacer(),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Container(
                      height: 60,
                      width: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        color: const Color(0xffEDEEEE),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(30),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _profile?['email'] ?? '',
                            style: TopEditStyle,
                          ),
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    // onPressed: _signOut,
                    onPressed: () {},
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xffFE8160),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      child: Text('Выйти', style: ButtonTextStyle),
                    ),
                  ),
                ],
              ),
    );
  }
}

class ProfileEdit extends StatefulWidget {
  final String? initialName;
  final String? initialEmail;

  const ProfileEdit({
    super.key,
    required this.initialName,
    required this.initialEmail,
  });

  @override
  State<ProfileEdit> createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName ?? '';
    _emailController.text = widget.initialEmail ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on AuthException catch (error) {
      setState(() {
        _errorMessage = error.message;
      });
    } catch (error) {
      setState(() {
        _errorMessage = 'Не удалось обновить профиль';
      });
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
    return Scaffold(backgroundColor: Colors.white, body: Column(children: []));
  }
}
