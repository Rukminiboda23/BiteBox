import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bitebox/services/auth_service.dart';
import 'package:intl/intl.dart';

class BookTableScreen extends StatefulWidget {
  const BookTableScreen({super.key});

  @override
  State<BookTableScreen> createState() => _BookTableScreenState();
}

class _BookTableScreenState extends State<BookTableScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _peopleController = TextEditingController(text: "2");
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isLoading = false;

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
        context: context, initialDate: _selectedDate, firstDate: DateTime.now(), lastDate: DateTime(2026));
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: _selectedTime);
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _bookTable() async {
    setState(() => _isLoading = true);
    try {
      final user = AuthService().currentUser;
      await FirebaseFirestore.instance.collection('reservations').add({
        'userId': user?.uid,
        'name': _nameController.text,
        'phone': _phoneController.text,
        'people': _peopleController.text,
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'time': _selectedTime.format(context),
        'status': 'Confirmed', // Auto-confirm for MVP
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Table Booked! 🥂")));
        Navigator.pop(context);
      }
    } catch (e) {
      print(e);
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Book a Table")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: _phoneController, decoration: const InputDecoration(labelText: "Phone")),
            TextField(controller: _peopleController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Number of People")),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: ElevatedButton(onPressed: _selectDate, child: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)))),
                const SizedBox(width: 10),
                Expanded(child: ElevatedButton(onPressed: _selectTime, child: Text(_selectedTime.format(context)))),
              ],
            ),
            const SizedBox(height: 30),
            _isLoading ? const CircularProgressIndicator() : ElevatedButton(onPressed: _bookTable, style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white), child: const Text("Confirm Booking"))
          ],
        ),
      ),
    );
  }
}