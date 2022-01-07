import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:test0/controller/firebasecontroller.dart';
import 'package:test0/main.dart';
import 'package:test0/model/category.dart';
import 'package:test0/model/profile.dart';
import 'package:test0/provider/google_sign_in.dart';
import 'package:test0/model/color_profile.dart';
import 'package:test0/model/constant.dart';
import 'package:test0/model/task.dart';
import 'package:test0/screen/myview/conifg.dart';
import 'package:test0/screen/task_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test0/screen/signup_screen.dart';
import 'package:test0/screen/myview/mydialog.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart';

class SignInScreen extends StatefulWidget {
  static const routeName = '/signInScreen';

  @override
  State<StatefulWidget> createState() {
    return _SignInState();
  }
}

class _SignInState extends State<SignInScreen> {
  late _Controller con;
  bool _isSigningIn = false;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<Task>? taskList;
  Profile? profileId;

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text("Welcome!"),
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              Image.asset(
                'images/taskmana2.png',
                scale: 2.5,
              ),
              // Text(
              //   'Personal',
              //   style: GoogleFonts.lato(
              //     textStyle: Theme.of(context).textTheme.headline4,
              //     fontSize: 48,
              //     fontWeight: FontWeight.w700,
              //     fontStyle: FontStyle.italic,
              //   ),
              // ),
              // Text(
              //   'Task',
              //   style: GoogleFonts.lato(
              //     textStyle: Theme.of(context).textTheme.headline4,
              //     fontSize: 48,
              //     fontWeight: FontWeight.w700,
              //     fontStyle: FontStyle.italic,
              //   ),
              // ),
              // Text(
              //   'Manager',
              //   style: GoogleFonts.lato(
              //     textStyle: Theme.of(context).textTheme.headline4,
              //     fontSize: 48,
              //     fontWeight: FontWeight.w700,
              //     fontStyle: FontStyle.italic,
              //   ),
              // ),
              TextFormField(
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(top: 20),
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(top: 15),
                    child: Icon(Icons.email_outlined),
                  ),
                  hintText: 'Email address',
                ),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                validator: con.validateEmail,
                onSaved: con.saveEmail,
              ),
              TextFormField(
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(top: 20),
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(top: 15),
                    child: Icon(Icons.lock),
                  ),
                  hintText: 'Enter Password',
                ),
                obscureText: true,
                autocorrect: false,
                validator: con.validatePassword,
                onSaved: con.savePassword,
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: con.signIn,
                child: Text(
                  'Sign In',
                  style: Theme.of(context).textTheme.button,
                ),
              ),
              Center(
                child: Text("Don't have an account yet?"),
              ),
              Center(
                child: InkWell(
                  child: Tooltip(
                    message: "Tap 'Sign up Here' to create an account!",
                    child: Text(
                      'Sign Up Here',
                      style: TextStyle(
                        color: Colors.blue[900],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: con.signUp,
                ),
              ),
              Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Text("OR"),
                  ],
                ),
              ),
              Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    FloatingActionButton.extended(
                      onPressed: () async {
                        MyDialog.circularProgressStart(context);
                        setState(() {
                          _isSigningIn = true;
                        });
                        User? user =
                            await GoogleSignInProvider.signInWithGoogle(
                                context: context);
                        setState(() {
                          _isSigningIn = false;
                        });
                        if (user != null) {
                          List<Task> taskList =
                              await FirebaseController.getTasks(
                            uid: user.uid,
                            sortBy: Task.DUE_DATE,
                            descending: false,
                          );
                          MyDialog.circularProgressStop(context);
                          Navigator.pushNamed(
                            context,
                            TaskListScreen.routeName,
                            arguments: {
                              Constant.ARG_TASK_LIST: taskList,
                              Constant.ARG_USER: user,
                            },
                          );
                        }
                      },
                      icon: Image.asset(
                        'images/google.jpg',
                        height: 32,
                        width: 32,
                      ),
                      label: Text('Sign in with Google'),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
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

class _Controller {
  late _SignInState state;
  _Controller(this.state);
  String? email;
  String? password;
  ColorProfile? colorProfile;
  Profile? profile;
  Profile profile2 = Profile();
  List<Profile>? profileList;
  List<Category>? getCategories;
  List<String> categoryList = ["Misc", "Homework", "Chores", "Yard Work"];

  String? validateEmail(String? value) {
    if (value == null || !(value.contains('.') && value.contains('@')))
      return 'Invalid email address';
    else
      return null;
  }

  void saveEmail(String? value) {
    if (value != null) email = value;
  }

  String? validatePassword(String? value) {
    if (value == null || value.length < 6)
      return 'Password must be at least 6 characters';
    else
      return null;
  }

  void savePassword(String? value) {
    if (value != null) password = value;
  }

  Future<void> signUp() async {
    Navigator.pushNamed(state.context, SignUpScreen.routeName);
  }

  Future<void> signIn() async {
    FormState? currentState = state.formKey.currentState;
    if (currentState == null || !currentState.validate()) return;

    currentState.save();

    User? user;

    MyDialog.circularProgressStart(state.context);

    try {
      if (email == null || password == null) {
        throw 'Email or password is null';
      }
      user =
          await FirebaseController.signIn(email: email!, password: password!);
      await getColorProfile(user!.uid);
      //await getProfile(user.uid);
      await FirebaseController.uploadUID(email: user.email!, uid: user.uid);
      MyDialog.circularProgressStop(state.context);
      MyDialog.showSnackBar(
        context: state.context,
        message: 'Sign In Successfully !!!',
        seconds: 4,
      );

      try {
        getCategories = await FirebaseController.getCategoryList(uid: user.uid);

        for (int i = 0; i < getCategories!.length; i++) {
          categoryList.add(getCategories![i].name!);
        }
      } catch (e) {
        MyDialog.info(
            context: state.context,
            title: 'Error obtaining category list',
            content: '$e');
      }

      try {
        MyDialog.circularProgressStart(state.context);
        List<Task> taskList = await FirebaseController.getTasks(
            uid: user.uid, sortBy: Task.DUE_DATE, descending: false);
        updateOldTasksForPriority(taskList);
        taskList = filterTasksIfCompleted(false, taskList);
        
        List profileList1 =
            await FirebaseController.getProfile(email: user.email);
        profile2.phone = profileList1[0];
        profile2.age = profileList1[1];
        profile2.name = profileList1[2];
        print("Profile: ${profile2.phone}");

        MyDialog.circularProgressStop(state.context);
        Navigator.pushNamed(
          state.context,
          TaskListScreen.routeName,
          arguments: {
            Constant.ARG_TASK_LIST: taskList,
            Constant.ARG_USER: user,
            Constant.ARG_COLOR_PROFILE: colorProfile,
            Constant.ARG_CATEGORY_LIST: categoryList,
            Constant.USERMEMO_COLLECTION: profile2,
          },
        );
        //print("PRofile: ${profileList1}");
        // final date1 = DateTime.parse(Task.DUE_DATE);
        final today = DateTime.now();
        //today.subtract(const Duration(days: 50));

        for (int i = 0; i < taskList.length; i++) {
          if ((taskList[i].dueDate!.difference(today)).inDays == 1 ||
              (taskList[i].dueDate!.difference(today)).inMinutes == 30) {
            var androidPlatformChannelSpecifics =
                const AndroidNotificationDetails(
              'alarm_notif',
              'alarm_notif',
              icon: 'dabois',
              //sound: RawResourceAndroidNotificationSound('a_long_cold_sting'),
              largeIcon: DrawableResourceAndroidBitmap('dabois'),
            );

            var iOSPlatformChannelSpecifics = const IOSNotificationDetails(
                //sound: 'a_long_cold_sting.wav',
                presentAlert: true,
                presentBadge: true,
                presentSound: true);
            var platformChannelSpecifics = NotificationDetails(
                android: androidPlatformChannelSpecifics,
                iOS: iOSPlatformChannelSpecifics);

            await flutterLocalNotificationsPlugin.show(1, ' Quack Quack',
                ' Alert - Task Due Soon!', platformChannelSpecifics,
                payload: 'New payload');
          }
        }
      } catch (e) {
        MyDialog.info(
          context: state.context,
          title: "Get Tasks Sign in error:",
          content: e.toString(),
        );
      }
    } catch (e) {
      if (Constant.DEV) print('==== signIn Error: $e');
      MyDialog.circularProgressStop(state.context);
      MyDialog.showSnackBar(
        context: state.context,
        message: 'Sign In Error: $e',
        seconds: 30,
      );
    }
  }

  Future<void> getColorProfile(String uid) async {
    try {
      colorProfile = await FirebaseController.getColorProfile(uid);
      currentTheme.setColor(colorProfile!.color);
      currentTheme.setBrightness(colorProfile!.darkMode);
    } catch (e) {
      MyDialog.info(
          context: state.context,
          title: "GetColorProfile Error",
          content: e.toString());
    }
  }

  // Future<void> getProfile(String uid) async {
  //   try {
  //     profile = await FirebaseController.getProfileOne(uid);
  //   } catch (e) {
  //     MyDialog.info(
  //         context: state.context,
  //         title: "Get 1 profile Error",
  //         content: e.toString());
  //   }
  // }

  List<Task> filterTasksIfCompleted(bool isCompleted, List<Task>? taskList) {
    List<Task> newList = [];
    for (int i = 0; i < taskList!.length; i++) {
      if (taskList[i].completed == isCompleted) {
        newList.add(taskList[i]);
      }
    }
    return newList;
  }

  void updateOldTasksForPriority(List<Task>? taskList) async {
    for (int i = 0; i < taskList!.length; i++) {
      if (taskList[i].priority == "Low") {
        Map<String, dynamic> updateInfo = {};
        taskList[i].priority = 'Low';
        updateInfo[Task.PRIORITY] = taskList[i].priority;
        await FirebaseController.updateTask(taskList[i].docId!, updateInfo);
      }
    }
  }
}
