import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kursovaia_work/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'authorization/sign.dart';

// Карточка товара (фото, название, цена) — используется в сетках и списках; по нажатию открывает страницу товара
class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onFavoritePressed;
  final bool isFavorite;

  const ProductCard({super.key, required this.product, required this.onFavoritePressed, required this.isFavorite, required String heroTag});

  @override
  // Карточка: фото сверху, ниже название и цена
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailPage(product: product)));
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xffF4F4F4)),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: product['image_url'] ?? '',
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey[200]),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product['name'] ?? 'Название товара', style: GoogleFonts.nunitoSans(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('${product['price']?.toStringAsFixed(2) ?? '0.00'} ₽', style: GoogleFonts.nunitoSans(color: const Color(0xffFE8160), fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Экран товара: фото, описание, аллергены, выбор количества и добавление в корзину
class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  // Выбранное количество, признак избранного и id пользователя
  int _quantity = 1;
  bool _isFavorite = false;
  bool _isCheckingFavorite = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndCheckFavorite();
  }

  // Загружаем пользователя и проверяем, есть ли товар в избранном
  Future<void> _loadUserIdAndCheckFavorite() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString('user_id');

      if (_userId == null || _userId!.isEmpty) {
        setState(() => _isCheckingFavorite = false);
        return;
      }

      final favoritesString = prefs.getString('user_favorites_$_userId');
      if (favoritesString != null) {
        final List<dynamic> favoritesList = json.decode(favoritesString);
        setState(() {
          _isFavorite = favoritesList.any((item) => item['id'] == widget.product['id']);
          _isCheckingFavorite = false;
        });
      } else {
        setState(() => _isCheckingFavorite = false);
      }
    } catch (e) {
      setState(() => _isCheckingFavorite = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка проверки избранного: $e')));
    }
  }

  // Добавить/убрать товар из избранного (нужен вход в аккаунт)
  Future<void> _toggleFavorite() async {
    if (_userId == null || _userId!.isEmpty) {
      _showLoginAlert();
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesString = prefs.getString('user_favorites_$_userId');
      List<dynamic> favoritesList = [];

      if (favoritesString != null && favoritesString.isNotEmpty) {
        favoritesList = json.decode(favoritesString);
      }

      setState(() => _isFavorite = !_isFavorite);

      if (_isFavorite) {
        favoritesList.add(widget.product);
      } else {
        favoritesList.removeWhere((item) => item['id'] == widget.product['id']);
      }

      await prefs.setString('user_favorites_$_userId', json.encode(favoritesList));
    } catch (e) {
      setState(() => _isFavorite = !_isFavorite);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка обновления избранного: $e')));
    }
  }

  // Добавить товар в корзину в выбранном количестве
  Future<void> _addToCart() async {
    if (_userId == null || _userId!.isEmpty) {
      _showLoginAlert();
      return;
    }

    try {
      await CartService.addToCart(_userId!, widget.product['id'].toString(), _quantity);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Добавлено в корзину: ${widget.product['name']} (x$_quantity)'), duration: const Duration(seconds: 2)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка при добавлении в корзину: $e'), duration: const Duration(seconds: 2)));
    }
  }

  // Диалог «Требуется вход» для неавторизованных пользователей
  void _showLoginAlert() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Требуется вход', style: GoogleFonts.nunitoSans()),
            content: Text('Чтобы добавлять товары в корзину, пожалуйста, войдите в аккаунт.', style: GoogleFonts.nunitoSans()),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Отмена', style: GoogleFonts.nunitoSans())),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SignIn()));
                },
                child: Text('Войти', style: GoogleFonts.nunitoSans(color: Colors.orange)),
              ),
            ],
          ),
    );
  }

  @override
  // Построение экрана товара: прокручиваемая шапка с фото и содержимое
  Widget build(BuildContext context) {
    final price = (widget.product['price'] as num).toDouble();
    final totalPrice = price * _quantity;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Большое фото товара с кнопкой избранного (сердечко)
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(widget.product['image_url'] ?? '', fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200])),
                  Positioned(
                    top: 45,
                    right: 25,
                    child:
                        _isCheckingFavorite
                            ? const CircularProgressIndicator()
                            : GestureDetector(onTap: _toggleFavorite, child: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border, color: _isFavorite ? Colors.red : Colors.black, size: 28)),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.product['name'] ?? '', style: GoogleFonts.nunitoSans(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('₽${price.toStringAsFixed(2)}', style: GoogleFonts.nunitoSans(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xffFE8160))),
                  const SizedBox(height: 16),
                  // Метка «Популярный товар»
                  if (widget.product['is_popular'] == true)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(children: [Icon(Icons.star, color: Colors.orange, size: 20), const SizedBox(width: 4), Text('Популярный товар', style: GoogleFonts.nunitoSans(color: Colors.orange, fontWeight: FontWeight.bold))]),
                    ),
                  Text('Описание', style: GoogleFonts.nunitoSans(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(widget.product['description'] ?? 'Нет описания', style: GoogleFonts.nunitoSans(fontSize: 16)),
                  // Блок аллергенов (если указаны)
                  if (widget.product['allergens'] != null && widget.product['allergens'].isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text('Аллергены', style: GoogleFonts.nunitoSans(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(widget.product['allergens'], style: GoogleFonts.nunitoSans(fontSize: 16)),
                      ],
                    ),
                  const SizedBox(height: 24),
                  _buildQuantitySelector(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      // Нижняя кнопка «Добавить в корзину» с итоговой ценой
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xffFE8160), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
          onPressed: _addToCart,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Добавить в корзину', style: GoogleFonts.nunitoSans(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(width: 8),
              Text('₽${totalPrice.toStringAsFixed(2)}', style: GoogleFonts.nunitoSans(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  // Выбор количества (− / +)
  Widget _buildQuantitySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Количество', style: GoogleFonts.nunitoSans(fontSize: 16, fontWeight: FontWeight.bold)),
        Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(20)),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  if (_quantity > 1) {
                    setState(() => _quantity--);
                  }
                },
              ),
              Text(_quantity.toString(), style: GoogleFonts.nunitoSans(fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  setState(() => _quantity++);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
