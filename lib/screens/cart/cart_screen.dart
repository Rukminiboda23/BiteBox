// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:bitebox/providers/cart_provider.dart';
// import 'package:bitebox/services/auth_service.dart';

// class CartScreen extends StatefulWidget {
//   const CartScreen({super.key});

//   @override
//   State<CartScreen> createState() => _CartScreenState();
// }

// class _CartScreenState extends State<CartScreen> {
//   bool _isLoading = false;

//   // Function to Place Order
//   void _placeOrder(CartProvider cart) async {
//     setState(() => _isLoading = true);

//     try {
//       final user = AuthService().currentUser;
//       if (user == null) return;

//       // 1. Create Order Data
//       await FirebaseFirestore.instance.collection('orders').add({
//         'userId': user.uid,
//         'userEmail': user.email,
//         'totalAmount': cart.totalAmount,
//         'status': 'Pending', // Initial status
//         'paymentMethod': 'Cash on Delivery',
//         'timestamp': FieldValue.serverTimestamp(),
//         'items': cart.items.values.map((item) => {
//           'id': item.id,
//           'name': item.name,
//           'quantity': item.quantity,
//           'price': item.price,
//         }).toList(),
//       });

//       // 2. Clear Cart & Show Success
//       cart.clearCart();
//       if (mounted) {
//         showDialog(
//           context: context,
//           builder: (ctx) => AlertDialog(
//             title: const Text("Order Placed! 🎉"),
//             content: const Text("Your food is being prepared. Check status in My Orders."),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(ctx).pop(); // Close dialog
//                   Navigator.of(context).pop(); // Go back to Home
//                 },
//                 child: const Text("Okay"),
//               )
//             ],
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
//       }
//     }

//     setState(() => _isLoading = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Listen to Cart Data
//     final cart = Provider.of<CartProvider>(context);
//     final cartItems = cart.items.values.toList();

//     return Scaffold(
//       appBar: AppBar(title: const Text("Your Cart")),
//       body: cart.items.isEmpty
//           ? const Center(child: Text("Your cart is empty 🛒", style: TextStyle(fontSize: 18)))
//           : Column(
//               children: [
//                 // LIST OF ITEMS
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: cart.items.length,
//                     itemBuilder: (ctx, i) => Card(
//                       margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
//                       child: ListTile(
//                         leading: CircleAvatar(
//                           backgroundColor: Colors.orange[100],
//                           child: Text("${cartItems[i].quantity}x"),
//                         ),
//                         title: Text(cartItems[i].name),
//                         subtitle: Text("Total: ₹${(cartItems[i].price * cartItems[i].quantity)}"),
//                         trailing: IconButton(
//                           icon: const Icon(Icons.delete, color: Colors.red),
//                           onPressed: () {
//                             // Ideally remove single item, but for now we haven't built that function
//                             // So we just tell user they can't delete yet or add a clear button
//                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("To remove, clear cart (Feature coming soon)")));
//                           },
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),

//                 // TOTAL & CHECKOUT BUTTON
//                 Card(
//                   margin: const EdgeInsets.all(15),
//                   elevation: 5,
//                   child: Padding(
//                     padding: const EdgeInsets.all(20),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text("Total", style: TextStyle(fontSize: 16, color: Colors.grey)),
//                             Text("₹${cart.totalAmount}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
//                           ],
//                         ),
//                         _isLoading
//                             ? const CircularProgressIndicator()
//                             : ElevatedButton(
//                                 onPressed: () => _placeOrder(cart),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.orange,
//                                   foregroundColor: Colors.white,
//                                   padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
//                                 ),
//                                 child: const Text("PLACE ORDER", style: TextStyle(fontSize: 18)),
//                               ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bitebox/providers/cart_provider.dart';
import 'package:bitebox/services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = false;

  void _placeOrder(CartProvider cart) async {
    setState(() => _isLoading = true);
    try {
      final user = AuthService().currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance.collection('orders').add({
        'userId': user.uid,
        'userEmail': user.email,
        'totalAmount': cart.totalAmount,
        'status': 'Pending',
        'paymentMethod': 'Cash on Delivery',
        'timestamp': FieldValue.serverTimestamp(),
        'items': cart.items.values.map((item) => {
          'id': item.id, 'name': item.name, 'quantity': item.quantity, 'price': item.price,
        }).toList(),
      });

      cart.clearCart();
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text("Order Placed! 🎉", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            content: Text("Your food is being prepared.", style: GoogleFonts.poppins()),
            actions: [
              TextButton(
                onPressed: () { Navigator.of(ctx).pop(); Navigator.of(context).pop(); },
                child: Text("Okay", style: GoogleFonts.poppins(color: Colors.orange)),
              )
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final cartItems = cart.items.values.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: Text("My Cart", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: cart.items.isEmpty
          ? Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                const SizedBox(height: 10),
                Text("Your cart is empty", style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey)),
              ],
            ))
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: cart.items.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 15),
                    itemBuilder: (ctx, i) => Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: Text("${cartItems[i].quantity}x", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.orange)),
                        ),
                        title: Text(cartItems[i].name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        subtitle: Text("₹${(cartItems[i].price * cartItems[i].quantity)}", style: GoogleFonts.poppins(color: Colors.grey)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Use 'Clear Cart' to remove all items (MVP)."))),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total Amount", style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)),
                          Text("₹${cart.totalAmount}", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : () => _placeOrder(cart),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 5,
                          ),
                          child: _isLoading 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text("Place Order", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}