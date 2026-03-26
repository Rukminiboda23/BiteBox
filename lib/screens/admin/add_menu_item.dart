import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class AddMenuItemScreen extends StatefulWidget {
  const AddMenuItemScreen({super.key});

  @override
  State<AddMenuItemScreen> createState() => _AddMenuItemScreenState();
}

class _AddMenuItemScreenState extends State<AddMenuItemScreen> {
  // ---------------- CONFIGURATION ---------------- //
  final String cloudName = "dtogz4idv"; 
  final String uploadPreset = "bitebox_preset"; 
  // ---------------------------------------------- //

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  
  // New Controller for Custom Category
  final TextEditingController _customCategoryController = TextEditingController();

  File? _selectedImage;
  bool _isLoading = false;

  // List of Default Categories
  final List<String> _categories = ['Pizza', 'Burger', 'Fries', 'Biryani', 'Drinks', 'Dessert', 'Other'];
  String _selectedCategory = 'Pizza'; // Default selection
  bool _isCustomCategory = false; // To check if "Other" is selected

  // 1. Pick Image
  Future<void> _pickImage() async {
    final returnedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnedImage != null) {
      setState(() {
        _selectedImage = File(returnedImage.path);
      });
    }
  }

  // 2. Upload to Cloudinary
  Future<String?> _uploadToCloudinary(File image) async {
    try {
      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', image.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final jsonMap = jsonDecode(String.fromCharCodes(responseData));
        return jsonMap['secure_url'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // 3. Save to Firestore
  Future<void> _uploadItem() async {
    // Logic to determine the final category name
    String finalCategory = _isCustomCategory ? _customCategoryController.text.trim() : _selectedCategory;

    if (!_formKey.currentState!.validate() || _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields and pick an image!"))
      );
      return;
    }

    if (finalCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a category name"))
      );
      return;
    }

    setState(() => _isLoading = true);

    String? imageUrl = await _uploadToCloudinary(_selectedImage!);

    if (imageUrl != null) {
      try {
        await FirebaseFirestore.instance.collection('menu_items').add({
          'name': _nameController.text,
          'price': double.parse(_priceController.text),
          'description': _descController.text,
          'imageUrl': imageUrl,
          'category': finalCategory, // <--- SAVING THE SELECTED CATEGORY
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Item Added! 🍔")));
          Navigator.pop(context);
        }
      } catch (e) {
        print(e);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Image upload failed.")));
      }
    }

    setState(() => _isLoading = false);
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(title: const Text("Add New Item")),
  //     body: SingleChildScrollView(
  //       padding: const EdgeInsets.all(16),
  //       child: Form(
  //         key: _formKey,
  //         child: Column(
  //           children: [
  //             // Image Picker
  //             GestureDetector(
  //               onTap: _pickImage,
  //               child: Container(
  //                 height: 150,
  //                 width: double.infinity,
  //                 decoration: BoxDecoration(
  //                   color: Colors.grey[200],
  //                   borderRadius: BorderRadius.circular(10),
  //                   border: Border.all(color: Colors.grey),
  //                 ),
  //                 child: _selectedImage != null
  //                     ? Image.file(_selectedImage!, fit: BoxFit.cover)
  //                     : const Column(
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         children: [
  //                           Icon(Icons.cloud_upload, size: 40, color: Colors.blueAccent),
  //                           Text("Tap to upload Image"),
  //                         ],
  //                       ),
  //               ),
  //             ),
  //             const SizedBox(height: 20),
              
  //             // Name
  //             TextFormField(
  //               controller: _nameController,
  //               decoration: const InputDecoration(labelText: "Food Name", border: OutlineInputBorder()),
  //               validator: (val) => val!.isEmpty ? "Enter name" : null,
  //             ),
  //             const SizedBox(height: 15),

  //             // CATEGORY DROPDOWN
  //             DropdownButtonFormField<String>(
  //               value: _selectedCategory,
  //               decoration: const InputDecoration(labelText: "Category", border: OutlineInputBorder()),
  //               items: _categories.map((String category) {
  //                 return DropdownMenuItem<String>(
  //                   value: category,
  //                   child: Text(category),
  //                 );
  //               }).toList(),
  //               onChanged: (String? newValue) {
  //                 setState(() {
  //                   _selectedCategory = newValue!;
  //                   // If "Other" is selected, show the text box
  //                   _isCustomCategory = newValue == 'Other';
  //                 });
  //               },
  //             ),
              
  //             // Custom Category Text Field (Only shows if "Other" is selected)
  //             if (_isCustomCategory) ...[
  //               const SizedBox(height: 10),
  //               TextFormField(
  //                 controller: _customCategoryController,
  //                 decoration: const InputDecoration(
  //                   labelText: "Enter New Category Name", 
  //                   border: OutlineInputBorder(),
  //                   prefixIcon: Icon(Icons.edit)
  //                 ),
  //                 validator: (val) => _isCustomCategory && val!.isEmpty ? "Enter category" : null,
  //               ),
  //             ],

  //             const SizedBox(height: 15),
              
  //             // Price
  //             TextFormField(
  //               controller: _priceController,
  //               keyboardType: TextInputType.number,
  //               decoration: const InputDecoration(labelText: "Price (₹)", border: OutlineInputBorder()),
  //               validator: (val) => val!.isEmpty ? "Enter price" : null,
  //             ),
  //             const SizedBox(height: 15),
              
  //             // Description
  //             TextFormField(
  //               controller: _descController,
  //               maxLines: 3,
  //               decoration: const InputDecoration(labelText: "Description", border: OutlineInputBorder()),
  //               validator: (val) => val!.isEmpty ? "Enter description" : null,
  //             ),
  //             const SizedBox(height: 25),
              
  //             // Button
  //             _isLoading 
  //               ? const CircularProgressIndicator()
  //               : ElevatedButton(
  //                   onPressed: _uploadItem,
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: Colors.blueAccent,
  //                     foregroundColor: Colors.white,
  //                     minimumSize: const Size(double.infinity, 50),
  //                   ),
  //                   child: const Text("Add to Menu"),
  //                 ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: Text("Add New Item", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                    image: _selectedImage != null ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover) : null,
                  ),
                  child: _selectedImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.cloud_upload_outlined, size: 50, color: Colors.orange),
                            const SizedBox(height: 10),
                            Text("Tap to upload Image", style: GoogleFonts.poppins(color: Colors.grey)),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 25),
              _buildInput(_nameController, "Food Name", Icons.fastfood),
              const SizedBox(height: 15),
              // Category Dropdown styled
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey[200]!)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedCategory,
                    items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: GoogleFonts.poppins()))).toList(),
                    onChanged: (val) => setState(() { _selectedCategory = val!; _isCustomCategory = val == 'Other'; }),
                  ),
                ),
              ),
              if (_isCustomCategory) ...[
                const SizedBox(height: 15),
                _buildInput(_customCategoryController, "New Category Name", Icons.category),
              ],
              const SizedBox(height: 15),
              _buildInput(_priceController, "Price (₹)", Icons.currency_rupee, isNumber: true),
              const SizedBox(height: 15),
              _buildInput(_descController, "Description", Icons.description, maxLines: 3),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _uploadItem,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text("Add to Menu", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label, IconData icon, {bool isNumber = false, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey[200]!)),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.grey),
          prefixIcon: Icon(icon, color: Colors.orange),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(15),
        ),
        validator: (val) => val!.isEmpty ? "Required" : null,
      ),
    );
  }
}