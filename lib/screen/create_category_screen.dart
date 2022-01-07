import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test0/controller/firebasecontroller.dart';
import 'package:test0/model/category.dart';
import 'package:test0/model/constant.dart';

class CreateCategoryScreen extends StatefulWidget {
  static const routeName = './createCategoryScreen';

  const CreateCategoryScreen({Key? key}) : super(key: key);

  @override
  _CreateCategoryScreenState createState() => _CreateCategoryScreenState();
}

class _CreateCategoryScreenState extends State<CreateCategoryScreen> {
  GlobalKey<FormState> formkey = new GlobalKey<FormState>();
  final imagePicker = ImagePicker();
  var _image;
  TextEditingController? _namecontroller;
  ColorSwatch? _tempMainColor;
  Color? _tempShadeColor = Colors.blue;
  ColorSwatch? _mainColor = Colors.blue;
  User? user;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _namecontroller = TextEditingController();
    _namecontroller!.addListener(() {
      print(_namecontroller!.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    Map args = ModalRoute
        .of(context)!
        .settings
        .arguments as Map;
    user ??= args[Constant.ARG_USER];

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Category'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.done),
        onPressed: onFabClick,
      ),
      body: addCategoryWidet(),
    );
  }


  Widget addCategoryWidet() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.all(8.0),
        child: Form(
          key: formkey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _namecontroller,
                  decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'Enter the name of Category'),
                  autocorrect: true,
                ),
                Container(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          width: 35, height: 35, color: _tempShadeColor),
                      MaterialButton(
                        onPressed: _openFullMaterialColorPicker,
                        child: Text(
                          'Pick Color',
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Theme
                            .of(context)
                            .primaryColor,
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
                        color: Theme
                            .of(context)
                            .primaryColor,
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

  void displayError(String error) {
    final snackBar = SnackBar(content: Text(error));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<String> onFabClick() async {
    bool isvalid = true;
    if (_namecontroller!.text.isEmpty) {
      displayError("Title is required");
      isvalid = false;
    }
    if (_tempShadeColor == null) {
      displayError("Choose atleast one color");
      isvalid = false;
    }
    if (_image == null) {
      displayError("Image is required");
      isvalid = false;
    }
    String id = "not a valid id ";
    if (isvalid) {
      final category = Category(
          name: _namecontroller!.text,
          color: _tempShadeColor!.toString().toHexColor(),
          icon: _image.toString(),
          uid: user!.uid);
      id = await FirebaseController.addCategory(category);
      displayError("Category is Added");
      setState(() {
        _namecontroller!.text = "";
        _image = null;
        _tempShadeColor = Theme
            .of(context)
            .primaryColor;
      });
      // Timer(Duration(seconds:1), (){
      //   Navigator.of(context).pop();
      // });

    }
    return id;
  }

  void _openFullMaterialColorPicker() async {
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
      ),
    );
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
              onPressed: Navigator
                  .of(context)
                  .pop,
            ),
            TextButton(
              child: Text('SUBMIT'),
              onPressed: () {
                Navigator.of(context).pop();
                // setState(() => _mainColor = _tempMainColor);
                // setState(() => _shadeColor = _tempShadeColor);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _namecontroller!.dispose();
  }



}
// Color(0xffffee58)
extension ColorExtension on String {
   toHexColor(){
     return split("0xff")[1].substring(0,6);
   }

   toColor(){
     return Color(int.parse("0xff$this"));
   }
}

class ColorName {
  String name;
  Color value;

  ColorName(this.name, this.value);
}
