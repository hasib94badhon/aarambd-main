

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RecoveryScreen extends StatefulWidget {
  const RecoveryScreen({super.key});

  @override
  State<RecoveryScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<RecoveryScreen> {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              SizedBox(height: 10,),
              Text("Forgot Password",
                style: TextStyle(
                  fontSize: 40,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30,),
              Text(
                "Please enter your email address. You will receive a link to create or set a new password via email.",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10,),
              TextFormField(
                  
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                    ),
                    labelText: "Reset Code",
                    prefixIcon: Icon(Icons.lock),

                  )
              ),
              SizedBox(height: 10,),

              TextFormField(
                  
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                    ),
                    labelText: "New Password",
                    prefixIcon: Icon(Icons.lock),
                     suffix: Icon(Icons.remove_red_eye),

                  )
              ),
              SizedBox(height: 10,),
              TextFormField(
                  
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                    ),
                    labelText: "Confirm Password",
                    prefixIcon: Icon(Icons.lock),
                    suffix: Icon(Icons.remove_red_eye),
                  )
              ),
              SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (context) => HomePage(),
                    //     ));
                  },
                  child: Text(
                    "Reset Password",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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