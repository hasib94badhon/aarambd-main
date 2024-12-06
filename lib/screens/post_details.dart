import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:aaram_bd/config.dart'; // Adjust as necessary for your project

class PostDetails extends StatefulWidget {
  final String postId;
  final String userId;
  final Key? key;

  PostDetails({required this.postId, required this.userId, this.key})
      : super(key: key);

  @override
  State<PostDetails> createState() =>
      _PostDetailsState(postId: postId, userId: userId);
}

class _PostDetailsState extends State<PostDetails> {
  TextEditingController commentController = TextEditingController();
  final String userId;
  final String postId;
  _PostDetailsState({required this.postId, required this.userId});

  String postDescription = "Post Description";
  String postMedia = "";
  String userName = "User Name";
  String profilePic = "";
  String userCategory = "Category";
  int postLiked = 0;
  int postViewed = 0;
  int postShared = 0;
  String postTime = '';
  List<dynamic> comments = [];

  @override
  void initState() {
    super.initState();
    fetchPostData();
    fetchComments(); // Fetch comments for the post
  }

  Future<void> submitComment(String commentText) async {
    print("Submitting comment: $commentText"); // Debug print
    final response = await http.post(
      Uri.parse('$host/submit_comment?com_user_id=$userId'),
      body: json.encode({
        'post_id': postId,
        'com_text': commentText,
        'com_user_id': userId, // Replace with actual user ID
      }),
      headers: {
        "Content-Type":
            "application/json", // This should be correctly set for JSON
      },
    );

    if (response.statusCode == 201) {
      print("Comment submitted successfully");
    } else {
      print("Failed to submit comment: ${response.statusCode}");
      print("Response body: ${response.body}"); // Debugging response body
    }
  }

  Future<void> fetchComments() async {
    print("Fetching comments for postId: $postId");
    final response = await http.get(
      Uri.parse('$host/get_comments?post_id=$postId'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      print("Fetched comments: $data");

      setState(() {
        comments = data['comments'];
      });
    } else {
      // Handle the error
      print("Failed to fetch comments: ${response.statusCode}");
    }
  }

  Future<void> fetchPostData() async {
    print("Fetching post data for postId: $postId");

    try {
      final response =
          await http.get(Uri.parse('$host/get_post?post_id=$postId'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Log the entire response body to check its structure
        print("Fetched post data: $data");
        setState(() {
          postDescription =
              data['post']['post_des'] ?? "No description available";
          postMedia = data['post']['post_media'] ?? "";
          userName = data['post']['user_name'] ?? "No name available";
          userCategory = data['post']['cat_name'] ?? "No category available";
          profilePic = data['post']['user_photo'];

          postLiked = data['post']['post_liked'] ?? 0;
          postViewed = data['post']['post_viewed'] ?? 0;
          postShared = data['post']['post_shared'] ?? 0;
          postTime = data['post']['post_time'] ?? '';
        });
      } else {
        print("Failed to fetch post data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching post data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Details'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 100),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Profile Section
                  Row(
                    children: [
                      // Profile Picture with border and shadow
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.blueAccent,
                              width: 3), // Border color and width
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 5,
                              offset: Offset(0, 3), // Shadow position
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius:
                              50, // Increased radius for a bigger profile picture
                          backgroundImage: profilePic.isNotEmpty
                              ? NetworkImage(profilePic)
                              : AssetImage('assets/images/default_profile.png')
                                  as ImageProvider,
                        ),
                      ),
                      SizedBox(
                          width:
                              15), // More spacing between profile picture and text
                      // User name and category section
                      Expanded(
                        // To prevent overflow
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // User Name
                            Text(
                              userName,
                              //textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize:
                                    20, // Slightly larger font for the name
                                fontWeight: FontWeight.bold,
                              ),
                              //overflow: TextOverflow.ellipsis, // Handle long names
                            ),
                            SizedBox(
                                height:
                                    5), // Small spacing between name and category
                            // User Category
                            Text(
                              userCategory,
                              style: TextStyle(
                                fontSize: 16, // Larger font for the category
                                fontWeight: FontWeight.w600,
                                color: Colors
                                    .blueAccent, // Make category color stand out
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10),

                  // Post Description
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        colors: [Colors.white12, Colors.white54],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Text(
                      postDescription,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Post Image
                  postMedia.isNotEmpty
                      ? Container(
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.black),
                            borderRadius: BorderRadius.circular(35),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(35),
                            child: Image.network(
                              postMedia,
                              height: 250,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // In case there's an issue with loading the image
                                return SizedBox(); // This will hide the widget if the image fails to load.
                              },
                            ),
                          ),
                        )
                      : SizedBox(), // This will hide the section entirely if `postMedia` is empty.

                  SizedBox(height: 6),

                  // Interaction buttons (Like, Share, Comments)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.thumb_up_alt_rounded,
                            color: Colors.blue),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(Icons.share, color: Colors.green),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(Icons.comment, color: Colors.orange),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  Divider(thickness: 1.5),

                  // Comment Section Header
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        'Comments',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  /// List of Comments
                  Column(
                    children: comments.isNotEmpty
                        ? comments
                            .map((comment) => _buildComment(comment))
                            .toList()
                        : [Text('No comments available')],
                  ),
                ],
              ),
            ),
          ),

          // Comment Input Box - pinned to the bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                color: Colors.white,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      // backgroundImage:
                      //     AssetImage('assets/images/default_profile.png'),
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        controller:
                            commentController, // Add this to bind the TextField
                        decoration: InputDecoration(
                          hintText: 'Write a comment...',
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: Colors.grey[400]!),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send, color: Colors.blueAccent),
                      onPressed: () async {
                        if (commentController.text.isNotEmpty) {
                          await submitComment(commentController
                              .text); // Function to submit the comment
                          commentController.clear();
                          fetchComments(); // Refresh the comments after posting
                        } else {
                          print(
                              "Comment is empty"); // Add this to ensure the input is not empty
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget for Each Comment
  Widget _buildComment(dynamic comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
              radius: 20, backgroundImage: NetworkImage(comment['photo'])),
          SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment['commenter_name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    comment['com_text'],
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
