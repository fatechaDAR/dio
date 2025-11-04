// lib/product_state.dart
import 'package:equatable/equatable.dart';
import 'product_model.dart'; 

// abstract class agar bisa di-extend
abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object> get props => [];
}

// 1. Status Awal: Belum terjadi apa-apa
class ProductInitial extends ProductState {}

// 2. Status Loading: Sedang mengambil data dari API
class ProductLoading extends ProductState {}

// 3. Status Sukses: Data berhasil didapat
class ProductLoaded extends ProductState {
  // Simpan data produk di dalam state ini
  final List<Product> allProducts;
  final List<Product> filteredProducts;

  const ProductLoaded({
    required this.allProducts,
    required this.filteredProducts,
  });

  @override
  List<Object> get props => [allProducts, filteredProducts];
}

// 4. Status Error: Terjadi kegagalan
class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object> get props => [message];
}