import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test0/controller/firebasecontroller.dart';
import 'package:test0/model/constant.dart';
import 'package:test0/model/task.dart';
import 'package:test0/screen/completedtask_screen.dart';
import 'package:test0/screen/edittask_screen.dart';
import 'package:test0/screen/task_list.dart';

class MyDialog {
//CircularProgressIndicator from Mobile Apps -----------------------------------
  static void circularProgressStart(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          strokeWidth: 10.0,
        ),
      ),
    );
  }

  static void circularProgressStop(BuildContext context) {
    Navigator.pop(context);
  }
//------------------------------------------------------------------------------

//Info Dialog Box from Mobile Apps ---------------------------------------------
  static void info({
    required BuildContext context,
    required String title,
    required String content,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(content)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              "OK",
              style: Theme.of(context).textTheme.button,
            ),
          )
        ],
      ),
    );
  }

  /*
   * Shows a dialog box showing the contents of a task in detail
   */
  static void detailedTaskView({
    required BuildContext context,
    required Task task,
    required User user,
    required List<Task>? taskList,
    required int index,
    List<String>? categoryList,
    String? sharedWith,
    bool? readOnly,
  }) {
    readOnly ??= false;
    bool isChecked = task.completed;
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return StatefulBuilder(builder: (context, StateSetter setState) {
            return AlertDialog(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(task.title),
                      (!(readOnly!))
                          ? TextButton(
                              onPressed: () {
                                Navigator.popAndPushNamed(
                                    context, EditTaskScreen.routeName,
                                    arguments: {
                                      Constant.ARG_USER: user,
                                      Constant.ARG_TASK: task,
                                      Constant.ARG_TASK_LIST: taskList,
                                      Constant.ARG_INDEX: index,
                                      Constant.ARG_CATEGORY_LIST: categoryList
                                    });
                              },
                              child: Visibility(
                                child: Icon(Icons.edit),
                                visible: isChecked ? false : true,
                              ),
                            )
                          : SizedBox(width: 1),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: Text(
                      task.category,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).primaryColor),
                      borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(task.description),
                  SizedBox(
                    height: 5,
                  ),
                  Text("Due: ${task.dueDate!.month}"
                      "/${task.dueDate!.day}"
                      "/${task.dueDate!.year}"),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                      "Time to complete: \n${task.completionTime!.hour} hrs ${task.completionTime!.minute} min"),
                  SizedBox(height: 5),
                  Text("Collaborating with: $sharedWith"),
                  Text("${task.priority} Priority",
                      style: task.priority == 'High'
                          ? TextStyle(color: Colors.red)
                          : null),
                  Row(
                    children: [
                      Text("Completed?"),
                      Checkbox(
                          checkColor: Colors.white,
                          value: isChecked,
                          onChanged: (bool? value) {
                            setState(
                              () {
                                isChecked = value!;
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => AlertDialog(
                                    title: isChecked
                                        ? Text(
                                            "Did you complete ${task.title}?")
                                        : Text(
                                            "Do you want to move this back to active?"),
                                    content: SingleChildScrollView(),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          isChecked = task.completed;

                                          Navigator.pop(context);
                                          setState(() {});
                                        },
                                        child: Text(
                                          "No",
                                          style: Theme.of(context)
                                              .textTheme
                                              .button,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          task.completed = isChecked;
                                          isChecked
                                              ? updateTaskAsCompleted(
                                                  isChecked,
                                                  task,
                                                  user,
                                                  categoryList!,
                                                  context)
                                              : updateTaskAsActive(isChecked,
                                                  task, user, context);
                                        },
                                        child: Text(
                                          "Yes",
                                          style: Theme.of(context)
                                              .textTheme
                                              .button,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }),
                    ],
                  )
                ],
              ),
            );
          });
        });
  }

  static void updateTaskAsCompleted(bool isChecked, Task task, User user,
      List<String> categoryList, BuildContext context) async {
    MyDialog.circularProgressStart(context);
    List<Task> taskList = [];

    try {
      Map<String, dynamic> updateInfo = {};

      if (isChecked) {
        updateInfo[Task.COMPLETED] = true;
        await FirebaseController.updateTask(task.docId!, updateInfo);
        List<Task> allTasks = await FirebaseController.getTasks(
            uid: user.uid, sortBy: Task.DUE_DATE, descending: false);

        for (int i = 0; i < allTasks.length; i++) {
          if (allTasks[i].completed == false) {
            taskList.add(allTasks[i]);
          }
        }

        MyDialog.circularProgressStop(context);
        Navigator.pop(context);
        Navigator.popAndPushNamed(context, TaskListScreen.routeName,
            arguments: {
              Constant.ARG_TASK: task,
              Constant.ARG_TASK_LIST: taskList,
              Constant.ARG_USER: user,
              Constant.ARG_CATEGORY_LIST: categoryList,
            });
      }
    } catch (e) {
      MyDialog.info(
        context: context,
        title: "Task completed error: ",
        content: e.toString(),
      );
      MyDialog.circularProgressStop(context);
    }
  }

  static void updateTaskAsActive(
      bool isChecked, Task task, User user, BuildContext context) async {
    MyDialog.circularProgressStart(context);
    List<Task> taskList = [];

    try {
      Map<String, dynamic> updateInfo = {};

      if (!isChecked) {
        updateInfo[Task.COMPLETED] = false;
        await FirebaseController.updateTask(task.docId!, updateInfo);
        List<Task> allTasks = await FirebaseController.getTasks(
            uid: user.uid, sortBy: Task.DUE_DATE, descending: false);

        for (int i = 0; i < allTasks.length; i++) {
          if (allTasks[i].completed == true) {
            taskList.add(allTasks[i]);
          }
        }

        MyDialog.circularProgressStop(context);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pushReplacementNamed(context, CompletedTaskScreen.routeName,
            arguments: {
              Constant.ARG_TASK: task,
              Constant.ARG_COMPLETED_TASK_LIST: taskList,
              Constant.ARG_USER: user,
            });
      }
    } catch (e) {
      MyDialog.info(
        context: context,
        title: "Task back to active error: ",
        content: e.toString(),
      );
      MyDialog.circularProgressStop(context);
    }
  }

  static void showSnackBar({
    required BuildContext context,
    required String message,
    int seconds = 5,
    String label = 'Dismiss',
  }) {
    final snackBar = SnackBar(
      duration: Duration(seconds: seconds),
      content: Text(message),
      action: SnackBarAction(
        label: label,
        onPressed: () {},
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
