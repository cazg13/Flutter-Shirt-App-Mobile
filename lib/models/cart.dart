import 'package:flutter/material.dart';
import 'package:flutter_clothingapp/models/shirt.dart';
import 'package:flutter_clothingapp/bloc/shirt_bloc.dart';
import 'package:flutter_clothingapp/bloc/shirt_event.dart';
import 'package:flutter_clothingapp/repositories/shirt_repository.dart';

class Cart extends ChangeNotifier {
  
  List<Shirt> userCart = [];
  List<Shirt> _searchResults = [];
  List<Shirt> _allShirts = []; 

  Cart() {
     
  }

  
 

  // Get cart
  List<Shirt> getUserCart() {
    return userCart;
  }

  // Add items to cart
  void addItemToCart(Shirt shirt) {
    
     // Tạo BẢN COPY của shirt object
        Shirt shirtCopy = Shirt(
          id: shirt.id,
          name: shirt.name,
          price: shirt.price,
          description: shirt.description,
          imageUrl: shirt.imageUrl,
          stock: shirt.stock,
          sizes: shirt.sizes,
          selectedSize: shirt.selectedSize,  // ← Copy cái selectedSize hiện tại
          quantity: 1,
        );

        int existingIndex = userCart.indexWhere(
          (item) => item.id == shirtCopy.id && 
                    item.selectedSize == shirtCopy.selectedSize &&
                    shirtCopy.selectedSize != null,
        );

        if (existingIndex != -1) {
          // Item đã có → tăng quantity (hoặc return)
           userCart[existingIndex].quantity += 1;
        } else {
          // Add COPY thay vì original
          userCart.add(shirtCopy);  // ← Thêm vào bản copy
        }
        notifyListeners();
        
  }

  // Remove item from cart
  void removeItemfromCart(Shirt shirt) {
    userCart.removeWhere((item) => item.id == shirt.id
    && item.selectedSize == shirt.selectedSize);
    notifyListeners();
  }

  // Get search results
  List<Shirt> get searchResults => _searchResults;
 

  // Search products
  void searchShirt(String query) {
      print('=== DEBUG SEARCH ===');
      print('Query: $query');
      print('All shirts count: ${_allShirts.length}');
      
      if (query.isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = _allShirts
            .where((shirt) {
              bool match = shirt.name.toLowerCase().contains(query.toLowerCase());
              print('Checking ${shirt.name} → $match');
              return match;
            })
            .toList();
      }
      print('Search results: ${_searchResults.length}');
      notifyListeners();
    }
      
  
  // Set tất cả shirts từ BLoC để dùng cho search
    void setAllShirts(List<Shirt> shirts) {
      _allShirts = shirts;
      notifyListeners();
    }

  // Clear search
  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }
  // Tăng quantity
  void increaseQuantity(Shirt shirt) {
    int index = userCart.indexWhere(
      (item) => item.id == shirt.id && item.selectedSize == shirt.selectedSize
    );
    if (index != -1) {
      userCart[index].quantity += 1;
      notifyListeners();
    }
  }

// Giảm quantity
  void decreaseQuantity(Shirt shirt) {
    int index = userCart.indexWhere(
      (item) => item.id == shirt.id && item.selectedSize == shirt.selectedSize
    );
    if (index != -1 && userCart[index].quantity > 1) {
      userCart[index].quantity -= 1;
      notifyListeners();
    }
  } 
}