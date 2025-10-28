// lib/main.dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'product_model.dart'; // Impor model yang tadi kita buat

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Produk Dio',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: const HomePage(),
    );
  }
}

// --- Halaman Utama (List, Search, Error Handling) ---
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Dio _dio = Dio();
  List<Product> _allProducts = []; // Menyimpan semua produk dari API
  List<Product> _displayedProducts = []; // Produk yang ditampilkan (hasil filter)
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  
  Future<void> _fetchProducts() async {
    try {
      final response = await _dio.get('https://fakestoreapi.com/products');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        setState(() {
          _allProducts = data.map((json) => Product.fromJson(json)).toList();
          _displayedProducts = _allProducts; 
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Gagal memuat data: Status ${response.statusCode}';
          _isLoading = false;
        });
      }
    } on DioException catch (e) {
      // Menangani error koneksi atau Dio
      setState(() {
        _error = 'Error jaringan: ${e.message}';
        _isLoading = false;
      });
    } catch (e) {
      // Menangani error lainnya
      setState(() {
        _error = 'Terjadi error: $e';
        _isLoading = false;
      });
    }
  }

  // 2. Fitur Pencarian Sederhana
  void _filterProducts(String query) {
    setState(() {
      _displayedProducts = _allProducts
          .where((product) =>
              product.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Widget _buildBody() {
    // Tampilkan loading
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Tampilkan error (Error Handling)
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Error: $_error', style: const TextStyle(color: Colors.red)),
        ),
      );
    }
    
    // Tampilkan jika hasil pencarian kosong
    if (_displayedProducts.isEmpty) {
      return const Center(child: Text('Produk tidak ditemukan.'));
    }

    // Tampilkan List Produk (ListView)
    return ListView.builder(
      itemCount: _displayedProducts.length,
      itemBuilder: (context, index) {
        final product = _displayedProducts[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: Image.network(
              product.image,
              width: 50,
              height: 50,
              fit: BoxFit.contain,
              // Error builder untuk gambar jika gagal dimuat
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 50),
            ),
            title: Text(product.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
            // 3. Navigasi ke Halaman Detail
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
        title: const Text('Daftar Produk'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _filterProducts, // Memanggil fungsi search setiap ada perubahan teks
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
          ),
        ),
      ),
      body: _buildBody(),
    );
  }
}

// --- Halaman Detail ---
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