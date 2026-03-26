// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:bitebox/services/auth_service.dart';
// import 'package:intl/intl.dart'; // For formatting the date
// import 'package:bitebox/screens/order/tracking_screen.dart';

// class MyOrdersScreen extends StatelessWidget {
//   const MyOrdersScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final user = AuthService().currentUser;

//     if (user == null) {
//       return const Scaffold(body: Center(child: Text("Please login first.")));
//     }

//     return Scaffold(
//       appBar: AppBar(title: const Text("My Orders 📦")),
//       body: StreamBuilder(
//         // Query: Get orders where userId matches the current user
//         stream: FirebaseFirestore.instance
//             .collection('orders')
//             .where('userId', isEqualTo: user.uid)
//             .orderBy('timestamp', descending: true) // Newest first
//             .snapshots(),
//         builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return const Center(child: Text("Error loading orders."));
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text("You haven't ordered anything yet 🍔"));
//           }

//           var orders = snapshot.data!.docs;

//           return ListView.builder(
//             padding: const EdgeInsets.all(12),
//             itemCount: orders.length,
//             itemBuilder: (context, index) {
//               var data = orders[index].data() as Map<String, dynamic>;
//               String status = data['status'] ?? 'Pending';
//               double total = data['totalAmount'] ?? 0.0;
//               List<dynamic> items = data['items'] ?? [];
              
//               // Handle Timestamp
//               Timestamp? time = data['timestamp'];
//               String dateStr = time != null 
//                   ? DateFormat('dd MMM, hh:mm a').format(time.toDate()) 
//                   : "Just now";

//               // Color Logic for Status Tag
//               Color statusColor = Colors.orange;
//               if (status == 'Preparing') statusColor = Colors.blue;
//               if (status == 'Completed') statusColor = Colors.green;

//               return Card(
//                 margin: const EdgeInsets.only(bottom: 15),
//                 elevation: 4,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // --- HEADER: Date & Status ---
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(dateStr, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
//                           Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                             decoration: BoxDecoration(
//                               color: statusColor.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(20),
//                               border: Border.all(color: statusColor),
//                             ),
//                             child: Text(
//                               status.toUpperCase(),
//                               style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const Divider(height: 20),
                      
//                       // --- ITEMS LIST ---
//                       ...items.map((item) => Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 2),
//                         child: Row(
//                           children: [
//                             Text("${item['quantity']}x ", style: const TextStyle(fontWeight: FontWeight.bold)),
//                             Expanded(child: Text(item['name'])),
//                             Text("₹${item['price'] * item['quantity']}"),
//                           ],
//                         ),
//                       )),
                      
//                       const Divider(height: 20),
                      
//                       // --- TOTAL PRICE ---
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text("Total Paid", style: TextStyle(fontWeight: FontWeight.bold)),
//                           Text("₹$total", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
//                         ],
//                       ),

//                       // Inside my_orders_screen.dart
//                       if (status == 'Preparing' || status == 'Completed') ...[
//                         const SizedBox(height: 10),
//                         const Divider(),
//                         SizedBox(
//                           width: double.infinity,
//                           child: TextButton.icon(
//                             onPressed: () {
//                               // This opens the Mock Map
//                               Navigator.push(context, MaterialPageRoute(builder: (_) => const TrackingScreen()));
//                             },
//                             icon: const Icon(Icons.map, color: Colors.blue),
//                             label: const Text("Track Delivery 🛵", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bitebox/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:bitebox/screens/order/tracking_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    if (user == null) return const Scaffold(body: Center(child: Text("Login required")));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: Text("Order History", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('orders').where('userId', isEqualTo: user.uid).orderBy('timestamp', descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var orders = snapshot.data!.docs;
          if (orders.isEmpty) return Center(child: Text("No orders yet", style: GoogleFonts.poppins()));

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var data = orders[index].data() as Map<String, dynamic>;
              String status = data['status'] ?? 'Pending';
              double total = data['totalAmount'] ?? 0.0;
              List<dynamic> items = data['items'] ?? [];
              String dateStr = data['timestamp'] != null ? DateFormat('dd MMM, hh:mm a').format(data['timestamp'].toDate()) : "Now";

              Color statusColor = status == 'Completed' ? Colors.green : (status == 'Preparing' ? Colors.blue : Colors.orange);

              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)]),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(dateStr, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: Text(status.toUpperCase(), style: GoogleFonts.poppins(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10)),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    ...items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Text("${item['quantity']}x ", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.orange)),
                          Expanded(child: Text(item['name'], style: GoogleFonts.poppins())),
                          Text("₹${item['price'] * item['quantity']}", style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    )),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total Paid", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                        Text("₹$total", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                      ],
                    ),
                    if (status == 'Preparing' || status == 'Completed') ...[
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TrackingScreen())),
                          icon: const Icon(Icons.map, size: 18),
                          label: Text("Track Delivery", style: GoogleFonts.poppins()),
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.blue, side: const BorderSide(color: Colors.blue)),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}