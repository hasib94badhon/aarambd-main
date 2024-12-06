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
  final String photo;
  final String phone;
  final int shop_id;
  final int service_id;
  final int userId;
  final bool isservice;
  final String extra;

  UserDetail(
      {required this.address,
      required this.business_name,
      required this.category,
      required this.photo,
      required this.phone,
      required this.userId,
      required this.shop_id,
      required this.service_id,
      required this.isservice,
      required this.extra});

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    int serviceId = json['service_id'] ?? 0;
    int shopId = json['shop_id'] ?? 0;

    // Initialize the extra field with an empty string
    String extra = '';

    // Add location if present
    if (json['location'] != null && json['location'].isNotEmpty) {
      extra += 'Location: ${json['location']} ';
    }

    // Add view if present
    if (json['view'] != null && json['view'] != 0) {
      extra += 'Total View: ${json['view']} ';
    }

    // Add call if present
    if (json['call'] != null && json['call'] != 0) {
      extra += 'Total Call: ${json['call']} ';
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
      address: json['location'] ?? '',
      category: json['cat_id'] ?? '',
      business_name: json['name'] ?? '',
      photo: json['photo'] ?? '',
      phone: json['phone'] ?? 0,
      userId: serviceId != 0 ? serviceId : shopId,
      service_id: serviceId,
      shop_id: shopId,
      isservice: serviceId != 0,
      extra: extra.trim(), //ensure there no trailing spaces
    );
  }
}

class FavoriteScreen extends StatefulWidget {
  final String cat_id;
  final String categoryName;

  FavoriteScreen({required this.categoryName, required this.cat_id});

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  late Future<List<UserDetail>> serviceData;
  late Future<List<UserDetail>> shopData;
  String sortBy = '';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() {
    serviceData = fetchUserDetails(widget.cat_id, 'service', sortBy);
    shopData = fetchUserDetails(widget.cat_id, 'shop', sortBy);
  }

  Future<List<UserDetail>> fetchUserDetails(
      String cat_id, String dataType, String sortBy) async {
    final url =
        '$host/get_data_by_category?cat_id=$cat_id&data_type=$dataType&sort_by=$sortBy';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final userDetails = jsonResponse['${dataType}_information'] != null
            ? (jsonResponse['${dataType}_information'] as List)
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

  void updateSorting(String newSortBy) {
    setState(() {
      sortBy = newSortBy;
      fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[100],
        elevation: 5,
        centerTitle: true,

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
              colors: [Colors.white38, Colors.green[600]!],
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
                colors: [Colors.white38, Colors.green],
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
                        updateSorting('nearby');
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
                        updateSorting('recent');
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
                        updateSorting('most_viewed');
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
                        updateSorting('most_called');
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
          SizedBox(width: 10),
          Expanded(
            child: FutureBuilder<List<UserDetail>>(
              future: Future.wait([serviceData, shopData])
                  .then((results) => results.expand((x) => x).toList()),
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
                                          userId: user.userId.toString(),
                                          isService: user.isservice,
                                          advertData: AdvertData(
                                            userId: user.userId.toString(),
                                            isService: user.isservice,
                                            additionalData: user.isservice
                                                ? {
                                                    'service_id':
                                                        user.service_id,
                                                  }
                                                : {
                                                    'shop_id': user.shop_id,
                                                  },
                                          ),
                                        )),
                              );
                            },
                            child: Container(
  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 6), // More balanced margin
  padding: EdgeInsets.all(8), // Added padding for better structure
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.green[200]!, Colors.white], // A soft gradient for depth
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    border: Border.all(
      width: 1.5,
      color: Color.fromARGB(255, 133, 199, 136),
    ),
    borderRadius: BorderRadius.circular(60), // Slightly less rounded for a modern look
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.4),
        spreadRadius: 4,
        blurRadius: 8,
        offset: Offset(0, 4), // Subtle elevation
      ),
    ],
  ),
  child: Row(
    children: [
      // Profile Image Container
      Container(
        width: 130,
        height: 130,
        margin: EdgeInsets.only(right: 10), // Reduced margin for better spacing
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(60), // Circular shape for image
          border: Border.all(
            width: 2,
            color: Colors.greenAccent, // Green accent for image border
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.greenAccent.withOpacity(0.4),
              spreadRadius: 4,
              blurRadius: 10,
              offset: Offset(0, 3), // Subtle glow for the image container
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(60), // Clip the image inside the circle
          child: FittedBox(
            fit: BoxFit.cover,
            child: Image.network(
              user.photo, // User's photo
            ),
          ),
        ),
      ),
      // Details Section
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Centering content vertically
          children: [
            // Business Name
            Text(
              user.business_name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18, // Slightly larger font for prominence
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 4),
            // Address with Icon
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.red, size: 16), // Location icon
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    user.phone,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black54, // Softer color for address
                    ),
                  ),
                ),
              ],
            ),
            // RichText for dynamic content (Total, Active)
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.black87,
                ),
                children: [
                  // Text before "Total"
                  TextSpan(
                    text: user.extra.split("Total")[0],
                  ),
                  if (user.extra.contains("Total"))
                    TextSpan(
                      text: '\nTotal',
                      style: TextStyle(
                        color: Colors.blue, // Highlight "Total" in blue
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (user.extra.contains("Total") &&
                      user.extra.contains("Active"))
                    TextSpan(
                      text: user.extra.split("Total")[1].split("Active")[0],
                    ),
                  if (user.extra.contains("Active"))
                    TextSpan(
                      text: '\nActive',
                      style: TextStyle(
                        color: Colors.redAccent, // Highlight "Active" in red
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (user.extra.contains("Active"))
                    TextSpan(
                      text: user.extra.split("Active")[1],
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

// void main() {
//   runApp(MaterialApp(
//     debugShowCheckedModeBanner: false,
//     home: FavoriteScreen(
//       categoryName: "Auto painting",
//     ),
//   ));
// }
