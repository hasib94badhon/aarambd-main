import 'package:aaram_bd/pages/cartPage.dart';
import 'package:aaram_bd/config.dart';
import 'package:aaram_bd/pages/test.dart';
import 'package:aaram_bd/screens/navigation_screen.dart';
import 'package:aaram_bd/screens/post_details.dart';
import 'package:aaram_bd/screens/user_profile.dart';
import 'package:aaram_bd/widgets/ExpendableText.dart';
import 'package:fan_carousel_image_slider/fan_carousel_image_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:aaram_bd/widgets/timeline_widget.dart'; // Ensure this import is correct
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserDetail {
  final String address;
  final String businessName;
  final String category;
  final String description;
  final String phone;
  final String photo;
  final int serviceId;
  final int shopId;
  final int user_called;
  final int user_shared;
  final int user_viewed;
  final int user_id;
  final List<PostDetail> posts;
  final int cat_id;
  final bool is_service;
  final int service_or_shop_id;

  UserDetail(
      {required this.address,
      required this.businessName,
      required this.category,
      required this.description,
      required this.phone,
      required this.photo,
      required this.serviceId,
      required this.shopId,
      required this.user_called,
      required this.user_shared,
      required this.user_viewed,
      required this.user_id,
      required this.cat_id,
      required this.posts,
      required this.is_service,
      required this.service_or_shop_id});

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    int serviceId = json['service_id'] ?? 0;
    int shopId = json['shop_id'] ?? 0;
    return UserDetail(
      cat_id: json['cat_id'],
      address: json['location'] ?? '',
      category: json['cat_name'] ?? '',
      description: json['description'] ?? '',
      businessName: json['name'] ?? '',
      phone: json['phone'] ?? 0,
      photo: json['photo'] ?? '',
      serviceId: json['service_id'] ?? 0,
      shopId: json['shop_id'] ?? 0,
      service_or_shop_id: serviceId != 0 ? serviceId : shopId,
      is_service: serviceId != 0,
      user_called: json['user_called'] ?? 0,
      user_shared: json['user_shared'] ?? 0,
      user_viewed: json['user_viewed'] ?? 0,
      user_id: json['user_id'],
      posts: (json['posts'] as List)
          .map((posttJson) => PostDetail.fromJson(posttJson))
          .toList(),
    );
  }
}

class PostDetail {
  final int postId;
  final String postDes;
  final String postMedia;
  final String postTime;
  final int postLiked;
  final int postShared;
  final int postViewed;

  PostDetail({
    required this.postId,
    required this.postDes,
    required this.postMedia,
    required this.postTime,
    required this.postLiked,
    required this.postShared,
    required this.postViewed,
  });

  factory PostDetail.fromJson(Map<String, dynamic> json) {
    // Check if post_media is a list and extract the first item if so
    String mediaUrl = "";
    if (json['post_media'] is List) {
      List<dynamic> mediaList = json['post_media'];
      if (mediaList.isNotEmpty) {
        mediaUrl = mediaList[0] as String;
      }
    } else {
      mediaUrl = json['post_media'] as String;
    }
    return PostDetail(
      postId: json['post_id'],
      postDes: json['post_des'],
      postMedia: mediaUrl,
      postTime: json['post_time'],
      postLiked: json['post_liked'],
      postShared: json['post_shared'],
      postViewed: json['post_viewed'],
    );
  }
}

class AdvertData {
  final String userId;
  final bool isService;
  final Map<String, dynamic> additionalData;

  AdvertData({
    required this.userId,
    required this.isService,
    required this.additionalData,
  });
}

class AdvertScreen extends StatefulWidget {
  final AdvertData advertData;
  final String userId;
  final bool isService;

  AdvertScreen({
    required this.advertData,
    required this.userId,
    required this.isService,
  });

  @override
  _AdvertScreenState createState() => _AdvertScreenState();
}

class _AdvertScreenState extends State<AdvertScreen> {
  List<dynamic> viewList = [];
  List<dynamic> callList = [];
  late Future<List<UserDetail>> userDetailsFuture;
  late Future<List<Map<String, dynamic>>> timelinePostsFuture;
  String? loginUserId;

  @override
  void initState() {
    super.initState();
    fetchViewList(widget.userId);
    // Retrieve and set login user ID before fetching user details
    _getUserId().then((id) {
      setState(() {
        loginUserId = id;
      });
      if (loginUserId != null) {
        // Fetch user details only if login user ID is available
        userDetailsFuture = fetchUserDetails(widget.userId, widget.isService);
      }
    });
    //userDetailsFuture = fetchUserDetails(widget.userId, widget.isService);
  }

  Future<void> fetchViewList(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$host/get_view_list?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // Debug logging to check if data is received as expected
        print("Response Data: $jsonData");

        // Ensure response contains `view_list` data
        if (jsonData['view_list'] != null) {
          setState(() {
            viewList = jsonData['view_list'];
          });
        } else {
          print("No view_list data available for this user.");
          setState(() {
            viewList = []; // Reset viewList if no data is returned
          });
        }
      } else {
        print("Failed to load view list, status code: ${response.statusCode}");
      }
    } catch (error) {
      print("Error fetching view list: $error");
    }
  }

  Future<void> fetchCallList(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$host/get_call_list?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // Debug logging to check if data is received as expected
        print("Response Data: $jsonData");

        // Ensure response contains `view_list` data
        if (jsonData['incoming_calls'] != null) {
          setState(() {
            callList = jsonData['incoming_calls'];
          });
        } else {
          print("No call data available for this user.");
          setState(() {
            callList = []; // Reset viewList if no data is returned
          });
        }
      } else {
        print("Failed to load call list, status code: ${response.statusCode}");
      }
    } catch (error) {
      print("Error fetching call list: $error");
    }
  }

  Future<String?> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id'); // Get the stored user_id
  }

  Future<List<UserDetail>> fetchUserDetails(String id, bool isService) async {
    final String idParam = isService ? 'service_id=$id' : 'shop_id=$id';
    final String url = '$host/get_service_or_shop_data?$idParam';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? loginUserId = prefs.getString('user_id');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'login_user_id': loginUserId}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final dataKey = isService ? 'service_data' : 'shop_data';
        final userDetails = jsonResponse[dataKey] != null
            ? (jsonResponse[dataKey] as List)
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

  // void updateUserCalled(String id, bool isService) async {
  //   final String idParam = isService ? 'service_id=$id' : 'shop_id=$id';
  //   final dataKey = isService ? 'service_data' : 'shop_data';
  //   final response = await http.post(
  //     Uri.parse('$host/post_user_called?$idParam'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode({"user_id": dataKey}),
  //   );

  //   if (response.statusCode == 200) {
  //     print("User Called updated successfully");
  //   } else {
  //     print("Failed to update user called: ${response.body}");
  //   }
  // }

  void updateUserCalled(String id, bool isService) async {
    final String idParam = isService ? 'service_id=$id' : 'shop_id=$id';
    final String url = '$host/post_user_called?$idParam';

    // Get the current time
    String callTime = DateTime.now().toIso8601String();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? loginUserId =
        prefs.getString('user_id'); // Get the stored login user ID

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "call_user_id": loginUserId,
          "call_time": callTime,
          "user_id": id
        }),
      );

      if (response.statusCode == 200) {
        print("User Called updated successfully");
      } else {
        print("Failed to update user called: ${response.body}");
      }
    } catch (e) {
      print("Error updating user called: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1), // White border
            boxShadow: [
              BoxShadow(
                color: Colors.white,
                blurRadius: 2, // Soft shadow with no offset
                spreadRadius: 1,
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
        backgroundColor: Colors.green[100],
        elevation: 5,
        centerTitle: true,
        title: Text(
          widget.userId,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins', // Use your preferred font family
            fontWeight: FontWeight.w700, // Use bold weight
            fontSize: 26, // Increase the font size for prominence
            letterSpacing: 1.2, // Adjust letter spacing for a cleaner look
            foreground: Paint()
              ..shader = LinearGradient(colors: <Color>[
                Colors.tealAccent,
                Colors.black,
                Colors.teal,
                Colors.orange
              ]).createShader(
                  Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)), // Gradient text
            shadows: [
              Shadow(
                offset: Offset(2.0, 2.0),
                blurRadius: 4.0,
                color: Colors.black26, // Subtle shadow for depth
              ),
              Shadow(
                offset: Offset(-2.0, -2.0),
                blurRadius: 4.0,
                color: Colors.grey.withOpacity(0.3), // Slight outer glow
              ),
            ],
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
        ),
      ),
      body: FutureBuilder<List<UserDetail>>(
        future: userDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (snapshot.hasData) {
              final users = snapshot.data!;
              if (users.isEmpty) {
                return Center(child: Text("No data available"));
              }
              final userCategory = users[0].category;
              return Container(
                margin: EdgeInsets.all(4),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange[100]!, Colors.green[600]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 3,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.4),
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(35),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(6),
                          margin: EdgeInsets.all(3),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.location_on,
                                  color: Colors.redAccent, size: 22),
                              SizedBox(width: 8),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          backgroundColor: Colors.orange[100]!,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(40),
                                          ),
                                          contentPadding: EdgeInsets.zero,
                                          content: Stack(
                                            children: [
                                              // The map widget
                                              Container(
                                                height: 600,
                                                width: 450,
                                                //color: Colors.white.withOpacity(0.3),
                                                // child: GoogleMap(
                                                //   initialCameraPosition: CameraPosition(
                                                //     target: userLocation, // Initial position
                                                //     zoom: 14, // Adjust zoom level
                                                //   ),
                                                //   markers: {
                                                //     Marker(
                                                //       markerId: MarkerId('user_location'),
                                                //       position: userLocation,
                                                //     ),
                                                //   },
                                                // ),
                                              ),
                                              // Floating Address on top of the map
                                              Positioned(
                                                top: 15,
                                                left: 15,
                                                right: 15,
                                                child: Container(
                                                  padding: EdgeInsets.all(6),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            40),
                                                  ),
                                                  child: Text(
                                                    users.isNotEmpty
                                                        ? users[0].address
                                                        : 'Unknown Address',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                              // Floating Distance at the bottom of the map
                                              Positioned(
                                                bottom: 15,
                                                left: 15,
                                                right: 15,
                                                child: Container(
                                                  padding: EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue
                                                        .withOpacity(0.9),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            40),
                                                  ),
                                                  child: Text(
                                                    'Distance: 5.2 km', // Placeholder for distance
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Text(
                                    users.isNotEmpty
                                        ? users[0].address
                                        : 'Unknown',
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    backgroundColor: Colors
                                        .transparent, // Make background transparent
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          width: 4,
                                          color:
                                              Colors.tealAccent, // Add a border
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            spreadRadius: 5,
                                            blurRadius: 20,
                                            offset: Offset(0,
                                                10), // Shadow for a floating effect
                                          ),
                                        ],
                                      ),
                                      child: ClipOval(
                                        child: Image.network(
                                          users[0]
                                              .photo, // Same photo in larger view
                                          fit: BoxFit.cover,
                                          width:
                                              300, // Increase the size of the image
                                          height: 300,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Container(
                              width: 140,
                              height: 140,
                              margin: EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(width: 3, color: Colors.white),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 10,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.network(
                                  users[0].photo,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),

                          // xoss area
                          Container(
                            margin: EdgeInsets.only(bottom: 5),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.white12, Colors.white],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(65),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  child: InkWell(
                                    onTap: () async {
                                      updateUserCalled(
                                          widget.userId, widget.isService);
                                      final phoneNumber = users[0].phone;
                                      final telUrl = 'tel:$phoneNumber';
                                      if (await canLaunch(telUrl)) {
                                        await launch(telUrl);
                                      } else {
                                        // Handle the error, perhaps show a message to the user
                                        print('Could not launch $telUrl');
                                      }
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(
                                              10), // Increased padding for a better look
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.green,
                                                Colors.lightGreenAccent
                                              ], // Gradient effect
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.green.withOpacity(
                                                    0.7), // Shadow color
                                                spreadRadius: 2,
                                                blurRadius: 8, // Soft shadow
                                                offset: Offset(0,
                                                    4), // Moves shadow downwards
                                              ),
                                            ],
                                            borderRadius: BorderRadius.circular(
                                                50), // Adjusted to make the button more round
                                          ),
                                          child: Icon(
                                            Icons.phone,
                                            color: Colors.white,
                                            size: 65,
                                          ),
                                        ),

                                        SizedBox(width: 4.0),
                                        // The phone number is hidden, no Text widget displaying the number
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20.0),

                                // Call Count and Call list
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        await fetchCallList(
                                            users[0].user_id.toString());
                                        setState(() {});
                                        showGeneralDialog(
                                          context: context,
                                          barrierDismissible: true,
                                          barrierLabel: "Dialog",
                                          barrierColor: Colors
                                              .black54, // Optional, for a semi-transparent background
                                          pageBuilder: (context, animation1,
                                              animation2) {
                                            return Center(
                                              child: Container(
                                                padding: EdgeInsets.all(15),
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 20),
                                                decoration: BoxDecoration(
                                                  color: Colors.green[
                                                      100], // Your desired background color
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                ),
                                                child: Material(
                                                  color: Colors.transparent,
                                                  child: SingleChildScrollView(
                                                    // Add scrolling here
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          "Call Records",
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        SizedBox(height: 10),
                                                        callList.isNotEmpty
                                                            ? ListView.builder(
                                                                shrinkWrap:
                                                                    true,
                                                                physics:
                                                                    NeverScrollableScrollPhysics(), // Prevent nested scrolling
                                                                itemCount:
                                                                    callList
                                                                        .length,
                                                                itemBuilder:
                                                                    (context,
                                                                        index) {
                                                                  final call =
                                                                      callList[
                                                                          index];
                                                                  final apiDateFormat =
                                                                      DateFormat(
                                                                          'EEE, dd MMM yyyy HH:mm:ss \'GMT\'');
                                                                  final displayDateFormat =
                                                                      DateFormat(
                                                                          'yyyy-MM-dd – kk:mm');
                                                                  final formattedTime =
                                                                      displayDateFormat
                                                                          .format(
                                                                              apiDateFormat.parse(call['call_time']));

                                                                  return Container(
                                                                    margin: EdgeInsets
                                                                        .symmetric(
                                                                            vertical:
                                                                                3),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                              .green[
                                                                          200],
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              25),
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                          color: Colors
                                                                              .grey
                                                                              .withOpacity(0.5),
                                                                          spreadRadius:
                                                                              2,
                                                                          blurRadius:
                                                                              3,
                                                                          offset: Offset(
                                                                              2,
                                                                              2),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    child:
                                                                        InkWell(
                                                                      onTap:
                                                                          () {
                                                                        String advertId = call['is_service']
                                                                            ? call['service_id'].toString()
                                                                            : call['shop_id'].toString();
                                                                        Navigator
                                                                            .push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                AdvertScreen(
                                                                              advertData: AdvertData(
                                                                                userId: advertId,
                                                                                isService: call['is_service'],
                                                                                additionalData: call['is_service']
                                                                                    ? {
                                                                                        'service_id': call['service_id'],
                                                                                      }
                                                                                    : {
                                                                                        'shop_id': call['shop_id'],
                                                                                      },
                                                                              ),
                                                                              userId: advertId,
                                                                              isService: call['is_service'],
                                                                            ),
                                                                          ),
                                                                        );
                                                                      },
                                                                      child:
                                                                          ListTile(
                                                                        leading:
                                                                            CircleAvatar(
                                                                          backgroundColor: const Color
                                                                              .fromRGBO(
                                                                              68,
                                                                              138,
                                                                              255,
                                                                              1),
                                                                          child: call['call_user_photo'] != null && call['call_user_photo'].isNotEmpty
                                                                              ? ClipOval(
                                                                                  child: Image.network(
                                                                                    call['call_user_photo'],
                                                                                    fit: BoxFit.cover,
                                                                                    width: 50,
                                                                                    height: 50,
                                                                                    loadingBuilder: (context, child, loadingProgress) {
                                                                                      if (loadingProgress == null) {
                                                                                        return child;
                                                                                      } else {
                                                                                        return Center(
                                                                                          child: CircularProgressIndicator(),
                                                                                        );
                                                                                      }
                                                                                    },
                                                                                    errorBuilder: (context, error, stackTrace) {
                                                                                      return Icon(Icons.person, color: Colors.white, size: 30);
                                                                                    },
                                                                                  ),
                                                                                )
                                                                              : Icon(Icons.person, color: Colors.white, size: 30),
                                                                        ),
                                                                        title:
                                                                            Text(
                                                                          "${call['call_user_name']}",
                                                                          style:
                                                                              TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            color:
                                                                                Colors.black87,
                                                                          ),
                                                                        ),
                                                                        subtitle:
                                                                            Text(
                                                                          "Time: $formattedTime",
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.black54,
                                                                            fontSize:
                                                                                14,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                              )
                                                            : Center(
                                                                child: Text(
                                                                  "No records available",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .black54,
                                                                    fontSize:
                                                                        16,
                                                                  ),
                                                                ),
                                                              ),
                                                        SizedBox(height: 10),
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: Text(
                                                            "Close",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .blueAccent),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          transitionBuilder: (context,
                                              animation1, animation2, child) {
                                            return ScaleTransition(
                                              scale: CurvedAnimation(
                                                parent: animation1,
                                                curve: Curves.easeOut,
                                              ),
                                              child: child,
                                            );
                                          },
                                          transitionDuration:
                                              Duration(milliseconds: 300),
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.white,
                                                  Colors.yellowAccent,
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.orange
                                                      .withOpacity(0.5),
                                                  spreadRadius: 2,
                                                  blurRadius: 2,
                                                  offset: Offset(1, 0),
                                                ),
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                            child: Icon(Icons.call_sharp,
                                                color: Colors.black, size: 45),
                                          ),
                                          SizedBox(width: 8.0),
                                          Text(
                                            users[0].user_called != null
                                                ? users[0]
                                                    .user_called
                                                    .toString()
                                                : "0",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    ///// seen count and seen list
                                    GestureDetector(
                                      onTap: () async {
                                        await fetchViewList(
                                            users[0].user_id.toString());
                                        setState(() {});
                                        showGeneralDialog(
                                          context: context,
                                          barrierDismissible: true,
                                          barrierLabel: "Dialog",
                                          barrierColor: Colors
                                              .black54, // Optional, for a semi-transparent background
                                          pageBuilder: (context, animation1,
                                              animation2) {
                                            return Center(
                                              child: Container(
                                                padding: EdgeInsets.all(15),
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 20),
                                                decoration: BoxDecoration(
                                                  color: Colors.green[
                                                      100], // Your desired background color
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                ),
                                                child: Material(
                                                  color: Colors.transparent,
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        "Seen",
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      SizedBox(height: 10),
                                                      Flexible(
                                                        child:
                                                            viewList.isNotEmpty
                                                                ? ListView
                                                                    .builder(
                                                                    shrinkWrap:
                                                                        true,
                                                                    physics:
                                                                        BouncingScrollPhysics(),
                                                                    itemCount:
                                                                        viewList
                                                                            .length,
                                                                    itemBuilder:
                                                                        (context,
                                                                            index) {
                                                                      final view =
                                                                          viewList[
                                                                              index];
                                                                      final apiDateFormat =
                                                                          DateFormat(
                                                                              'EEE, dd MMM yyyy HH:mm:ss \'GMT\'');
                                                                      final displayDateFormat =
                                                                          DateFormat(
                                                                              'yyyy-MM-dd – kk:mm');
                                                                      final formattedTime =
                                                                          displayDateFormat
                                                                              .format(apiDateFormat.parse(view['view_time']));

                                                                      return Container(
                                                                        margin: EdgeInsets.symmetric(
                                                                            vertical:
                                                                                3),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              Colors.green[200],
                                                                          borderRadius:
                                                                              BorderRadius.circular(25),
                                                                          boxShadow: [
                                                                            BoxShadow(
                                                                              color: Colors.grey.withOpacity(0.5),
                                                                              spreadRadius: 2,
                                                                              blurRadius: 3,
                                                                              offset: Offset(2, 2),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        child:
                                                                            InkWell(
                                                                          onTap:
                                                                              () {
                                                                            String advertId = view['is_service']
                                                                                ? view['service_id'].toString()
                                                                                : view['shop_id'].toString();
                                                                            Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                builder: (context) => AdvertScreen(
                                                                                  advertData: AdvertData(
                                                                                    userId: advertId,
                                                                                    isService: view['is_service'],
                                                                                    additionalData: view['is_service']
                                                                                        ? {
                                                                                            'service_id': view['service_id'],
                                                                                          }
                                                                                        : {
                                                                                            'shop_id': view['shop_id'],
                                                                                          },
                                                                                  ),
                                                                                  userId: advertId,
                                                                                  isService: view['is_service'],
                                                                                ),
                                                                              ),
                                                                            );
                                                                          },
                                                                          child:
                                                                              ListTile(
                                                                            leading:
                                                                                CircleAvatar(
                                                                              backgroundColor: const Color.fromRGBO(68, 138, 255, 1),
                                                                              child: view['view_user_photo'] != null && view['view_user_photo'].isNotEmpty
                                                                                  ? ClipOval(
                                                                                      child: Image.network(
                                                                                        view['view_user_photo'],
                                                                                        fit: BoxFit.cover,
                                                                                        width: 50,
                                                                                        height: 50,
                                                                                        loadingBuilder: (context, child, loadingProgress) {
                                                                                          if (loadingProgress == null) {
                                                                                            return child;
                                                                                          } else {
                                                                                            return Center(
                                                                                              child: CircularProgressIndicator(),
                                                                                            );
                                                                                          }
                                                                                        },
                                                                                        errorBuilder: (context, error, stackTrace) {
                                                                                          return Icon(Icons.person, color: Colors.white, size: 30);
                                                                                        },
                                                                                      ),
                                                                                    )
                                                                                  : Icon(Icons.person, color: Colors.white, size: 30),
                                                                            ),
                                                                            title:
                                                                                Text(
                                                                              "${view['view_user_name']}",
                                                                              style: TextStyle(
                                                                                fontWeight: FontWeight.w600,
                                                                                color: Colors.black87,
                                                                              ),
                                                                            ),
                                                                            subtitle:
                                                                                Text(
                                                                              "Time: $formattedTime",
                                                                              style: TextStyle(
                                                                                color: Colors.black54,
                                                                                fontSize: 14,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    },
                                                                  )
                                                                : Center(
                                                                    child: Text(
                                                                      "No views available",
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .black54,
                                                                        fontSize:
                                                                            16,
                                                                      ),
                                                                    ),
                                                                  ),
                                                      ),
                                                      SizedBox(height: 10),
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text(
                                                          "Close",
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .blueAccent),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          transitionBuilder: (context,
                                              animation1, animation2, child) {
                                            return ScaleTransition(
                                              scale: CurvedAnimation(
                                                parent: animation1,
                                                curve: Curves.easeOut,
                                              ),
                                              child: child,
                                            );
                                          },
                                          transitionDuration:
                                              Duration(milliseconds: 300),
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.white,
                                                  Colors.yellowAccent,
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.orange
                                                      .withOpacity(0.5),
                                                  spreadRadius: 2,
                                                  blurRadius: 2,
                                                  offset: Offset(1, 0),
                                                ),
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                            child: Icon(Icons.visibility,
                                                color: Colors.black, size: 45),
                                          ),
                                          SizedBox(width: 8.0),
                                          Text(
                                            users[0].user_viewed != null
                                                ? users[0]
                                                    .user_viewed
                                                    .toString()
                                                : "0",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Row(
                                    //   children: [
                                    //     Container(
                                    //       padding: EdgeInsets.all(8),
                                    //       decoration: BoxDecoration(
                                    //         gradient: LinearGradient(
                                    //           colors: [
                                    //             Colors.white,
                                    //             Colors.lightGreenAccent
                                    //           ],
                                    //           begin: Alignment.topLeft,
                                    //           end: Alignment.bottomRight,
                                    //         ),
                                    //         boxShadow: [
                                    //           BoxShadow(
                                    //             color: Colors.green
                                    //                 .withOpacity(0.5),
                                    //             spreadRadius: 2,
                                    //             blurRadius: 2,
                                    //             offset: Offset(1, 0),
                                    //           ),
                                    //         ],
                                    //         borderRadius:
                                    //             BorderRadius.circular(50),
                                    //       ),
                                    //       child: Icon(Icons.share,
                                    //           color: Colors.black, size: 25),
                                    //     ),
                                    //     SizedBox(width: 8.0),
                                    //     Text(
                                    //       users[0].user_shared != null
                                    //           ? users[0].user_shared.toString()
                                    //           : "0",
                                    //       style: TextStyle(
                                    //         color: Colors.black,
                                    //         fontSize: 20,
                                    //         fontWeight: FontWeight.bold,
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ),
                                  ],
                                ),
                                SizedBox(height: 10.0),
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 35),
                                  padding: EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.orange[100]!,
                                        Colors.green[100]!
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(75),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      IconButton(
                                        icon: FaIcon(
                                          FontAwesomeIcons.facebook,
                                          color: Colors.blue,
                                          size: 35,
                                        ),
                                        onPressed: () {
                                          // Open Facebook profile
                                        },
                                      ),
                                      IconButton(
                                        icon: FaIcon(
                                          FontAwesomeIcons.facebookMessenger,
                                          color: Colors.blue,
                                          size: 35,
                                        ),
                                        onPressed: () {
                                          // Open Facebook profile
                                        },
                                      ),
                                      IconButton(
                                        icon: FaIcon(
                                          FontAwesomeIcons.whatsapp,
                                          color: Colors.green,
                                          size: 35,
                                        ),
                                        onPressed: () {
                                          // Open Twitter profile
                                        },
                                      ),
                                      IconButton(
                                        icon: FaIcon(
                                          FontAwesomeIcons.instagram,
                                          color: Colors.pink.shade400,
                                          size: 35,
                                        ),
                                        onPressed: () {
                                          // Open Instagram profile
                                        },
                                      ),
                                      IconButton(
                                        icon: FaIcon(
                                          FontAwesomeIcons.linkedin,
                                          color:
                                              Color.fromARGB(255, 0, 119, 181),
                                          size: 35,
                                        ),
                                        onPressed: () {
                                          // Open Instagram profile
                                        },
                                      ),
                                      
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.white38, Colors.white24],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(45),
                                ),
                                child: Text(
                                  users[0].businessName,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily:
                                        'Poppins', // Use your preferred font family
                                    fontWeight:
                                        FontWeight.w700, // Use bold weight
                                    fontSize:
                                        26, // Increase the font size for prominence
                                    letterSpacing:
                                        1.2, // Adjust letter spacing for a cleaner look
                                    foreground: Paint()
                                      ..shader = LinearGradient(colors: <Color>[
                                        Colors.black,
                                        Colors.black,
                                        Colors.black,
                                        Colors.black,
                                        Colors.black
                                      ]).createShader(Rect.fromLTWH(0.0, 0.0,
                                          200.0, 70.0)), // Gradient text
                                    shadows: [
                                      Shadow(
                                        offset: Offset(2.0, 2.0),
                                        blurRadius: 4.0,
                                        color: Colors
                                            .black26, // Subtle shadow for depth
                                      ),
                                      Shadow(
                                        offset: Offset(-2.0, -2.0),
                                        blurRadius: 4.0,
                                        color: Colors.grey.withOpacity(
                                            0.3), // Slight outer glow
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                users[0].category,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily:
                                      'Poppins', // Use your preferred font family
                                  fontWeight:
                                      FontWeight.w700, // Use bold weight
                                  fontSize:
                                      18, // Increase the font size for prominence
                                  letterSpacing:
                                      1.2, // Adjust letter spacing for a cleaner look
                                  foreground: Paint()
                                    ..shader = LinearGradient(colors: <Color>[
                                      Colors.red,
                                      Colors.black,
                                      Colors.red,
                                      Colors.black,
                                    ]).createShader(Rect.fromLTWH(0.0, 0.0,
                                        200.0, 70.0)), // Gradient text
                                  shadows: [
                                    Shadow(
                                      offset: Offset(2.0, 2.0),
                                      blurRadius: 4.0,
                                      color: Colors
                                          .black26, // Subtle shadow for depth
                                    ),
                                    Shadow(
                                      offset: Offset(-2.0, -2.0),
                                      blurRadius: 4.0,
                                      color: Colors.grey.withOpacity(
                                          0.3), // Slight outer glow
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // M I D D L E
                          Divider(
                              color: Colors.black, height: 20, thickness: 1),
                          TimelineWidget(
                            cat_id: users[0].cat_id,
                            dataType: widget.isService ? 'service' : 'shop',
                          ),
                          Divider(
                              color: Colors.black, height: 20, thickness: 1),

                          // L O W E R
                          Container(
                            padding: EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.tealAccent, Colors.green],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            height: 600,
                            child: GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 1,
                                  childAspectRatio: 1.2,
                                ),
                                itemCount: users[0].posts.length,
                                itemBuilder: (context, index) {
                                  final post = users[0].posts[
                                      index]; // Get post at current index

                                  return FutureBuilder<String?>(
                                      future:
                                          _getUserId(), // Call the method to get user_id from SharedPreferences
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Center(
                                              child:
                                                  CircularProgressIndicator());
                                        } else if (snapshot.hasError) {
                                          return Center(
                                              child: Text(
                                                  "Error retrieving user ID"));
                                        } else {
                                          final userId = snapshot.data;
                                          print(userId);
                                          return Card(
                                            elevation: 5,
                                            margin: EdgeInsets.all(5),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(45),
                                            ),
                                            child: Stack(
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            PostDetails(
                                                          postId: post.postId
                                                              .toString(), // Use the post's postId from PostDetail
                                                          userId: userId
                                                              .toString(), // Use the userId from the widget's advertData or widget.userId
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Expanded(
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.vertical(
                                                                  top: Radius
                                                                      .circular(
                                                                          15)),
                                                          child: post.postMedia
                                                                  .isNotEmpty
                                                              ? Image.network(
                                                                  post.postMedia,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  width: double
                                                                      .infinity,
                                                                )
                                                              : Container(
                                                                  color: Colors
                                                                          .grey[
                                                                      200],
                                                                  child: Center(
                                                                    child: Text(
                                                                        "No Image Available"),
                                                                  )),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceAround,
                                                              children: [
                                                                // Like Icon with background and shadow
                                                                Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                    shape: BoxShape
                                                                        .rectangle,
                                                                    color: Colors
                                                                        .white70,
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        color: Colors
                                                                            .black
                                                                            .withOpacity(0.1),
                                                                        blurRadius:
                                                                            5,
                                                                        offset: Offset(
                                                                            0,
                                                                            2),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              8),
                                                                  child: Row(
                                                                    children: [
                                                                      Icon(
                                                                          Icons
                                                                              .thumb_up_alt,
                                                                          color: Colors
                                                                              .red,
                                                                          size:
                                                                              20),
                                                                      SizedBox(
                                                                          width:
                                                                              5),
                                                                      Text(
                                                                          '${post.postLiked}'),
                                                                    ],
                                                                  ),
                                                                ),

                                                                // Comment Icon with background and shadow
                                                                Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                    shape: BoxShape
                                                                        .rectangle,
                                                                    color: Colors
                                                                        .white70,
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        color: Colors
                                                                            .black
                                                                            .withOpacity(0.1),
                                                                        blurRadius:
                                                                            5,
                                                                        offset: Offset(
                                                                            0,
                                                                            2),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              8),
                                                                  child: Row(
                                                                    children: [
                                                                      Icon(
                                                                          Icons
                                                                              .chat_bubble_outline,
                                                                          color: Colors
                                                                              .blue,
                                                                          size:
                                                                              20),
                                                                      SizedBox(
                                                                          width:
                                                                              5),
                                                                      Text(
                                                                          '000'),
                                                                    ],
                                                                  ),
                                                                ),

                                                                // Share Icon with background and shadow
                                                                Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                    shape: BoxShape
                                                                        .rectangle,
                                                                    color: Colors
                                                                        .white70,
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        color: Colors
                                                                            .black
                                                                            .withOpacity(0.1),
                                                                        blurRadius:
                                                                            5,
                                                                        offset: Offset(
                                                                            0,
                                                                            2),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              8),
                                                                  child: Row(
                                                                    children: [
                                                                      Icon(
                                                                          Icons
                                                                              .share,
                                                                          color: Colors
                                                                              .green,
                                                                          size:
                                                                              20),
                                                                      SizedBox(
                                                                          width:
                                                                              5),
                                                                      Text(
                                                                          '${post.postShared}'),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(height: 5),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                // Positioned description at the bottom
                                                Positioned(
                                                  bottom: 55,
                                                  left: 0,
                                                  right: 0,
                                                  child: Container(
                                                    margin: EdgeInsets.all(8),
                                                    padding: EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white70,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: Text(
                                                      post.postDes,
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 18,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ),

                                                // Seen icon and view count at the top left
                                                Positioned(
                                                  top: 10,
                                                  left: 10,
                                                  child: Container(
                                                    padding: EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      color: Colors.white70,
                                                      shape: BoxShape.rectangle,
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                            Icons
                                                                .remove_red_eye,
                                                            color:
                                                                Colors.purple,
                                                            size: 20),
                                                        SizedBox(width: 5),
                                                        Text(
                                                          '${post.postViewed}',
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),

                                                // Share icon and share count at the top right
                                                Positioned(
                                                  top: 10,
                                                  right: 10,
                                                  child: Container(
                                                    padding: EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      color: Colors.white70,
                                                      shape: BoxShape.rectangle,
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                            Icons
                                                                .watch_off_outlined,
                                                            color:
                                                                Colors.orange,
                                                            size: 20),
                                                        SizedBox(width: 5),
                                                        Text(
                                                          '${post.postShared} 00:00 AM',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 14),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      });
                                }),
                          )
                        ],
                      ),
                    ],
                  ),
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
