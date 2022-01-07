import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:test0/screen/sign_in.dart';
import 'package:test0/screen/signup_screen.dart';

class OnBoardingScreen extends StatelessWidget {
  static const routeName = '/onboardingScreen';
  @override
  Widget build(BuildContext context) => SafeArea(
        child: IntroductionScreen(
          pages: [
            PageViewModel(
              image: Image.asset('images/resetpass.png'),
              title: 'Welcome to TaskMana by DaBois',
              body: 'Rise up and Attack',
              decoration: getPageDecoration(),
            ),
            PageViewModel(
              title: 'Two-factor Authentification',
              body: 'Something you know, Something you have, Something you are',
              image: Image.asset('images/twofactor.png'),
              decoration: getPageDecoration(),
            ),
            PageViewModel(
              title: 'Create, View, and Edit Tasks',
              body: 'Somedays you just have to create your own sunshine.',
              image: Image.asset('images/task.png'),
              decoration: getPageDecoration(),
            ),
            PageViewModel(
              title: 'Vamos...',
              body: 'Start your journey',
              decoration: getPageDecoration(),
              image: Image.asset('images/signup.jpeg'),
            ),
          ],
          done: Text('Done',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontSize: 17)),
          onDone: () => Navigator.pushNamed(context, SignUpScreen.routeName),
          showSkipButton: true,
          skip: Text(
            'Skip',
            style: TextStyle(color: Colors.black, fontSize: 17),
          ),
          onSkip: () => Navigator.pushNamed(context, SignInScreen.routeName),
          next: Icon(
            Icons.arrow_forward,
            color: Colors.black,
          ),
          dotsDecorator: getDotDecoration(),
          // ignore: avoid_print
          onChange: (index) => print('Page $index selected'),
          globalBackgroundColor: Colors.white,
          skipFlex: 0,
          nextFlex: 0,
          // isProgressTap: false,
          // isProgress: false,
          // showNextButton: false,
          // freeze: true,
          // animationDuration: 1000,
        ),
      );
  DotsDecorator getDotDecoration() => DotsDecorator(
        color: Color(0xFFBDBDBD),
        //activeColor: Colors.orange,
        size: Size(10, 10),
        activeSize: Size(22, 10),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      );

  PageDecoration getPageDecoration() => PageDecoration(
        titleTextStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        bodyTextStyle: TextStyle(fontSize: 20),
        descriptionPadding: EdgeInsets.all(16).copyWith(bottom: 0),
        imagePadding: EdgeInsets.all(24),
        pageColor: Colors.white,
      );
}
