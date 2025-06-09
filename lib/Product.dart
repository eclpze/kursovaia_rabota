import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 10, 5, 15),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailPage(product: product),
            ),
          );
        },
        child: Container(
          width: 190,
          height: 200,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
          BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 1,
          blurRadius: 5,
          offset: Offset(0, 2),)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: product['image_url'] ?? '',
                height: 130,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  height: 120,
                  width: double.infinity,
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? '',
                    style: GoogleFonts.nunitoSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '₽${product['price']?.toStringAsFixed(0) ?? '0'}',
                    style: GoogleFonts.nunitoSans(
                      color: Colors.brown[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
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

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1;
  bool _isFavorite = false;
  bool _isProcessing = false;
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final response = await _supabase
          .from('favorites')
          .select()
          .eq('user_id', userId)
          .eq('product_id', widget.product['id'])
          .maybeSingle();

      if (response != null) {
        setState(() => _isFavorite = true);
      }
    } catch (e) {
      debugPrint('Error checking favorite status: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        _showAuthError();
        return;
      }

      if (_isFavorite) {
        await _supabase
            .from('favorites')
            .delete()
            .eq('user_id', userId)
            .eq('product_id', widget.product['id']);
      } else {
        await _supabase.from('favorites').upsert({
          'user_id': userId,
          'product_id': widget.product['id'],
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      setState(() => _isFavorite = !_isFavorite);
      _showSnackBar(
          _isFavorite ? 'Добавлено в избранное' : 'Удалено из избранного');
    } catch (e) {
      _showSnackBar('Ошибка: ${e.toString()}');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _addToCart() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        _showAuthError();
        return;
      }

      final response = await _supabase
          .from('cart_items')
          .select('quantity')
          .eq('user_id', userId)
          .eq('product_id', widget.product['id'])
          .maybeSingle();

      final currentQuantity = response?['quantity'] ?? 0;
      final newQuantity = currentQuantity + _quantity;

      await _supabase.from('cart_items').upsert({
        'user_id': userId,
        'product_id': widget.product['id'],
        'quantity': newQuantity,
      });

      _showSnackBar('Товар добавлен в корзину');
    } catch (e) {
      _showSnackBar('Ошибка: ${e.toString()}');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.nunitoSans()),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(10),
      ),
    );
  }

  void _showAuthError() {
    _showSnackBar('Войдите в аккаунт для выполнения этого действия');
  }

  @override
  Widget build(BuildContext context) {
    final price = (widget.product['price'] as num).toDouble();
    final totalPrice = price * _quantity;
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'product-${widget.product['id']}',
                child: CachedNetworkImage(
                  imageUrl: widget.product['image_url'] ?? '',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey[200]),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: _isProcessing
                    ? CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.onPrimary,
                )
                    : Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : theme.colorScheme.onPrimary,
                ),
                onPressed: _toggleFavorite,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product['name'] ?? '',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₽${price.toStringAsFixed(2)}',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xffFE8160),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Описание',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product['description'] ?? 'Нет описания',
                    style: GoogleFonts.nunitoSans(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  _buildQuantitySelector(),
                  const SizedBox(height: 80), // Space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          backgroundColor: Color(0xffFE8160),
          onPressed: _isProcessing ? null : _addToCart,
          label: _isProcessing
              ? CircularProgressIndicator(
            color: Colors.white,
          )
              : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Добавить в корзину',
                style: GoogleFonts.nunitoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '₽${totalPrice.toStringAsFixed(2)}',
                style: GoogleFonts.nunitoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Количество',
          style: GoogleFonts.nunitoSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(20),
          ),
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
              Text(
                _quantity.toString(),
                style: GoogleFonts.nunitoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
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


// class _ProductDetailPageState extends State<ProductDetailPage> {
//   bool _isFavorite = false;
//   bool _isLoading = false;
//   int _quantity = 1;
//
//   final _formKey = GlobalKey<FormState>();
//
//   @override
//   void initState() {
//     super.initState();
//     _checkFavoriteStatus();
//   }
//
//   Future<void> _checkFavoriteStatus() async {
//     final userId = Supabase.instance.client.auth.currentUser?.id;
//     if (userId == null) return;
//
//     setState(() => _isLoading = true);
//     try {
//       final response = await Supabase.instance.client
//           .from('favorites')
//           .select()
//           .eq('user_id', userId)
//           .eq('product_id', widget.product['id'])
//           .single()
//           .execute();
//
//       if (response.data != null) {
//         setState(() => _isFavorite = true);
//       }
//     } catch (e) {
//       // Если товар не найден в избранном, оставляем _isFavorite = false
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   Future<void> _toggleFavorite() async {
//     if (_isLoading) return;
//     setState(() => _isLoading = true);
//
//     try {
//       final userId = Supabase.instance.client.auth.currentUser?.id;
//       if (userId == null) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 'Войдите в аккаунт',
//                 style: GoogleFonts.nunitoSans(),
//               ),
//             ),
//           );
//         }
//         return;
//       }
//
//       if (_isFavorite) {
//         await Supabase.instance.client
//             .from('favorites')
//             .delete()
//             .eq('user_id', userId)
//             .eq('product_id', widget.product['id']);
//       } else {
//         await Supabase.instance.client.from('favorites').upsert({
//           'user_id': userId,
//           'product_id': widget.product['id'],
//           'created_at': DateTime.now().toIso8601String(),
//         });
//       }
//
//       setState(() => _isFavorite = !_isFavorite);
//
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             duration: Duration(seconds: 1),
//             backgroundColor: Color(0xffFE8160),
//             content: Text(
//               _isFavorite ? 'Добавлено в избранное' : 'Удалено из избранного',
//               style: GoogleFonts.nunitoSans(),
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Ошибка: ${e.toString()}',
//               style: GoogleFonts.nunitoSans(),
//             ),
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }
//
//   Future<void> _addToCart() async {
//     if (_isLoading) return;
//     setState(() => _isLoading = true);
//
//     try {
//       final userId = Supabase.instance.client.auth.currentUser?.id;
//       if (userId == null) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 'Войдите в аккаунт',
//                 style: GoogleFonts.nunitoSans(),
//               ),
//             ),
//           );
//         }
//         return;
//       }
//
//       final response = await Supabase.instance.client
//           .from('cart_items')
//           .select('quantity')
//           .eq('user_id', userId)
//           .eq('product_id', widget.product['id'])
//           .maybeSingle();
//
//       int currentQuantity = 0;
//
//       final newQuantity = currentQuantity + _quantity;
//
//       await Supabase.instance.client.from('cart_items').upsert({
//         'user_id': userId,
//         'product_id': widget.product['id'],
//         'quantity': newQuantity,
//       });
//
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             duration: Duration(seconds: 1),
//             backgroundColor: Color(0xffFE8160),
//             content: Text(
//               'Товар добавлен в корзину',
//               style: GoogleFonts.nunitoSans(),
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Ошибка: ${e.toString()}',
//               style: GoogleFonts.nunitoSans(),
//             ),
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final price = widget.product['price']?.toDouble() ?? 0.0;
//     final totalPrice = price * _quantity;
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         surfaceTintColor: Colors.white,
//         title: Text('Детали товара', style: GoogleFonts.nunitoSans()),
//         actions: [
//           IconButton(
//             icon: _isLoading
//                 ? SizedBox(
//               width: 24,
//               height: 24,
//               child: CircularProgressIndicator(
//                 strokeWidth: 2,
//                 color: Color(0xffFE8160),
//               ),
//             )
//                 : _isFavorite
//                 ? SvgPicture.asset(
//               'assets/icons/heart.svg',
//               color: Colors.red,
//             )
//                 : SvgPicture.asset(
//               'assets/icons/heart.svg',
//               color: Colors.grey[700],
//             ),
//             onPressed: _isLoading ? null : _toggleFavorite,
//           ),
//         ],
//       ),
//       body: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           padding: EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 height: 250,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(12),
//                   image: DecorationImage(
//                     image: CachedNetworkImageProvider(
//                       widget.product['image_url'] ?? '',
//                     ),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20),
//               Text(
//                 widget.product['name'] ?? '',
//                 style: GoogleFonts.nunitoSans(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 10),
//               Text(
//                 '₽${price.toStringAsFixed(2)}',
//                 style: GoogleFonts.nunitoSans(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.orange,
//                 ),
//               ),
//               SizedBox(height: 15),
//               Text(
//                 'Описание',
//                 style: GoogleFonts.nunitoSans(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 8),
//               Text(
//                 widget.product['description'] ?? 'Нет описания',
//                 style: GoogleFonts.nunitoSans(fontSize: 16),
//               ),
//               SizedBox(height: 20),
//               Row(
//                 children: [
//                   Text(
//                     'Количество:',
//                     style: GoogleFonts.nunitoSans(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Spacer(),
//                   Row(
//                     children: [
//                       IconButton(
//                         icon: Icon(Icons.remove),
//                         onPressed: () {
//                           if (_quantity > 1) {
//                             setState(() => _quantity--);
//                           }
//                         },
//                       ),
//                       Text(
//                         _quantity.toString(),
//                         style: GoogleFonts.nunitoSans(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.add),
//                         onPressed: () {
//                           setState(() => _quantity++);
//                         },
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: BottomAppBar(
//         color: Color(0xffF4F4F4),
//         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   'Итоговая цена',
//                   style: GoogleFonts.nunitoSans(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     color: Color(0xff6E7489),
//                   ),
//                 ),
//                 Text(
//                   '₽${totalPrice.toStringAsFixed(2)}',
//                   style: GoogleFonts.nunitoSans(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w700,
//                     color: Color(0xffFE8160),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(
//               width: 200,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Color(0xffFE8160),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   padding: EdgeInsets.symmetric(vertical: 12),
//                 ),
//                 onPressed: _isLoading ? null : _addToCart,
//                 child: _isLoading
//                     ? CircularProgressIndicator(color: Colors.white)
//                     : Text(
//                   'Добавить в корзину',
//                   style: GoogleFonts.nunitoSans(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 16, color: Colors.white),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }