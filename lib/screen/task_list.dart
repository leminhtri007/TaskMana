// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:test0/controller/firebasecontroller.dart';
import 'package:test0/model/color_profile.dart';
import 'package:test0/model/constant.dart';
import 'package:test0/model/profile.dart';
import 'package:test0/model/filter_options.dart';
import 'package:test0/model/task.dart';
import 'package:test0/screen/category_list_screen.dart';
import 'package:test0/screen/completedtask_screen.dart';
import 'package:test0/screen/createtask_screen.dart';
import 'package:test0/screen/filter_screen.dart';
import 'package:test0/screen/help_screen.dart';
import 'package:test0/screen/myview/mydialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test0/screen/profile_screen.dart';
import 'package:test0/screen/settings_screen.dart';
import 'package:test0/screen/sharedwithme_screen.dart';
import 'package:test0/screen/sign_in.dart';
import 'myview/conifg.dart';

class TaskListScreen extends StatefulWidget {
  static const routeName = "/task_listScreen";
  String? categoryName;

  TaskListScreen({Key? key, required this.categoryName}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TaskListState();
  }
}

class TaskListState extends State<TaskListScreen> {
  late _Controller con;

//args-----------------
  List<Task>? taskList;
  User? user;
  ColorProfile? colorProfile;
  Profile? profile;

  List<String>? categoryList;
  String? categoryName;
//---------------------

  String? sortBy = Task.DUE_DATE;
  bool descending = false;

  FilterOptions? filterOptions;

  //Maps constant values for the sort dropdown to text that looks nice to user
  Map<String, String> sortChoices = {
    Task.DUE_DATE: "Due Date",
    Task.TITLE: "Title",
    Task.CATEGORY: "Category",
    Task.COMPLETION_TIME: "Time to Complete",
    Task.PRIORITY: "Priority",
  };

  @override
  void initState() {
    super.initState();

    con = _Controller(this);
  }

  void render(fn) {
    setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context)!.settings.arguments as Map;
    categoryName ??= args[Constant.CATEGORY_NAME];
    categoryList ??= args[Constant.ARG_CATEGORY_LIST];
    colorProfile ??= args[Constant.ARG_COLOR_PROFILE];
    user ??= args[Constant.ARG_USER];
    if (categoryName != null || categoryName != "") {
      taskList ??= args[Constant.ARG_TASK_LIST];
    }
    
    filterOptions ??= FilterOptions();

    print(taskList.toString());
    print(categoryName.toString());

    categoryList ??= args[Constant.ARG_CATEGORY_LIST];
    colorProfile ??= args[Constant.ARG_COLOR_PROFILE];
    profile ??= args[Constant.USERMEMO_COLLECTION];


    return Scaffold(
      appBar: AppBar(
        title: Tooltip(
          message: "View your upcoming task lists down below",
          child: Text("Tasks"),
        ),
        actions: [
          con.delIndexes.isEmpty?
          //Ascending/Descending arrow button. Changes icon depending on ascending or descending
          Row(
            children: [
              IconButton(
                onPressed: con.filter,
                icon: Icon(Icons.filter_list ),
              ),
              IconButton(
                icon: descending ? Icon(Icons.arrow_downward) : Icon(Icons.arrow_upward),
                onPressed: con.changeOrder,
              ),
              //Sort by dropdown. Uses the constant values from the Task class and the sortChoices map
              DropdownButton<String>(
                value: sortBy,
                icon: Icon(Icons.sort),
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.caption!.fontSize,
                  color: Colors.white,
                ),
                dropdownColor: Theme.of(context).primaryColor,
                underline: Container(), //to get rid of underline
                onChanged: (String? newValue) => con.sort(newValue),
                items: <String>[
                  Task.DUE_DATE,
                  Task.TITLE,
                  Task.CATEGORY,
                  Task.COMPLETION_TIME,
                  Task.PRIORITY,
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(sortChoices[
                        value]!), //maps constant value from Task class to user-friendly string
                  );
                }).toList(),
              ),
              // OutlinedButton(
              //   onPressed: null, 
              //   style: ButtonStyle(
              //     shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)))
              //   ),
              //   child: const Text("Filter"),
              // ),
              
            ],
          )
          : Row(
            children: [
              IconButton(
                onPressed: () => showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Warning!!'),
                    content: const Text('Are you sure you want to delete task(s)?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'Cancel'),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: con.delete,
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                ),
                icon: Icon(Icons.delete_forever),
                iconSize: 30,
              ),
              IconButton(onPressed: con.cancelDelete, icon: Icon(Icons.cancel)),
            ],
          ),
        ],
      ),
      //We can add stuff to drawer later
      drawer: Drawer(
        child: Tooltip(
          message: "Select an option from above",
          child: ListView(
            children: [
              Container(
                child: DrawerHeader(
                    child: Center(
                        child: Tooltip(
                  message: "Current Logged In User",
                  child: Text(
                    " User: ${user!.email}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 25),
                  ),
                ))),
                color: currentTheme.color![300],
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text("Home"),
                onTap: con.toHome,
              ),
              ListTile(
                leading: Icon(Icons.category_rounded),
                title: Text("Category List"),
                onTap: con.toCategoyListScreen,
              ),
              ListTile(
                leading: Icon(Icons.share),
                title: Text("Collaborations"),
                onTap: con.toSharedWithMe,
              ),
              ListTile(
                leading: Icon(Icons.check_box),
                title: Text("Completed Tasks"),
                onTap: con.toCompletedTasks,
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Tooltip(
                  message: "Tap Edit Email/Password",
                  child: Text("Settings"),
                ),
                onTap: con.toSettings,
              ),
              ListTile(
                leading: const Icon(
                  Icons.help,
                ),
                title: Tooltip(
                    message: "Tap for more information", child: Text('Help')),
                onTap: () {
                  Navigator.pushNamed(context, HelpScreen.routeName);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.exit_to_app,
                ),
                title: Tooltip(
                    message: "Tap to sign Out from the App",
                    child: Text('Sign out')),
                onTap: () {
                  Navigator.pushReplacementNamed(
                      context, SignInScreen.routeName);
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: con.addButton,
      ),
      body: (taskList?.length == 0)
          ? Text("All caught up!")
          : ListView.builder(
              itemCount: taskList?.length,
              itemBuilder: (BuildContext context, int index) => Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Container(
                    color: con.delIndexes.contains(index)
                        ? Theme.of(context).highlightColor
                        : Theme.of(context).scaffoldBackgroundColor,
                    child: ListTile(
                        onTap: () => con.detailedView(index),
                        onLongPress: () => con.onLongPress(index),
                        trailing: Icon(Icons.keyboard_arrow_right),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(taskList![index].title),
                            Container(
                              padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                              child: Text(
                                taskList![index].category,
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Theme.of(context).primaryColor),
                                borderRadius: BorderRadius.circular(20),
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text((taskList![index].description.length >= 20)
                                ? taskList![index]
                                        .description
                                        .substring(0, 20) +
                                    "..."
                                : taskList![index].description),
                            Text("Due: ${taskList![index].dueDate!.month}"
                                "/${taskList![index].dueDate!.day}"
                                "/${taskList![index].dueDate!.year}"),
                            Text("Time to complete:"
                                " ${taskList![index].completionTime!.hour} hrs"
                                " ${taskList![index].completionTime!.minute} min"),
                            Text("${taskList![index].priority} Priority",
                                style: taskList![index].priority == 'High'
                                    ? TextStyle(color: Colors.red)
                                    : null),
                          ],
                        )),
                  ))),
    );
  }
}

class _Controller {
  TaskListState state;

  _Controller(this.state);

  List<int> delIndexes = [];

  void filter() async{
    state.filterOptions = (await Navigator.pushNamed(
      state.context, 
      FilterScreen.routeName,
      arguments: {
        Constant.ARG_FILTER_OPTIONS: state.filterOptions,
    })) as FilterOptions?;
    await getTasksFiltered(state.sortBy!, state.descending);
  }

  Future<void> getTasksFiltered(String? sortBy, bool descending) async{
    //make sure all the tasks are pulled
    await getTasks(sortBy!, descending);
    

    List<Task> filteredTasks = [];
    filteredTasks.addAll(state.taskList!);

    if(state.filterOptions!.title != null){
      List<Task> newList = [];
      newList.addAll(filteredTasks
        .where((i) => i.title == state.filterOptions!.title));
      filteredTasks = newList;
    }

    if(state.filterOptions!.dueDate != null){
      List<Task> newList = [];
      if (state.filterOptions!.dueComp == -1) {
        newList.addAll(filteredTasks
          .where((i) => i.dueDate!.isBefore(state.filterOptions!.dueDate!)));
      }
      else if (state.filterOptions!.dueComp == 0) {
        newList.addAll(filteredTasks
          .where((i) => i.dueDate!.isAtSameMomentAs(state.filterOptions!.dueDate!)));
      }
      else if (state.filterOptions!.dueComp == 1) {
        newList.addAll(filteredTasks
          .where((i) => i.dueDate!.isAfter(state.filterOptions!.dueDate!)));
      }
      filteredTasks = newList;
    }

    if(state.filterOptions!.category != null){
      List<Task> newList = [];
      newList.addAll(filteredTasks
        .where((i) => i.category == state.filterOptions!.category));
      filteredTasks = newList;
    }

    if(state.filterOptions!.completionTime != null){
      List<Task> newList = [];
      if (state.filterOptions!.timeComp == -1) {
        newList.addAll(filteredTasks
          .where((i) => 
            Duration(hours: i.completionTime!.hour, minutes: i.completionTime!.minute)
            .compareTo(Duration(hours: state.filterOptions!.completionTime!.hour, minutes: state.filterOptions!.completionTime!.minute),)
            < 0));
      }
      else if (state.filterOptions!.timeComp == 0) {
        newList.addAll(filteredTasks
          .where((i) => 
            Duration(hours: i.completionTime!.hour, minutes: i.completionTime!.minute)
            .compareTo(Duration(hours: state.filterOptions!.completionTime!.hour, minutes: state.filterOptions!.completionTime!.minute),)
            == 0));
      }
      else if (state.filterOptions!.timeComp == 1) {
        newList.addAll(filteredTasks
          .where((i) => 
            Duration(hours: i.completionTime!.hour, minutes: i.completionTime!.minute)
            .compareTo(Duration(hours: state.filterOptions!.completionTime!.hour, minutes: state.filterOptions!.completionTime!.minute),)
            > 0));
      }
      filteredTasks = newList;
    } 

    if(state.filterOptions!.shared != null){
      List<Task> newList = [];
      newList.addAll(filteredTasks
        .where((i) => i.sharedWith!.isNotEmpty == state.filterOptions!.shared));
      filteredTasks = newList;
    }

    if(state.filterOptions!.priority != null){
      List<Task> newList = [];
      newList.addAll(filteredTasks
        .where((i) {
            return i.priority == (FilterOptions.priorityOptions.keys.firstWhere(
              (element) => FilterOptions.priorityOptions[element] == state.filterOptions!.priority)
            ); 
          }
        )
      );
      filteredTasks = newList;
    }
    
    state.taskList = filteredTasks;
    state.render(() {});
  }

  void toSharedWithMe() async {
    List<Task> sharedWithList = await FirebaseController.getSharedWithTasks(
        uid: state.user!.uid, sortBy: Task.DUE_DATE, descending: false);

    await Navigator.pushNamed(state.context, SharedWithMeScreen.routeName,
        arguments: {
          Constant.ARG_USER: state.user,
          Constant.ARG_TASK_LIST: sharedWithList,
        });
  }

  void delete() async {
    MyDialog.circularProgressStart(state.context);
    delIndexes.sort();
    for (int i = delIndexes.length - 1; i >= 0; i--) {
      try {
        Task t = state.taskList![delIndexes[i]];
        await FirebaseController.deleteTask(task: t);
      } catch (e) {
        if (Constant.DEV) print("===== failed to delete Task: $e");
        MyDialog.showSnackBar(
          context: state.context,
          message: "Failed to delete Task: $e",
        );
        break;
      }
    }
    MyDialog.showSnackBar(
        context: state.context, message: "Task(s) Deleted Successfully!!");
    MyDialog.circularProgressStop(state.context);
    Navigator.pop(state.context, 'Ok');
    final list = await FirebaseController.getTasks(
        uid: state.user!.uid,
        sortBy: state.sortBy!,
        descending: state.descending);
    state.taskList = list;
    state.taskList = filterTasksIfCompleted(false, state.taskList);

    state.render(() => delIndexes.clear());
  }

  void cancelDelete() {
    state.render(() {
      delIndexes.clear();
    });
  }

  void onLongPress(int index) {
    state.render(() {
      if (delIndexes.contains(index))
        delIndexes.remove(index);
      else
        delIndexes.add(index);
    });
  }

  /*
   * Goes to createtask_screen.
   * Upon return gets the new task list from firebase, then rerenders the screen.
   */
  void addButton() async {
    await Navigator.pushNamed(state.context, CreateTaskScreen.routeName,
        arguments: {
          Constant.ARG_USER: state.user,
          Constant.ARG_CATEGORY_LIST: state.categoryList,
          Constant.ARG_TASK_LIST: state.taskList
        });
    //get new tasklist and user categories
    MyDialog.circularProgressStart(state.context);
    try {
      var getCategories =
          await FirebaseController.getCategoryList(uid: state.user!.uid);
      state.categoryList = ["Misc", "Homework", "Chores", "Yard Work"];
      for (int i = 0; i < getCategories.length; i++) {
        state.categoryList!.add(getCategories[i].name!);
      }

      final list = await FirebaseController.getTasks(
          uid: state.user!.uid,
          sortBy: state.sortBy!,
          descending: state.descending);
      state.taskList = list;
      state.taskList = filterTasksIfCompleted(false, state.taskList);
      MyDialog.circularProgressStop(state.context);
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      MyDialog.info(
        context: state.context,
        title: "List After Add Error: ",
        content: e.toString(),
      );
    }

    //refresh after task is added
    state.render(() {});
  }

  void getAllTasks(String name) async {
    final list = await FirebaseController.getTasks(
        uid: state.user!.uid,
        sortBy: state.sortBy!,
        descending: state.descending);

    state.render(() {
      if (name.isNotEmpty) {
        state.taskList = list
            .where((element) => element.category == state.categoryName)
            .toList();
      } else {
        state.taskList = list;
      }
    });
  }

  /* 
   * Shows a dialog box with the detailed view of the task.
   */
  void detailedView(int index) async {
    String? sharedWithString;
    if (delIndexes.isNotEmpty) {
      onLongPress(index);
      return;
    }
    //added this in as it was throwing an error when empty
    if (state.taskList![index].sharedWith!.isNotEmpty) {
      sharedWithString = await FirebaseController.getSharedWithList(
          uids: state.taskList![index].sharedWith!);
    }

    MyDialog.detailedTaskView(
      context: state.context,
      task: state.taskList![index],
      user: state.user!,
      taskList: state.taskList!,
      index: index,
      categoryList: state.categoryList,
      sharedWith: sharedWithString,
    );
  }

  void toCompletedTasks() async {
    List<Task>? completedTaskList;
    try {
      var getAllTasks = await FirebaseController.getTasks(
          uid: state.user!.uid, sortBy: Task.DUE_DATE, descending: false);
      completedTaskList = filterTasksIfCompleted(true, getAllTasks);

      MyDialog.circularProgressStop(state.context);
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      MyDialog.info(
        context: state.context,
        title: "Sort Error: ",
        content: e.toString(),
      );
    }

    await Navigator.pushNamed(state.context, CompletedTaskScreen.routeName,
        arguments: {
          Constant.ARG_USER: state.user,
          Constant.ARG_COMPLETED_TASK_LIST: completedTaskList,
          Constant.ARG_CATEGORY_LIST: state.categoryList
        });

    state.render(() {});
  }

  /* 
   * Goes to profile_screen.
   * Upon return rerenders the screen.
   */
  void toSettings() async {
    Navigator.of(state.context).pop();
    await Navigator.pushNamed(state.context, ProfileScreen.routeName,
        arguments: {
          Constant.ARG_USER: state.user,
          Constant.ARG_COLOR_PROFILE: state.colorProfile,
          Constant.USERMEMO_COLLECTION: state.profile,
        });
    state.render(() {}); //to refresh if settings are changed
  }

  void toCategoyListScreen() async {
    Navigator.of(state.context).pop();
    await Navigator.pushNamed(state.context, CategoryListScreen.routeName,
        arguments: {
          Constant.ARG_USER: state.user,
          Constant.ARG_TASK_LIST: state.taskList,
        });
    getTasks(Task.DUE_DATE, false);
    state.render(() {}); //to refresh if settings are changed
  }

  void toHome() async {
    Navigator.of(state.context).pop();
    await Navigator.pushReplacementNamed(
        state.context, TaskListScreen.routeName,
        arguments: {
          Constant.ARG_USER: state.user,
          Constant.ARG_TASK_LIST: state.taskList,
        });
    state.render(() {}); //to refresh if settings are changed
  }

  Future<void> getTasks(String? sortBy, bool descending) async {
    MyDialog.circularProgressStart(state.context);
    try {
      state.taskList = await FirebaseController.getTasks(
          uid: state.user!.uid, sortBy: sortBy!, descending: descending);
      state.taskList = filterTasksIfCompleted(false, state.taskList);
      MyDialog.circularProgressStop(state.context);
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      MyDialog.info(
        context: state.context,
        title: "Sort Error: ",
        content: e.toString(),
      );
    }
    state.render(() {});
  }

  List<Task> filterTasksIfCompleted(bool isCompleted, List<Task>? taskList) {
    List<Task> newList = [];
    for (int i = 0; i < taskList!.length; i++) {
      if (taskList[i].completed == isCompleted) {
        newList.add(taskList[i]);
      }
    }
    return newList;
  }

  /*
   * Grabs the taskList from Firebase, which sorts and orders it based on the 
   * value chosen by the sortBy dropdown and the current state.descending value,
   * then rerenders the screen, setting the new state.sortBy value.
   */
  void sort(String? newValue) async {
    await getTasksFiltered(newValue, state.descending);
    state.render(() {
      state.sortBy = newValue;
    });
  }

  /* 
   *  Grabs the taskList from Firebase, which sorts and orders it based on the 
   *  current state.sortBy value and the value chosen by the descending 
   *  IconButton, then rerenders the screen, setting the new state.descending 
   *  value.
   */
  void changeOrder() async {
    bool newDescending = state.descending ? false : true;
    await getTasksFiltered(state.sortBy!, newDescending);
    state.render(() {
      state.descending = newDescending;
    });
  }
}
