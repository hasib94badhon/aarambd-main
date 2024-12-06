import 'package:flutter/material.dart';
import 'package:aaram_bd/config.dart';
import 'package:aaram_bd/screens/SignUp_screen.dart';
import 'package:aaram_bd/screens/login_screen.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUpScreen> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> addDataToDB() async {
    final String apiUrl = '$host/add';

    final Map<String, dynamic> requestData = {
      'name': _nameController.text,
      'phone': _phoneController.text,
      'password': _passwordController.text,
    };

    String jsonData = jsonEncode(requestData);
    print('Raw JSON Data: $jsonData');

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json;charset=UTF-8',
      },
      body: jsonData,
    );

    if (response.statusCode == 200) {
      print('Data added successfully');
      _showSuccessMessage();
    } else {
      print('Failed to add data: ${response.body}');
    }
  }

  void _showSuccessMessage() {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.greenAccent),
            SizedBox(width: 10),
            Text(
              'Registration Completed Successfully',
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
      ),
    );

    // Delay navigation until after the SnackBar is shown
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: _scaffoldMessengerKey,
      home: Scaffold(
        body: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                Image.asset(
                  'images/call1.png',
                  height: 150,
                ),
                SizedBox(height: 15),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Enter Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(14)),
                          ),
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Enter Number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(14)),
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
                            borderRadius: BorderRadius.all(Radius.circular(14)),
                          ),
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: Icon(Icons.remove_red_eye),
                        ),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          addDataToDB();
                        },
                        child: Text(
                          "Create Account",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size.fromHeight(60),
                          backgroundColor: Color.fromARGB(255, 30, 224, 208),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account ?",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontSize: 18,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(),
                                ),
                              );
                            },
                            child: Text(
                              "Login",
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
      ),
    );
  }
}

void main() {
  runApp(SignUpScreen());
}
