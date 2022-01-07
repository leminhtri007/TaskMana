import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test0/controller/firebasecontroller.dart';
import 'package:test0/model/category.dart';
import 'package:test0/model/constant.dart';
import 'package:test0/model/task.dart';
import 'package:test0/screen/task_list.dart';

import 'myview/mydialog.dart';

class EditTaskScreen extends StatefulWidget {
  const EditTaskScreen({Key? key}) : super(key: key);
  static const routeName = './editTaskScreen';

  @override
  State<StatefulWidget> createState() {
    return _EditTaskScreen();
  }
}

class _EditTaskScreen extends State<EditTaskScreen> {
  User? user;
  late _Controller con;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  DateTime currentDate = DateTime.now();
  String? dropDownValue;
  String? dropDownValuePriority;
  Task? originalTask;
  Task? updatedTask;
  List<Task>? taskList;
  List<String>? categoryList;
  int? index;
  GlobalKey<FormState> userKey = GlobalKey<FormState>();
  String? addUserErrorString;

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
    addUserErrorString == "";
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context)!.settings.arguments as Map;
    user ??= args[Constant.ARG_USER];
    originalTask ??= args[Constant.ARG_TASK];
    updatedTask ??= Task.clone(originalTask!);
    taskList ??= args[Constant.ARG_TASK_LIST];
    index ??= args[Constant.ARG_INDEX];
    categoryList ??= args[Constant.ARG_CATEGORY_LIST];
    if (con.sharedWithEmail == null) con.sharedWithList();
    //print(categoryList);

    return Scaffold(
      appBar: AppBar(
        title: Text("Edit ${updatedTask!.title}"),
        centerTitle: true,
        actions: [
          ElevatedButton(onPressed: con.saveTask, child: const Text("Save")),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Title',
                    ),
                    initialValue: updatedTask!.title,
                    autocorrect: true,
                    validator: con.validateTitle,
                    onSaved: con.saveTitle,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Description',
                    ),
                    initialValue: updatedTask!.description,
                    autocorrect: true,
                    keyboardType: TextInputType.multiline,
                    onSaved: con.saveDescription,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    width: MediaQuery.of(context).size.width,
                    child: DropdownButtonFormField<String>(
                      hint: const Text('Choose a Category'),
                      value: updatedTask!.category,
                      icon: const Icon(Icons.arrow_downward),
                      iconSize: 12,
                      onChanged: (String? newValue) {
                        setState(() {
                          dropDownValue = newValue!;
                        });
                      },
                      validator: con.validateCategory,
                      onSaved: con.saveCategory,
                      items: categoryList!
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    width: MediaQuery.of(context).size.width,
                    child: DropdownButtonFormField<String>(
                      hint: const Text('Set Priority'),
                      value: (updatedTask!.priority),
                      icon: const Icon(Icons.arrow_downward),
                      iconSize: 12,
                      onChanged: (String? newValue) {
                        setState(() {
                          dropDownValuePriority = newValue!;
                        });
                      },
                      validator: con.validatePriority,
                      onSaved: con.savePriority,
                      items: <String>['Low', 'Medium', 'High']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                          child: Text("${updatedTask!.dueDate!.month}"
                              "/${updatedTask!.dueDate!.day}"
                              "/${updatedTask!.dueDate!.year}"),
                          width: 150.0),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () => con.selectDueDate(context),
                          child: const Text('Select Due Date'),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                          child: Text(
                              '${updatedTask!.completionTime!.hour} hrs ${updatedTask!.completionTime!.minute} min'),
                          width: 150.0),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () => con.selectCompletionTime(context),
                          child: const Text('Select Completion Time'),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Form(
                        key: userKey,
                        child: Row(children: [
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: "User Email",
                              ),
                              validator: null, //con.validateUser,
                              onSaved: con.saveUser,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: ElevatedButton(
                              onPressed: con.addUser,
                              child: const Text('Add User'),
                            ),
                          ),
                        ]),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // ignore: prefer_const_literals_to_create_immutables
                        children: [
                          Text(
                            (addUserErrorString == null)
                                ? ""
                                : addUserErrorString!,
                            style: TextStyle(
                              color: Colors.red,
                              fontStyle: FontStyle.italic,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        child: Text(
                          "Collaborating with: " +
                              ((con.sharedWithEmail == null)
                                  ? ""
                                  : con.sharedWithEmail!),
                        ),
                      ),
                    ],
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
  late _EditTaskScreen state;
  _Controller(this.state);

  //preset default due dates and completion dates
  DateTime dueDate = DateTime.now().add(const Duration(days: 3));
  // Task updatedTask = Task();
  String? sharedWithEmail;
  String? userToAdd; //email

  Future<void> saveUser(String? value) async {
    if (value == null) return;
    String? uid = await FirebaseController.getUID(email: value);

    if (uid == null) {
      state.addUserErrorString =
          "User not found \n or has not signed in since collaboration was implemented";
      return;
    }

    state.addUserErrorString = "";

    if (sharedWithEmail == null) {
      sharedWithEmail = value + ",";
    } else {
      sharedWithEmail = (sharedWithEmail)! + (value + ",");
    }

    userToAdd = uid;
    state.updatedTask!.sharedWith!.add(userToAdd!);

    userToAdd = null;
  }

  void addUser() {
    FormState? currentState = state.userKey.currentState;
    if (currentState == null) return;
    currentState.save();

    state.render(() {});
  }

  Future<void> sharedWithList() async {
    print("SharedWithList");
    sharedWithEmail = "";
    assert(state.originalTask!.sharedWith != null);
    state.originalTask!.sharedWith!.forEach((uid) async {
      print("Inside loop");
      print(uid);
      String? nextEmail = await FirebaseController.getEmail(uid: uid);
      print(nextEmail);
      sharedWithEmail = (sharedWithEmail)! + nextEmail + ",";
      print(sharedWithEmail);
      state.render(() {});
    });
  }

  Future<void> selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: state.updatedTask!.dueDate!.day < state.currentDate.day
          ? state.currentDate
          : state.updatedTask!.dueDate!,
      firstDate: DateTime.now().subtract(const Duration(days: 0)),
      lastDate: DateTime(2023),
    );

    if (picked != null) {
      state.updatedTask!.dueDate = picked;
      state.render(() {});
    }
  }

  Future<void> selectCompletionTime(BuildContext context) async {
    final TimeOfDay? chooseTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(state.updatedTask!.completionTime!),
        initialEntryMode: TimePickerEntryMode.input,
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        });

    if (chooseTime != null) {
      state.updatedTask!.completionTime = DateTime(dueDate.year, dueDate.month,
          dueDate.day, chooseTime.hour, chooseTime.minute);
      state.render(() {});
    }
  }

  String? validateTitle(String? value) {
    if (value != null && value.isEmpty) {
      return 'Must include a title';
    } else {
      return null;
    }
  }

  void saveTitle(String? value) {
    if (value != null) {
      state.updatedTask!.title = value;
    }
  }

  String? validateCategory(String? value) {
    if (value == null) {
      return 'Choose a category';
    } else {
      return null;
    }
  }

  void saveCategory(String? value) {
    if (value != null) {
      state.updatedTask!.category = value;
    }
  }

  void saveDescription(String? value) {
    if (value != null) {
      state.updatedTask!.description = value;
    }
  }

  String? validatePriority(String? value) {
    if (value == null) {
      return 'Choose a priority';
    } else {
      return null;
    }
  }

  void savePriority(String? value) {
    if (value != null) {
      state.updatedTask!.priority = value;
    }
  }

  void saveTask() async {
    FormState? currentState = state.formKey.currentState;
    if (currentState == null || !currentState.validate()) return;
    currentState.save();
    FocusScope.of(state.context).unfocus();
    var displayTimeDifference = "";
    MyDialog.circularProgressStart(state.context);

    try {
      Map<String, dynamic> updateInfo = {};
      if (state.originalTask!.title != state.updatedTask!.title) {
        updateInfo[Task.TITLE] = state.updatedTask!.title;
        state.taskList![state.index!].title = state.updatedTask!.title;
      }
      if (state.originalTask!.description != state.updatedTask!.description) {
        updateInfo[Task.DESCRIPTION] = state.updatedTask!.description;
        state.taskList![state.index!].description =
            state.updatedTask!.description;
      }

      if (state.originalTask!.category != state.updatedTask!.category) {
        updateInfo[Task.CATEGORY] = state.updatedTask!.category;
        state.taskList![state.index!].category = state.updatedTask!.category;
      }
      if (state.originalTask!.priority != state.updatedTask!.priority) {
        updateInfo[Task.PRIORITY] = state.updatedTask!.priority;
        state.taskList![state.index!].priority = state.updatedTask!.priority;
      }
      if (state.originalTask!.dueDate != state.updatedTask!.dueDate) {
        updateInfo[Task.DUE_DATE] = state.updatedTask!.dueDate;
        state.taskList![state.index!].dueDate = state.updatedTask!.dueDate;
      }
      if (state.originalTask!.completionTime !=
          state.updatedTask!.completionTime) {
        updateInfo[Task.COMPLETION_TIME] = state.updatedTask!.completionTime;
        state.taskList![state.index!].completionTime =
            state.updatedTask!.completionTime;
      }

      var timeDifference = state.taskList![state.index!].dueDate!
          .difference(DateTime.now().add(const Duration(hours: -24)));

      if (timeDifference.inDays == 0) {
        displayTimeDifference = timeDifference.inHours.toString() + " hours ";
      } else {
        displayTimeDifference = timeDifference.inDays.toString() + " day(s) ";
      }

      //SharedWith--------------------------------------------------------------
      if (state.updatedTask!.sharedWith!.isNotEmpty) {
        updateInfo[Task.SHARED_WITH] = state.updatedTask!.sharedWith;
      }

      await FirebaseController.updateTask(
          state.updatedTask!.docId!, updateInfo);
      state.originalTask!.assign(state.updatedTask!);
      MyDialog.circularProgressStop(state.context);
      Navigator.pop(state.context);
      Navigator.pushReplacementNamed(
        state.context,
        TaskListScreen.routeName,
        arguments: {
          Constant.ARG_TASK_LIST: state.taskList!,
          Constant.ARG_USER: state.user,
          Constant.ARG_CATEGORY_LIST: state.categoryList,
        },
      );

      MyDialog.info(
          context: state.context,
          title: state.updatedTask!.title.toUpperCase(),
          content: "You updated your task!\n\nYou have " +
              displayTimeDifference +
              "remaining to complete the task. Better get to work!");
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      MyDialog.info(context: state.context, title: "Task Error", content: '$e');
    }
    FocusScope.of(state.context).unfocus();
    //print(state.updatedTask?.printContents());
  }
}
