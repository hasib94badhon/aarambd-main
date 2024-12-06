import 'dart:convert';
import 'dart:async';
import 'package:aaram_bd/config.dart';
import 'package:flutter/material.dart';
import 'package:aaram_bd/screens/signup_screen.dart';
import 'package:aaram_bd/screens/forgot_screen.dart';
import 'package:aaram_bd/screens/navigation_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;

  Future<void> loginUser() async {
    final String apiUrl = '$host/login';

    final Map<String, dynamic> requestData = {
      'phone': _phoneController.text,
      'password': _passwordController.text,
    };
    print("Request Data: $requestData");

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestData),
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final userPhone = responseData['user']['phone'];
        final userId = responseData['user']['user_id']
            .toString(); // Get user_id from response

        ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.greenAccent),
                SizedBox(width: 10),
                Text(
                  'Login Successful',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.black87,
            behavior: SnackBarBehavior.floating,
            elevation: 6.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            duration: Duration(seconds: 3),
            animation: CurvedAnimation(
              parent: AnimationController(
                duration: const Duration(seconds: 2),
                vsync: _scaffoldKey.currentState!,
              ),
              curve: Curves.easeOut,
            ),
          ),
        );

        // Save login state in shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userPhone', userPhone);
        await prefs.setString('user_id', userId).toString(); // Save user_id

        // Delay to ensure the context is ready before navigating
        Future.delayed(Duration(milliseconds: 500), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => NavigationScreen(userPhone: userPhone)),
          );
        });
      } else {
        _showErrorDialog('Failed to login. Please check your credentials.');
      }
    } catch (e) {
      print("Exception: $e");
      _showErrorDialog('An unexpected error occurred. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        alignment: Alignment.center,
        backgroundColor: Colors.transparent,
        content: Container(
          padding: EdgeInsets.all(16.0),
          width: 350,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.all(Radius.circular(32.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black54,
                offset: Offset(0, 6),
                blurRadius: 10.0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 40,
              ),
              SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('images/call1.png'),
                    SizedBox(height: 0),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        children: [
                          TextField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              labelText: 'Enter Number',
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(14)),
                              ),
                              prefixIcon: Icon(Icons.numbers),
                            ),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Enter Password',
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(14)),
                              ),
                              prefixIcon: Icon(Icons.lock),
                              suffixIcon: Icon(Icons.remove_red_eye),
                            ),
                          ),
                          SizedBox(height: 15),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ForgotScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                "Forgot Password",
                                style: TextStyle(
                                  color: Colors.blue.shade800,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                          ElevatedButton(
                            onPressed: loginUser,
                            child: Text(
                              "Log In",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size.fromHeight(60),
                              backgroundColor:
                                  Color.fromARGB(255, 30, 224, 208),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Text("OR"),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account?",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  fontSize: 15,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SignUpScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
