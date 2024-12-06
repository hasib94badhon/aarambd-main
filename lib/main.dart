import 'package:flutter/material.dart';
import 'config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aaram_bd/screens/login_screen.dart';
import 'package:aaram_bd/screens/navigation_screen.dart';
import 'package:aaram_bd/screens/splash_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      home: InitialScreen(),
    );
  }
}

class InitialScreen extends StatefulWidget {
  @override
  _InitialScreenState createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  @override
  void initState() {
    super.initState();
    _navigateBasedOnState();
  }

  Future<void> _navigateBasedOnState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String userPhone = prefs.getString('userPhone') ?? '';

    print("from main.dart userphone $userPhone");

    if (isFirstTime) {
      prefs.setBool('isFirstTime', false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SplashScreen()),
      );
    } else if (isLoggedIn && userPhone.isNotEmpty) {
      // Check if the phone exists in the database
      final bool phoneExists = await _checkPhoneInDatabase(userPhone);
      if (phoneExists) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => NavigationScreen(userPhone: userPhone)),
        );
      } else {
        // If phone number is not found in the database, log out the user
        await prefs.setBool('isLoggedIn', false);
        await prefs.remove('userPhone');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  Future<bool> _checkPhoneInDatabase(String phone) async {
    final String apiUrl = '$host/check_phone'; // Updated API endpoint
    final Map<String, dynamic> requestData = {
      'phone': phone,
      'password': 'dummy_password' // Update as necessary
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData[
            'exists']; // Assumes the API returns a JSON object with an 'exists' boolean field
      } else {
        return false;
      }
    } catch (e) {
      print("Exception: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
