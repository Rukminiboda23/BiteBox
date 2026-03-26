import 'package:flutter/material.dart';

// A simple class to represent an item in the cart
class CartItem {
  final String id;
  final String name;
  final double price;
  final int quantity;

  CartItem({required this.id, required this.name, required this.price, required this.quantity});
}

class CartProvider with ChangeNotifier {
  // This list holds the items
  final Map<String, CartItem> _items = {};

  // Getters
  Map<String, CartItem> get items => _items;
  
  int get itemCount => _items.length;

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, item) {
      total += item.price * item.quantity;
    });
    return total;
  }

  // Function to Add Item
  void addToCart(String id, String name, double price) {
    if (_items.containsKey(id)) {
      // If item already exists, increase quantity
      _items.update(
        id,
        (existing) => CartItem(
          id: existing.id,
          name: existing.name,
          price: existing.price,
          quantity: existing.quantity + 1,
        ),
      );
    } else {
      // If it's new, add it
      _items.putIfAbsent(
        id,
        () => CartItem(id: id, name: name, price: price, quantity: 1),
      );
    }
    notifyListeners(); // Tell the app to update the UI
  }

  // Clear Cart
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}