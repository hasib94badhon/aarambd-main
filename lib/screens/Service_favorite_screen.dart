import 'dart:convert';
import 'package:aaram_bd/config.dart';
import 'package:aaram_bd/pages/ServiceCart.dart';
import 'package:aaram_bd/pages/cartPage.dart';
import 'package:aaram_bd/screens/advert_screen.dart';
import 'package:aaram_bd/screens/service_homepage.dart';
import 'package:aaram_bd/screens/navigation_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserDetail {
  final String address;
  final String business_name;
  final String category;
  final String? phone;
  final String photo;
  final bool isService;
  // final String photo;
  final int service_id;
  final int shop_id;
  final String extra;

  UserDetail({
    required this.address,
    required this.business_name,
    required this.category,
    required this.phone,
    required this.photo,
    required this.service_id,
    required this.isService,
    required this.shop_id,
    required this.extra,
  });
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
      business_name: json['name'] ?? "No Name",
      photo: json['photo'],
      // Provide default value if null
      phone: json['phone']
          as String?, // Cast as nullable int // Provide default value if null
      service_id: json['service_id'],
      shop_id: json['shop_id'] ?? 0,
      isService: true, // Assuming service_id will always be provided
      extra: extra.trim(),
    );
  }
}

class ServiceFavorite extends StatefulWidget {
  final String cat_id;
  final String category_name;

  ServiceFavorite({required this.cat_id, required this.category_name});

  @override
  _ServiceFavoriteState createState() => _ServiceFavoriteState();
}

class _ServiceFavoriteState extends State<ServiceFavorite> {
  late Future<List<UserDetail>> data;
  String sortBy = "";
  String userLocation = '23.8103,90.4125'; // example location (Dhaka)

  @override
  void initState() {
    super.initState();
    data = fetchUserDetails(widget.cat_id, sortBy);
  }

  Future<List<UserDetail>> fetchUserDetails(String cat_id, sortBy) async {
    final url =
        '$host/get_service_data_by_category?cat_id=$cat_id&sort_by=$sortBy&user_location=$userLocation';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final userDetails = jsonResponse['service_information'] != null
            ? (jsonResponse['service_information'] as List)
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

  void _sortData(String criteria) {
    setState(() {
      sortBy = criteria;
      data = fetchUserDetails(widget.cat_id, sortBy);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[100],
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
              colors: [Colors.white, Colors.yellow],
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
            child: Text('${widget.category_name}'),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white30, Colors.yellow],
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

                        final String pp = user.photo;

                        return Center(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AdvertScreen(
                                          userId: user.service_id.toString(),
                                          isService: user.isService,
                                          advertData: AdvertData(
                                            userId: user.service_id.toString(),
                                            isService: user.isService,
                                            additionalData: user.isService
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
  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 6), // Adjusted for better spacing
  padding: EdgeInsets.all(8), // Increased padding for a balanced look
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.yellow[200]!, Colors.white], // Brighter gradient for more depth
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    border: Border.all(
      width: 1.5,
      color: Color.fromARGB(255, 133, 199, 136),
    ),
    borderRadius: BorderRadius.circular(60), // Softer, rounded corners
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.2), // Softer shadow for a more elegant effect
        spreadRadius: 4,
        blurRadius: 12,
        offset: Offset(0, 6), // Slight lift for more realism
      ),
    ],
  ),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.center, // Center-align content
    children: [
      // Image container
      Container(
        width: 130,
        height: 130,
        margin: EdgeInsets.only(right: 10),
        padding: EdgeInsets.all(6), // Adjusted padding
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(60), // Circular shape for the image
          border: Border.all(
            width: 2.5,
            color: Colors.orangeAccent, // Brighter border for image
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.orangeAccent.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 3,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(60),
          child: FittedBox(
            fit: BoxFit.cover,
            child: Image.network(user.photo), // Ensure image fits well
          ),
        ),
      ),
      // Text content
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Business name
            Text(
              user.business_name,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18, // Slightly larger for emphasis
                color: Colors.black87,
                letterSpacing: 0.5, // Improved spacing
              ),
            ),
            // Phone number with icon
            Row(
              children: [
                Icon(Icons.phone, color: Colors.green, size: 18), // Phone icon
                SizedBox(width: 8),
                Text(
                  user.phone.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            // RichText for dynamic content (Total, Active)
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87,
                ),
                children: [
                  // Text before "Total"
                  TextSpan(
                    text: user.extra.split("Total")[0],
                    style: TextStyle(color: Colors.black87),
                  ),
                  // "Total" with new line and different color
                  if (user.extra.contains("Total"))
                    TextSpan(
                      text: '\nTotal',
                      style: TextStyle(
                        color: Colors.blueAccent,
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
                  // "Active" with new line and different color
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

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ServiceFavorite(cat_id: "hello", category_name: "mello"),
  ));
}
