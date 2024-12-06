import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TermsPolicies extends StatefulWidget {
  @override
  _TermsPoliciesState createState() => _TermsPoliciesState();
}

class _TermsPoliciesState extends State<TermsPolicies> {
  String termsPolicy = "Loading terms and policies...";

  @override
  void initState() {
    super.initState();
    fetchTermsPolicy();
  }

  Future<void> fetchTermsPolicy() async {
    final String apiUrl =
        "http://your-api-host/get_terms_policy"; // Replace with your API host

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            termsPolicy = data['terms_policy'];
          });
        } else {
          setState(() {
            termsPolicy = "Failed to load terms and policies.";
          });
        }
      } else {
        setState(() {
          termsPolicy = "Error fetching terms and policies.";
        });
      }
    } catch (e) {
      setState(() {
        termsPolicy = "Something went wrong. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildGradientAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            termsPolicy,
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ),
      ),
    );
  }

  AppBar buildGradientAppBar() {
    return AppBar(
      title: Text('Terms & Policies'),
      centerTitle: true,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blueAccent,
              Colors.lightBlueAccent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }
}
