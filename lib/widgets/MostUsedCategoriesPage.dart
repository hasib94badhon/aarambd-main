import 'package:flutter/material.dart';
import 'package:aaram_bd/screens/favorite_screen.dart';
import 'package:aaram_bd/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';

class MostUsedCategoriesPage extends StatelessWidget {
  final List<dynamic> categories;

  void updateCategoryUsage(String catId) async {
    final response = await http.post(
      Uri.parse('$host/update_cat_used'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'cat_id': catId}),
    );
  }

  MostUsedCategoriesPage({required this.categories});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Use'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1, // Number of items per row
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 8.0,
            childAspectRatio: 3 / 2, // Adjust aspect ratio as needed
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: InkWell(
                onTap: () {
                  updateCategoryUsage(category['cat_id'].toString());
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FavoriteScreen(
                        categoryName: category['cat_name'],
                        cat_id: category['cat_id'].toString(),
                      ),
                    ),
                  );
                },
                child: Stack(
                  children: [
                    // Category Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.network(
                        'https://aarambd.com/cat logo/${category['cat_logo']}',
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Category Name and Views
                    Positioned(
                      bottom: 8.0,
                      left: 8.0,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(15)),
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category['cat_name'],
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 24.0,
                              ),
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              'Seen: ${category['cat_used']}',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
