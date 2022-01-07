import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test0/controller/firebasecontroller.dart';
import 'package:test0/model/category.dart';
import 'package:test0/model/constant.dart';
import 'package:test0/model/task.dart';

import 'category_list_screen.dart';
import 'create_category_screen.dart';
import 'myview/mydialog.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({Key? key}) : super(key: key);
  static const routeName = './createTaskScreen';

  @override
  State<StatefulWidget> createState() {
    return _CreateTaskScreen();
  }
}

class _CreateTaskScreen extends State<CreateTaskScreen> {
  User? user;
  late _Controller con;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  DateTime currentDate = DateTime.now();
  String? dropDownValue;
  String? dropDownValuePriority;
  List<Task> taskList = [];
  List<Task> _tempTaskList = [];
  List<Category> categoryList = [];
  List<String?> categoryString = [];
  List<String?>? originalCategoryList;
  GlobalKey? dropdownKey;
  bool isExpanded = false;
  GlobalKey<FormState> userKey = GlobalKey<FormState>();
  String? addUserErrorString;

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
    dropdownKey = GlobalKey<FormFieldState>();

    //getCategoryData();
  }

  void getCategoryData() async {
    categoryList = await FirebaseController.getCategories(uid: user!.uid);
    categoryList.add(
        Category(docId: "jsk", name: "add", color: "color", icon: "/path"));
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    setState(() {
      categoryString = getcategoryAsString(categoryList);
    });

    Map args = ModalRoute.of(context)!.settings.arguments as Map;
    user ??= args[Constant.ARG_USER];
    _tempTaskList = args[Constant.ARG_TASK_LIST];

    originalCategoryList = args[Constant.ARG_CATEGORY_LIST];
    print("original list $originalCategoryList");
    getCategoryData();

    return Scaffold(
      appBar: AppBar(
        title: Tooltip(
            message: "Fill All the blanks down below to add a new Task",
            child: Text("Enter Task Details")),
        centerTitle: true,
        actions: [
          ElevatedButton(
              onPressed: con.saveTask,
              child: Tooltip(
                  message: "Tap here to save your Task",
                  child: const Text("Create"))),
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
                        hintText: 'Enter the name of your task'),
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
                      hintText: 'Leave a note',
                    ),
                    autocorrect: true,
                    keyboardType: TextInputType.multiline,
                    onSaved: con.saveDescription,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: DropdownButtonFormField<String>(
                      key: dropdownKey,
                      hint: const Text('Choose a Category'),
                      value: dropDownValue,
                      icon: const Icon(Icons.arrow_downward),
                      iconSize: 12,
                      onChanged: (String? newValue) {
                        setState(() {
                          dropDownValue = newValue!;
                        });
                      },
                      validator: con.validateCategory,
                      onSaved: con.saveCategory,
                      items: categoryString
                          .map<DropdownMenuItem<String>>((String? value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: value != 'add'
                              ? Text(value!)
                              : MaterialButton(
                                  child: Text(
                                    "Add Category",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  color: Theme.of(context).primaryColor,
                                  onPressed: _onAddCategoryBtnClick,
                                ),
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
                      value: dropDownValuePriority,
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
                          child: Text("${con.dueDate.toLocal()}".split(' ')[0]),
                          width: 150.0),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () => con.selectDueDate(context),
                          child: const Tooltip(
                              message:
                                  "Tap here to select your due date for the Task",
                              child: Text('Select Due Date')),
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
                            con.completionTime.minute == 0
                                ? ("${con.completionTime.hour} hour")
                                : ("${con.completionTime.hour} hour, ${con.completionTime.minute} min"),
                          ),
                          width: 150.0),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () => con.selectCompletionTime(context),
                          child: Tooltip(
                              message:
                                  "Tap here to set a time frame for your Task",
                              child: Text('Select Completion Time')),
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
                          (con.sharedWithEmail == null)
                              ? ""
                              : con.sharedWithEmail!,
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

  void _onAddCategoryBtnClick() {
    Navigator.pop(dropdownKey!.currentState!.context);
    Navigator.of(context).pushNamed(
      CategoryListScreen.routeName,
      arguments: {
        Constant.ARG_USER: user,
        Constant.ARG_TASK_LIST: _tempTaskList,
      },
    ).then((value) async {
      final result = await FirebaseController.getCategories(uid: user!.uid);
      result.add(
          Category(docId: "jsk", name: "add", color: "color", icon: "/path"));
      setState(() {
        categoryList = result;
        categoryString = getcategoryAsString(categoryList);
        originalCategoryList = getcategoryAsString(categoryList);
      });
    });
  }

  List<String?> getcategoryAsString(List<Category> cList) {
    return cList.map((e) => e.name).toList();
  }
}

class _Controller {
  late _CreateTaskScreen state;
  _Controller(this.state);

  //preset default due dates and completion dates
  DateTime dueDate = DateTime.now().add(const Duration(days: 3));
  TimeOfDay completionTime = const TimeOfDay(hour: 1, minute: 0);
  Task tempTask = Task();
  String? sharedWithEmail;
  String? userToAdd; //uid
  List<String>? sharedWith;

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
    sharedWith ??= [];
    sharedWith!.add(userToAdd!);

    userToAdd = null;
  }

  void addUser() {
    FormState? currentState = state.userKey.currentState;
    if (currentState == null) return;
    currentState.save();

    state.render(() {});
  }

  Future<void> selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 0)),
      lastDate: DateTime(2023),
    );

    if (picked != null) {
      dueDate = picked;
      state.render(() {});
    }
  }

  Future<void> selectCompletionTime(BuildContext context) async {
    final TimeOfDay? chooseTime = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 1, minute: 0),
        initialEntryMode: TimePickerEntryMode.input,
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        });

    if (chooseTime != null) {
      completionTime = chooseTime;
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
      tempTask.title = value;
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
      tempTask.category = value;
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
      tempTask.priority = value;
    }
  }

  void saveDescription(String? value) {
    if (value != null) {
      tempTask.description = value;
    }
  }

  void saveTask() async {
    FormState? currentState = state.formKey.currentState;
    if (currentState == null || !currentState.validate()) return;
    currentState.save();

    var displayTimeDifference = "";
    var timeDifference =
        dueDate.difference(DateTime.now().add(const Duration(hours: -24)));

    if (timeDifference.inDays == 0) {
      displayTimeDifference = timeDifference.inHours.toString() + " hours ";
    } else {
      displayTimeDifference = timeDifference.inDays.toString() + " day(s) ";
    }

    try {
      tempTask.dueDate = dueDate;
      tempTask.completionTime = DateTime(dueDate.year, dueDate.month,
          dueDate.day, completionTime.hour, completionTime.minute);
      tempTask.uid = state.user!.uid;
      tempTask.sharedWith = sharedWith;
      String docId = await FirebaseController.addTask(tempTask);
      tempTask.docId = docId;
      Navigator.pop(state.context);
      MyDialog.info(
          context: state.context,
          title: tempTask.title.toUpperCase(),
          content: "You have created a new task!\n\nYou have " +
              displayTimeDifference +
              "remaining to complete the task. Better get to work!");
    } catch (e) {
      MyDialog.info(context: state.context, title: "Task Error", content: '$e');
    }
    FocusScope.of(state.context).unfocus();
    print(tempTask.printContents());
  }
}
