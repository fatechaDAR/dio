// lib/product_state.dart
import 'package:equatable/equatable.dart';
import 'product_model.dart'; 

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => []; // Ubah ke List<Object?>
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> allProducts;
  final List<Product> filteredProducts;
  
  // TAMBAHKAN INI: Lacak produk yang sedang dipilih
  final Product? selectedProduct; 

  const ProductLoaded({
    required this.allProducts,
    required this.filteredProducts,
    this.selectedProduct, // Tambahkan di constructor
  });

  @override
  // Tambahkan selectedProduct ke props
  List<Object?> get props => [allProducts, filteredProducts, selectedProduct];

  // Tambahkan copyWith untuk mempermudah update state
  ProductLoaded copyWith({
    List<Product>? allProducts,
    List<Product>? filteredProducts,
    Product? selectedProduct,
  }) {
    return ProductLoaded(
      allProducts: allProducts ?? this.allProducts,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      selectedProduct: selectedProduct ?? this.selectedProduct,
    );
  }
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object> get props => [message];
}