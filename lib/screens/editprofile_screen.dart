import 'package:aaram_bd/config.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  final String userName;
  final String userPhone;
  final String userCategory;
  final String userDescription;
  final String userAddress;

  EditProfileScreen({
    required this.userName,
    required this.userPhone,
    required this.userCategory,
    required this.userDescription,
    required this.userAddress,
  });

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  late GoogleMapController mapController;
  LatLng _currentPosition = LatLng(23.8103, 90.4125); // Default to Dhaka

  List<Map<String, dynamic>> _categories = [];
  String? _selectedCategory;
  bool _isLoading = true;
  List<XFile> _images = [];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.userName;
    _phoneController.text = widget.userPhone;
    _categoryController.text = widget.userCategory;
    _descriptionController.text = widget.userDescription;
    _addressController.text = widget.userAddress;
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final response = await http.get(Uri.parse('$host/get_categories_name'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> categoryList = data['categories'];
      setState(() {
        _categories = categoryList.cast<Map<String, dynamic>>();
        var selectedCategoryMap = _categories.firstWhere(
            (category) => category['cat_name'] == widget.userCategory,
            orElse: () => {});
        _selectedCategory = selectedCategoryMap.isNotEmpty
            ? selectedCategoryMap['cat_id'].toString()
            : null;
        _categoryController.text = _selectedCategory ?? '';
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load categories');
    }
  }

  Future<void> updateProfile() async {
    final url = '$host/update_user_profile';
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.fields['name'] = _nameController.text;
    request.fields['phone'] = _phoneController.text;
    request.fields['category'] = _categoryController.text;
    request.fields['description'] = _descriptionController.text;
    request.fields['location'] = _addressController.text;

    for (var image in _images) {
      request.files
          .add(await http.MultipartFile.fromPath('images', image.path));
    }

    var response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await http.Response.fromStream(response);
      final data = json.decode(responseData.body);
      if (data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context, true); // Indicate the profile was updated
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to update profile: ${data["message"]}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error updating profile: ${response.reasonPhrase}')),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _images = pickedFiles;
      });
    }
  }

  Widget _buildTextField(
      {required String label,
      required TextEditingController controller,
      TextInputType keyboardType = TextInputType.text,
      int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        filled: true,
        fillColor: Colors.grey[200],
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: Colors.grey[300]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: Colors.blue,
          ),
        ),
        hintText: label,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Name TextField
                _buildTextField(
                  label: 'Name',
                  controller: _nameController,
                ),
                SizedBox(height: 16),

                // Phone TextField
                _buildTextField(
                  label: 'Phone',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 16),

                // Radio Buttons
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.start,
                //   children: [
                //     Radio<String>(
                //       value: 'Service',
                //       groupValue: _selectedType,
                //       onChanged: (value) {
                //         setState(() {
                //           _selectedType = value!;
                //         });
                //       },
                //     ),
                //     Text('Service'),
                //     SizedBox(width: 16),
                //     Radio<String>(
                //       value: 'Shops',
                //       groupValue: _selectedType,
                //       onChanged: (value) {
                //         setState(() {
                //           _selectedType = value!;
                //         });
                //       },
                //     ),
                //     Text('Shops'),
                //   ],
                // ),
                SizedBox(height: 16),

                // Category Dropdown
                _isLoading
                    ? CircularProgressIndicator()
                    : DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        items: _categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category['cat_id'].toString(),
                            child: Text(category['cat_name']),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCategory = newValue;
                            _categoryController.text = newValue ?? '';
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Select Category',
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                SizedBox(height: 16),

                // Description TextField
                _buildTextField(
                  label: 'Description',
                  controller: _descriptionController,
                  maxLines: 3,
                ),
                SizedBox(height: 16),

                // Address TextField
                _buildTextField(
                  label: 'Address',
                  controller: _addressController,
                ),
                SizedBox(height: 16),

                // Upload Images Button
                ElevatedButton.icon(
                  onPressed: _pickImages,
                  icon: Icon(Icons.photo_library),
                  label: Text('Upload Images'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Google Map Container
                // Container(
                //   height: 200,
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(8.0),
                //     boxShadow: [
                //       BoxShadow(
                //         color: Colors.grey.withOpacity(0.5),
                //         spreadRadius: 2,
                //         blurRadius: 5,
                //         offset: Offset(0, 3),
                //       ),
                //     ],
                //   ),
                //   child: ClipRRect(
                //     borderRadius: BorderRadius.circular(8.0),
                //     child: GoogleMap(
                //       onMapCreated: _onMapCreated,
                //       initialCameraPosition: CameraPosition(
                //         target: _currentPosition,
                //         zoom: 14.0,
                //       ),
                //       markers: {
                //         Marker(
                //           markerId: MarkerId("current_location"),
                //           position: _currentPosition,
                //           draggable: true,
                //           onDragEnd: (newPosition) {
                //             setState(() {
                //               _currentPosition = newPosition;
                //               _addressController.text =
                //                   "${newPosition.latitude}, ${newPosition.longitude}";
                //             });
                //           },
                //         ),
                //       },
                //     ),
                //   ),
                // ),
                SizedBox(height: 20),

                // Update Profile Button
                ElevatedButton(
                  onPressed: updateProfile,
                  child: Text('Update Profile'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Display Selected Images
                _images.isNotEmpty
                    ? Column(
                        children: _images.map((image) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.file(
                                File(image.path),
                                height: 100,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        }).toList(),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
