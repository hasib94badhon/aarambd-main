import 'package:aaram_bd/widgets/AppDrawer.dart';
import 'package:flutter/material.dart';
import 'package:aaram_bd/pages/ServiceCart.dart';
import 'package:aaram_bd/pages/cartPage.dart';
import 'package:aaram_bd/screens/login_screen.dart';
import 'package:aaram_bd/pages/ShopsCart.dart';
import 'package:aaram_bd/screens/user_profile.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:aaram_bd/config.dart';

class NavigationScreen extends StatefulWidget {
  final String userPhone;

  NavigationScreen({required this.userPhone});

  @override
  State<NavigationScreen> createState() =>
      _NavigationScreenState(userPhone: userPhone);
}

class _NavigationScreenState extends State<NavigationScreen> {
  final String userPhone;
  _NavigationScreenState({required this.userPhone});

  int pageIndex = 0;

  late List<Widget> pages;

  // List of keys to manage page state refresh
  List<UniqueKey> pageKeys = [
    UniqueKey(),
    UniqueKey(),
    UniqueKey(),
    UniqueKey(),
  ];

  // Pages data storage after fetching from API
  dynamic cartData;
  dynamic serviceData;
  dynamic shopData;
  dynamic userData;

  @override
  void initState() {
    super.initState();
    pages = [
      CartPage(
        key: pageKeys[0],
        userPhone: userPhone,
        data: cartData,
      ),
      ServiceCart(
          key: pageKeys[1],
          dataa:
              serviceData), // Assuming this screen doesn't need the phone number
      ShopsCart(
          dataa: shopData,
          key: pageKeys[
              2]), // Assuming this screen doesn't need the phone number
      UserProfile(userPhone: userPhone, key: pageKeys[3], userData: userData),
    ];
    fetchPageData(0); // Initial page data fetching for CartPage
  }

  // Function to fetch API data based on the page index
  void fetchPageData(int index) async {
    switch (index) {
      case 0:
        final response =
            await http.get(Uri.parse('$host/get_combined_data'));
        if (response.statusCode == 200) {
          setState(() {
            cartData = response.body; // Update the CartPage data
          });
        }
        break;
      case 1:
        final response = await http.get(Uri.parse('$host/get_service_data'));
        if (response.statusCode == 200) {
          setState(() {
            serviceData = response.body; // Update the ServiceCart data
          });
        }
        break;
      case 2:
        final response = await http.get(Uri.parse('$host/get_shops_data'));
        if (response.statusCode == 200) {
          setState(() {
            shopData = response.body; // Update the ShopsCart data
          });
        }
        break;
      case 3:
        final response = await http
            .get(Uri.parse('$host/get_user_by_phone?phone=$userPhone'));
        if (response.statusCode == 200) {
          setState(() {
            userData = response.body; // Update the UserProfile data
          });
        }
        break;
    }
  }

  void onTapNavigation(int index) {
    if (index == pageIndex) {
      // If the same tab is tapped, refresh the current page
      refreshPage(index);
    } else {
      // If a different tab is tapped, switch to the new page and fetch data
      setState(() {
        pageIndex = index;
        fetchPageData(index); // Fetch API data for the newly selected page
      });
    }
  }

  void refreshPage(int index) {
    setState(() {
      // Update the key for the selected page to force a rebuild/refresh
      pageKeys[index] = UniqueKey();
      fetchPageData(index); // Refresh data by hitting API again
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //backgroundColor: Colors.lightBlue,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        leading: Builder(
    builder: (context) {
      return IconButton(
        icon: Icon(Icons.home, size: 30), // Custom size
        color: Colors.white, // Custom color
        onPressed: () {
          Scaffold.of(context).openDrawer(); // Open the drawer
        },
      );
    },
  ),
        titleSpacing: 2,
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                // Action to refresh the app
                setState(() {
                  // Code to refresh the app
                });
              },
              child: Stack(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'A',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          foreground: Paint()
                            ..shader = LinearGradient(
                              colors: [Colors.orange, Colors.white],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(
                                Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                          shadows: [
                            Shadow(
                              offset: Offset(3.0, 3.0),
                              blurRadius: 6.0,
                              color: Colors.black45,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'a',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(1.0, 1.0),
                              blurRadius: 5.0,
                              color: Colors.orangeAccent,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'r',
                        style: TextStyle(
                          fontSize: 34,
                          fontStyle: FontStyle.italic,
                          color: Colors.orange,
                          shadows: [
                            Shadow(
                              offset: Offset(-2.0, 2.0),
                              blurRadius: 4.0,
                              color: Colors.black26,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'a',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange[700],
                          shadows: [
                            Shadow(
                              offset: Offset(2.0, 2.0),
                              blurRadius: 3.0,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'm',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          foreground: Paint()
                            ..shader = LinearGradient(
                              colors: [Colors.white, Colors.orangeAccent],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ).createShader(
                                Rect.fromLTWH(0.0, 0.0, 100.0, 50.0)),
                          shadows: [
                            Shadow(
                              offset: Offset(4.0, 4.0),
                              blurRadius: 5.0,
                              color: Colors.black38,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'B',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          foreground: Paint()
                            ..shader = LinearGradient(
                              colors: [Colors.orange[600]!, Colors.white],
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                            ).createShader(
                                Rect.fromLTWH(0.0, 0.0, 100.0, 50.0)),
                          shadows: [
                            Shadow(
                              offset: Offset(3.0, 3.0),
                              blurRadius: 6.0,
                              color: Colors.black45,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'D',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          foreground: Paint()
                            ..shader = LinearGradient(
                              colors: [Colors.white, Colors.orange[300]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(
                                Rect.fromLTWH(0.0, 0.0, 100.0, 50.0)),
                          shadows: [
                            Shadow(
                              offset: Offset(2.0, 2.0),
                              blurRadius: 5.0,
                              color: Colors.black26,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Spacer(),
            // Spacer to push the logout icon to the right
            // Logout Icon
            Stack(
  children: [
    Container(
      margin: EdgeInsets.only(right: 5),
      child: Icon(
        Icons.notifications_none_sharp,
        color: Colors.white,
        size: 35,
      ),
    ),
    Positioned(
      right: 0,
      bottom: 0,
      child: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
        constraints: BoxConstraints(
          minWidth: 20,
          minHeight: 20,
        ),
        child: Text(
          '0', // Default notification count
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ),
  ],
),
SizedBox(width: 10,),


            pageIndex == 3 // Show only on the profile page (pageIndex == 3)
                ? Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black, Colors.yellowAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(65),
                      ),
                    ),
                    child: IconButton(
                        icon: Icon(Icons.logout_rounded,
                            color: Colors.white, size: 30),
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.remove('userPhone');
                          await prefs.setBool('isLoggedIn', false);

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()),
                            (Route<dynamic> route) => false,
                          );
                        }),
                  )
                : SizedBox(), //
          ],
        ),
      ),
      drawer: AppDrawer(
        userPhone: userPhone,
      ),
      body: IndexedStack(
        index: pageIndex,
        children: pages,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: AnimatedBottomNavigationBar(
          height: 60,
          activeColor: Colors.white,
          inactiveColor: Colors.black,
          iconSize: 35,
          backgroundColor: Colors.transparent, // Transparent to show gradient
          icons: [
            Icons.dashboard_outlined, // Service and Shops
            Icons.engineering_rounded, // Service
            Icons.view_carousel_rounded, // Shops
            Icons.person, // User Account
          ],
          activeIndex: pageIndex,
          gapLocation: GapLocation.none,
          notchSmoothness: NotchSmoothness.softEdge,
          leftCornerRadius: 10,
          elevation: 8,
          onTap: (index) {
            if (index == pageIndex) {
              // If the same tab is tapped, refresh the current page
              refreshPage(index);
            } else {
              // If a different tab is tapped, simply switch to the new page
              setState(() {
                pageIndex = index;
              });
            }
          },
        ),
      ),
    );
  }
}
