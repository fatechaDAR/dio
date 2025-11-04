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
    // 1. Sediakan Cubit di level tertinggi aplikasi
    // Kita juga langsung panggil ..fetchProducts() agar data
    // langsung diambil saat aplikasi dibuka.
    return BlocProvider(
      create: (context) => ProductCubit(Dio())..fetchProducts(),
      child: MaterialApp(
        title: 'nge tesss si dio',
        theme: ThemeData(
          primarySwatch: Colors.red,
          brightness: Brightness.dark,
        ),
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
  // Controller untuk text field pencarian
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  // Widget untuk search bar
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        onChanged: (query) {
          // Panggil fungsi filter di Cubit setiap kali teks berubah
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

  // Widget untuk menampilkan list produk
  Widget _buildProductList(List<Product> products) {
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailPage(product: product),
                ),
              );
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
        // Tampilkan search bar di sini
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: _buildSearchBar(),
        ),
      ),
      // 2. Gunakan BlocConsumer
      // (Gabungan BlocListener dan BlocBuilder, seperti di video)
      body: BlocConsumer<ProductCubit, ProductState>(
        // --- LISTENER: Untuk aksi sekali jalan (spt SnackBar) ---
        listener: (context, state) {
          if (state is ProductError) {
            // Tampilkan SnackBar jika state-nya Error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        // --- BUILDER: Untuk membangun/menggambar UI ---
        builder: (context, state) {
          // Tentukan widget apa yang tampil berdasarkan state
          
          // 3. Jika state-nya Loading
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 4. Jika state-nya Sukses (Loaded)
          if (state is ProductLoaded) {
            // Kita ambil data produk dari state
            return _buildProductList(state.filteredProducts);
          }

          // 5. Jika state-nya Error (tampilkan pesan)
          if (state is ProductError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      // Coba panggil API lagi
                      context.read<ProductCubit>().fetchProducts();
                    }, 
                    child: const Text('Coba Lagi'),
                  )
                ],
              ),
            );
          }

          // 6. Jika state-nya Initial (awal)
          return const Center(child: Text('Memulai...'));
        },
      ),
    );
  }
}


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