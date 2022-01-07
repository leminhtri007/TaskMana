import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test0/screen/myview/mydialog.dart';

class HelpScreen extends StatefulWidget {
  static const routeName = '/helpScreen';
  // final User user;

  @override
  State<StatefulWidget> createState() {
    return _HelpScreen();
  }
}

class _HelpScreen extends State<HelpScreen> {
  late _Controller con;

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help screen'),
      ),
      // body: Padding(
      //   padding: const EdgeInsets.only(top: 5, left: 20, right: 20),
      //   child: Text(
      //     "Create An Account",
      //     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      //   ),
      // ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              children: <Widget>[
                Text(
                  'Welcome to Da Bois!',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ],
            ),
            SizedBox(height: 20),
            Wrap(
              children: <Widget>[
                Text(
                  'These Terms of Use govern your use of Da Bois and provide information about the Da Bois Service, outlined below. When you create an Da Bois account or use Da Bois, you agree to these terms. ',
                  style: Theme.of(context).textTheme.subtitle2,
                  overflow: TextOverflow.clip,
                ),
              ],
            ),
            SizedBox(height: 19),
            Wrap(
              children: <Widget>[
                Text('Create An Account',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 19),
            Wrap(
              children: <Widget>[
                Text(
                  "1. Tap 'Sign Up Here' link on the initial Sign in Page. \n "
                  "2. Enter your Email Address. \n"
                  '3. Enter your Password \n'
                  '4. Conform your Password \n'
                  '5. Tap Sign Up',
                  style: Theme.of(context).textTheme.subtitle2,
                  overflow: TextOverflow.clip,
                ),
              ],
            ),
            SizedBox(height: 20),
            Wrap(
              children: <Widget>[
                Text('Add a New Task',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 10),
            Wrap(
              children: <Widget>[
                Text(
                  "1. Tap '+' on the home Page. \n "
                  "2. Enter a Tittle. \n"
                  '3. Enter a description \n'
                  '4. Enter a description \n'
                  '5. Choose a category \n'
                  '6. Select a Due date \n'
                  '7. Select Completion time \n'
                  '8. Tap Create on the top right hand corner',
                  style: Theme.of(context).textTheme.subtitle2,
                  overflow: TextOverflow.clip,
                ),
              ],
            ),
            SizedBox(height: 20),
            Wrap(
              children: <Widget>[
                Text('Reset new Password',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 10),
            Wrap(
              children: <Widget>[
                Text(
                  "1. Tap ' ≡ ' on the home Page. \n "
                  "2. Tap on Settings. \n"
                  "3. Tap on Reset Password \n"
                  '4. Enter your current email address \n'
                  '5. Tap send Email button \n'
                  '6. Follow the directions on your email to reset your password \n'
                  "7. Tap '✎' to save settings \n",
                  style: Theme.of(context).textTheme.subtitle2,
                  overflow: TextOverflow.clip,
                ),
              ],
            ),
            SizedBox(height: 20),
            Wrap(
              children: <Widget>[
                Text('The Data Policy',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 10),
            Wrap(
              children: <Widget>[
                Text(
                  'Providing our Service requires collecting and using your information. The Data'
                  'Policy explains how we collect, use, and share information across other Products. You must agree to the Data Policy to use Da Bois. ',
                  style: Theme.of(context).textTheme.subtitle2,
                  overflow: TextOverflow.clip,
                ),
              ],
            ),
            SizedBox(height: 20),
            Wrap(
              children: <Widget>[
                Text('Your Commitments',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 10),
            Wrap(
              children: <Widget>[
                Text(
                  'In return for our commitment to provide the Service, we require you to make the below commitments to us.',
                  style: Theme.of(context).textTheme.subtitle2,
                  overflow: TextOverflow.clip,
                ),
              ],
            ),
            SizedBox(height: 10),
            Wrap(
              children: <Widget>[
                Text(
                  'Who Can Use Da Bois. We want our Service to be as open and inclusive as possible, but we also want it to be safe,'
                  'secure, and in accordance with the law. So, we need you to commit to a few restrictions in order to be part of the Da Bois'
                  'community. You must be at least 13 years old. You must not be prohibited from receiving any aspect of our Service under'
                  'applicable laws or engaging in payments related Services if you are on an applicable denied party listing.'
                  'We must not have previously disabled your account for violation of law or any of our policies. You must not be a convicted sex offender.',
                  style: Theme.of(context).textTheme.subtitle2,
                  overflow: TextOverflow.clip,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Controller {
  late _HelpScreen state;
  _Controller(this.state);
}
