import 'package:flutter/material.dart';
import 'package:aaram_bd/screens/post_details.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdatePost extends StatelessWidget {
  final List<dynamic> posts;

  UpdatePost({required this.posts});

  // Method to retrieve user_id from SharedPreferences
  Future<String?> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id'); // Get the stored user_id
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
        future:
            _getUserId(), // Call the method to get user_id from SharedPreferences
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error retrieving user ID"));
          } else {
            final userId = snapshot.data;
            print(userId);
            // User ID from SharedPreferences
            return Scaffold(
              appBar: AppBar(
                title: Text('To-Day Live'),
              ),
              body: ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return Container(
                    margin:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green,
                          blurRadius: 6.0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Stack(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PostDetails(
                                    postId: post['post_id'].toString(),
                                    userId: userId.toString(),
                                  ), // Navigate to the PostDetails page
                                ),
                              );
                            },
                            child: Container(
                              child: Image.network(
                                post['photo'],
                                width: double.infinity,
                                height: 250,
                                fit: BoxFit.fitWidth,
                                errorBuilder: (context, error, stackTrace) {
                                  // This widget is shown if the image fails to load
                                  return Image.network(
                                    'https://via.placeholder.com/1000?text=No Image Found', // Fallback image URL
                                    width: double.infinity,
                                    height: 250,
                                    fit: BoxFit.fitWidth,
                                  );
                                },
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8.0,
                            left: 8.0,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6.0, vertical: 2.0),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.visibility,
                                      color: Colors.white, size: 20),
                                  SizedBox(width: 4.0),
                                  Text('${post['view']}',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18)),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8.0,
                            right: 8.0,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6.0, vertical: 2.0),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text('${post['time']}',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18)),
                            ),
                          ),
                          Positioned(
                            bottom: 48.0,
                            left: 8.0,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6.0, vertical: 2.0),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${post['name']}',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22),
                                  ),
                                  Text(
                                    '${post['category']}',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${post['description']}',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 17),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8.0,
                            left: 8.0,
                            right: 8.0,
                            child: Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.phone, color: Colors.white),
                                      SizedBox(width: 4.0),
                                      Text('${post['phone']}',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 17)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.thumb_up, color: Colors.white),
                                      SizedBox(width: 4.0),
                                      Text('${post['like']}',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.share, color: Colors.white),
                                      SizedBox(width: 4.0),
                                      Text('${post['share']}',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ],
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
            );
          }
        });
  }
}
