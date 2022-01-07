import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:test0/controller/firebasecontroller.dart';
import 'package:test0/model/category.dart';
import 'package:test0/model/constant.dart';
import 'package:test0/model/task.dart';
import 'package:test0/screen/create_category_screen.dart';
import 'package:test0/screen/editcategory_screen.dart';
import 'package:test0/screen/task_list.dart';

import 'myview/mydialog.dart';

class CategoryListScreen extends StatefulWidget {
  static const String routeName = "/categoryListScreen";

  const CategoryListScreen({Key? key}) : super(key: key);

  @override
  _CategoryListScreenState createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  User? user;
  List<Category>? categoryList;
  List<Task>? _tempTaskList;
  List<int> delIndexes = [];

  @override
  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context)!.settings.arguments as Map;
    user ??= args[Constant.ARG_USER];
    _tempTaskList ??= args[Constant.ARG_TASK_LIST];
    print("task list: ");
    print(_tempTaskList);

    return Scaffold(
      appBar: AppBar(title: Text('Category List')),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _onAddFabClick,
      ),
      body: FutureBuilder(
        future: _getCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              categoryList = snapshot.data as List<Category>;
              return categoryListView();
            }
          }

          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Widget categoryListView() {
    return ListView.builder(
      itemBuilder: (context, index) {
        print(
            'name ${categoryList![index].name}, color : ${categoryList![index].color}');
        return categoryTile(categoryList![index]);
      },
      itemCount: categoryList!.length,
    );
  }

  Widget categoryTile(Category category) {
    return InkWell(
      onTap: () {
        goToTaskScreen(category.name);
      },
      onLongPress: () => showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Alert!!'),
          content: const Text('What would you like to do?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => editCategory(category),
              child: const Text('Edit'),
            ),
            TextButton(
              onPressed: () => deleteCategory(category),
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 15,
                  height: 50,
                  color: category.color!.toConvertColor(),
                ),
                SizedBox(width: 8),
                Text(
                  category.name!,
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                    height: 50,
                    width: 50,
                    child: FutureBuilder(
                        future: toImageFromPath(category.icon!),
                        builder: (context, snapshot) {
                          File file = snapshot.data as File;
                          return file.existsSync()
                              ? Image.file(file)
                              : new Container();
                        }))
              ],
            )
          ],
        ),
      ),
    );
  }

  void deleteCategory(Category category) async {
    MyDialog.circularProgressStart(context);
    try {
      await FirebaseController.deleteCategory(category: category);
    } catch (e) {
      if (Constant.DEV) print("===== failed to delete Category: $e");
      MyDialog.showSnackBar(
        context: context,
        message: "Failed to delete Category: $e",
      );
    }
    MyDialog.showSnackBar(
        context: context, message: "Category Deleted Successfully!!");
    MyDialog.circularProgressStop(context);
    Navigator.pop(context, 'Delete');
    await FirebaseController.getCategories(uid: user!.uid);
    setState(() {});
  }

  void editCategory(Category category) async {
    Navigator.of(context).pushNamed(
      EditCategoryScreen.routeName,
      arguments: {
        Constant.ARG_USER: user,
        Constant.ARG_CATEGORY: category,
        Constant.ARG_TASK_LIST: _tempTaskList,
      },
    ).then((value) async {
      setState(() {});
    });
  }

  Future<List<Category>> _getCategories() {
    return FirebaseController.getCategories(uid: user!.uid);
  }

  void goToTaskScreen(String? catName) {
    _tempTaskList =
        _tempTaskList!.where((element) => element.category == catName).toList();
    Navigator.of(context).pushNamedAndRemoveUntil(
        TaskListScreen.routeName, (Route<dynamic> route) => false,
        arguments: {
          Constant.CATEGORY_NAME: catName,
          Constant.ARG_TASK_LIST: _tempTaskList,
          Constant.ARG_USER: user,
        });
  }

  void _onAddFabClick() {
    Navigator.of(context).pushNamed(
      CreateCategoryScreen.routeName,
      arguments: {
        Constant.ARG_USER: user,
      },
    ).then((value) async {
      setState(() {});
    });
  }

  Future<File> toImageFromPath(String file) async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    File f = new File('$dir/$file');
    return f;
  }
}

extension ColorExtension on String {
  toHexColor() {
    return split("0xff")[1].substring(0, 6);
  }

  toConvertColor() {
    return Color(int.parse("0xff$this"));
  }
}
