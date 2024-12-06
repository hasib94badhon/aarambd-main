import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:aaram_bd/pages/Homepage.dart';
import 'package:aaram_bd/screens/login_screen.dart';

class Onboarding extends StatelessWidget {
  final introKey = GlobalKey<IntroductionScreenState>();

  @override
  Widget build(BuildContext context) {
    final pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
      ),
      bodyTextStyle: TextStyle(fontSize: 19),
      bodyPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );
    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: Colors.white,
      pages: [
        PageViewModel(
          title: 'Welcome To \n AaramBD ',
          
          body:
              "Alone we can do so little; together we can do so much.",
          image: Image.asset(
            'images/call1.png',
            width: 200,
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: 'Connect to your nearest one',
          body:
              "Coming together is a beginning, staying together is progress, and working together is success.",
          image: Image.asset(
            'images/call2.png',
            width: 200,
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: 'Create Your own shop',
          body:
              "Entrepreneurship is living a few years of your life like most people won't, so that you can spend the rest of your life like most people can't.",
          image: Image.asset(
            'images/call3.png',
            width: 200,
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
            title: 'Create your own comfort',
            body:
                "The greatest gift you can give someone is your time because when you give your time, you are giving a portion of your life that you will never get back.",
            image: Image.asset(
              'images/call4.png',
              width: 200,
            ),
            decoration: pageDecoration,
            footer: Padding(
              padding: EdgeInsets.only(left: 15, right: 15,top:40),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoginScreen(),
            ));
                  
                },
                child: Text(
                  "Let's Start ",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                    minimumSize: Size.fromHeight(60),
                    backgroundColor: Color(0xFF5866E6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
              ),
            )),
      ],
      showSkipButton: false,
      showDoneButton: false,
      showBackButton: true,
      back: Text("back",
          style:
              TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF5866E6))),
      next: Text(
        "Next",
        style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF5866E6)),
      ),
      onDone: () {},
      onSkip: () {},
      dotsDecorator: DotsDecorator(
          size: Size.square(10),
          activeSize: Size(20, 10),
          activeColor: Color(0xFF5866E6),
          color: Colors.black26,
          spacing: EdgeInsets.symmetric(horizontal: 3),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          )),
    );
  }
}
