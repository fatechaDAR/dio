// lib/product_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'product_model.dart';
import 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final Dio _dio;

  // Beri tahu Cubit apa state awalnya (ProductInitial)
  ProductCubit(this._dio) : super(ProductInitial());

  // --- Fungsi untuk mengambil data ---
  Future<void> fetchProducts() async {
    try {
      // 1. Kirim state Loading agar UI tampilkan progres
      emit(ProductLoading());

      // 2. Panggil API
      final response = await _dio.get('https://fakestoreapi.com/products');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final products = data.map((json) => Product.fromJson(json)).toList();

        // 3. Kirim state Sukses (Loaded) beserta datanya
        emit(ProductLoaded(
          allProducts: products,
          filteredProducts: products, // Awalnya tampilkan semua
        ));
      } else {
        // 4. Kirim state Error jika status code bukan 200
        emit(ProductError('Gagal memuat data: Status ${response.statusCode}'));
      }
    } on DioException catch (e) {
      // 4. Kirim state Error jika Dio gagal
      emit(ProductError('Error jaringan: ${e.message}'));
    } catch (e) {
      // 4. Kirim state Error untuk masalah lainnya
      emit(ProductError('Terjadi error: $e'));
    }
  }

  // --- Fungsi untuk pencarian ---
  void filterProducts(String query) {
    // Hanya filter jika state-nya sedang ProductLoaded
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      final allProducts = currentState.allProducts;

      if (query.isEmpty) {
        // Jika query kosong, tampilkan semua
        emit(ProductLoaded(
          allProducts: allProducts,
          filteredProducts: allProducts,
        ));
      } else {
        // Jika ada query, filter
        final filteredList = allProducts
            .where((product) =>
                product.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
        
        // Kirim state baru dengan hasil filter
        emit(ProductLoaded(
          allProducts: allProducts,
          filteredProducts: filteredList,
        ));
      }
    }
  }
}