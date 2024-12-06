import 'package:flutter/material.dart';
import 'package:aaram_bd/screens/otp_verify_screen.dart';

class OTPScreen extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              SizedBox(height: 10),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Forgot Password",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 60),
              Text(
                "Please enter your mobile number. You will receive a OTP to create or set a new password via nmobile number",
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Enter Number",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OTPVerifyScreen(),
                        ));
                  },
                  child: Text(
                    "Send Code",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        ),
                  ),
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size.fromHeight(60),
                      backgroundColor: Color.fromARGB(255, 30, 224, 208),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                ),
            ],
          ),
        ),
      ),
    );
  }
}