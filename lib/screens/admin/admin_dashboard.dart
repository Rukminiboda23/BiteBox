import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bitebox/services/auth_service.dart';
import 'package:bitebox/screens/auth/login_screen.dart';
import 'package:bitebox/screens/admin/add_menu_item.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  void _updateStatus(String orderId, String newStatus) {
    FirebaseFirestore.instance.collection('orders').doc(orderId).update({'status': newStatus});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: Text("Kitchen Orders 👨‍🍳", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () {
              AuthService().signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text("Add Item", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMenuItemScreen())),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('orders').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var orders = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var data = orders[index].data() as Map<String, dynamic>;
              String status = data['status'] ?? 'Pending';
              List<dynamic> items = data['items'] ?? [];
              Color statusColor = status == 'Completed' ? Colors.green : (status == 'Preparing' ? Colors.blue : Colors.orange);

              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(data['userEmail'].split('@')[0], style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("₹${data['totalAmount']}", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                    const Divider(),
                    ...items.map((item) => Text("${item['quantity']}x ${item['name']}", style: GoogleFonts.poppins(color: Colors.grey[700]))),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Status:", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: status,
                              icon: Icon(Icons.arrow_drop_down, color: statusColor),
                              items: ['Pending', 'Preparing', 'Completed'].map((s) => DropdownMenuItem(value: s, child: Text(s, style: GoogleFonts.poppins(color: statusColor, fontWeight: FontWeight.bold)))).toList(),
                              onChanged: (val) { if (val != null) _updateStatus(orders[index].id, val); },
                            ),
                          ),
                        ),
                      ],
                    )
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