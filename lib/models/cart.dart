import 'package:flutter/material.dart';
import 'package:flutter_clothingapp/models/shoe.dart';
import 'package:flutter_clothingapp/bloc/shoe_bloc.dart';
import 'package:flutter_clothingapp/bloc/shoe_event.dart';
import 'package:flutter_clothingapp/repositories/shoe_repository.dart';

class Cart extends ChangeNotifier {
  
  List<Shoe> userCart = [];
  List<Shoe> _searchResults = [];
  List<Shoe> _allShoes = []; 

  Cart() {
     
  }

  
 

  // Get cart
  List<Shoe> getUserCart() {
    return userCart;
  }

  // Add items to cart
  void addItemToCart(Shoe shoe) {
    
     // Tạo BẢN COPY của shoe object
        Shoe shoeCopy = Shoe(
          id: shoe.id,
          name: shoe.name,
          price: shoe.price,
          description: shoe.description,
          imageUrl: shoe.imageUrl,
          stock: shoe.stock,
          sizes: shoe.sizes,
          selectedSize: shoe.selectedSize,  // ← Copy cái selectedSize hiện tại
          quantity: 1,
        );

        int existingIndex = userCart.indexWhere(
          (item) => item.id == shoeCopy.id && 
                    item.selectedSize == shoeCopy.selectedSize &&
                    shoeCopy.selectedSize != null,
        );

        if (existingIndex != -1) {
          // Item đã có → tăng quantity (hoặc return)
           userCart[existingIndex].quantity += 1;
        } else {
          // Add COPY thay vì original
          userCart.add(shoeCopy);  // ← Thêm vào bản copy
        }
        notifyListeners();
        
  }

  // Remove item from cart
  void removeItemfromCart(Shoe shoe) {
    userCart.removeWhere((item) => item.id == shoe.id
    && item.selectedSize == shoe.selectedSize);
    notifyListeners();
  }

  // Get search results
  List<Shoe> get searchResults => _searchResults;
 

  // Search products
  void searchShoe(String query) {
      print('=== DEBUG SEARCH ===');
      print('Query: $query');
      print('All shoes count: ${_allShoes.length}');
      
      if (query.isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = _allShoes
            .where((shoe) {
              bool match = shoe.name.toLowerCase().contains(query.toLowerCase());
              print('Checking ${shoe.name} → $match');
              return match;
            })
            .toList();
      }
      print('Search results: ${_searchResults.length}');
      notifyListeners();
    }
      
  
  // Set tất cả shoes từ BLoC để dùng cho search
    void setAllShoes(List<Shoe> shoes) {
      _allShoes = shoes;
      notifyListeners();
    }

  // Clear search
  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }
  // Tăng quantity
  void increaseQuantity(Shoe shoe) {
    int index = userCart.indexWhere(
      (item) => item.id == shoe.id && item.selectedSize == shoe.selectedSize
    );
    if (index != -1) {
      userCart[index].quantity += 1;
      notifyListeners();
    }
  }

// Giảm quantity
  void decreaseQuantity(Shoe shoe) {
    int index = userCart.indexWhere(
      (item) => item.id == shoe.id && item.selectedSize == shoe.selectedSize
    );
    if (index != -1 && userCart[index].quantity > 1) {
      userCart[index].quantity -= 1;
      notifyListeners();
    }
  } 
}