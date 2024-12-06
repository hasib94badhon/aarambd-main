import 'package:aaram_bd/widgets/FloatingPage.dart';
import 'package:aaram_bd/config.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'MostUsedCategoriesPage.dart';
import 'UpdatePost.dart'; // Import the new widget
import 'FbPage.dart';
import 'package:aaram_bd/widgets/termsPolicies.dart';

class AppDrawer extends StatefulWidget {
  final String userPhone;

  AppDrawer({
    required this.userPhone,
  });

  @override
  _AppDrawerState createState() => _AppDrawerState(userPhone: userPhone);
}

class _AppDrawerState extends State<AppDrawer> {
  final String userPhone;
  int _selectedIndex = -1;
  String userName = "";
  String userPhotoUrl = 'https://www.example.com/profile_picture.jpg';
  String userMobile = "+880123456789";

  _AppDrawerState({required this.userPhone});
  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final response = await http.get(
      Uri.parse('$host/get_user_by_phone?phone=$userPhone'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        userName = data['name'] ?? "User Name";
        userPhotoUrl = data['photo'];
        userMobile = userPhone; // Or fetch from data if available
      });
    } else {
      // Handle the error
      print("Failed to fetch user data: ${response.statusCode}");
    }
  }

  Future<void> fetchMostUsedCategory() async {
    final response = await http.get(
      Uri.parse('$host/get_most_used_category'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MostUsedCategoriesPage(
            categories: data['most_used_cat'],
          ),
        ),
      );
    } else {
      // Handle the error
      print("Failed to fetch most used category data: ${response.statusCode}");
    }
  }

  Future<void> mostUpdatePost() async {
    final response = await http.get(
      Uri.parse('$host/get_today_post'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => UpdatePost(
            posts: data['most_update_post'],
          ),
        ),
      );
    } else {
      // Handle the error
      print("Failed to fetch most used category data: ${response.statusCode}");
    }
  }

  Future<void> fb_page() async {
    final response = await http.get(
      Uri.parse('$host/get_fb_page'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => FbPage(
            pages: data['fb_page'],
          ),
        ),
      );
    } else {
      // Handle the error
      print("Failed to fetch most used category data: ${response.statusCode}");
    }
  }

  void _onItemTap(int index, String title, String content) {
    setState(() {
      _selectedIndex = index;
    });

    Navigator.pop(context);

    if (title == 'Daily Use') {
      fetchMostUsedCategory();
    } else if (title == 'To-day Live') {
      mostUpdatePost();
    } else if (title == 'Business') {
      fb_page();
    } else if (title == "Terms and policies") {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => TermsPolicies(),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => FloatingPage(
            title: title,
            content: content,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black26,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // Account description container
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black26, Colors.black38],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 15,
                  spreadRadius: 5,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Profile picture
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.network(
                      userPhotoUrl, // Replace with your image URL
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  userName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // Divider between account section and menu items

          // Drawer menu items
          _createDrawerItem(
            icon: Icons.home,
            text: 'Daily Use',
            index: 0,
            title: 'Daily Use',
            content: 'Content for Daily Use',
            textSize: 16,
          ),
          _createDrawerItem(
            icon: Icons.shopping_cart,
            text: 'Social Apps',
            index: 1,
            title: 'Social Market',
            content: 'Content for Social Market',
            textSize: 16,
          ),
          _createDrawerItem(
            icon: Icons.business,
            text: 'Business',
            index: 5,
            title: 'Business',
            content: 'Content for Business',
            textSize: 16,
          ),
          _createDrawerItem(
            icon: Icons.live_tv,
            text: 'To-day Live',
            index: 2,
            title: 'To-day Live',
            content: 'Content for To-day Live',
            textSize: 16,
          ),
          
          _createDrawerItem(
            icon: Icons.phone,
            text: 'Hotline Numbers',
            index: 4,
            title: 'Emergency Contacts',
            content: 'Content for Emergency Contacts',
            textSize: 16,
          ),
          _createDrawerItem(
            icon: Icons.contacts,
            text: 'My Contacts',
            index: 3,
            title: 'My Contacts',
            content: 'Content for My Contacts',
            textSize: 16,
          ),
          
          _createDrawerItem(
            icon: Icons.group,
            text: 'Collaborators',
            index: 6,
            title: 'Collaborators',
            content: 'Content for Collaborators',
            textSize: 16,
          ),
          _createDrawerItem(
            icon: Icons.contact_mail,
            text: 'Contact AaramBD',
            index: 7,
            title: 'Contact AaramBD',
            content: 'Content for Contact AaramBD',
            textSize: 16,
          ),
          _createDrawerItem(
            icon: Icons.policy,
            text: 'Terms and policies',
            index: 8,
            title: 'Terms and policies',
            content: 'Content for Terms and policies',
            textSize: 16,
          ),
          
          _createDrawerItem(
            icon: Icons.more,
            text: 'More',
            index: 9,
            title: 'More',
            content: 'Content for More',
            textSize: 16,
          ),
          
          Divider(
            color: Colors.black,
            height: 10,
          ),
        ],
      ),
    );
  }

  Widget _createDrawerItem({
    required IconData icon,
    required String text,
    required int index,
    required String title,
    required String content,
    required double textSize,
  }) {
    return Container(
      margin: EdgeInsets.only(left: 6, right: 6, bottom: 5),
      decoration: BoxDecoration(
        color: _selectedIndex == index ? Colors.green[300] : Colors.black45,
        border: Border.all(width: 1),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            offset: const Offset(
              5.0,
              5.0,
            ),
            blurRadius: 10.0,
            spreadRadius: 1.0,
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          icon,
          size: 30,
          color: Colors.white,
        ),
        title: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: textSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () => _onItemTap(index, title, content),
      ),
    );
  }
}
