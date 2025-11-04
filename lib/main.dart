// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'product_model.dart';
import 'product_cubit.dart';
import 'product_state.dart';
import 'package:sizer/sizer.dart'; // Pastikan import ini ada

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductCubit(Dio())..fetchProducts(),
      child: Sizer(
        builder: (context, orientation, deviceType) {
          return MaterialApp(
            title: 'nge tesss si dio',
            theme: ThemeData(
              primarySwatch: Colors.red,
              brightness: Brightness.dark,
            ),
            home: const HomePage(),
          );
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSearchBar() {
    return Padding(
      // --- SIZER --- Ganti '8.0'
      padding: EdgeInsets.all(2.w),
      child: TextField(
        controller: _searchController,
        onChanged: (query) {
          context.read<ProductCubit>().filterProducts(query);
        },
        decoration: InputDecoration(
          hintText: 'Cari produk...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            // --- SIZER --- Ganti '12'
            borderRadius: BorderRadius.circular(12.sp),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.black.withOpacity(0.1),
        ),
      ),
    );
  }

  Widget _buildProductList(List<Product> products, bool isLargeScreen) {
    if (products.isEmpty) {
      return const Center(child: Text('Produk tidak ditemukan.'));
    }

    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          // --- SIZER --- Ganti 'horizontal: 16, vertical: 8'
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: ListTile(
            leading: Image.network(
              product.image,
              // --- SIZER --- Ganti 'width: 50, height: 50'
              // Kita pakai 12.w (12% lebar) agar proporsional
              width: 12.w,
              height: 12.w,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  // --- SIZER --- Ganti 'size: 50'
                  Icon(Icons.broken_image, size: 12.w),
            ),
            title: Text(product.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            // --- SIZER --- Ganti font size hardcode
            // Kita pakai .sp (Scalable Pixels) untuk teks
            subtitle: Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 12.sp),
            ),
            onTap: () {
              if (isLargeScreen) {
                context.read<ProductCubit>().selectProduct(product);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailPage(product: product),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('tessssssss bloc - cubit'),
        bottom: PreferredSize(
          // --- SIZER --- Ganti 'kToolbarHeight'
          // kToolbarHeight itu ~56. Kita buat responsif pakai 8% tinggi layar
          preferredSize: Size.fromHeight(8.h),
          child: _buildSearchBar(),
        ),
      ),
      body: BlocConsumer<ProductCubit, ProductState>(
        listener: (context, state) {
          if (state is ProductError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return LayoutBuilder(
            builder: (context, constraints) {
              // Breakpoint 600px ini tetap kita pakai untuk Adaptive
              final isLargeScreen = constraints.maxWidth >= 600;

              if (state is ProductLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is ProductLoaded) {
                if (isLargeScreen) {
                  return Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: _buildProductList(
                          state.filteredProducts,
                          isLargeScreen,
                        ),
                      ),
                      const VerticalDivider(width: 1),
                      Expanded(
                        flex: 2,
                        child: state.selectedProduct != null
                            ? DetailPage(product: state.selectedProduct!)
                            : Center(
                                // --- SIZER --- Ganti font size
                                child: Text(
                                  'Pilih produk dari daftar...',
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                              ),
                      ),
                    ],
                  );
                } else {
                  // Layout HP (Kecil)
                  return _buildProductList(
                    state.filteredProducts,
                    isLargeScreen,
                  );
                }
              }

              if (state is ProductError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.message, style: const TextStyle(color: Colors.red)),
                      SizedBox(height: 1.h), // --- SIZER ---
                      ElevatedButton(
                        onPressed: () {
                          context.read<ProductCubit>().fetchProducts();
                        },
                        child: const Text('Coba Lagi'),
                      )
                    ],
                  ),
                );
              }

              return const Center(child: Text('Memulai...'));
            },
          );
        },
      ),
    );
  }
}

// --- Halaman Detail juga kita ubah ---
class DetailPage extends StatelessWidget {
  final Product product;
  const DetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: SingleChildScrollView(
        // --- SIZER --- Ganti '16.0'
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                product.image,
                // --- SIZER --- Ganti '250'
                // Kita set 30% dari tinggi layar
                height: 30.h,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    // --- SIZER --- Ganti '250'
                    Icon(Icons.broken_image, size: 30.h),
              ),
            ),
            // --- SIZER --- Ganti '20'
            SizedBox(height: 2.h),
            Text(
              product.title,
              // --- SIZER --- Ganti TextTheme
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            // --- SIZER --- Ganti '10'
            SizedBox(height: 1.h),
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              // --- SIZER --- Ganti TextTheme
              style: TextStyle(
                fontSize: 22.sp,
                color: Colors.greenAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            // --- SIZER --- Ganti '20'
            SizedBox(height: 2.h),
            Text(
              'Deskripsi Produk',
              // --- SIZER --- Ganti TextTheme
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            // --- SIZER --- Ganti '10'
            SizedBox(height: 1.h),
            Text(
              product.description,
              // --- SIZER --- Ganti TextTheme
              style: TextStyle(fontSize: 12.sp),
            ),
          ],
        ),
      ),
    );
  }
}