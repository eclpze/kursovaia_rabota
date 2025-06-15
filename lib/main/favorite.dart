import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kursovaia_work/authorization/sign%20in.dart';
import 'package:kursovaia_work/Product.dart';
import 'package:kursovaia_work/main/Main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Favorite extends StatefulWidget {
  const Favorite({super.key});

  @override
  State<Favorite> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<Favorite> {
  List<Map<String, dynamic>> _favoriteProducts = [];
  bool _isLoading = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFavorites();
  }

  Future<void> _loadUserIdAndFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString('user_id');

      if (_userId == null || _userId!.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final favoritesString = prefs.getString('user_favorites_$_userId');
      if (favoritesString != null && favoritesString.isNotEmpty) {
        final List<dynamic> favoritesList = jsonDecode(favoritesString);
        setState(() {
          _favoriteProducts =
              favoritesList
                  .map((item) => item as Map<String, dynamic>)
                  .toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeFavorite(String productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesString = prefs.getString('user_favorites_$_userId');

      if (favoritesString != null) {
        List<dynamic> favoritesList = jsonDecode(favoritesString);
        favoritesList.removeWhere((item) => item['id'].toString() == productId);

        await prefs.setString(
          'user_favorites_$_userId',
          jsonEncode(favoritesList),
        );

        setState(() {
          _favoriteProducts.removeWhere(
            (product) => product['id'].toString() == productId,
          );
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Товар удален из избранного',  style: GoogleFonts.nunitoSans())),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка: ${e.toString()}',  style: GoogleFonts.nunitoSans())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _userId == null || _userId!.isEmpty
              ? _buildLoginPrompt()
              : Column(
                children: [
                  SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 15,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => Main()),
                            );
                          },
                          child: SvgPicture.asset(
                            'assets/icons/arrow-left.svg',
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Избранное',
                          style: GoogleFonts.nunitoSans(
                            color: const Color(0xff212121),
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  Expanded(
                    child:
                        _favoriteProducts.isEmpty
                            ? Center(
                              child: Text(
                                'Нет избранных товаров',
                                style: GoogleFonts.nunitoSans(),
                              ),
                            )
                            : Expanded(
                              child: GridView.builder(
                                shrinkWrap: true,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.65,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                    ),
                                itemCount: _favoriteProducts.length,
                                padding: EdgeInsets.fromLTRB(10, 0, 10, 15),
                                itemBuilder: (context, index) {
                                  final product = _favoriteProducts[index];
                                  return ProductCard(
                                    product: product,
                                    isFavorite: true,
                                    onFavoritePressed:
                                        () => _removeFavorite(
                                          product['id'].toString(),
                                        ), heroTag: '',
                                  );
                                },
                              ),
                            ),
                  ),
                ],
              ),
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Чтобы просмотреть избранное, войдите в аккаунт',
            style: GoogleFonts.nunitoSans(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffFE8160),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SignIn()),
              );
            },
            child: Text(
              'Войти',
              style: GoogleFonts.nunitoSans(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
