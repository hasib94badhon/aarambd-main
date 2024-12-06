import 'dart:convert';
import 'dart:developer';
import 'package:aaram_bd/config.dart';
import 'package:aaram_bd/pages/Homepage.dart';
import 'package:aaram_bd/pages/ServiceCart.dart';
import 'package:aaram_bd/pages/ShopsCart.dart';
import 'package:aaram_bd/screens/navigation_screen.dart';
import 'package:aaram_bd/screens/service_homepage.dart';
import 'package:aaram_bd/screens/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:aaram_bd/pages/cartPage.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:aaram_bd/screens/advert_screen.dart';
import 'package:http/http.dart' as http;

// Data model for category counts
class UserDetail {
  final String address;
  final String business_name;
  final String category;
  final String? phone;
  final String images;
  final int shop_id;
  final int service_id;
  final bool is_service;
  final String extra;

  UserDetail(
      {required this.address,
      required this.business_name,
      required this.category,
      required this.phone,
      required this.images,
      required this.shop_id,
      required this.is_service,
      required this.service_id,
      required this.extra});

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    String extra = '';

    // Add location if present
    if (json['location'] != null && json['location'].isNotEmpty) {
      extra += 'Location: ${json['location']} ';
    }

    // Add view if present
    if (json['user_viewed'] != null && json['user_viewed'] != 0) {
      extra += 'Total View: ${json['user_viewed']} ';
    }

    // Add call if present
    if (json['user_called'] != null && json['user_called'] != 0) {
      extra += 'Total Call: ${json['user_called']} ';
    }

    String day = json['days_since_creation'];
    // Add days_since_creation if present
    if (json['days_since_creation'] != "" && json['days_since_creation'] != 0) {
      if (day == "0") {
        extra += 'Active Today';
      } else if (day == "1") {
        extra += 'Active 1 day Ago';
      } else {
        extra += 'Active ${json['days_since_creation']} days ago';
      }
    }
    return UserDetail(
        address:
            json['location'] ?? "No Address", // Provide default value if null
        category:
            json['cat_name'] ?? "No Category", // Provide default value if null
        business_name:
            json['name'] ?? "No Name", // Provide default value if null
        phone: json['phone'] as String?, // Cast as nullable int
        images: json['photo'], // Provide default value if null
        shop_id: json['shop_id'],
        service_id: json['service_id'] ?? 0,
        is_service: false, // Assuming service_id will always be provided
        extra: extra.trim());
  }
}

class ShopsFavorite extends StatefulWidget {
  final String cat_id;
  final String categoryName;

  ShopsFavorite({required this.cat_id, required this.categoryName});
  @override
  _ShopsFavoriteState createState() => _ShopsFavoriteState();
}

class _ShopsFavoriteState extends State<ShopsFavorite> {
  late Future<List<UserDetail>> data;
  List<String> images = [];
  String sortBy = "";
  String userLocation = '23.8103,90.4125'; // example location (Dhaka)

  @override
  void initState() {
    super.initState();
    data = fetchUserDetails(widget.cat_id, sortBy);
  }

  Future<List<UserDetail>> fetchUserDetails(String cat_id, sortBy) async {
    final url =
        '$host/get_shop_data_by_category?cat_id=$cat_id&sort_by=$sortBy&user_location=$userLocation';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final userDetails = jsonResponse['shop_information'] != null
            ? (jsonResponse['shop_information'] as List)
                .map((data) => UserDetail.fromJson(data))
                .toList()
            : <UserDetail>[];

        return userDetails;
      } else {
        throw Exception('Failed to load data from API');
      }
    } catch (e) {
      throw Exception("An unexpected error occurred: ${e.toString()}");
    }
  }

  void _sortData(criteria) {
    setState(() {
      sortBy = criteria;
      data = fetchUserDetails(widget.cat_id, sortBy);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[100],
        elevation: 5,
        centerTitle: true,

        // Leading: Custom arrow back button with floating effect
        leading: Container(
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 1), // White border
            boxShadow: [
              BoxShadow(
                color: Colors.white,
                blurRadius: 0, // Soft shadow with no offset
                spreadRadius: 0,
              ),
            ],
          ),
          child: IconButton(
            iconSize: 30,
            color: Colors.black,
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () {
              Navigator.pop(context);
            },
            splashColor: Colors.white.withOpacity(0.3),
          ),
        ),

        // Title: Floating text with container and decoration
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white38, Colors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
            borderRadius: BorderRadius.circular(25),
          ),
          child: AnimatedDefaultTextStyle(
            duration: Duration(milliseconds: 500),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            child: Text('${widget.categoryName}'),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white38, Colors.blue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(45),
                bottomRight: Radius.circular(45),
              ),
            ),
            padding: EdgeInsets.all(2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: sortBy == 'nearby' ? Colors.green : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        _sortData('nearby');
                      },
                      icon: Icon(
                        Icons.location_on,
                        color: Colors.black,
                        size: 35,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: sortBy == 'recent' ? Colors.green : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        _sortData('recent');
                      },
                      icon: Icon(
                        Icons.access_time,
                        color: Colors.black,
                        size: 30,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color:
                          sortBy == 'most_viewed' ? Colors.green : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        _sortData('most_viewed');
                      },
                      icon: Icon(
                        Icons.visibility,
                        color: Colors.black,
                        size: 30,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color:
                          sortBy == 'most_called' ? Colors.green : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        _sortData('most_called');
                      },
                      icon: Icon(
                        Icons.phone,
                        color: Colors.black,
                        size: 30,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<UserDetail>>(
              future: data,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (snapshot.hasData) {
                    final users = snapshot.data!;
                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return Center(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AdvertScreen(
                                          userId: user.shop_id.toString(),
                                          isService: user.is_service,
                                          advertData: AdvertData(
                                            userId: user.shop_id.toString(),
                                            isService: user.is_service,
                                            additionalData: user.is_service
                                                ? {
                                                    'service_id':
                                                        user.service_id,
                                                  } // Replace with actual service details
                                                : {
                                                    'shop_id': user.shop_id,
                                                  },
                                          ),
                                        )),
                              );
                            },
                            child: Container(
  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 6), // More balanced margin
  padding: EdgeInsets.all(8), // Increased padding for better space utilization
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.blue[200]!, Colors.white], // Softer gradient for better depth
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    border: Border.all(
      width: 1.5,
      color: Color.fromARGB(255, 133, 199, 136),
    ),
    borderRadius: BorderRadius.circular(60), // Slightly rounded corners for a softer look
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.4), // Softer shadow for elegance
        spreadRadius: 4,
        blurRadius: 8,
        offset: Offset(0, 4), // Slightly lifted effect
      ),
    ],
  ),
  child: Row(
    children: [
      // Image Container
      Container(
        width: 130,
        height: 130,
        margin: EdgeInsets.only(right: 10),
        padding: EdgeInsets.all(3), // Slight padding adjustment
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(55), // Circular shape for image
          border: Border.all(
            width: 2.5,
            color: Colors.blueAccent, // Brighter border for image
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 3,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(55), // Same radius to clip image
          child: FittedBox(
            fit: BoxFit.cover,
            child: Image.network(user.images), // Ensure image covers entire space
          ),
        ),
      ),
      // Business details section
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Business Name
            Text(
              user.business_name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18, // Slightly larger font for emphasis
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 2),
            // Phone Number with Icon
            Row(
              children: [
                Icon(Icons.phone, color: Colors.green, size: 16), // Phone icon
                SizedBox(width: 8),
                Text(
                  user.phone.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2),
            // RichText for dynamic content ("Total", "Active")
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.black,
                ),
                children: [
                  // Text before "Total"
                  TextSpan(
                    text: user.extra.split("Total")[0],
                    style: TextStyle(color: Colors.black87),
                  ),
                  // "Total" with new line and blue color
                  if (user.extra.contains("Total"))
                    TextSpan(
                      text: '\nTotal',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  // Text between "Total" and "Active"
                  if (user.extra.contains("Total") &&
                      user.extra.contains("Active"))
                    TextSpan(
                      text: user.extra.split("Total")[1].split("Active")[0],
                      style: TextStyle(color: Colors.black87),
                    ),
                  // "Active" with new line and red color
                  if (user.extra.contains("Active"))
                    TextSpan(
                      text: '\nActive',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  // Text after "Active"
                  if (user.extra.contains("Active"))
                    TextSpan(
                      text: user.extra.split("Active")[1],
                      style: TextStyle(color: Colors.black87),
                    ),
                ],
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ],
  ),
)

                          ),
                        );
                      },
                    );
                  }
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Modified fetchData function to return both categories and user details

// ignore: must_be_immutable

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ShopsFavorite(
      categoryName: "Auto painting",
      cat_id: "auto",
    ),
  ));
}
