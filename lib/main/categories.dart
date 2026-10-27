import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kursovaia_work/product.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Блок категорий на главном экране: берёт категории из Supabase и показывает сеткой
class Categories extends StatelessWidget {
  const Categories({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Supabase.instance.client.from('categories').select(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Colors.black));
        }

        if (snapshot.hasError) {
          return Center(child: Text('Ошибка загрузки категорий', style: GoogleFonts.nunitoSans()));
        }

        final categories = snapshot.data ?? [];

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
          itemCount: categories.length,
          padding: const EdgeInsets.fromLTRB(10, 15, 10, 0),
          itemBuilder: (context, index) {
            final category = categories[index];
            return CategoryCard(category: category);
          },
        );
      },
    );
  }
}

// Карточка категории (фото с названием); по нажатию открывает товары категории
class CategoryCard extends StatelessWidget {
  final Map<String, dynamic> category;

  const CategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => CategoryProductsPage(categoryId: category['id'])));
      },
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 2))]),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: category['image_url'] ?? '',
                height: double.infinity,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey[200]),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.black.withOpacity(0.3))),
            Center(child: Text(category['name'] ?? '', style: GoogleFonts.nunitoSans(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }
}

// Экран товаров выбранной категории
class CategoryProductsPage extends StatefulWidget {
  final String categoryId;

  const CategoryProductsPage({super.key, required this.categoryId});

  @override
  State<CategoryProductsPage> createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {
  late Future<Map<String, dynamic>?> _categoryFuture;
  late Future<List<Map<String, dynamic>>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _categoryFuture = _fetchCategory();
    _productsFuture = _fetchProducts();
  }

  // Загружаем данные категории (для заголовка)
  Future<Map<String, dynamic>?> _fetchCategory() async {
    try {
      return await Supabase.instance.client.from('categories').select().eq('id', widget.categoryId).single();
    } catch (e) {
      debugPrint('Error fetching category: $e');
      return null;
    }
  }

  // Загружаем товары этой категории из Supabase
  Future<List<Map<String, dynamic>>> _fetchProducts() async {
    try {
      return await Supabase.instance.client.from('products').select().eq('category_id', widget.categoryId);
    } catch (e) {
      debugPrint('Error fetching products: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: FutureBuilder<Map<String, dynamic>?>(
          future: _categoryFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('Загрузка...', style: GoogleFonts.nunitoSans(fontWeight: FontWeight.w600));
            }
            return Text(snapshot.data?['name'] ?? 'Категория', style: GoogleFonts.nunitoSans(fontWeight: FontWeight.w600));
          },
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xffFE8160)));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Ошибка загрузки товаров', style: GoogleFonts.nunitoSans(fontSize: 16, color: Colors.grey[600])));
          }

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return Center(child: Text('В этой категории пока нет товаров', style: GoogleFonts.nunitoSans(fontSize: 16, color: Colors.grey[600])));
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: MasonryGridView.count(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 15),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductCard(product: product, onFavoritePressed: () {}, heroTag: 'product-${product['id']}', isFavorite: false);
              },
            ),
          );
        },
      ),
    );
  }
}

// Экран «Категории»: вкладки категорий сверху и сетка товаров выбранной категории
class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  late Future<List<Map<String, dynamic>>> _categoriesFuture;

  // Индекс выбранной вкладки категории
  int _selectedCategoryIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _fetchCategories();
  }

  // Загружаем список категорий, отсортированный по названию
  Future<List<Map<String, dynamic>>> _fetchCategories() async {
    try {
      final response = await Supabase.instance.client.from('categories').select().order('name', ascending: true);
      return response;
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      throw Exception('Failed to load categories');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Категории', style: GoogleFonts.nunitoSans(fontSize: 24, fontWeight: FontWeight.bold)), centerTitle: true, surfaceTintColor: Colors.white, backgroundColor: Colors.white, elevation: 0),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xffFE8160)));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Ошибка загрузки категорий', style: GoogleFonts.nunitoSans()));
          }

          final categories = snapshot.data ?? [];
          if (categories.isEmpty) {
            return Center(child: Text('Категории не найдены', style: GoogleFonts.nunitoSans()));
          }

          return Column(
            children: [
              SizedBox(
                height: 60,
                // Горизонтальные вкладки категорий
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategoryIndex = index;
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              categories[index]['name'] ?? 'Категория',
                              style: GoogleFonts.nunitoSans(fontSize: 16, fontWeight: _selectedCategoryIndex == index ? FontWeight.bold : FontWeight.normal, color: _selectedCategoryIndex == index ? const Color(0xffFE8160) : Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            if (_selectedCategoryIndex == index) Container(height: 3, width: 40, color: const Color(0xffFE8160)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 1, color: Color(0xffF4F4F4)),

              // Товары выбранной категории
              Expanded(child: _buildProductsGrid(categories[_selectedCategoryIndex])),
            ],
          );
        },
      ),
    );
  }

  // Сетка товаров выбранной категории
  Widget _buildProductsGrid(Map<String, dynamic> category) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Supabase.instance.client.from('products').select().eq('category_id', category['id']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xffFE8160)));
        }

        if (snapshot.hasError) {
          return Center(child: Text('Ошибка загрузки товаров', style: GoogleFonts.nunitoSans()));
        }

        final products = snapshot.data ?? [];

        if (products.isEmpty) {
          return Center(child: Text('В этой категории пока нет товаров', style: GoogleFonts.nunitoSans()));
        }

        return Padding(
          padding: const EdgeInsets.all(12),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.65, crossAxisSpacing: 12, mainAxisSpacing: 12),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(product: product, onFavoritePressed: () {}, heroTag: 'product-${product['id']}', isFavorite: false);
            },
          ),
        );
      },
    );
  }
}
