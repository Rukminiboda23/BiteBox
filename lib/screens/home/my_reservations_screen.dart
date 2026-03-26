import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bitebox/services/auth_service.dart';

class MyReservationsScreen extends StatelessWidget {
  const MyReservationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Please login first.")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("My Table Bookings 🥂")),
      body: StreamBuilder(
        // Query: Get reservations for the current user
        stream: FirebaseFirestore.instance
            .collection('reservations')
            .where('userId', isEqualTo: user.uid)
            // .orderBy('date', descending: true) // Uncomment if you create an Index
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading bookings."));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No upcoming bookings."));
          }

          var docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              String docId = docs[index].id;
              
              String date = data['date'] ?? 'Unknown Date';
              String time = data['time'] ?? 'Unknown Time';
              String guests = data['people'] ?? '2';
              String name = data['name'] ?? 'User';
              String status = data['status'] ?? 'Confirmed';

              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Header: Status and Delete
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.green),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () async {
                              // Delete Booking Logic
                              await FirebaseFirestore.instance.collection('reservations').doc(docId).delete();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Booking Cancelled.")));
                              }
                            },
                          )
                        ],
                      ),
                      const Divider(),
                      
                      // Date & Time Big Display
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today, color: Colors.orange[700]),
                          const SizedBox(width: 8),
                          Text("$date  |  $time", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // Details Grid
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text("Guests", style: TextStyle(color: Colors.grey)),
                              const SizedBox(height: 5),
                              Text(guests, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            children: [
                              const Text("Name", style: TextStyle(color: Colors.grey)),
                              const SizedBox(height: 5),
                              Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}