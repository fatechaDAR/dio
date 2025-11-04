// lib/product_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'product_model.dart';
import 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final Dio _dio;

  ProductCubit(this._dio) : super(ProductInitial());

  Future<void> fetchProducts() async {
    try {
      emit(ProductLoading());
      final response = await _dio.get('https://fakestoreapi.com/products');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final products = data.map((json) => Product.fromJson(json)).toList();

        emit(ProductLoaded(
          allProducts: products,
          filteredProducts: products,
          // Saat pertama load, belum ada yang dipilih
          selectedProduct: null, 
        ));
      } else {
        emit(ProductError('Gagal memuat data: Status ${response.statusCode}'));
      }
    } on DioException catch (e) {
      emit(ProductError('Error jaringan: ${e.message}'));
    } catch (e) {
      emit(ProductError('Terjadi error: $e'));
    }
  }

  void filterProducts(String query) {
    if (state is ProductLoaded) {
      // Kita pakai 'as' untuk akses copyWith
      final currentState = state as ProductLoaded; 

      final filteredList = currentState.allProducts
          .where((product) =>
              product.title.toLowerCase().contains(query.toLowerCase()))
          .toList();

      // Gunakan copyWith untuk emit state baru
      // Ini akan menjaga selectedProduct yang sudah ada
      emit(currentState.copyWith(
        filteredProducts: filteredList,
      ));
    }
  }

  // TAMBAHKAN FUNGSI INI
  // Fungsi untuk mengubah produk yang dipilih
  void selectProduct(Product product) {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      
      // Kirim state baru dengan produk yang baru dipilih
      emit(currentState.copyWith(selectedProduct: product));
    }
  }
}