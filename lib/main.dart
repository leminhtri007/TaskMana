import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:test0/provider/google_sign_in.dart';
import 'package:test0/screen/category_list_screen.dart';
import 'package:test0/screen/editcategory_screen.dart';
import 'package:test0/screen/completedtask_screen.dart';
import 'package:test0/screen/filter_screen.dart';
import 'package:test0/screen/help_screen.dart';
import 'package:test0/screen/internalerror_screen.dart';
import 'package:test0/screen/myview/conifg.dart';
import 'package:test0/screen/onboarding_screen.dart';
import 'package:test0/screen/profile_screen.dart';
import 'package:test0/screen/settings_screen.dart';
import 'package:test0/screen/sharedwithme_screen.dart';
import 'package:test0/screen/sign_in.dart';
import 'package:test0/screen/createtask_screen.dart';
import 'package:test0/screen/signup_screen.dart';
import 'package:test0/screen/task_list.dart';
import 'package:test0/screen/create_category_screen.dart';
import 'package:test0/screen/edittask_screen.dart';

import 'model/constant.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var initializationSettingsAndroid = AndroidInitializationSettings('dabois');
  var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {});
  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String? payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
  });
  await Firebase.initializeApp();
  runApp(PersonalTaskManager());
}

class PersonalTaskManager extends StatefulWidget {
  const PersonalTaskManager({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return AppState();
  }
}

class AppState extends State<PersonalTaskManager> {
  late Color primaryColor;
  late bool darkMode;

  @override
  void initState() {
    super.initState();
    currentTheme.addListener(() {
      print("Changes");
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: currentTheme.currentTheme(),
      initialRoute: OnBoardingScreen.routeName,
      routes: {
        OnBoardingScreen.routeName: (BuildContext context) =>
            OnBoardingScreen(),
        SignInScreen.routeName: (BuildContext context) => SignInScreen(),
        TaskListScreen.routeName: (BuildContext context) => TaskListScreen(
              categoryName: "",
            ),
        CreateTaskScreen.routeName: (context) => const CreateTaskScreen(),
        SignUpScreen.routeName: (context) => SignUpScreen(),
        ProfileScreen.routeName: (context) => ProfileScreen(),
        SettingsScreen.routeName: (context) => SettingsScreen(),
        HelpScreen.routeName: (context) => HelpScreen(),
        EditTaskScreen.routeName: (context) => EditTaskScreen(),
        CreateCategoryScreen.routeName: (context) => CreateCategoryScreen(),
        SharedWithMeScreen.routeName: (context) => SharedWithMeScreen(),
        CompletedTaskScreen.routeName: (context) => CompletedTaskScreen(),
        CategoryListScreen.routeName: (context) => CategoryListScreen(),
        EditCategoryScreen.routeName: (context) => EditCategoryScreen(),
        FilterScreen.routeName: (context) => FilterScreen(),
      },
      onGenerateRoute: (setting) {
        if (setting.name == TaskListScreen.routeName) {
          Map args = ModalRoute.of(context)!.settings.arguments as Map;
          String categoryName = args[Constant.CATEGORY_NAME];
          print("setting");
          print(categoryName);
          // TaskListScreen.routeName: (BuildContext context) => TaskListScreen(),
          return MaterialPageRoute(builder: (context) {
            return TaskListScreen(categoryName: categoryName);
          });
        }
      },
    );
  }
}
