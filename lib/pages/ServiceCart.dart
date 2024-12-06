import 'dart:async';
import 'dart:convert';
import "package:aaram_bd/config.dart";
import 'package:aaram_bd/pages/Homepage.dart';
import 'package:aaram_bd/screens/Search_Category.dart';
import 'package:aaram_bd/screens/Service_favorite_screen.dart';
import 'package:aaram_bd/screens/advert_screen.dart';
import 'package:aaram_bd/screens/favorite_screen.dart';
import 'package:aaram_bd/screens/service_homepage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Data model for category counts
class CategoryCount {
  final int categoryCount;
  final String categoryName;
  final String cat_id;
  final photo;

  CategoryCount(
      {required this.categoryCount,
      required this.categoryName,
      required this.cat_id,
      required this.photo});

  factory CategoryCount.fromJson(Map<String, dynamic> json) {
    return CategoryCount(
        categoryCount: json['count'],
        cat_id: json['cat_id'],
        categoryName: json['name'],
        photo: json['photo']);
  }
}

// Data model for user details
class UserDetail {
  final String address;
  final String business_name;
  final String category;
  final String phone;
  final String photo;
  final int service_id;
  final int shop_id;
  final bool isService;

  UserDetail({
    required this.address,
    required this.business_name,
    required this.category,
    required this.phone,
    required this.photo,
    required this.service_id,
    required this.shop_id,
    required this.isService,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    return UserDetail(
      category: json['cat_name'],
      address: json['location'],
      business_name: json['name'],
      phone: json['phone'],
      service_id: json['service_id'],
      shop_id: json['service_id'] ?? 0,
      photo: json['photo'],
      isService: true,
    );
  }
}

// Modified fetchData function to return both categories and user details
Future<Map<String, List<dynamic>>> fetchData() async {
  final url = '$host/get_service_data';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    final categoryCounts = (jsonResponse['category_count'] as List)
        .map((data) => CategoryCount.fromJson(data))
        .toList();
    final userDetails = (jsonResponse['service_information'] as List)
        .map((data) => UserDetail.fromJson(data))
        .toList();

    return {
      'categoryCounts': categoryCounts,
      'userDetails': userDetails,
    };
  } else {
    throw Exception('Failed to load data from API');
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

class ServiceCart extends StatelessWidget {
  final Future<Map<String, List<dynamic>>> data;
  final dynamic dataa;

  ServiceCart({Key? key, this.dataa})
      : data = fetchData(),
        super(key: key);

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
                    colors: [Colors.orange[100]!, Colors.yellow[100]!],
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
                        categoryType: 'service',
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
                                borderRadius: BorderRadius.circular(45)),
                            elevation: 10.0,
                            //margin: EdgeInsets.all(5),
                            color: Colors.white,
                            child: InkWell(
                              onTap: () {
                                updateCategoryUsage(category.cat_id.toString());
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ServiceFavorite(
                                      cat_id: category.cat_id,
                                      category_name: category.categoryName,
                                    ),
                                  ),
                                );
                              },
                              child: Stack(children: [
                                Center(
                                  child: Container(
                                    height: 200,
                                    width: 200,
                                    decoration: BoxDecoration(
                                        // border: Border.all(
                                        //     width: 2, color: Colors.lightGreen),
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(45),
                                        image: DecorationImage(
                                            image: NetworkImage(category.photo),
                                            fit: BoxFit.cover)),
                                  ),
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
                                          color: Colors.white.withOpacity(0.6),
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
                                                Colors.white.withOpacity(0.6),
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
                                )
                              ]),
                            ),
                          );
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(child: Divider(color: Colors.green)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(Icons.star, color: Colors.green),
                        ),
                        Expanded(child: Divider(color: Colors.green)),
                      ],
                    ),
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
                                            userId: user.service_id.toString(),
                                            isService: user.isService,
                                            advertData: AdvertData(
                                              userId:
                                                  user.service_id.toString(),
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
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 15),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.3),
                                            borderRadius:
                                                BorderRadius.circular(40),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.3),
                                                spreadRadius: 3,
                                                blurRadius: 7,
                                                offset: Offset(0,
                                                    5), // Slight shadow below the container
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              // Phone Row with Icon Border and Shadow
                                              Flexible(
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.white,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.2),
                                                            spreadRadius: 2,
                                                            blurRadius: 6,
                                                            offset:
                                                                Offset(0, 4),
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
                                                      child:
                                                          SingleChildScrollView(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        child: Text(
                                                          '${user.phone}', // Replace with dynamic user phone number
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.black87,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis, // Prevent overflow
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
                                                        padding:
                                                            EdgeInsets.all(8),
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Colors.white,
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.2),
                                                              spreadRadius: 2,
                                                              blurRadius: 6,
                                                              offset:
                                                                  Offset(0, 4),
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
                                                          fontWeight:
                                                              FontWeight.bold,
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
                                                        padding:
                                                            EdgeInsets.all(8),
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Colors.white,
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.2),
                                                              spreadRadius: 2,
                                                              blurRadius: 6,
                                                              offset:
                                                                  Offset(0, 4),
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
                                                          fontWeight:
                                                              FontWeight.bold,
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
    home: ServiceCart(),
  ));
}
