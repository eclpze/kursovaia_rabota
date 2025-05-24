import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalStorageService {
  static Future<void> addToCart(Map<String, dynamic> product) async {
    final prefs = await SharedPreferences.getInstance();
    final cart = prefs.getString('cart') ?? '[]';
    final List<dynamic> cartItems = json.decode(cart);

    // Проверяем, есть ли уже такой товар в корзине
    final existingIndex = cartItems.indexWhere((item) =>
    item['id'] == product['id']);

    if (existingIndex >= 0) {
      // Увеличиваем количество, если товар уже есть
      cartItems[existingIndex]['quantity'] += 1;
    } else {
      // Добавляем новый товар с количеством 1
      cartItems.add({
        ...product,
        'quantity': 1,
      });
    }

    await prefs.setString('cart', json.encode(cartItems));
  }

  static Future<void> toggleFavorite(Map<String, dynamic> product) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getString('favorites') ?? '[]';
    final List<dynamic> favoriteItems = json.decode(favorites);

    final existingIndex = favoriteItems.indexWhere((item) =>
    item['id'] == product['id']);

    if (existingIndex >= 0) {
      // Удаляем из избранного
      favoriteItems.removeAt(existingIndex);
    } else {
      // Добавляем в избранное
      favoriteItems.add(product);
    }

    await prefs.setString('favorites', json.encode(favoriteItems));
  }

  static Future<bool> isFavorite(Map<String, dynamic> product) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getString('favorites') ?? '[]';
    final List<dynamic> favoriteItems = json.decode(favorites);

    return favoriteItems.any((item) => item['id'] == product['id']);
  }
}