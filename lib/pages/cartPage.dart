import 'dart:async';
import 'package:aaram_bd/config.dart';
import 'dart:convert';
import 'dart:io';
import 'package:aaram_bd/screens/advert_screen.dart';
import 'package:aaram_bd/screens/favorite_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:aaram_bd/screens/Search_Category.dart';
// Import FavoriteScreen

// Data model for category counts
class CategoryCount {
  final int categoryCount;
  final String categoryName;
  final String cat_id;
  final photo;

  CategoryCount({
    required this.categoryCount,
    required this.categoryName,
    required this.cat_id,
    required this.photo,
  });

  factory CategoryCount.fromJson(Map<String, dynamic> json) {
    return CategoryCount(
      categoryCount: json['count'],
      categoryName: json['cat_name'],
      cat_id: json['cat_id'],
      photo: json['cat_logo'],
    );
  }
}

// Data model for user details
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

  UserDetail({
    required this.address,
    required this.business_name,
    required this.category,
    required this.photo,
    required this.phone,
    required this.userId,
    required this.shop_id,
    required this.service_id,
    required this.isservice,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    int serviceId = json['service_id'] ?? 0;
    int shopId = json['shop_id'] ?? 0;
    return UserDetail(
      address: json['location'] ?? '',
      category: json['cat_name'] ?? '',
      business_name: json['name'] ?? '',
      photo: json['photo'],
      phone: json['phone'] ?? 0,
      userId: serviceId != 0 ? serviceId : shopId,
      service_id: serviceId,
      shop_id: shopId,
      isservice: serviceId != 0,
    );
  }
}

class CartPage extends StatefulWidget {
  final String userPhone;
  final Key? key;
  final dynamic data; // Add this parameter to accept the data

  CartPage({required this.userPhone, this.data, this.key});

  @override
  _CartPageState createState() => _CartPageState(userPhone: userPhone);
}

class _CartPageState extends State<CartPage> {
  final String userPhone;
  List<String> categories = [];
  List<String> filteredCategories = [];
  final TextEditingController searchController = TextEditingController();
  late SearchController searchBarController;

  _CartPageState({required this.userPhone});
  late Future<Map<String, List<dynamic>>> data;

  @override
  void initState() {
    super.initState();
    data = fetchData();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final response = await http.get(
      Uri.parse("$host/get_categories_name"),
    );

    if (response.statusCode == 200) {
      final category_data = json.decode(response.body);
      setState(() {
        categories = List<String>.from(category_data['categories']);
        filteredCategories = categories;
      });
    } else {
      print("Failed to fetch categories: ${response.statusCode}");
    }
  }

  void updateCategoryUsage(String catId) async {
    final response = await http.post(
      Uri.parse('$host/update_cat_used'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'cat_id': catId}),
    );

    if (response.statusCode == 200) {
      print("Category usage updated successfully");
    } else {
      print("Failed to update category usage: ${response.body}");
    }
  }

  Future<Map<String, List<dynamic>>> fetchData() async {
    const url = "$host/get_combined_data";
    int retries = 3;
    for (int i = 0; i < retries; i++) {
      try {
        final response = await http
            .get(Uri.parse(url))
            .timeout(const Duration(seconds: 60)); // Increase timeout duration
        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);
          final categoryCounts = jsonResponse['category_count'] != null
              ? (jsonResponse['category_count'] as List)
                  .map((data) => CategoryCount.fromJson(data))
                  .toList()
              : <CategoryCount>[];
          final userDetails = jsonResponse['combined_information'] != null
              ? (jsonResponse['combined_information'] as List)
                  .map((data) => UserDetail.fromJson(data))
                  .toList()
              : <UserDetail>[];

          return {
            'categoryCounts': categoryCounts,
            'userDetails': userDetails,
          };
        } else {
          throw Exception('Failed to load data from API');
        }
      } on SocketException catch (e) {
        if (i == retries - 1) {
          throw Exception("Failed to connect to API: ${e.message}");
        }
      } on http.ClientException catch (e) {
        if (i == retries - 1) {
          throw Exception("Failed to connect to API: ${e.message}");
        }
      } catch (e) {
        if (i == retries - 1) {
          throw Exception("An unexpected error occurred: ${e.toString()}");
        }
      }
      await Future.delayed(Duration(seconds: 2)); // Delay before retrying
    }
    throw Exception("Failed to connect to API after $retries attempts");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, List<dynamic>>>(
        future: data,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (snapshot.hasData) {
              final categories =
                  snapshot.data!['categoryCounts'] as List<CategoryCount>;
              final users = snapshot.data!['userDetails'] as List<UserDetail>;

              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange[100]!, Colors.green[600]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: SearchCategory(
                        categoryType: '',
                      ), // Replace with your SearchCategory class
                    ),

                    Expanded(
                      flex: 2,
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 1,
                          crossAxisSpacing: 1,
                          childAspectRatio: 0.92,
                        ),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50)),
                            elevation: 10.0,
                            color: Colors.blue,
                            child: InkWell(
                              onTap: () {
                                updateCategoryUsage(category.cat_id.toString());
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FavoriteScreen(
                                      categoryName: category.categoryName,
                                      cat_id: category.cat_id.toString(),
                                    ),
                                  ),
                                );
                              },
                              child: Stack(children: [
                                Container(
                                  decoration: BoxDecoration(
                                      // border: Border.all(
                                      //     width: 2, color: Colors.lightGreen),
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(45),
                                      image: DecorationImage(
                                          image: NetworkImage(
                                            "https://aarambd.com/cat logo/${category.photo}",
                                          ),
                                          fit: BoxFit.cover)),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10))),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(65),
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                        child: Text(
                                          "${category.categoryCount}",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: Container(
                                          padding: EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            //border: Border.all(width: 1),
                                            borderRadius:
                                                BorderRadius.circular(35),
                                            color:
                                                Colors.white.withOpacity(0.8),
                                          ),
                                          child: Text(
                                            "${category.categoryName}",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                              ]),
                              
                            ),
                          );
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(child: Divider(color: Colors.white)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(Icons.star, color: Colors.white),
                        ),
                        Expanded(child: Divider(color: Colors.white)),
                      ],
                    ),

                    // Lower side

                    Expanded(
                      flex: 1,
                      child: ListView.builder(
                        shrinkWrap: true,
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
                                margin: EdgeInsets.only(
                                    left: 3, top: 4, bottom: 4, right: 3),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 3,
                                      blurRadius: 4,
                                      offset: Offset(
                                          0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Card(
                                  color: Colors.blueGrey,
                                  margin: EdgeInsets.only(
                                      left: 5, top: 4, bottom: 4, right: 5),
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(5),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(35),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 120,
                                                height: 120,
                                                padding: EdgeInsets.all(3),
                                                margin:
                                                    EdgeInsets.only(right: 4),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    width: 1,
                                                    color: Colors.lightGreen,
                                                  ),
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(60),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(60),
                                                  child: Image.network(
                                                    user.photo,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  padding: EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey
                                                        .withOpacity(0.4),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25),
                                                  ),
                                                  margin: EdgeInsets.symmetric(
                                                      vertical: 6),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        user.business_name,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Poppins', // Use your preferred font family
                                                          fontWeight: FontWeight
                                                              .w700, // Use bold weight
                                                          fontSize:
                                                              20, // Increase the font size for prominence
                                                          letterSpacing:
                                                              1.2, // Adjust letter spacing for a cleaner look
                                                          foreground: Paint()
                                                            ..shader = LinearGradient(
                                                                colors: <Color>[
                                                                  Colors.red,
                                                                  Colors.black,
                                                                  Colors.red,
                                                                  Colors.black,
                                                                ]).createShader(
                                                                Rect.fromLTWH(
                                                                    0.0,
                                                                    0.0,
                                                                    200.0,
                                                                    70.0)), // Gradient text
                                                          shadows: [
                                                            Shadow(
                                                              offset: Offset(
                                                                  2.0, 2.0),
                                                              blurRadius: 4.0,
                                                              color: Colors
                                                                  .black26, // Subtle shadow for depth
                                                            ),
                                                            Shadow(
                                                              offset: Offset(
                                                                  -2.0, -2.0),
                                                              blurRadius: 4.0,
                                                              color: Colors.grey
                                                                  .withOpacity(
                                                                      0.3), // Slight outer glow
                                                            ),
                                                          ],
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                      ),
                                                      SizedBox(height: 6),
                                                      Row(
                                                        children: [
                                                          Icon(Icons.business,
                                                              size: 20,
                                                              color:
                                                                  Colors.white),
                                                          SizedBox(width: 5),
                                                          Text(
                                                            user.category,
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 6),
                                                      Row(
                                                        children: [
                                                          Icon(
                                                              Icons.location_on,
                                                              size: 20,
                                                              color:
                                                                  Colors.white),
                                                          SizedBox(width: 5),
                                                          Expanded(
                                                            child: Text(
                                                              user.address,
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 1,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
  margin: EdgeInsets.all(5),
  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.3),
    borderRadius: BorderRadius.circular(40),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.3),
        spreadRadius: 3,
        blurRadius: 7,
        offset: Offset(0, 5), // Slight shadow below the container
      ),
    ],
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      // Phone Row with Icon Border and Shadow
      Flexible(
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 6,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.phone,
                size: 24,
                color: Colors.green,
              ),
            ),
            SizedBox(width: 10),
            // Make the phone number scrollable
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  '${user.phone}', // Replace with dynamic user phone number
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis, // Prevent overflow
                ),
              ),
            ),
          ],
        ),
      ),

      // View and Share Icons and Digits in one row
      Row(
        children: [
          // View Icon with digit
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.remove_red_eye,
                  size: 24,
                  color: Colors.blue,
                ),
              ),
              SizedBox(width: 5),
              Text(
                '250', // Replace with dynamic value if necessary
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(width: 20),

          // Share Icon with digit
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.share,
                  size: 24,
                  color: Colors.blue,
                ),
              ),
              SizedBox(width: 5),
              Text(
                '150', // Replace with dynamic value if necessary
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  ),
)

                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              );
            }
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CartPage(
      userPhone: "",
    ),
  ));
}
