import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Pro Images
import 'package:google_fonts/google_fonts.dart';
import 'package:bitebox/services/auth_service.dart';
import 'package:bitebox/screens/auth/login_screen.dart';
import 'package:bitebox/providers/cart_provider.dart';
import 'package:bitebox/screens/cart/cart_screen.dart';
import 'package:bitebox/screens/order/my_orders_screen.dart';
import 'package:bitebox/screens/home/book_table_screen.dart';
import 'package:bitebox/screens/home/my_reservations_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Pizza', 'Burger', 'Fries', 'Biryani', 'Dessert'];

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8), // Light Grey BG
      
      // --- CUSTOM APP BAR ---
      appBar: AppBar(
        title: Column(
          children: [
            Text("Delivering to", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.orange),
                Text(" Home, New York ", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                const Icon(Icons.keyboard_arrow_down, size: 16),
              ],
            ),
          ],
        ),
        actions: [
          // Cart Icon with Badge
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_bag_outlined, size: 28),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
                ),
                Positioned(
                  right: 5, top: 5,
                  child: Consumer<CartProvider>(
                    builder: (ctx, cart, _) => cart.itemCount > 0
                      ? Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          child: Text('${cart.itemCount}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        )
                      : Container(),
                  ),
                )
              ],
            ),
          )
        ],
      ),

      // --- DRAWER (Keep existing) ---
      drawer: _buildDrawer(context, user?.email ?? "Guest"),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // 1. SEARCH BAR
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search 'Pizza'...",
                    hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(15),
                  ),
                ),
              ),
            ),

            // 2. PROMO BANNER (Carousel simulation)
            SizedBox(
              height: 160,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 16),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildPromoCard(Colors.orangeAccent, "30% OFF", "On your first order", "https://i.imgur.com/CGCyp1d.png"),
                  _buildPromoCard(Colors.blueAccent, "FREE DRINK", "With every burger", "https://i.imgur.com/l2XbdgE.png"),
                ],
              ),
            ),

            // 3. CATEGORIES
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: Text("Categories", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  bool isSelected = _selectedCategory == _categories[index];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = _categories[index]),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.orange : Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: isSelected ? null : Border.all(color: Colors.grey[300]!),
                      ),
                      child: Center(
                        child: Text(
                          _categories[index],
                          style: GoogleFonts.poppins(
                            color: isSelected ? Colors.white : Colors.black87, 
                            fontWeight: FontWeight.w600
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // 4. POPULAR ITEMS (GRID VIEW)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: Text("Popular Now 🔥", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('menu_items').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                var items = snapshot.data!.docs;
                if (_selectedCategory != 'All') {
                  items = items.where((doc) => doc['category'] == _selectedCategory).toList();
                }

                if (items.isEmpty) return const Center(child: Text("No items found."));

            //     return GridView.builder(
            //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            //       shrinkWrap: true, // Important for scrolling inside Column
            //       physics: const NeverScrollableScrollPhysics(), // Disable Grid scrolling
            //       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            //         crossAxisCount: 2, // 2 Items per row
            //         childAspectRatio: 0.75, // Taller cards
            //         crossAxisSpacing: 15,
            //         mainAxisSpacing: 15,
            //       ),
            //       itemCount: items.length,
            //       itemBuilder: (context, index) {
            //         var data = items[index].data() as Map<String, dynamic>;
            //         return _buildFoodCard(context, items[index].id, data);
            //       },
            //     );
            //   },
            // ),

                return Center(
                  // Constrain the width so it doesn't stretch infinitely on huge monitors
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1000), 
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200, // Maximum width of one card
                        childAspectRatio: 0.75, // Height ratio
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        var data = items[index].data() as Map<String, dynamic>;
                        return _buildFoodCard(context, items[index].id, data);
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGET: PROMO CARD ---
  Widget _buildPromoCard(Color color, String title, String subtitle, String imgUrl) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 5),
                Text(subtitle, style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: Text("Order Now", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
                )
              ],
            ),
          ),
          // Placeholder for Image (You can use network images here)
          const Icon(Icons.fastfood, size: 80, color: Colors.white24),
        ],
      ),
    );
  }

  // --- HELPER WIDGET: FOOD GRID CARD ---
  Widget _buildFoodCard(BuildContext context, String docId, Map<String, dynamic> data) {
    String imageUrl = data['imageUrl'] ?? '';
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl, 
                        width: double.infinity, 
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: Colors.grey[200]),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      )
                    : Container(color: Colors.grey[200]),
                ),
                Positioned(
                  top: 10, right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.favorite_border, size: 16, color: Colors.grey),
                  ),
                )
              ],
            ),
          ),
          
          // DETAILS
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['name'], maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(data['category'] ?? 'General', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("₹${data['price']}", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange)),
                    InkWell(
                      onTap: () {
                         Provider.of<CartProvider>(context, listen: false).addToCart(docId, data['name'], data['price']);
                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${data['name']} added!"), duration: const Duration(seconds: 1)));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                        child: const Icon(Icons.add, color: Colors.white, size: 20),
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

//   // --- HELPER: DRAWER (Same as before, just styled) ---
//   Widget _buildDrawer(BuildContext context, String email) {
//     return Drawer(
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: [
//           UserAccountsDrawerHeader(
//             accountName: Text("Welcome", style: GoogleFonts.poppins()),
//             accountEmail: Text(email, style: GoogleFonts.poppins()),
//             currentAccountPicture: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person, color: Colors.orange)),
//             decoration: const BoxDecoration(color: Colors.orange),
//           ),
//           _drawerItem(context, Icons.fastfood, "Menu", null),
//           _drawerItem(context, Icons.shopping_bag, "My Orders", const MyOrdersScreen()),
//           _drawerItem(context, Icons.table_bar, "Book Table", const BookTableScreen()),
//           _drawerItem(context, Icons.event_seat, "Reservations", const MyReservationsScreen()),
//           const Divider(),
//           ListTile(
//             leading: const Icon(Icons.logout, color: Colors.red),
//             title: Text("Logout", style: GoogleFonts.poppins(color: Colors.red)),
//             onTap: () {
//               AuthService().signOut();
//               Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _drawerItem(BuildContext context, IconData icon, String title, Widget? page) {
//     return ListTile(
//       leading: Icon(icon, color: Colors.black87),
//       title: Text(title, style: GoogleFonts.poppins(fontSize: 15)),
//       onTap: () {
//         Navigator.pop(context);
//         if (page != null) Navigator.push(context, MaterialPageRoute(builder: (_) => page));
//       },
//     );
//   }
// }

// --- HELPER: MODERN DRAWER ---
  Widget _buildDrawer(BuildContext context, String email) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Header
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFFFF5722), // Deep Orange
              image: DecorationImage(
                image: NetworkImage("https://i.imgur.com/L4L9p0D.png"), // Subtle pattern
                fit: BoxFit.cover,
                opacity: 0.2,
              ),
            ),
            accountName: Text("Welcome", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            accountEmail: Text(email, style: GoogleFonts.poppins(fontSize: 14)),
            currentAccountPicture: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                color: Colors.white,
              ),
              child: const Icon(Icons.person, color: Colors.orange, size: 40),
            ),
          ),
          
          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _drawerItem(context, Icons.fastfood_outlined, "Menu", null),
                _drawerItem(context, Icons.shopping_bag_outlined, "My Orders", const MyOrdersScreen()),
                _drawerItem(context, Icons.table_bar_outlined, "Book Table", const BookTableScreen()),
                _drawerItem(context, Icons.event_seat_outlined, "My Reservations", const MyReservationsScreen()),
              ],
            ),
          ),

          // Logout at Bottom
          const Divider(),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.logout, color: Colors.red, size: 20),
            ),
            title: Text("Logout", style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.w600)),
            onTap: () {
              AuthService().signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String title, Widget? page) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: Colors.black87, size: 20),
      ),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
      onTap: () {
        Navigator.pop(context);
        if (page != null) Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
    );
  }
}