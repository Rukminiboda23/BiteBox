import 'package:flutter/material.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  // We simulate a driver moving by updating this value
  double _driverProgress = 0.3; 

  @override
  void initState() {
    super.initState();
    // Simulate movement: Update progress after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _driverProgress = 0.6);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Track Order 🛵")),
      body: Stack(
        children: [
          // 1. THE MAP BACKGROUND (Static Image)
          // Positioned.fill(
          //   child: Image.network(
          //     'https://i.imgur.com/L4L9p0D.png', 
          //     fit: BoxFit.cover,
          //     color: Colors.black.withOpacity(0.1),
          //     colorBlendMode: BlendMode.darken,
          //   ),
          // ),

          // 2. THE ROUTE LINE
          Center(
            child: Container(
              width: 5,
              height: 200,
              color: Colors.blueAccent.withOpacity(0.5),
            ),
          ),

          // 3. THE RESTAURANT MARKER (Top)
          // Removed 'const' here because Container inside has decoration
          Positioned(
            top: 150,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Icon(Icons.location_on, color: Colors.red, size: 40),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: const Text("Restaurant", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          // 4. THE DRIVER MARKER (Animated Position)
          AnimatedPositioned(
            duration: const Duration(seconds: 3),
            curve: Curves.easeInOut,
            top: 150 + (_driverProgress * 200), 
            left: 0, 
            right: 0,
            // Removed 'const' here as well
            child: Column(
              children: [
                const Icon(Icons.delivery_dining, color: Colors.blue, size: 50),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: const Text("Driver", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                ),
              ],
            ),
          ),

          // 5. BOTTOM INFO CARD
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(15),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Arriving in 15 mins", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text("Your food is on the way!", style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 20),
                  const LinearProgressIndicator(value: 0.6, backgroundColor: Colors.grey, color: Colors.orange),
                  const SizedBox(height: 20),
                  
                  // Driver Info
                  ListTile(
                    leading: const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.person, color: Colors.white)),
                    title: const Text("Ramesh Kumar"),
                    subtitle: const Text("4.8 ⭐ • Hero Splendor Bike"),
                    trailing: IconButton(
                      icon: const Icon(Icons.phone, color: Colors.green),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Calling Driver...")));
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}