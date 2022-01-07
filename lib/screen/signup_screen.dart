import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test0/controller/firebasecontroller.dart';
import 'package:test0/model/constant.dart';
import 'package:test0/model/profile.dart';
import 'package:test0/screen/myview/mydialog.dart';
import 'package:test0/screen/sign_in.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = '/signupScreen';

  @override
  State<StatefulWidget> createState() {
    return _SignUpState();
  }
}

class _SignUpState extends State<SignUpScreen> {
  late _Controller con;
  GlobalKey<FormState> formkey = GlobalKey();
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
        title: Text('Sign Up'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formkey,
          child: Column(
            children: [
              Text(
                'Create an account',
                style: Theme.of(context).textTheme.headline5,
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Email',
                ),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                validator: con.validateEmail,
                onSaved: con.saveEmail,
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Password',
                ),
                obscureText: true,
                autocorrect: false,
                validator: con.validatePassword,
                onSaved: con.savePassword,
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Password confirm',
                ),
                autocorrect: false,
                obscureText: true,
                validator: con.validatePassword,
                onSaved: con.saveConfirmPassword,
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Name',
                ),
                autocorrect: false,
                validator: con.validateName,
                onSaved: con.saveName,
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Age',
                ),
                autocorrect: false,
                validator: con.validateAge,
                onSaved: con.saveAge,
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Phone Number',
                ),
                autocorrect: false,
                validator: con.validatePhone,
                onSaved: con.savePhone,
              ),
              ElevatedButton(
                  onPressed: con.signUp,
                  child: Text(
                    'Sign up',
                    style: Theme.of(context).textTheme.button,
                  )),
              Center(
                child: InkWell(
                  child: Tooltip(
                    message: "Tap Sign In!",
                    child: Text(
                      'Already have an account? Sign In Here!',
                      style: TextStyle(
                        color: Colors.blue[900],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () =>
                      Navigator.pushNamed(context, SignInScreen.routeName),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Controller {
  late _SignUpState state;

  String? email;
  String? password;
  String? passwordConfirm;
  String? name;
  int? age;
  String? phone;
  Profile? tempProfile = Profile();

  _Controller(this.state);

  void signUp() async {
    FormState? currentState = state.formkey.currentState;
    if (currentState == null || !currentState.validate()) return;
    currentState.save();

    if (password != passwordConfirm) {
      MyDialog.showSnackBar(
          context: state.context,
          message: 'Passwords do not match',
          seconds: 15);
      return;
    }
    try {
      MyDialog.circularProgressStart(state.context);
      FirebaseController.createAccount(
          email: email!, password: password!, name: name!);

      tempProfile!.email = email!;
      tempProfile!.password = password!;
      tempProfile!.name = name!;
      tempProfile!.phone = phone!;
      tempProfile!.age = age!;
      // tempProfile!.docId = profileDocId;
      // print("docid: ${profileDocId}");
      String? userId =
          await FirebaseController.getUIDProfile(email: tempProfile!.email);
      print("UID: ${userId}");
      FirebaseController.addUserInfo(tempProfile!);

      String profileDocId =
          await FirebaseController.getDocID(uid: tempProfile!.uid);
      Map<String, dynamic> updateInfo = {};
      //tempProfile!.uid = userId!;
      tempProfile!.docId = profileDocId;
      print("UIDaaaaaa: ${tempProfile!.uid}");
      updateInfo[Profile.EMAIL] = tempProfile!.email;
      updateInfo[Profile.NAME] = tempProfile!.name;
      updateInfo[Profile.PHONE] = tempProfile!.phone;
      updateInfo[Profile.AGE] = tempProfile!.age;
      updateInfo[Profile.UID] = tempProfile!.uid;
      updateInfo[Profile.DOCID] = tempProfile!.docId;

      FirebaseController.updateProfileInfo(tempProfile!.docId, updateInfo);

      MyDialog.circularProgressStop(state.context);
      Navigator.pop(state.context);
      MyDialog.showSnackBar(
        context: state.context,
        message: 'Account Created! Sign in to use the app',
      );
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      if (Constant.DEV) print('====== create account error: $e');
      MyDialog.showSnackBar(
        context: state.context,
        message: 'can not  create account:$e',
      );
    }
  }

  String? validateEmail(String? value) {
    if (value == null || !(value.contains('.') && value.contains('@')))
      return 'Invalid Email address';
    else
      return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.length < 6)
      return 'password too short';
    else
      return null;
  }

  String? validateName(String? value) {
    if (value == null)
      return 'Please enter your name';
    else
      return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.length < 10)
      return 'Invalid phone number';
    else
      return null;
  }

  String? validateAge(String? value) {
    if (value == null) return 'Invalid age';
    try {
      int age = int.parse(value);
      if (age >= 12)
        return null;
      else
        return 'Min age is 12';
    } catch (e) {
      return 'Age must be an integer';
    }
  }

  void saveEmail(String? value) {
    email = value;
  }

  void savePassword(String? value) {
    password = value;
  }

  void saveConfirmPassword(String? value) {
    passwordConfirm = value;
  }

  void saveName(String? value) {
    name = value;
  }

  void savePhone(String? value) {
    phone = value;
  }

  void saveAge(String? value) {
    if (value != null) age = int.parse(value);
  }
}
