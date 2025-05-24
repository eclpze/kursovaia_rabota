import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kursovaia_work/Product.dart';
import 'package:kursovaia_work/main/Main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Popular extends StatelessWidget {
  const Popular({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Supabase.instance.client
          .from('products')
          .select()
          .eq('is_popular', true)
          .limit(5),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Colors.black));
        }

        if (snapshot.hasError) {
          return Center(child: Text('Ошибка загрузки данных', style: GoogleFonts.nunitoSans()));
        }

        final products = snapshot.data ?? [];

        return SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(product: product);
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
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Supabase.instance.client
          .from('products')
          .select()
          .eq('is_popular', true),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Colors.black));
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

        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(
                          context,
                        ).push(MaterialPageRoute(builder: (context) => Main()));
                      },
                      child: SvgPicture.asset('assets/icons/arrow-left.svg'),
                    ),
                    Spacer(),
                    Text(
                      'Популярное',
                      style: GoogleFonts.nunitoSans(
                        color: Color(0xff212121),
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ),
              SizedBox(height: 15),
              Expanded(
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
              ),
            ],
          ),
        );
      },
    );
  }
}
