import 'dart:convert';
import 'dart:io';
import 'package:aaram_bd/config.dart'; // Replace with your actual config
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class PostUpload extends StatefulWidget {
  final String postName;
  final String postPhone;
  final String postCategory;
  final String postDescription;

  PostUpload({
    required this.postName,
    required this.postPhone,
    required this.postCategory,
    required this.postDescription,
  });

  @override
  _PostUploadState createState() => _PostUploadState();
}

class _PostUploadState extends State<PostUpload> {
  final _descriptionController = TextEditingController();
  XFile? _selectedMedia; // To store the selected media (image or video)

  @override
  void initState() {
    super.initState();
    _descriptionController.text = widget.postDescription;
  }

  // Pick media (either from gallery or camera)
  Future<void> _pickMedia() async {
    final ImagePicker picker = ImagePicker();
    final XFile? media = await picker.pickImage(
        source: ImageSource.gallery); // You can also allow camera
    if (media != null) {
      setState(() {
        _selectedMedia = media;
      });
    }
  }

  // Submit post to the backend API
  Future<void> submitPost(String description, XFile? media) async {
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post description cannot be empty')),
      );
      return;
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$host/submit_post'), // Replace with your actual API endpoint
    );

    request.fields['phone'] = widget.postPhone;
    request.fields['post_description'] = description;

    // If media is selected, attach it to the request
    if (media != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'post_media',
          await media.readAsBytes(),
          filename: media.name,
        ),
      );
    }

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post submitted successfully')),
        );
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        final errorData = json.decode(responseBody);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${errorData['error']}')),
        );
      }
    } catch (e) {
      print("Error submitting post: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit post')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Post'),
        backgroundColor: Colors.blueAccent, // Optional: Change AppBar color
      ),
      body: Center(
        // Wrap Column with Center widget
        child: Container(
          //margin: EdgeInsets.all(3),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[100]!, Colors.blue[100]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3), // Shadow position
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Centers content vertically
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Centers content horizontally
              children: [
                // Text field for post description
                Container(
                  height: 250,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white70, Colors.white70],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3), // Shadow position
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Post Description : ',
                      labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 26,
                      ),
                      border: InputBorder.none,
                    ),
                    maxLines: 3,
                    style: TextStyle(
                        color: Colors.black, fontSize: 18), // White text
                  ),
                ),
                SizedBox(height: 24),

                // Button to pick media
                ElevatedButton(
                  onPressed: _pickMedia,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                    backgroundColor:
                        Colors.yellowAccent, // Button background color
                    foregroundColor: Colors.white, // Text color
                  ),
                  child: Text(
                    _selectedMedia != null
                        ? 'Change Media'
                        : 'Pick Media (Optional)',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
                SizedBox(height: 24),

                // Preview selected media (image)
                if (_selectedMedia != null) ...[
                  Text(
                    'Selected Media: ${_selectedMedia!.name}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(_selectedMedia!.path),
                        height: 160,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],

                SizedBox(height: 24),

                // Submit button
                ElevatedButton(
                  onPressed: () async {
                    final description = _descriptionController.text;
                    await submitPost(description, _selectedMedia);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 6,
                    backgroundColor:
                        Colors.deepOrangeAccent, // Gradient effect on button
                    foregroundColor: Colors.white, // Text color
                  ),
                  child: Text(
                    'Submit Post',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
