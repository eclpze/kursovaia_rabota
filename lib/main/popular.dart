import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kursovaia_work/Product.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Popular extends StatelessWidget {
  const Popular({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Supabase.instance.client
          .from('products')
          .select('id, name, price, image_url, is_popular, description')
          .eq('is_popular', true)
          .limit(5),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 220,
            child: Center(
              child: CircularProgressIndicator(color: Colors.black),
            ),
          );
        }

        // Обработка ошибок
        if (snapshot.hasError) {
          return SizedBox(
            height: 220,
            child: Center(
              child: Text(
                'Ошибка загрузки данных',
                style: GoogleFonts.nunitoSans(),
              ),
            ),
          );
        }

        final products = snapshot.data ?? [];

        // Если нет данных
        if (products.isEmpty) {
          return SizedBox(
            height: 220,
            child: Center(
              child: Text(
                'Нет популярных товаров',
                style:  GoogleFonts.nunitoSans(fontSize: 16),
              ),
            ),
          );
        }

        return SizedBox(
          height: 245,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            separatorBuilder: (context, index) => const SizedBox(width: 1),
            itemBuilder: (context, index) {
              final product = products[index];

              final productId = product['id']?.toString() ?? 'unknown';
              final productName = product['name'] ?? 'Без названия';
              final productPrice = product['price']?.toStringAsFixed(2) ?? '0.00';
              final imageUrl = product['image_url'] ?? '';
              final description = product['description'] ?? 'Описания нет';

              return SizedBox(
                width: 160,
                child: ProductCard(
                  product: {
                    'id': productId,
                    'name': productName,
                    'price': double.tryParse(productPrice) ?? 0.0,
                    'image_url': imageUrl,
                    'is_popular': product['is_popular'] ?? false,
                    'description': description
                  },
                  isFavorite: false,
                  onFavoritePressed: () {},
                  heroTag: 'popular-$productId',
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class PopularProducts extends StatelessWidget {
  const PopularProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: SvgPicture.asset('assets/icons/arrow-left.svg'),
                ),
                const Spacer(),
                Text(
                  'Популярное',
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
          const SizedBox(height: 15),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: Supabase.instance.client
                    .from('products')
                    .select()
                    .eq('is_popular', true),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.black),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Ошибка загрузки популярных товаров',
                        style: GoogleFonts.nunitoSans(),
                      ),
                    );
                  }

                  final products = snapshot.data ?? [];

                  if (products.isEmpty) {
                    return const Center(
                      child: Text('Нет популярных товаров'),
                    );
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductCard(
                        product: product,
                        isFavorite: false,
                        onFavoritePressed: () {},
                        heroTag: 'popular-grid-${product['id']}',
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}