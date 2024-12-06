import 'dart:convert';
import 'dart:ffi';
import 'package:aaram_bd/config.dart';
import 'package:aaram_bd/screens/advert_screen.dart';
import 'package:aaram_bd/screens/post_details.dart';
import 'package:aaram_bd/widgets/ExpendableText.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:aaram_bd/screens/editprofile_screen.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:aaram_bd/screens/post_upload.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class UserProfile extends StatefulWidget {
  final String userPhone;
  final Key? key;
  final dynamic userData; // Add this parameter to accept the user data

  UserProfile({required this.userPhone, this.userData, this.key})
      : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState(userPhone: userPhone);
}

class _UserProfileState extends State<UserProfile> {
  final String userPhone;
  List<dynamic> viewList = [];
  List<dynamic> incomingCallList = [];
  List<dynamic> outgoingCallList = [];

  _UserProfileState({required this.userPhone});

  // List<String> images = [];
  List<Map<String, dynamic>> posts = []; // New list to hold posts data
  String user_id = '';
  String userName = "User Name";
  String profile_pic = "";
  String userCategory = "Category";
  String userDescription = "User Description";
  String userAddress = "User Address";
  int userview = 0;
  int usercall = 0;
  int usershare = 0;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    print("Fetching user data for phone: $userPhone");
    final response = await http.get(
      Uri.parse('$host/get_user_by_phone?phone=$userPhone'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("Fetched data: $data");
      setState(() {
        user_id = data['user_id'];
        userName = data['name'] ?? "User Name";
        userCategory = data['cat_name'] ?? "Category";
        userDescription = data['description'] ?? "User Description";
        userAddress = data['location'] ?? "User Address";
        profile_pic = data['photo'] ?? "No image";
        userview = data['user_viewed'];
        usercall = data['user_called'];
        usershare = data['user_shared'];
        // images = List<String>.from(data['photos'] ?? []);
        posts = List<Map<String, dynamic>>.from(
            data['posts'] ?? []); // Store posts data
      });
    } else {
      // Handle the error
      print("Failed to fetch user data: ${response.statusCode}");
    }
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

        setState(() {
          // Check if `incoming_calls` is available in the response
          if (jsonData['incoming_calls'] != null) {
            incomingCallList = jsonData['incoming_calls'];
          } else {
            print("No incoming call data available for this user.");
            incomingCallList = []; // Reset if no data is returned
          }

          // Check if `outgoing_calls` is available in the response
          if (jsonData['outgoing_calls'] != null) {
            outgoingCallList = jsonData['outgoing_calls'];
          } else {
            print("No outgoing call data available for this user.");
            outgoingCallList = []; // Reset if no data is returned
          }
        });
      } else {
        print("Failed to load call list, status code: ${response.statusCode}");
      }
    } catch (error) {
      print("Error fetching call list: $error");
    }
  }

  Future<bool> deletePost(String postId) async {
    final url = Uri.parse('$host/delete_post');
    try {
      final response = await http.delete(url, body: {
        // 'phone': userPhone,
        'post_id': postId,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data['message']); // Log success message
        return true; // Indicate success
      } else {
        final errorData = jsonDecode(response.body);
        print(errorData['error']); // Log error message
        return false; // Indicate failure
      }
    } catch (e) {
      print('Failed to delete post: $e');
      return false; // Indicate failure
    }
  }

//need to fix
  Future<bool> updatePost(String postId) async {
    final url = Uri.parse('$host/delete_post');
    try {
      final response = await http.delete(url, body: {
        // 'phone': userPhone,
        'post_id': postId,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data['message']); // Log success message
        return true; // Indicate success
      } else {
        final errorData = jsonDecode(response.body);
        print(errorData['error']); // Log error message
        return false; // Indicate failure
      }
    } catch (e) {
      print('Failed to delete post: $e');
      return false; // Indicate failure
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              //margin: EdgeInsets.all(3),
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    spreadRadius: 5,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
                //borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [Colors.orange[200]!, Colors.blue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
                    decoration: BoxDecoration(
                      color: Colors.transparent, // Background color
                      border: Border.all(
                        //width: 1.5,
                        color: Colors.black.withOpacity(0.1), // Soft border
                      ),
                      borderRadius:
                          BorderRadius.circular(35), // Rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey
                              .withOpacity(0.4), // Shadow with light opacity
                          spreadRadius: 5,
                          blurRadius: 15,
                          offset: Offset(
                              0, 3), // Position the shadow slightly downward
                        ),
                      ],
                    ), // Adjust padding for overall spacing
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.center, // Align text at the top
                      children: [
                        // Profile picture with a shadow effect
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                // Handle the tap event for expanding the picture
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      backgroundColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.all(15),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Stack(
                                              alignment: Alignment.bottomCenter,
                                              children: [
                                                Container(
                                                  height: 300,
                                                  width: 300,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black45,
                                                        blurRadius: 10,
                                                        spreadRadius: 5,
                                                        offset: Offset(0, 5),
                                                      ),
                                                    ],
                                                  ),
                                                  child: ClipOval(
                                                    child: profile_pic
                                                            .isNotEmpty
                                                        ? Image.network(
                                                            profile_pic,
                                                            height: 180,
                                                            width: 180,
                                                            fit: BoxFit.cover,
                                                          )
                                                        : Container(
                                                            height: 180,
                                                            width: 180,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors.blue
                                                                  .shade300,
                                                            ),
                                                            child: Icon(
                                                              Icons.person,
                                                              size:
                                                                  120, // Adjust icon size
                                                              color:
                                                                  Colors.blue,
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                                Positioned(
                                                  bottom: 5,
                                                  child: Column(
                                                    children: [
                                                      Icon(
                                                        Icons.add_circle,
                                                        color: Colors.white,
                                                        size: 30,
                                                      ),
                                                      SizedBox(height: 5),
                                                      Text(
                                                        'Change',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                height: 120,
                                width: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black45,
                                      blurRadius: 5,
                                      spreadRadius: 2,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: profile_pic.isNotEmpty
                                      ? Image.network(
                                          profile_pic,
                                          height: 120,
                                          width: 120,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          height: 120,
                                          width: 120,
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade300,
                                          ),
                                          child: Icon(
                                            Icons.person,
                                            size: 80,
                                            color: Colors.blue,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(width: 10), // Space between image and text
                        // Username text with gradient and shadows
                        Expanded(
                          child: Text(
                            userName,
                            textAlign: TextAlign.left, // Align text to the left
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight:
                                  FontWeight.w700, // Bold weight for prominence
                              fontSize: 20, // Reduced font size to fit better
                              letterSpacing: 1.2,
                              foreground: Paint()
                                ..shader = LinearGradient(
                                  colors: <Color>[
                                    Colors.yellow,
                                    Colors.black,
                                  ],
                                ).createShader(Rect.fromLTWH(
                                    0.0, 0.0, 200.0, 70.0)), // Gradient text
                              shadows: [
                                Shadow(
                                  offset: Offset(2.0, 2.0),
                                  blurRadius: 4.0,
                                  color: Colors.black26,
                                ),
                                Shadow(
                                  offset: Offset(-2.0, -2.0),
                                  blurRadius: 4.0,
                                  color: Colors.grey.withOpacity(0.3),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Column(
                    children: [
                      // Phone Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape:
                                      BoxShape.circle, // Circular icon holder
                                  color: Colors
                                      .blue.shade100, // Light blue background
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: Offset(0, 4), // Shadow for depth
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.all(
                                    6), // Increased padding for larger icon
                                child: Icon(
                                  Icons.phone,
                                  color: Colors.blue.shade600,
                                  size:
                                      28, // Bigger icon size for better visibility
                                ),
                              ),
                              SizedBox(width: 4),
                              Text(
                                widget.userPhone,
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15, // Increased font size
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.orange
                                      .shade100, // Light orange background
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.all(6),
                                child: Icon(
                                  Icons.category,
                                  color: Colors.orange.shade600,
                                  size: 28,
                                ),
                              ),
                              SizedBox(width: 6),
                              Text(
                                userCategory,
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      Container(
                        margin: EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal:
                                15), // Add margin for spacing around the container
                        padding: EdgeInsets.all(
                            16), // Add padding for spacing inside the container
                        decoration: BoxDecoration(
                          color: Colors.white, // Background color
                          border: Border.all(
                            width: 1.5,
                            color: Colors.black.withOpacity(0.1), // Soft border
                          ),
                          borderRadius:
                              BorderRadius.circular(35), // Rounded corners
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(
                                  0.4), // Shadow with light opacity
                              spreadRadius: 5,
                              blurRadius: 10,
                              offset: Offset(0,
                                  3), // Position the shadow slightly downward
                            ),
                          ],
                        ),
                        child: Text(
                          userDescription.isNotEmpty
                              ? userDescription
                              : 'Edit your profile and update your description here...', // Default text if no description
                          style: TextStyle(
                            color: userDescription.isNotEmpty
                                ? Colors.grey.shade700
                                : Colors.blueGrey
                                    .shade400, // Lighter color for the default text
                            fontSize: 16,
                            fontStyle: userDescription.isNotEmpty
                                ? FontStyle.normal
                                : FontStyle.italic, // Italic for default text
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      // Category Row
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue, Colors.green[600]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ), // Background color
                          border: Border.all(
                            width: 1.5,
                            color: Colors.black, // Soft border
                          ),
                          borderRadius:
                              BorderRadius.circular(35), // Rounded corners
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(
                                  0.4), // Shadow with light opacity
                              spreadRadius: 5,
                              blurRadius: 10,
                              offset: Offset(0,
                                  3), // Position the shadow slightly downward
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            //callcount

                            GestureDetector(
                              onTap: () async {
                                // Call the function to fetch the call list data
                                await fetchCallList(user_id.toString());
                                setState(() {}); // Refresh the UI if needed

                                // Show the dialog with Incoming and Outgoing filter buttons
                                showGeneralDialog(
                                  context: context,
                                  barrierDismissible: true,
                                  barrierLabel: "Dialog",
                                  barrierColor: Colors.black54,
                                  pageBuilder:
                                      (context, animation1, animation2) {
                                    bool showIncoming = true;

                                    return StatefulBuilder(
                                      builder: (context, setState) {
                                        final filteredList = showIncoming
                                            ? incomingCallList
                                                .where((call) =>
                                                    call['direction'] ==
                                                    'incoming')
                                                .toList()
                                            : outgoingCallList
                                                .where((call) =>
                                                    call['direction'] ==
                                                    'outgoing')
                                                .toList();

                                        return Center(
                                          child: Container(
                                            padding: EdgeInsets.all(15),
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 20),
                                            decoration: BoxDecoration(
                                              color: Colors.white30,
                                              border: Border.all(
                                                  width: 1,
                                                  color: Colors.black),
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                            ),
                                            child: Material(
                                              color: Colors.transparent,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,

                                                ///modify here
                                                children: [
                                                  Text(
                                                    "Call History",
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(height: 5),
                                                  incomingCallList.isNotEmpty
                                                      ? ListView.builder(
                                                          shrinkWrap: true,
                                                          physics:
                                                              NeverScrollableScrollPhysics(),
                                                          itemCount:
                                                              incomingCallList
                                                                  .length,
                                                          itemBuilder:
                                                              (context, index) {
                                                            final call =
                                                                incomingCallList[
                                                                    index];
                                                            final apiDateFormat =
                                                                DateFormat(
                                                                    'EEE, dd MMM yyyy HH:mm:ss \'GMT\'');
                                                            final displayDateFormat =
                                                                DateFormat(
                                                                    'yyyy-MM-dd – kk:mm');
                                                            final formattedTime =
                                                                displayDateFormat.format(
                                                                    apiDateFormat
                                                                        .parse(call[
                                                                            'call_time']));

                                                            return Container(
                                                              margin: EdgeInsets
                                                                  .symmetric(
                                                                      vertical:
                                                                          3),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .green[200],
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            25),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .grey
                                                                        .withOpacity(
                                                                            0.5),
                                                                    spreadRadius:
                                                                        2,
                                                                    blurRadius:
                                                                        3,
                                                                    offset:
                                                                        Offset(
                                                                            2,
                                                                            2),
                                                                  ),
                                                                ],
                                                              ),
                                                              child: InkWell(
                                                                onTap: () {
                                                                  String advertId = call[
                                                                          'is_service']
                                                                      ? call['service_id']
                                                                          .toString()
                                                                      : call['shop_id']
                                                                          .toString();
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              AdvertScreen(
                                                                        advertData:
                                                                            AdvertData(
                                                                          userId:
                                                                              advertId,
                                                                          isService:
                                                                              call['is_service'],
                                                                          additionalData: call['is_service']
                                                                              ? {
                                                                                  'service_id': call['service_id']
                                                                                }
                                                                              : {
                                                                                  'shop_id': call['shop_id']
                                                                                },
                                                                        ),
                                                                        userId:
                                                                            advertId,
                                                                        isService:
                                                                            call['is_service'],
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                                child: ListTile(
                                                                  leading:
                                                                      CircleAvatar(
                                                                    backgroundColor:
                                                                        Color.fromRGBO(
                                                                            68,
                                                                            138,
                                                                            255,
                                                                            1),
                                                                    child: call['call_user_photo'] !=
                                                                                null &&
                                                                            call['call_user_photo'].isNotEmpty
                                                                        ? ClipOval(
                                                                            child:
                                                                                Image.network(
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
                                                                        : const Icon(
                                                                            Icons.person,
                                                                            color:
                                                                                Colors.white,
                                                                            size:
                                                                                30,
                                                                          ),
                                                                  ),
                                                                  title: Row(
                                                                    children: [
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
                                                                      SizedBox(
                                                                          width:
                                                                              8),
                                                                      Icon(
                                                                          Icons
                                                                              .call_received,
                                                                          color:
                                                                              Colors.green), // Incoming call icon
                                                                    ],
                                                                  ),
                                                                  subtitle:
                                                                      Text(
                                                                    "Time: $formattedTime",
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .black54,
                                                                      fontSize:
                                                                          14,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        )
                                                      : const Center(
                                                          child: Text(
                                                            "No Incoming Call records",
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .black54,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ),
                                                  SizedBox(height: 5),
                                                  outgoingCallList.isNotEmpty
                                                      ? Expanded(
                                                          child:
                                                              ListView.builder(
                                                            shrinkWrap: true,
                                                            physics:
                                                                NeverScrollableScrollPhysics(),
                                                            itemCount:
                                                                outgoingCallList
                                                                    .length,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              final call =
                                                                  outgoingCallList[
                                                                      index];
                                                              final apiDateFormat =
                                                                  DateFormat(
                                                                      'EEE, dd MMM yyyy HH:mm:ss \'GMT\'');
                                                              final displayDateFormat =
                                                                  DateFormat(
                                                                      'yyyy-MM-dd – kk:mm');
                                                              final formattedTime =
                                                                  displayDateFormat.format(
                                                                      apiDateFormat
                                                                          .parse(
                                                                              call['call_time']));

                                                              return Container(
                                                                margin: EdgeInsets
                                                                    .symmetric(
                                                                        vertical:
                                                                            3),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                          .blue[
                                                                      200],
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              25),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Colors
                                                                          .grey
                                                                          .withOpacity(
                                                                              0.5),
                                                                      spreadRadius:
                                                                          2,
                                                                      blurRadius:
                                                                          3,
                                                                      offset:
                                                                          Offset(
                                                                              2,
                                                                              2),
                                                                    ),
                                                                  ],
                                                                ),
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    String advertId = call[
                                                                            'is_service']
                                                                        ? call['service_id']
                                                                            .toString()
                                                                        : call['shop_id']
                                                                            .toString();
                                                                    Navigator
                                                                        .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                AdvertScreen(
                                                                          advertData:
                                                                              AdvertData(
                                                                            userId:
                                                                                advertId,
                                                                            isService:
                                                                                call['is_service'],
                                                                            additionalData: call['is_service']
                                                                                ? {
                                                                                    'service_id': call['service_id']
                                                                                  }
                                                                                : {
                                                                                    'shop_id': call['shop_id']
                                                                                  },
                                                                          ),
                                                                          userId:
                                                                              advertId,
                                                                          isService:
                                                                              call['is_service'],
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                  child:
                                                                      ListTile(
                                                                    leading:
                                                                        CircleAvatar(
                                                                      backgroundColor:
                                                                          Color.fromRGBO(
                                                                              68,
                                                                              138,
                                                                              255,
                                                                              1),
                                                                      child: call['receiver_photo'] != null &&
                                                                              call['receiver_photo'].isNotEmpty
                                                                          ? ClipOval(
                                                                              child: Image.network(
                                                                                call['receiver_photo'],
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
                                                                          : Icon(
                                                                              Icons.person,
                                                                              color: Colors.white,
                                                                              size: 30,
                                                                            ),
                                                                    ),
                                                                    title: Row(
                                                                      children: [
                                                                        Expanded(
                                                                          // Wrap Text with Expanded to control overflow within the row
                                                                          child:
                                                                              Text(
                                                                            "${call['receiver_name']}",
                                                                            style:
                                                                                TextStyle(
                                                                              fontWeight: FontWeight.w600,
                                                                              color: Colors.black87,
                                                                            ),
                                                                            overflow:
                                                                                TextOverflow.ellipsis, // Truncates text with "..."
                                                                            maxLines:
                                                                                1, // Restricts text to a single line
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                            width:
                                                                                8),
                                                                        Icon(
                                                                          Icons
                                                                              .call_made,
                                                                          color:
                                                                              Colors.blue,
                                                                          size:
                                                                              20, // Adjust size if necessary for better alignment
                                                                        ), // Outgoing call icon
                                                                      ],
                                                                    ),
                                                                    subtitle:
                                                                        Text(
                                                                      "Time: $formattedTime",
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .black54,
                                                                        fontSize:
                                                                            14,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        )
                                                      : Center(
                                                          child: Text(
                                                            "No Outgoing Call records",
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .black54,
                                                              fontSize: 16,
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
                                    );
                                  },
                                  transitionBuilder:
                                      (context, animation1, animation2, child) {
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
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.orange.shade100,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.orange.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    padding: EdgeInsets.all(10),
                                    child: Icon(Icons.call,
                                        color: Colors.orange, size: 35),
                                  ),
                                  SizedBox(width: 8.0),
                                  Text(
                                    userview.toString(),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            //view count

                            //// seen count and seen list
                            GestureDetector(
                              onTap: () async {
                                await fetchViewList(user_id.toString());
                                setState(() {});
                                showGeneralDialog(
                                  context: context,
                                  barrierDismissible: true,
                                  barrierLabel: "Dialog",
                                  barrierColor: Colors
                                      .black54, // Optional, for a semi-transparent background
                                  pageBuilder:
                                      (context, animation1, animation2) {
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
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                "Seen",
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              SizedBox(height: 10),
                                              viewList.isNotEmpty
                                                  ? ListView.builder(
                                                      shrinkWrap: true,
                                                      itemCount:
                                                          viewList.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        final view =
                                                            viewList[index];
                                                        final apiDateFormat =
                                                            DateFormat(
                                                                'EEE, dd MMM yyyy HH:mm:ss \'GMT\'');
                                                        final displayDateFormat =
                                                            DateFormat(
                                                                'yyyy-MM-dd – kk:mm');
                                                        final formattedTime =
                                                            displayDateFormat.format(
                                                                apiDateFormat
                                                                    .parse(view[
                                                                        'view_time']));

                                                        return Container(
                                                          margin: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 3),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .green[200],
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        25),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .grey
                                                                    .withOpacity(
                                                                        0.5),
                                                                spreadRadius: 2,
                                                                blurRadius: 3,
                                                                offset: Offset(
                                                                    2, 2),
                                                              ),
                                                            ],
                                                          ),
                                                          child: InkWell(
                                                            onTap: () {
                                                              // Navigate to AdvertScreen with the user_id from call data
                                                              // Determine whether to pass `service_id` or `shop_id` based on `is_service`
                                                              String advertId = view[
                                                                      'is_service']
                                                                  ? view['service_id']
                                                                      .toString()
                                                                  : view['shop_id']
                                                                      .toString();
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          AdvertScreen(
                                                                    advertData:
                                                                        AdvertData(
                                                                      userId:
                                                                          advertId,
                                                                      isService:
                                                                          view[
                                                                              'is_service'], // Adjust based on whether it’s a service or shop
                                                                      additionalData: view[
                                                                              'is_service']
                                                                          ? {
                                                                              'service_id': view['service_id'],
                                                                            }
                                                                          : {
                                                                              'shop_id': view['shop_id'],
                                                                            }, // Pass any additional data if required
                                                                    ),
                                                                    userId:
                                                                        advertId,
                                                                    isService: view[
                                                                        'is_service'],
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            child: ListTile(
                                                              leading:
                                                                  CircleAvatar(
                                                                backgroundColor:
                                                                    const Color
                                                                        .fromRGBO(
                                                                        68,
                                                                        138,
                                                                        255,
                                                                        1),
                                                                child: view['view_user_photo'] !=
                                                                            null &&
                                                                        view['view_user_photo']
                                                                            .isNotEmpty
                                                                    ? ClipOval(
                                                                        child: Image
                                                                            .network(
                                                                          view[
                                                                              'view_user_photo'],
                                                                          fit: BoxFit
                                                                              .cover,
                                                                          width:
                                                                              50,
                                                                          height:
                                                                              50,
                                                                          loadingBuilder: (context,
                                                                              child,
                                                                              loadingProgress) {
                                                                            if (loadingProgress ==
                                                                                null) {
                                                                              return child;
                                                                            } else {
                                                                              return Center(
                                                                                child: CircularProgressIndicator(),
                                                                              );
                                                                            }
                                                                          },
                                                                          errorBuilder: (context,
                                                                              error,
                                                                              stackTrace) {
                                                                            return Icon(Icons.person,
                                                                                color: Colors.white,
                                                                                size: 30);
                                                                          },
                                                                        ),
                                                                      )
                                                                    : Icon(
                                                                        Icons
                                                                            .person,
                                                                        color: Colors
                                                                            .white,
                                                                        size:
                                                                            30),
                                                              ),
                                                              title: Text(
                                                                "${view['view_user_name']}",
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: Colors
                                                                      .black87,
                                                                ),
                                                              ),
                                                              subtitle: Text(
                                                                "Time: $formattedTime",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black54,
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
                                                        style: TextStyle(
                                                          color: Colors.black54,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ),
                                              SizedBox(height: 10),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text(
                                                  "Close",
                                                  style: TextStyle(
                                                      color: Colors.blueAccent),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  transitionBuilder:
                                      (context, animation1, animation2, child) {
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
                                          color: Colors.orange.withOpacity(0.5),
                                          spreadRadius: 2,
                                          blurRadius: 2,
                                          offset: Offset(1, 0),
                                        ),
                                      ],
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Icon(Icons.visibility,
                                        color: Colors.black, size: 45),
                                  ),
                                  SizedBox(width: 8.0),
                                  Text(
                                    userview != null
                                        ? userview.toString()
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

                            //sharecount
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.blue.shade100,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blue.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  padding: EdgeInsets.all(10),
                                  child: Icon(Icons.share,
                                      color: Colors.blue, size: 26),
                                ),
                                SizedBox(width: 8.0),
                                Text(
                                  usershare.toString(),
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 15),
                  // Social media section

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white, // Background color
                      border: Border.all(
                        width: 1.5,
                        color: Colors.black.withOpacity(0.1), // Soft border
                      ),
                      borderRadius:
                          BorderRadius.circular(35), // Rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey
                              .withOpacity(0.4), // Shadow with light opacity
                          spreadRadius: 5,
                          blurRadius: 15,
                          offset: Offset(
                              0, 3), // Position the shadow slightly downward
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                            color: Color.fromARGB(255, 0, 119, 181),
                            size: 35,
                          ),
                          onPressed: () {
                            // Open Instagram profile
                          },
                        ),
                        IconButton(
                          icon: FaIcon(
                            FontAwesomeIcons.twitter,
                            color: Colors.blue,
                            size: 35,
                          ),
                          onPressed: () {
                            // Open Instagram profile
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(
                      color: Colors.orangeAccent,
                      thickness: 1,
                    ),
                  ),
                  SizedBox(height: 10),

                  //lower section

                  Text(
                    "Gallery",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 15),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio:
                          3 / 2, // Adjust the aspect ratio as needed
                    ),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      final postImages =
                          List<String>.from(post['post_media'] ?? []);

                      return Stack(
                        children: [
                          // Background Image Container
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PostDetails(
                                    postId: post['post_id'].toString(),
                                    userId: user_id,
                                  ), // Navigate to the PostDetails page
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 10,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: postImages.isNotEmpty &&
                                        postImages[0] != "No image"
                                    ? Image.network(
                                        postImages[0],
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        color: Colors.blue[300],
                                        child: Center(
                                          child: Icon(
                                            Icons.photo,
                                            size: 100,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ),

                          // Top Left: Views
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.visibility,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '${post['post_viewed']}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Top Right: Post Time
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    post['post_time'],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(
                                  width: 3,
                                ),
                                Container(
                                  //padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(60),
                                  ),
                                  child: PopupMenuButton<String>(
                                    icon: Icon(Icons.more_vert,
                                        color: Colors.white),
                                    color: Colors.black.withOpacity(0.8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(35),
                                    ),
                                    onSelected: (value) async {
                                      if (value == 'delete') {
                                        // Confirm delete action before making API call
                                        final confirmDelete = await showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text('Confirm Delete'),
                                            content: Text(
                                                'Are you sure you want to delete this post?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(false),
                                                child: Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(true),
                                                child: Text('Delete'),
                                              ),
                                            ],
                                          ),
                                        );

                                        // If confirmed, call deletePost()
                                        if (confirmDelete == true) {
                                          final result = await deletePost(
                                              post['post_id'].toString());

                                          if (result) {
                                            setState(() {
                                              posts.removeWhere((p) =>
                                                  p['post_id'] ==
                                                  post[
                                                      'post_id']); // remove post
                                            });
                                            // Show success message
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Post deleted successfully!')),
                                            );
                                          } else {
                                            // Show failure message
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      "Couldn't delete the post. Try again!")),
                                            );
                                          }
                                        }
                                      } else if (value == 'modify') {
                                        final post_images = List<String>.from(
                                            post['post_media'] ?? []);
                                        // Navigate to PostUpload screen
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PostUpload(
                                              postName: userName,
                                              postPhone: userPhone,
                                              postCategory: userCategory,
                                              postDescription:
                                                  post['post_description'],
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return [
                                        PopupMenuItem(
                                          value: 'modify',
                                          child: Center(
                                            child: Icon(Icons.edit,
                                                color: Colors.blueAccent),
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Center(
                                            child: Icon(Icons.delete,
                                                color: Colors.redAccent),
                                          ),
                                        ),
                                      ];
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),

                          // Floating Description above Icons
                          Positioned(
                            bottom:
                                55, // Positioned above the like/comment/share row
                            left: 10,
                            right: 10,
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Text(
                                post['post_description'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),

                          // Bottom: Like, Comment, Share Section
                          Positioned(
                            bottom: 10,
                            left: 10,
                            right: 10,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(25)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  // Like
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          //color: Colors.white.withOpacity(0.4),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.thumb_up,
                                          color: Colors.blue,
                                          size: 24,
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        '${post['post_liked']}',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Comment
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          //color: Colors.white.withOpacity(0.4),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.comment_rounded,
                                          color: Colors.orange,
                                          size: 24,
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        '${post['post_viewed']}', // Assuming a static comment count for now
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Share
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          //color: Colors.white.withOpacity(0.4),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.share,
                                          color: Colors.green,
                                          size: 24,
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        '${post['post_shared']}',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(
                    userName: userName,
                    userPhone: widget.userPhone,
                    userCategory: userCategory,
                    userDescription: userDescription,
                    userAddress: userAddress,
                  ),
                ),
              );

              if (result == true) {
                fetchUserData(); // Fetch updated data
              }
            },
            heroTag: "editProfile",
            backgroundColor: Colors.amber,
            child: Icon(
              Icons.edit,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostUpload(
                    postName: userName,
                    postPhone: widget.userPhone,
                    postCategory: userCategory,
                    postDescription: userDescription,
                  ),
                ),
              );

              if (result == true) {
                fetchUserData(); // Fetch updated data
              }
            }

            // Handle Upload Post button pressed
            ,
            heroTag: "uploadPost",
            backgroundColor: Colors.blue,
            child: Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
