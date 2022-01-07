import 'constant.dart';

class ColorProfile{
  static const UID = "uid";
  static const COLOR = "color";
  static const DARK_MODE = "darkMode";
  static const DOC_ID = 'docId';

  late String uid;
  late String color;
  late bool darkMode;
  late String docId;

  ColorProfile(){
    uid = '';
    color = Constant.BLUE;
    darkMode = false;
    docId = '';
  }

  ColorProfile.deserialize(Map<String, dynamic> doc, docId){
    uid = doc[UID];
    color = doc[COLOR];
    darkMode = doc[DARK_MODE];
    this.docId = docId;
  }

  Map<String, dynamic> serialize(){
    return <String, dynamic>{
      UID: uid,
      COLOR: color,
      DARK_MODE: darkMode,
      DOC_ID: docId,
    };
  }
}