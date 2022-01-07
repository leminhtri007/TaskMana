import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:test0/controller/firebasecontroller.dart';
import 'package:test0/model/color_profile.dart';
import 'package:test0/model/constant.dart';
import 'package:test0/model/profile.dart';
import 'package:test0/screen/myview/mydialog.dart';
import 'package:test0/screen/settings_screen.dart';
import 'myview/conifg.dart';
import 'myview/my_app_theme.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profileScreen';
  Profile profileMemo = Profile();

  @override
  State<StatefulWidget> createState() {
    return _ProfileState();
  }
}

class _ProfileState extends State<ProfileScreen> {
  User? user;
  late _Controller con;
  bool editMode = false;
  Profile? profile;
  ColorProfile? colorProfile;
  // print("profile: ${profile}");
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context)!.settings.arguments as Map;
    user ??= args[Constant.ARG_USER];
    profile ??= args[Constant.USERMEMO_COLLECTION];
    colorProfile ??= args[Constant.ARG_COLOR_PROFILE];

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Setting'),
        actions: [
          editMode
              ? IconButton(onPressed: con.update, icon: Icon(Icons.check))
              : IconButton(icon: Icon(Icons.edit), onPressed: con.edit)
        ],
      ),
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 0,
                        child: Text(
                          'Email: ',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          enabled: editMode,
                          style: Theme.of(context).textTheme.headline6,
                          decoration: InputDecoration(hintText: 'Enter Email'),
                          initialValue: "${user!.email}",
                          autocorrect: true,
                          validator: Profile.validateEmail,
                          onSaved: con.saveEmail,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 0,
                        child: Text(
                          'Name: ',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          enabled: editMode,
                          style: Theme.of(context).textTheme.headline6,
                          decoration: InputDecoration(hintText: 'Enter Name'),
                          initialValue: "${profile!.name}",
                          autocorrect: true,
                          //validator: Profile.validateEmail,
                          onSaved: con.saveName,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 0,
                        child: Text(
                          'Phone: ',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          enabled: editMode,
                          style: Theme.of(context).textTheme.headline6,
                          decoration: InputDecoration(hintText: 'Enter Phone'),
                          // ignore: unnecessary_string_interpolations
                          initialValue: "${profile!.phone}",
                          autocorrect: true,
                          //validator: Profile.validateEmail,
                          onSaved: con.savePhone,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 0,
                        child: Text(
                          'age: ',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          enabled: editMode,
                          style: Theme.of(context).textTheme.headline6,
                          decoration: InputDecoration(hintText: 'Enter Age'),
                          // ignore: unnecessary_string_interpolations
                          initialValue: "${profile!.age}",
                          autocorrect: true,
                          //validator: Profile.validateEmail,
                          onSaved: con.saveAge,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 5.0),
          DropdownButton<String>(
            value: Constant.colorOptions.keys.firstWhere((element) =>
                Constant.colorOptions[element] == currentTheme.color),
            icon: const Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            onChanged: //editMode? con.setColor : null,
                con.setColor,
            items: Constant.colorOptions.keys
                .toList()
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Icon(
                  Icons.brightness_1,
                  color: Constant.colorOptions[value],
                ),
              );
            }).toList(),
          ),
          Switch(
            value: currentTheme.darkMode,
            onChanged: //editMode? con.switchBrightness : null,
                con.switchBrightness,
          ),
          ElevatedButton(
            child: Text("Reset Password"),
            onPressed: con.toPasswordReset,
          ),
        ],
      ),
    );
  }
}

class _Controller {
  late _ProfileState state;
  _Controller(this.state);
  Profile tempProfile = Profile();

  void toPasswordReset() async {
    await Navigator.pushNamed(
      state.context, 
      SettingsScreen.routeName, 
      arguments: {Constant.ARG_USER: state.user}
    );
  }

  Future<void> update() async {
    FormState? currentState = state.formKey.currentState;
    if (currentState == null || !currentState.validate()) return;
    currentState.save();

    MyDialog.circularProgressStart(state.context);
    String profileDocId =
        await FirebaseController.getDocID(uid: state.profile!.uid);
    print("docid:  ${profileDocId}");
    state.profile!.docId = profileDocId;
    try {
      Map<String, dynamic> cloneChangeEmail = {};
      String changeEmail = '';
      if (tempProfile.email != state.user!)
        cloneChangeEmail[Profile.EMAIL] = tempProfile.email;

      Map<String, dynamic> updateInfo = {};
      changeEmail = tempProfile.email;
      if (state.user! != tempProfile.email) {
        updateInfo[Profile.EMAIL] = tempProfile.email;
      }
      if (state.profile!.name != tempProfile.name) {
        updateInfo[Profile.NAME] = tempProfile.name;
      }
      if (state.profile!.phone != tempProfile.phone) {
        updateInfo[Profile.PHONE] = tempProfile.phone;
      }
      if (state.profile!.age != tempProfile.age) {
        updateInfo[Profile.AGE] = tempProfile.age;
      }
      await FirebaseController.updateProfileInfo(
          state.profile!.docId, updateInfo);

      changeEmail = cloneChangeEmail[Profile.EMAIL];
      if (changeEmail.isNotEmpty) {
        // await FirebaseController.addUserInfo(tempProfile);

        //   state.profile!.assign(tempProfile);
        await FirebaseController.changeEmail(changeEmail);
        state.widget.profileMemo.assign(tempProfile);
        MyDialog.circularProgressStop(state.context);
      }

      MyDialog.showSnackBar(
        context: state.context,
        message: 'Update Email successful!',
      );
      state.render(() {});
      Navigator.pop(state.context);
      Navigator.pop(state.context);
      //Navigator.pop(state.context);
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      if (Constant.DEV) print(' ======= update email error:$e');
      MyDialog.showSnackBar(
        context: state.context,
        message: 'Update Email error ($e)',
      );
    }

    // try {
    //   Map<String, dynamic> updateInfo = {};
    //   if (state.user!.displayName != tempProfile.name) {
    //     updateInfo[Profile.NAME] = tempProfile.name;
    //   }
    //   if (state.profile!.phone != tempProfile.phone) {
    //     updateInfo[Profile.PHONE] = tempProfile.phone;
    //   }
    //   if (state.profile!.age != tempProfile.age) {
    //     updateInfo[Profile.AGE] = tempProfile.age;
    //   }
    //   await FirebaseController.updateProfileInfo(profileDocId, updateInfo);
    //   state.profile!.assign(tempProfile);

    //   print("docid:  ${tempProfile}");
    // } catch (e) {
    //   MyDialog.circularProgressStop(state.context);
    //   MyDialog.info(
    //       context: state.context,
    //       title: "update profile info error",
    //       content: '$e');
    // }

    state.render(() => state.editMode = false);
  }

  void edit() {
    state.render(() => state.editMode = true);
  }

  void saveEmail(String? value) {
    if (value != null) tempProfile.email = value;
  }

  void saveName(String? value) {
    if (value != null) tempProfile.name = value;
  }

  void savePhone(String? value) {
    if (value != null) tempProfile.phone = value;
  }

  void saveAge(String? value) {
    if (value != null) tempProfile.age = int.parse(value);
  }

  void switchBrightness(bool value) async {
    currentTheme.switchBrightness();

    MyDialog.circularProgressStart(state.context);

    try {
      await FirebaseController.setColorProfile(
          {ColorProfile.DARK_MODE: value}, state.colorProfile!.docId);
      MyDialog.circularProgressStop(state.context);
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      MyDialog.info(
          context: state.context,
          title: "Set Color Error",
          content: e.toString());
    }

    state.render(() {});
  }

  void setColor(String? value) async {
    if (value == null) return;

    currentTheme.setColor(value);

    MyDialog.circularProgressStart(state.context);

    try {
      await FirebaseController.setColorProfile(
          {ColorProfile.COLOR: value}, state.colorProfile!.docId);
      MyDialog.circularProgressStop(state.context);
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      MyDialog.info(
          context: state.context,
          title: "Set Color Error",
          content: e.toString());
    }

    state.render(() {});
  }
}
