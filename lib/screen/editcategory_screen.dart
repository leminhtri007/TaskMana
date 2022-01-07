import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test0/controller/firebasecontroller.dart';
import 'package:test0/model/category.dart';
import 'package:test0/model/constant.dart';
import 'package:test0/model/task.dart';
import 'package:test0/screen/myview/mydialog.dart';
import 'package:test0/screen/task_list.dart';

class EditCategoryScreen extends StatefulWidget {
  static const routeName = './editcategoryscreen';
  const EditCategoryScreen({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _EditCategoryState();
  }
}

class _EditCategoryState extends State<EditCategoryScreen> {
  User? user;
  late _Controller con;
  Category? categoryOrigin;
  Category? categoryUpdated;
  List<Category>? categoryList;
  List<Task>? taskList;
  Color? _originColor;
  ColorSwatch? _tempMainColor;
  ColorSwatch? _mainColor;
  Color? _tempShadeColor = Colors.blue;
  final imagePicker = ImagePicker();
  var _image;
  int? index;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context)!.settings.arguments as Map;
    user ??= args[Constant.ARG_USER];
    categoryOrigin ??= args[Constant.ARG_CATEGORY];
    categoryUpdated ??= Category.clone(categoryOrigin!);
    categoryList ??= args[Constant.ARG_CATEGORY_LIST];
    taskList ??= args[Constant.ARG_TASK_LIST];
    index ??= args[Constant.ARG_INDEX];
    // _tempShadeColor = categoryOrigin!.color as Color?;
    ;
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Category'),
        actions: [
          ElevatedButton(
              onPressed: con.saveCategory, child: const Text("Save")),
        ],
      ),
      body: editCategoryWidget(),
    );
  }

  Widget editCategoryWidget() {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        padding: EdgeInsets.all(8.0),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  style: Theme.of(context).textTheme.headline6,
                  decoration: InputDecoration(hintText: 'Title'),
                  initialValue: categoryUpdated!.name,
                  autocorrect: true,
                  validator: con.validateTitle,
                  onSaved: con.saveTitle,
                ),
                Container(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 35,
                        height: 35,
                        color: _tempShadeColor,
                      ),
                      MaterialButton(
                        onPressed: _openFullMaterialColorPicker,
                        child: Text(
                          'Pick Color',
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        child: _image != null
                            ? Image.file(_image,
                                width: 100, height: 100, fit: BoxFit.cover)
                            : Icon(Icons.image_outlined),
                      ),
                      MaterialButton(
                        onPressed: () async {
                          XFile? image = await imagePicker.pickImage(
                              source: ImageSource.gallery, imageQuality: 50);
                          setState(() {
                            _image = File(image!.path);
                            print("Imagepath: $_image");
                          });
                        },
                        child: Text(
                          'Pick Icon from Gallery',
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Theme.of(context).primaryColor,
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

  void _openFullMaterialColorPicker() {
    _openDialog(
        "",
        MaterialColorPicker(
          colors: fullMaterialColors,
          onColorChange: (color) {
            setState(() {
              print(_tempMainColor);
              _tempShadeColor = color;
            });
          },
          selectedColor: _mainColor,
          onMainColorChange: (color) {
            setState(() {
              print(_tempMainColor);
              _tempMainColor = color;
            });
          },
        ));
  }

  void _openDialog(String title, Widget content) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(6.0),
          title: Text(title),
          content: content,
          actions: [
            TextButton(
              child: Text('CANCEL'),
              onPressed: Navigator.of(context).pop,
            ),
            TextButton(
              child: Text('SUBMIT'),
              onPressed: () {
                //con.saveColor;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class _Controller {
  late _EditCategoryState state;
  String? _docId;
  String? _name;
  String? oldCategory;

  _Controller(this.state);

  void saveTitle(String? value) {
    if (value != null) {
      state.categoryUpdated!.name = value;
    }
  }

  void displayError(String error) {
    final snackBar = SnackBar(content: Text(error));
    ScaffoldMessenger.of(state.context).showSnackBar(snackBar);
  }

  void saveCategory() async {
    FormState? currentState = state.formKey.currentState;
    if (currentState == null || !currentState.validate()) return;
    currentState.save();
    FocusScope.of(state.context).unfocus();
    MyDialog.circularProgressStart(state.context);
    if (state._tempShadeColor != null) {
      state.categoryUpdated!.color =
          state._tempShadeColor!.toString().toHexColor();
    } else {
      displayError("Please choose a color");
    }
    if (state._image != null) {
      state.categoryUpdated!.icon = state._image.toString();
    } else {
      displayError("Please choose an icon");
    }
    try {
      Map<String, dynamic> updateInfo = {};
      if (state.categoryOrigin!.name != state.categoryUpdated!.name) {
        updateInfo[Category.NAME] = state.categoryUpdated!.name;
        //state.categoryList![state.index!].name = state.categoryUpdated!.name;
      }
      if (state.categoryOrigin!.color != state.categoryUpdated!.color) {
        updateInfo[Category.COLOR] = state.categoryUpdated!.color;
        //state.categoryList![state.index!].color = state.categoryUpdated!.color;
      }
      if (state.categoryOrigin!.icon != state.categoryUpdated!.icon) {
        updateInfo[Category.ICON] = state.categoryUpdated!.icon;
        //state.categoryList![state.index!].icon = state.categoryUpdated!.icon;
      }

      await FirebaseController.updateCategory(
          state.categoryUpdated!.docId!, updateInfo);

      List<String> taskIDs = await FirebaseController.getTaskWithCategory(
          state.categoryOrigin!.name);
      Map<String, dynamic> update = {Task.CATEGORY: updateInfo};
      taskIDs.forEach((id) async {
        await FirebaseController.updateTaskCategory(
            id, state.categoryUpdated!.name);
      });
      state.categoryOrigin!.assign(state.categoryUpdated!);
      MyDialog.circularProgressStop(state.context);
      Navigator.pop(state.context);
      Navigator.pop(state.context);
      Navigator.pop(state.context);
      state.render(() {});
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      MyDialog.info(
          context: state.context,
          title: "update category error",
          content: '$e');
    }
    FocusScope.of(state.context).unfocus();
    //print(updatedCategory.printContents());
  }

  String? validateTitle(String? value) {
    if (value != null && value.isEmpty) {
      return 'Please type in title';
    }
  }
}

extension ColorExtension on String {
  toHexColor() {
    return split("0xff")[1].substring(0, 6);
  }

  toColor() {
    return Color(int.parse("0xff$this"));
  }
}

class ColorName {
  String name;
  Color value;

  ColorName(this.name, this.value);
}
