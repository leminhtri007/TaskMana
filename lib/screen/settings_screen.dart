import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test0/screen/myview/mydialog.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settingsScreen';
  // final User user;

  @override
  State<StatefulWidget> createState() {
    return _SettingsScreen();
  }
}

class _SettingsScreen extends State<SettingsScreen> {
  late _Controller con;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
        title: const Text('Setting screen'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 5, left: 20, right: 20),
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                // Text('Current User: ${widget.user.email}'),
                // //   style: TextStyle(
                // //     color: Colors.black,
                // //     fontSize: 20,
                // //   ),
                // // ),
                Text(
                  'Email will be sent shortly! Please Click on the link in your email to reset your password.',
                  style: TextStyle(
                    color: Colors.red[400],
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 20),
                Theme(
                  data: ThemeData(
                    hintColor: Colors.brown[300],
                  ),
                  child: TextFormField(
                    validator: con.validatorEmail,
                    style: TextStyle(color: Colors.brown[300]),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      fillColor: Colors.brown[100],
                      filled: true,
                      focusColor: Colors.brown[100],
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5, left: 20, right: 20),
                  child: ElevatedButton(
                    onPressed: con.sendEmail,
                    child: const Text(
                      'Send Email',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
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

class _Controller {
  late _SettingsScreen state;
  _Controller(this.state);
  String? email;

  String? validatorEmail(String? value) {
    if (value!.isEmpty || !value.contains('@') || !value.contains('.')) {
      return 'Invalid/Please Enter correct email address!';
    } else {
      email = value;
    }
    return null;
  }

  Future<void> sendEmail() async {
    try {
      if (state.formKey.currentState!.validate()) {
        FirebaseAuth.instance.sendPasswordResetEmail(email: email!).then(
              (value) => MyDialog.info(
                context: state.context,
                title: 'Email Sent!!',
                content: 'Please check your email. Thank you!',
              ),
            );
        //print('Email Sent! Please check your email')
      }
    } catch (e) {
      MyDialog.info(
        context: state.context,
        title: 'Error sending email',
        content: e.toString(),
      );
      return;
    }
  }
}
