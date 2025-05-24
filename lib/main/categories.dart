import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kursovaia_work/Product.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: categories.length,
          padding: EdgeInsets.fromLTRB(10, 15, 10, 0),
          itemBuilder: (context, index) {
            final category = categories[index];
            return CategoryCard(category: category);
          },
        );
      },
    );
  }
}

class CategoryCard extends StatelessWidget {
  final Map<String, dynamic> category;

  const CategoryCard({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryProductsPage(categoryId: category['id']),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: category['image_url'] ?? '',
                height: double.infinity,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.black.withOpacity(0.3),
              ),
            ),
            Center(
              child: Text(
                category['name'] ?? '',
                style: GoogleFonts.nunitoSans(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryProductsPage extends StatelessWidget {
  final String categoryId;

  const CategoryProductsPage({Key? key, required this.categoryId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, surfaceTintColor: Colors.white               ,
        title: FutureBuilder<Map<String, dynamic>?>(
          future: Supabase.instance.client
              .from('categories')
              .select()
              .eq('id', categoryId)
              .single(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('Загрузка...', style: GoogleFonts.nunitoSans());
            }
            if (snapshot.hasError) {
              return Text('Ошибка загрузки', style: GoogleFonts.nunitoSans());
            }
            return Text(snapshot.data?['name'] ?? 'Категория');
          },
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: Supabase.instance.client
            .from('products')
            .select()
            .eq('category_id', categoryId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.black));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Ошибка загрузки товаров',
                style: GoogleFonts.nunitoSans(),
              ),
            );
          }

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return Center(
              child: Text(
                'В этой категории пока нет товаров',
                style: GoogleFonts.nunitoSans(),
              ),
            );
          }
          return MasonryGridView.count(
            padding: EdgeInsets.all(16),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ProductCard(product: products[index]);
            },
          );
        },
      ),
    );
  }
}

class CategoriesPage extends StatefulWidget {
  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  late Future<List<Map<String, dynamic>>> _categoriesFuture;
  int _selectedCategory = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _fetchCategories();
  }

  Future<List<Map<String, dynamic>>> _fetchCategories() async {
    final response = await Supabase.instance.client.from('categories').select();
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Категории', style: GoogleFonts.nunitoSans(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        )),
        centerTitle: true,
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.black));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Ошибка загрузки категорий',
                style: GoogleFonts.nunitoSans(),
              ),
            );
          }

          final categories = snapshot.data ?? [];
          if (categories.isEmpty) {
            return Center(
              child: Text(
                'Категории не найдены',
                style: GoogleFonts.nunitoSans(),
              ),
            );
          }

          return Column(
            children: [
              SizedBox(
                height: 60,
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = index;
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              categories[index]['name'] ?? 'Категория',
                              style: GoogleFonts.nunitoSans(
                                fontSize: 16,
                                fontWeight: _selectedCategory == index
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: _selectedCategory == index
                                    ? Color(0xffFE8160)
                                    : Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            if (_selectedCategory == index)
                              Container(
                                height: 3,
                                width: 40,
                                color: Color(0xffFE8160),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Divider(height: 1, color: Colors.grey[300]),
              Expanded(
                child: _buildProductsList(categories[_selectedCategory]),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProductsList(Map<String, dynamic> category) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Supabase.instance.client
          .from('products')
          .select()
          .eq('category_id', category['id']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Colors.black));
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Ошибка загрузки товаров',
              style: GoogleFonts.nunitoSans(),
            ),
          );
        }

        final products = snapshot.data ?? [];

        if (products.isEmpty) {
          return Center(
            child: Text(
              'В этой категории пока нет товаров',
              style: GoogleFonts.nunitoSans(),
            ),
          );
        }

        return Expanded(
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: products.length,
            padding: EdgeInsets.fromLTRB(10, 0, 10, 15),
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(product: product);
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
