import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kursovaia_work/globals.dart';
import 'package:kursovaia_work/main/mainScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Экран «Корзина» (вкладка): список товаров, суммы и оформление заказа
class Cart extends StatefulWidget {
  const Cart({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<Cart> {
  final SupabaseClient _supabase = Supabase.instance.client;
  Map<String, int> _cartItems = {};
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;
  String? _userId;

  // Фиксированная стоимость сборки и упаковки
  final double _packagingFee = 90.0;

  @override
  void initState() {
    super.initState();
    _loadCartData();
  }

  // Загружаем корзину из SharedPreferences и данные товаров из Supabase
  Future<void> _loadCartData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString('user_id');

      if (_userId == null || _userId!.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      _cartItems = await CartService.getCartItems(_userId!);

      if (_cartItems.isNotEmpty) {
        final response = await _supabase.from('products').select().inFilter('id', _cartItems.keys.toList());

        setState(() {
          _products = List<Map<String, dynamic>>.from(response);
        });
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка загрузки корзины: $e', style: GoogleFonts.nunitoSans())));
    }
  }

  // Изменение количества товара (при 0 товар удаляется)
  Future<void> _updateQuantity(String productId, int newQuantity) async {
    if (_userId == null) return;

    try {
      await CartService.updateQuantity(_userId!, productId, newQuantity);
      await _loadCartData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка обновления количества: $e', style: GoogleFonts.nunitoSans())));
    }
  }

  // Очистка корзины
  Future<void> _clearCart() async {
    if (_userId == null) return;

    try {
      await CartService.clearCart(_userId!);
      setState(() {
        _cartItems = {};
        _products = [];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка очистки корзины: $e', style: GoogleFonts.nunitoSans())));
    }
  }

  // Собираем товары корзины вместе с их количеством
  List<Map<String, dynamic>> _getCartItems() {
    return _products.where((product) => _cartItems.containsKey(product['id'])).map((product) {
      return {...product, 'quantity': _cartItems[product['id']] ?? 0};
    }).toList();
  }

  @override
  // Считаем сумму заказа и итог с упаковкой
  Widget build(BuildContext context) {
    final items = _getCartItems();
    final subtotal = items.fold(0.0, (sum, item) => sum + (item['price'] as num).toDouble() * (item['quantity'] as int));
    final total = subtotal + _packagingFee;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        title: Text('Корзина', style: GoogleFonts.nunitoSans()),
        actions: [if (items.isNotEmpty) IconButton(icon: const Icon(Icons.delete), onPressed: _clearCart, tooltip: 'Очистить корзину')],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.black))
              : items.isEmpty
              ? Center(child: Text('Корзина пуста', style: GoogleFonts.nunitoSans(fontSize: 18)))
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      // Карточка товара в корзине: фото, название, кнопки +/− и сумма
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final price = (item['price'] as num).toDouble();
                        final quantity = item['quantity'] as int;
                        final totalPrice = price * quantity;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Color(0xff838383).withOpacity(0.2)),
                            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 2))],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(item['image_url'] ?? '', width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200], child: const Icon(Icons.error))),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item['name'] ?? '', style: GoogleFonts.nunitoSans(fontWeight: FontWeight.bold, fontSize: 16)),
                                      const SizedBox(height: 4),
                                      Text('${item['weight'] ?? '100'}г • ₽${price.toStringAsFixed(2)}', style: GoogleFonts.nunitoSans(color: Colors.grey[600], fontSize: 14)),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => _updateQuantity(item['id'], quantity - 1), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                                          Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text(quantity.toString(), style: GoogleFonts.nunitoSans(fontSize: 16, fontWeight: FontWeight.bold))),
                                          IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => _updateQuantity(item['id'], quantity + 1), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                                          const Spacer(),
                                          Text('₽${totalPrice.toStringAsFixed(2)}', style: GoogleFonts.nunitoSans(fontWeight: FontWeight.bold, fontSize: 16)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Color(0xffF4F4F4), borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30)), border: Border(top: BorderSide(color: Colors.grey[200]!))),
                    child: Column(
                      children: [
                        // Блок итогов и кнопка «Оформить заказ»
                        _buildPriceRow('Сумма', subtotal),
                        const SizedBox(height: 8),
                        _buildPriceRow('Сборка и упаковка', _packagingFee),
                        const SizedBox(height: 8),
                        _buildPriceRow('Итого', total, isTotal: true),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xffFE8160), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => OrderDetailsPage(
                                        total: total,
                                        packagingFee: _packagingFee,
                                        cartItems: items,
                                        onOrderConfirmed: () {
                                          _clearCart();
                                        },
                                      ),
                                ),
                              );
                            },
                            child: Text('Оформить заказ', style: GoogleFonts.nunitoSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  // Строка с названием и суммой
  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.nunitoSans(fontSize: isTotal ? 16 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        Text('₽${amount.toStringAsFixed(2)}', style: GoogleFonts.nunitoSans(fontSize: isTotal ? 16 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: isTotal ? const Color(0xffFE8160) : Colors.black)),
      ],
    );
  }
}

// Экран «Оформление заказа»: контакты, самовывоз, способ оплаты, итого и подтверждение
class OrderDetailsPage extends StatelessWidget {
  final double total;
  final double packagingFee;
  final List<Map<String, dynamic>> cartItems;
  final VoidCallback onOrderConfirmed;

  const OrderDetailsPage({Key? key, required this.total, required this.packagingFee, required this.cartItems, required this.onOrderConfirmed}) : super(key: key);

  @override
  // Построение экрана оформления заказа
  Widget build(BuildContext context) {
    final subtotal = total - packagingFee;
    final currentTime = TimeOfDay.now();
    final formattedTime = '${currentTime.hour}:${currentTime.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(surfaceTintColor: Colors.white, backgroundColor: Colors.white, title: Text('Оформление заказа', style: GoogleFonts.nunitoSans(fontSize: 20, fontWeight: FontWeight.bold)), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(formattedTime, style: GoogleFonts.nunitoSans(fontSize: 14, color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text('Заказ', style: GoogleFonts.nunitoSans(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),

            // Контактная информация
            Text('Контактная информация', style: GoogleFonts.nunitoSans(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildInfoField('Email', '*******@*******'),
            const SizedBox(height: 16),
            _buildInfoField('Телефон', '**** **** ****'),
            const SizedBox(height: 24),

            // Доставка
            Text('Доставка (только самовывоз)', style: GoogleFonts.nunitoSans(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildInfoField('Адрес', 'Сургут, ул. Пушкина, д. 10'),
            const SizedBox(height: 16),
            _buildInfoField('Дата и время доставки', ''),
            const SizedBox(height: 24),

            // Способ оплаты
            Text('Способ оплаты', style: GoogleFonts.nunitoSans(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildPaymentMethod(),
            const SizedBox(height: 24),

            // Итоговая сумма
            _buildSummaryRow('Сумма', subtotal),
            const SizedBox(height: 8),
            _buildSummaryRow('Сборка и упаковка', packagingFee),
            const SizedBox(height: 8),
            _buildSummaryRow('Итого', total, isTotal: true),
            const SizedBox(height: 24),

            // Кнопка подтверждения
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xffFE8160), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                onPressed: () {
                  onOrderConfirmed();
                  _showSuccessDialog(context);
                },
                child: Text('Подтвердить заказ', style: GoogleFonts.nunitoSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Поле с подписью, значением и разделителем
  Widget _buildInfoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.nunitoSans(fontSize: 14, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.nunitoSans(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        const Divider(height: 1, color: Colors.grey),
      ],
    );
  }

  // Блок способа оплаты (заглушка)
  Widget _buildPaymentMethod() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          const Icon(Icons.add_circle_outline, size: 24),
          const SizedBox(width: 12),
          Text('Добавить', style: GoogleFonts.nunitoSans(fontSize: 16, fontWeight: FontWeight.w600)),
          const Spacer(),
          Text('***', style: GoogleFonts.nunitoSans(fontSize: 16)),
        ],
      ),
    );
  }

  // Строка итогов
  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.nunitoSans(fontSize: isTotal ? 16 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        Text('₽${amount.toStringAsFixed(2)}', style: GoogleFonts.nunitoSans(fontSize: isTotal ? 16 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: isTotal ? const Color(0xffFE8160) : Colors.black)),
      ],
    );
  }

  // Диалог «Вы успешно оформили заказ»
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: Text('Вы успешно\nоформили заказ!', textAlign: TextAlign.center, style: GoogleFonts.nunitoSans(fontWeight: FontWeight.w800, fontSize: 24, color: const Color(0xffB95B43))),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/order.png'),
                const SizedBox(height: 10),
                SizedBox(
                  width: 300,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xffFE8160), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => Main()));
                    },
                    child: Text('Вернуться к покупкам', style: GoogleFonts.nunitoSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
