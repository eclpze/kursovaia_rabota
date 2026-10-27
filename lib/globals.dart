import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Стили
final OnboardingTopStyle = GoogleFonts.nunitoSans(color: const Color(0xff1A1D26), fontSize: 18, fontWeight: FontWeight.w900);

final OnboardingBotStyle = GoogleFonts.nunitoSans(color: const Color(0xff4A4E4D), fontSize: 16, fontWeight: FontWeight.normal);

final ButtonTextStyle = GoogleFonts.nunitoSans(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold);

final AuthorizationTopStyle = GoogleFonts.nunitoSans(color: Colors.black, fontSize: 28, fontWeight: FontWeight.w900, height: 1.2);

final AuthorizationBotStyle = GoogleFonts.nunitoSans(color: const Color(0xff4A4E4D), fontSize: 18, fontWeight: FontWeight.w500, height: 1.2);

final TextEditStyle = GoogleFonts.nunitoSans(color: const Color(0xff474747), fontWeight: FontWeight.bold, fontSize: 16);

final TopEditStyle = GoogleFonts.nunitoSans(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18);

// Контроллеры
final SmoothController = PageController();
final EmailController = TextEditingController();
final PasswordController = TextEditingController();
final NameController = TextEditingController();

// Настройки подключения к Supabase (URL и публичный anon-ключ)
class SupabaseConfig {
  static const String url = 'https://dzqvgirkmftcrtlfolee.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR6cXZnaXJrbWZ0Y3J0bGZvbGVlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDAxMzgwMDMsImV4cCI6MjA1NTcxNDAwM30.GIiPuXo_GVX37kEtGmxNg4lKRImKh9a1XKThn2uQV1k';
}

// Функции адаптивных размеров относительно размера экрана
getAdaptiveWidth(context, basePadding) {
  return basePadding * (MediaQuery.of(context).size.width / 1440);
}

getAdaptiveHeight(context, basePadding) {
  return basePadding * (MediaQuery.of(context).size.height / 900);
}

// Сервис корзины: хранит товары и количество в SharedPreferences для каждого пользователя
class CartService {
  // Получить корзину в виде {id товара: количество}
  static Future<Map<String, int>> getCartItems(String userId) async {
    if (userId.isEmpty) return {};

    final prefs = await SharedPreferences.getInstance();
    final cartKey = 'user_cart_$userId';
    final cartString = prefs.getString(cartKey);

    if (cartString == null) return {};

    try {
      return Map<String, int>.from(json.decode(cartString));
    } catch (e) {
      return {};
    }
  }

  // Добавить товар (количество суммируется)
  static Future<void> addToCart(String userId, String productId, int quantity) async {
    if (userId.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final cartKey = 'user_cart_$userId';
    final cartItems = await getCartItems(userId);

    final currentQuantity = cartItems[productId] ?? 0;
    cartItems[productId] = currentQuantity + quantity;

    await prefs.setString(cartKey, json.encode(cartItems));
  }

  // Удалить товар из корзины
  static Future<void> removeFromCart(String userId, String productId) async {
    if (userId.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final cartKey = 'user_cart_$userId';
    final cartItems = await getCartItems(userId);

    cartItems.remove(productId);

    await prefs.setString(cartKey, json.encode(cartItems));
  }

  // Изменить количество (<= 0 — товар удаляется)
  static Future<void> updateQuantity(String userId, String productId, int newQuantity) async {
    if (userId.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final cartKey = 'user_cart_$userId';
    final cartItems = await getCartItems(userId);

    if (newQuantity <= 0) {
      cartItems.remove(productId);
    } else {
      cartItems[productId] = newQuantity;
    }

    await prefs.setString(cartKey, json.encode(cartItems));
  }

  // Полностью очистить корзину
  static Future<void> clearCart(String userId) async {
    if (userId.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final cartKey = 'user_cart_$userId';
    await prefs.remove(cartKey);
  }
}

// Модель данных о погоде
class WeatherData {
  final int temperature;
  final String description;
  final String iconCode;
  final String city;

  WeatherData({required this.temperature, required this.description, required this.iconCode, required this.city});
}
