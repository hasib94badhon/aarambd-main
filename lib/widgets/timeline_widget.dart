import 'package:aaram_bd/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:aaram_bd/screens/advert_screen.dart';

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
      category: json['cat_name'] ?? '',
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

class TimelineWidget extends StatefulWidget {
  final int cat_id;
  final String dataType; // Add dataType parameter

  const TimelineWidget({
    Key? key,
    required this.cat_id,
    required this.dataType, // Accept dataType in constructor
  }) : super(key: key);

  @override
  State<TimelineWidget> createState() => _TimelineWidgetState();
}

class _TimelineWidgetState extends State<TimelineWidget> {
  late Future<List<UserDetail>> serviceData;
  late Future<List<UserDetail>> shopData;
  String sortBy = '';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() {
    serviceData = fetchPosts(widget.cat_id.toString(), 'service', sortBy);
    shopData = fetchPosts(widget.cat_id.toString(), 'shop', sortBy);
  }

  Future<List<UserDetail>> fetchPosts(
      String cat_id, String dataType, String sortBy) async {
    String info = '';
    final String url =
        '$host/get_data_by_category?data_type=${widget.dataType}&cat_id=${widget.cat_id}&sort_by=$sortBy';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (widget.dataType == 'service') {
          info = 'service_information';
        } else {
          info = 'shop_information';
        }
        final userDetails = jsonResponse[info] != null
            ? (jsonResponse[info] as List)
                .map((data) => UserDetail.fromJson(data))
                .toList()
            : <UserDetail>[];
        return userDetails;
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserDetail>>(
      future: Future.wait([serviceData, shopData])
          .then((results) => results.expand((x) => x).toList()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final posts = snapshot.data!;
            return Container(
  height: 220, // Increased height for more space
  child: ListView.builder(
    itemCount: posts.length,
    scrollDirection: Axis.horizontal,
    itemBuilder: (context, index) {
      var post = posts[index];

      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdvertScreen(
                userId: post.userId.toString(),
                isService: post.isservice,
                advertData: AdvertData(
                  userId: post.userId.toString(),
                  isService: post.isservice,
                  additionalData: post.isservice
                      ? {'service_id': post.service_id}
                      : {'shop_id': post.shop_id},
                ),
              ),
            ),
          );
        },
        child: Container(
          width: 250, // Slightly increased width for better spacing
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color.fromARGB(255, 52, 170, 150), const Color.fromARGB(255, 149, 255, 128)!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.6),
                spreadRadius: 3,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            borderRadius: BorderRadius.circular(30), // Softer edges
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Enlarged image with border and shadow
              Container(
                margin: const EdgeInsets.only(top: 15),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 10,
                      spreadRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    post.photo,
                    width: 120,
                    height: 120, // Bigger image size
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Business name text with overflow protection
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  post.business_name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white, // White text for contrast
                    shadows: [
                      Shadow(
                        color: Colors.black38,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  maxLines: 1, // Limit to one line
                  overflow: TextOverflow.ellipsis, // Avoid overflow
                ),
              ),
              const SizedBox(height: 2),

              // Category text with new style
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  post.category,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black, // Soft contrast color
                    //fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  maxLines: 1, // Limit to one line
                  overflow: TextOverflow.ellipsis, // Avoid overflow
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      );
    },
  ),
);

          } else {
            return Center(child: Text("No posts available"));
          }
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
