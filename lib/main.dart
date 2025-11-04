// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'product_model.dart';
import 'product_cubit.dart';
import 'product_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductCubit(Dio())..fetchProducts(),
      child: MaterialApp(
        title: 'nge tesss si dio',
        theme: ThemeData(
          primarySwatch: Colors.red,
          brightness: Brightness.dark,
        ),
        // Kita tidak lagi butuh DetailPage sebagai route terpisah
        // karena akan kita gabung, tapi kita tetap butuh class-nya
        home: const HomePage(),
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
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        onChanged: (query) {
          context.read<ProductCubit>().filterProducts(query);
        },
        decoration: InputDecoration(
          hintText: 'Cari produk...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.black.withOpacity(0.1),
        ),
      ),
    );
  }

  // --- MODIFIKASI WIDGET INI ---
  // Tambahkan 'isLargeScreen' untuk menentukan aksi 'onTap'
  Widget _buildProductList(List<Product> products, bool isLargeScreen) {
    if (products.isEmpty) {
      return const Center(child: Text('Produk tidak ditemukan.'));
    }

    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: Image.network(
              product.image,
              width: 50,
              height: 50,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 50),
            ),
            title: Text(product.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
            onTap: () {
              // --- INI LOGIKA ADAPTIF-NYA ---
              if (isLargeScreen) {
                // Jika layar besar, panggil cubit untuk update state
                context.read<ProductCubit>().selectProduct(product);
              } else {
                // Jika layar kecil, navigasi seperti biasa
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
          preferredSize: const Size.fromHeight(kToolbarHeight),
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
          // --- GUNAKAN LAYOUTBUILDER UNTUK JADI RESPONSIVE/ADAPTIVE ---
          return LayoutBuilder(
            builder: (context, constraints) {
              // Tentukan breakpoint kita. 600px adalah standar umum.
              final isLargeScreen = constraints.maxWidth >= 600;

              if (state is ProductLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is ProductLoaded) {
                // --- INI BAGIAN ADAPTIVE UTAMA ---
                if (isLargeScreen) {
                  // --- LAYOUT TABLET/WEB ---
                  return Row(
                    children: [
                      // Bagian Kiri (List) - Responsif (flex: 1)
                      Expanded(
                        flex: 1,
                        child: _buildProductList(
                          state.filteredProducts,
                          isLargeScreen, // true
                        ),
                      ),
                      const VerticalDivider(width: 1),
                      // Bagian Kanan (Detail) - Responsif (flex: 2)
                      Expanded(
                        flex: 2,
                        child: state.selectedProduct != null
                            ? DetailPage(product: state.selectedProduct!)
                            : const Center(
                                child: Text('Pilih produk dari daftar...'),
                              ),
                      ),
                    ],
                  );
                } else {
                  // --- LAYOUT HP (KECIL) ---
                  // Tampilan standar, hanya list
                  return _buildProductList(
                    state.filteredProducts,
                    isLargeScreen, // false
                  );
                }
              }

              if (state is ProductError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.message, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 10),
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


// --- Class DetailPage tidak perlu diubah SAMA SEKALI ---
// Dia hanya menerima produk dan menampilkannya.
class DetailPage extends StatelessWidget {
  final Product product;
  const DetailPage({super.key, required this.product});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar ini hanya akan muncul jika di-push di layar kecil
      appBar: AppBar(
        title: Text(product.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                product.image,
                height: 250,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 250),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              product.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            Text(
              'Deskripsi Produk',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Text(
              product.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}