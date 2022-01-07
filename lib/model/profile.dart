import 'package:firebase_auth/firebase_auth.dart';

import 'constant.dart';

class Profile {
  late String docId;
  late String uid;
  late String email;
  late String password;
  late String name;
  late String phone;
  late int age;

  static const EMAIL = 'email';
  static const PASSWORD = 'password';
  static const NAME = 'name';
  static const PHONE = 'phone';
  static const AGE = 'age';
  static const UID = "uid";
  static const DOCID = "docId";

  Profile({
    this.docId = '',
    this.uid = '',
    this.email = '',
    this.password = '',
    this.name = '',
    this.age = -1,
    this.phone = '',
  });

  Profile.clone(Profile user) {
    this.docId = user.docId;
    this.email = user.email;
    this.password = user.password;
    this.name = user.name;
    //this.age = user.age;
    this.phone = user.phone;
    this.uid = user.uid;
  }

  void assign(Profile user) {
    this.docId = user.docId;
    this.email = user.email;
    this.password = user.password;
    this.name = user.name;
    //this.age = user.age;
    this.phone = user.phone;
    this.uid = user.uid;
  }

  Map<String, dynamic> serialize() {
    return <String, dynamic>{
      EMAIL: this.email,
      //PASSWORD: this.password,
      NAME: this.name,
      PHONE: this.phone,
      AGE: this.age,
      UID: this.uid,
      DOCID: this.docId,
    };
  }

  static Profile deserialize(Map<String, dynamic> doc, String docId) {
    return Profile(
      docId: docId,
      email: doc[EMAIL],
      password: doc[PASSWORD],
      name: doc[NAME],
      phone: doc[PHONE],
      age: doc[AGE],
      uid: doc[UID],
    );
  }

  static String? validateEmail(String? value) {
    if (value == null) return 'no email typed';
    List<String> emailCheck =
        value.trim().split(RegExp('(,| )+')).map((e) => e.trim()).toList();
    for (String e in emailCheck) {
      if (e.contains('@') && e.contains('.'))
        continue;
      else
        return 'Invalid email';
    }
  }
}
