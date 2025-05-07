import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Cart extends StatefulWidget {
  const Cart({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<Cart> {
  final double _packagingFee = 90.0;
  bool _isLoading = false;

  Future<List<Map<String, dynamic>>> _fetchCartItems() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await Supabase.instance.client
        .from('cart_items')
        .select('''
          id, 
          quantity, 
          size, 
          custom_text,
          products (
            id, 
            name, 
            price, 
            image_url,
            weight
          )
        ''')
        .eq('user_id', userId)
        .order('created_at', ascending: true);

    return (response as List).cast<Map<String, dynamic>>();
  }

  Future<void> _updateQuantity(String cartItemId, int newQuantity) async {
    if (newQuantity < 1) return;

    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client
          .from('cart_items')
          .update({'quantity': newQuantity})
          .eq('id', cartItemId);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _removeItem(String cartItemId) async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client
          .from('cart_items')
          .delete()
          .eq('id', cartItemId);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchCartItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Ошибка загрузки корзины'));
          }

          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return Center(
              child: Text(
                'Корзина пуста',
                style: GoogleFonts.nunitoSans(fontSize: 18),
              ),
            );
          }

          double subtotal = items.fold(0, (sum, item) {
            final product = item['products'] as Map<String, dynamic>;
            return sum + (product['price'] * item['quantity']);
          });

          double total = subtotal + _packagingFee;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final product = item['products'] as Map<String, dynamic>;
                    final price = product['price']?.toDouble() ?? 0.0;
                    final itemTotal = price * item['quantity'];

                    return Card(
                      margin: EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Изображение товара
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: product['image_url'] ?? '',
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey[200],
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.fastfood),
                                  ),
                                ),
                                SizedBox(width: 12),

                                // Название и параметры
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['name'] ?? '',
                                        style: GoogleFonts.nunitoSans(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      if (item['size'] != null)
                                        Text(
                                          'Размер: ${item['size']}',
                                          style: GoogleFonts.nunitoSans(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      if (item['custom_text'] != null)
                                        Text(
                                          'Надпись: ${item['custom_text']}',
                                          style: GoogleFonts.nunitoSans(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      Text(
                                        product['weight'] ?? '',
                                        style: GoogleFonts.nunitoSans(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Удаление
                                IconButton(
                                  icon: Icon(Icons.close, size: 20),
                                  onPressed: _isLoading
                                      ? null
                                      : () => _removeItem(item['id']),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),

                            // Количество и цена
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Счетчик количества
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.remove, size: 18),
                                        onPressed: _isLoading
                                            ? null
                                            : () => _updateQuantity(
                                          item['id'],
                                          item['quantity'] - 1,
                                        ),
                                      ),
                                      Text(
                                        item['quantity'].toString(),
                                        style: GoogleFonts.nunitoSans(),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.add, size: 18),
                                        onPressed: _isLoading
                                            ? null
                                            : () => _updateQuantity(
                                          item['id'],
                                          item['quantity'] + 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Итоговая цена за позицию
                                Text(
                                  '₽${itemTotal.toStringAsFixed(2)}',
                                  style: GoogleFonts.nunitoSans(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Итоговая сумма
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow('Сумма', subtotal),
                    _buildSummaryRow('Сборка и упаковка', _packagingFee),
                    Divider(),
                    _buildSummaryRow('Итого', total, isTotal: true),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xffFE8160),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isLoading ? null : () {},
                        child: Text(
                          'Оформить заказ',
                          style: GoogleFonts.nunitoSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.nunitoSans(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            '₽${value.toStringAsFixed(2)}',
            style: GoogleFonts.nunitoSans(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Color(0xffFE8160) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
