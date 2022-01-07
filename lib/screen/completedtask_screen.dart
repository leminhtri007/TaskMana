// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:test0/controller/firebasecontroller.dart';
import 'package:test0/model/color_profile.dart';
import 'package:test0/model/constant.dart';
import 'package:test0/model/task.dart';
import 'package:test0/screen/myview/mydialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test0/screen/task_list.dart';

class CompletedTaskScreen extends StatefulWidget {
  static const routeName = "/completedTaskScreen";

  @override
  State<StatefulWidget> createState() {
    return CompletedTaskState();
  }
}

class CompletedTaskState extends State<CompletedTaskScreen> {
  late _Controller con;

//args-----------------
  List<Task>? taskList;
  User? user;
  ColorProfile? colorProfile;
  List<String>? categoryList;
//---------------------

  String? sortBy = Task.DUE_DATE;
  bool descending = false;

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
    taskList ??= args[Constant.ARG_COMPLETED_TASK_LIST];
    user ??= args[Constant.ARG_USER];
    categoryList ??= args[Constant.ARG_CATEGORY_LIST];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Completed Tasks',
          style: TextStyle(fontSize: 15),
        ),
        leading: IconButton(
            icon: Icon(Icons.arrow_back), onPressed: con.updateTaskListScreen),
        actions: [
          con.delIndexes.isEmpty
              ?
              //Ascending/Descending arrow button. Changes icon depending on ascending or descending
              IconButton(
                  icon: descending
                      ? Icon(Icons.arrow_downward)
                      : Icon(Icons.arrow_upward),
                  onPressed: con.changeOrder,
                )
              : IconButton(
                  onPressed: () => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Warning!!'),
                      content: const Text(
                          'Are you sure you want to delete task(s)?'),
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
          con.delIndexes.isEmpty
              ?
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
                )
              : IconButton(
                  onPressed: con.cancelDelete, icon: Icon(Icons.cancel)),
        ],
      ),
      //We can add stuff to drawer later

      body: (taskList?.length == 0)
          ? Text("Complete your first task!")
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
  CompletedTaskState state;
  _Controller(this.state);
  List<int> delIndexes = [];
  List<String> categoryList = [];

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
    state.taskList = await FirebaseController.getTasks(
        uid: state.user!.uid,
        sortBy: state.sortBy!,
        descending: state.descending);
    state.taskList = filterTasksIfCompleted(true, state.taskList);
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
   * Shows a dialog box with the detailed view of the task.
   */
  void detailedView(int index) async {
    if (delIndexes.isNotEmpty) {
      onLongPress(index);
      return;
    }
    MyDialog.detailedTaskView(
      context: state.context,
      task: state.taskList![index],
      user: state.user!,
      taskList: state.taskList!,
      index: index,
      categoryList: state.categoryList,
    );
  }

  void getTasks(String? sortBy, bool descending) async {
    MyDialog.circularProgressStart(state.context);
    try {
      state.taskList = await FirebaseController.getTasks(
          uid: state.user!.uid, sortBy: sortBy!, descending: descending);
      state.taskList = filterTasksIfCompleted(true, state.taskList);

      MyDialog.circularProgressStop(state.context);
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      MyDialog.info(
        context: state.context,
        title: "Sort Error: ",
        content: e.toString(),
      );
    }
  }

  /*
   * Grabs the taskList from Firebase, which sorts and orders it based on the 
   * value chosen by the sortBy dropdown and the current state.descending value,
   * then rerenders the screen, setting the new state.sortBy value.
   */
  void sort(String? newValue) async {
    getTasks(newValue, state.descending);
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
    getTasks(state.sortBy!, newDescending);
    state.render(() {
      state.descending = newDescending;
    });
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

  void updateTaskListScreen() async {
    MyDialog.circularProgressStart(state.context);
    try {
      var getAllTasks = await FirebaseController.getTasks(
          uid: state.user!.uid, sortBy: Task.DUE_DATE, descending: false);
      getAllTasks = filterTasksIfCompleted(false, getAllTasks);

      var getCategories =
          await FirebaseController.getCategoryList(uid: state.user!.uid);

      for (int i = 0; i < getCategories.length; i++) {
        categoryList.add(getCategories[i].name!);
      }

      ColorProfile? colorProfile =
          await FirebaseController.getColorProfile(state.user!.uid);

      MyDialog.circularProgressStop(state.context);
      Navigator.pushReplacementNamed(state.context, TaskListScreen.routeName,
          arguments: {
            Constant.ARG_TASK_LIST: getAllTasks,
            Constant.ARG_USER: state.user,
            Constant.ARG_CATEGORY_LIST: categoryList,
            Constant.ARG_COLOR_PROFILE: colorProfile,
          });
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      MyDialog.info(
        context: state.context,
        title: "Sort Error: ",
        content: e.toString(),
      );
    }
  }
}
