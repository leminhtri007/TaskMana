import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test0/controller/firebasecontroller.dart';
import 'package:test0/model/constant.dart';
import 'package:test0/model/task.dart';

import 'myview/mydialog.dart';

class SharedWithMeScreen extends StatefulWidget {
  static const routeName = "/sharedWithMeScreen";

  @override
  State<StatefulWidget> createState() {
    return SharedWithMeState();
  }
}

class SharedWithMeState extends State<SharedWithMeScreen> {
  late _Controller con;
  User? user;
  List<Task>? taskList;

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
    user ??= args[Constant.ARG_USER];
    taskList ??= args[Constant.ARG_TASK_LIST];
    return Scaffold(
      appBar: AppBar(
        title: Text("Collaborations"),
        actions: [
          IconButton(
            icon: descending
                ? Icon(Icons.arrow_downward)
                : Icon(Icons.arrow_upward),
            onPressed: con.changeOrder,
          ),
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
              Task.PRIORITY
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(sortChoices[
                    value]!), //maps constant value from Task class to user-friendly string
              );
            }).toList(),
          )
        ],
      ),
      body: (taskList?.length == 0)
          ? Text("All caught up!")
          : ListView.builder(
              itemCount: taskList?.length,
              itemBuilder: (BuildContext context, int index) => Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: ListTile(
                      onTap: () => con.detailedView(index),
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
                              ? taskList![index].description.substring(0, 20) +
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
                ),
              ),
            ),
    );
  }
}

class _Controller {
  SharedWithMeState state;

  _Controller(this.state);

  Future<void> getTasks(String? sortBy, bool descending) async {
    MyDialog.circularProgressStart(state.context);
    try {
      state.taskList = await FirebaseController.getSharedWithTasks(
          uid: state.user!.uid, sortBy: sortBy!, descending: descending);
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
    await getTasks(newValue, state.descending);
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
    await getTasks(state.sortBy!, newDescending);
    state.render(() {
      state.descending = newDescending;
    });
  }

  /* 
   * Shows a dialog box with the detailed view of the task.
   */
  void detailedView(int index) async {
    String sharedWithString = await FirebaseController.getSharedWithList(
        uids: state.taskList![index].sharedWith!);

    MyDialog.detailedTaskView(
      context: state.context,
      task: state.taskList![index],
      user: state.user!,
      taskList: state.taskList!,
      index: index,
      sharedWith: sharedWithString,
      readOnly: true,
    );
  }
}
