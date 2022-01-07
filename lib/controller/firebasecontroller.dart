import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:test0/model/category.dart';
import 'package:test0/model/color_profile.dart';

import 'package:test0/model/constant.dart';
import 'package:test0/model/profile.dart';
import 'package:test0/model/task.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseController {
  static Future<User?> signIn(
      {required String email, required String password}) async {
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    return userCredential.user;
  }

  static Future<void> createAccount({
    required String email,
    required String password,
    required String name,
  }) async {
    UserCredential result =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    User? user = result.user;
    user!.updateDisplayName(name);
  }

  static Future<void> changeEmail(String email) async {
    await FirebaseAuth.instance.currentUser!.updateEmail(email);
    await FirebaseAuth.instance.currentUser!.reload();
  }

  static Future<List<Task>> getTasks(
      {required String uid,
      required String sortBy,
      required bool descending}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.TASK_COLLECTION)
        .where(
          Task.UID,
          isEqualTo: uid,
        )
        .orderBy(sortBy, descending: descending)
        .get();

    var result = <Task>[];
    querySnapshot.docs.forEach((doc) {
      result.add(Task.deserialize(doc.data() as Map<String, dynamic>, doc.id));
    });

    print("end gettasks");
    return result;
  }

  static Future<String> addTask(Task task) async {
    var ref = await FirebaseFirestore.instance
        .collection(Constant.TASK_COLLECTION)
        .add(task.toFirestoreDoc());
    return ref.id;
  }

  static Future<String> addUserInfo(Profile profileUserInfo) async {
    var ref4 = await FirebaseFirestore.instance
        .collection(Constant.USERMEMO_COLLECTION)
        .add(profileUserInfo.serialize());
    return ref4.id;
  }

  static Future<ColorProfile> getColorProfile(String uid) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.ARG_COLOR_PROFILE)
        .where(ColorProfile.UID, isEqualTo: uid)
        .get();

    if (querySnapshot.size == 0) {
      return await newColorProfile(uid);
    } else {
      var doc = querySnapshot.docs[0];
      return ColorProfile.deserialize(
          doc.data() as Map<String, dynamic>, doc.id);
    }
  }

  static Future<ColorProfile> newColorProfile(String uid) async {
    ColorProfile newProfile = ColorProfile();
    newProfile.uid = uid;
    var ref = await FirebaseFirestore.instance
        .collection(Constant.ARG_COLOR_PROFILE)
        .add(newProfile.serialize());
    newProfile.docId = ref.id;
    await setColorProfile(
        {ColorProfile.DOC_ID: newProfile.docId}, newProfile.docId);
    return newProfile;
  }

  static Future<void> setColorProfile(
      Map<String, dynamic> newInfo, String docId) async {
    await FirebaseFirestore.instance
        .collection(Constant.ARG_COLOR_PROFILE)
        .doc(docId)
        .update(newInfo);
  }

  //rohit
  static Future<String> addCategory(Category category) async {
    var ref = await FirebaseFirestore.instance
        .collection(Constant.CATEGORY_COLLECTION)
        .add(category.toMap());
    return ref.id;
  }

  //jon - keeping both for now until merge done
  static Future<List<Category>> getCategoryList({required String uid}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.CATEGORY_COLLECTION)
        .where(Category.UID, isEqualTo: uid)
        //.orderBy(Category.NAME, descending: true)
        .get();
    var result = <Category>[];
    querySnapshot.docs.forEach((doc) {
      result.add(Category.fromMap(doc.data() as Map<String, dynamic>, doc.id));
    });

    return result;
  }

  static Future<String> getDocID({required String uid}) async {
    var collection = FirebaseFirestore.instance
        .collection(Constant.USERMEMO_COLLECTION)
        .where(Profile.UID, isEqualTo: uid);
    var querySnapshots = await collection.get();
    // ignore: prefer_typing_uninitialized_variables
    var documentID;
    for (var snapshot in querySnapshots.docs) {
      documentID = snapshot.id;
    }
    return documentID;
  }

  static Future<List<Category>> getCategories({required String uid}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.CATEGORY_COLLECTION)
        .where(Category.UID, isEqualTo: uid)
        .get();

    var result = <Category>[];
    querySnapshot.docs.forEach((doc) {
      result.add(Category.fromMap(doc.data() as Map<String, dynamic>, doc.id));
    });

    return result;
  }

  static Future<List<String>> getTaskWithCategory(String? oldCategory) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.TASK_COLLECTION)
        .where(Task.CATEGORY, isEqualTo: oldCategory)
        .get();
    //     .then((QuerySnapshot snapshot) {
    //   snapshot.docs.forEach((doc) {
    //     print(doc.id);
    //   });
    // });
    List<String> taskIDs = [];
    querySnapshot.docs.forEach((doc) {
      taskIDs.add(doc.id);
    });
    String test = querySnapshot.docs.toString();
    print("querysnapshot: {$test}");
    print("old category: {$oldCategory}");
    return taskIDs;
  }

  // static Future<void> changeTasksCategory(
  //     {required String? oldCategory, required String? newCategory}) async {
  //   QuerySnapshot querySnapshot = await FirebaseFirestore.instance
  //       .collection(Constant.TASK_COLLECTION)
  //       .where(Task.CATEGORY, isEqualTo: oldCategory)
  //       .get();
  //   Map<String, dynamic> updateNew = {Task.CATEGORY: newCategory};
  //   querySnapshot.docs.forEach((doc) async {
  //     await FirebaseFirestore.instance
  //         .collection(Constant.TASK_COLLECTION)
  //         .doc(doc.id)
  //         .update(updateNew);
  //   });
  //}

  static Future<void> updateTask(
      String docId, Map<String, dynamic> updateInfo) async {
    await FirebaseFirestore.instance
        .collection(Constant.TASK_COLLECTION)
        .doc(docId)
        .update(updateInfo);
  }

  static Future<void> updateTaskCategory(String docId, String? cateInfo) async {
    await FirebaseFirestore.instance
        .collection(Constant.TASK_COLLECTION)
        .doc(docId)
        .set({Constant.CATEGORY_COLLECTION: cateInfo}, SetOptions(merge: true));
  }

  static Future<void> deleteTask({required Task task}) async {
    await FirebaseFirestore.instance
        .collection(Constant.TASK_COLLECTION)
        .doc(task.docId)
        .delete();
  }

  static Future<void> deleteCategory({required Category category}) async {
    await FirebaseFirestore.instance
        .collection(Constant.CATEGORY_COLLECTION)
        .doc(category.docId)
        .delete();
  }

  static Future<void> updateCategory(
      String docId, Map<String, dynamic> updateInfo) async {
    await FirebaseFirestore.instance
        .collection(Constant.CATEGORY_COLLECTION)
        .doc(docId)
        .update(updateInfo);
  }

  static Future<void> updateProfileInfo(
      String docId, Map<String, dynamic> updateInfo) async {
    await FirebaseFirestore.instance
        .collection(Constant.USERMEMO_COLLECTION)
        .doc(docId)
        .update(updateInfo);
  }

  static Future<void> uploadUID(
      {required String email, required String uid}) async {
    Map<String, dynamic> info = {
      Constant.ARG_EMAIL: email,
      Constant.ARG_UID: uid,
    };

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.EMAIL_TO_UID_COLLECTION)
        .where(Category.UID, isEqualTo: uid)
        .get();

    if (querySnapshot.size > 0) {
      String docId = querySnapshot.docs[0].id;
      await FirebaseFirestore.instance
          .collection(Constant.EMAIL_TO_UID_COLLECTION)
          .doc(docId)
          .set(info);
    } else {
      await FirebaseFirestore.instance
          .collection(Constant.EMAIL_TO_UID_COLLECTION)
          .add(info);
    }
  }

  static Future<String?> getUID({required String? email}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.EMAIL_TO_UID_COLLECTION)
        .where(Constant.ARG_EMAIL, isEqualTo: email)
        .get();

    var result = <String, dynamic>{};
    querySnapshot.docs.forEach((doc) {
      result = doc.data() as Map<String, dynamic>;
    });

    return result[Constant.ARG_UID];
  }

  static Future<String?> getUIDProfile({required String? email}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.USERMEMO_COLLECTION)
        .where(Constant.ARG_EMAIL, isEqualTo: email)
        .get();

    var result = <String, dynamic>{};
    querySnapshot.docs.forEach((doc) {
      result = doc.data() as Map<String, dynamic>;
    });

    return result[Constant.ARG_UID];
  }

  static Future<List> getProfile({required String? email}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.USERMEMO_COLLECTION)
        .where(Profile.EMAIL, isEqualTo: email)
        .get();

    var result = <String, dynamic>{};
    querySnapshot.docs.forEach((doc) {
      result = doc.data() as Map<String, dynamic>;
    });
    var data = [];
    data.add(result["phone"]);
    data.add(result["age"]);
    data.add(result["name"]);

    // querySnapshot.docs.forEach((doc) {
    //   result
    //       .add(Profile.deserialize(doc.data() as Map<String, dynamic>, doc.id));
    // });
    return data;
  }

  static Future<String> getEmail({required String uid}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.EMAIL_TO_UID_COLLECTION)
        .where(Constant.ARG_UID, isEqualTo: uid)
        .get();

    var result = <String, dynamic>{};
    querySnapshot.docs.forEach((doc) {
      result = doc.data() as Map<String, dynamic>;
    });

    return result[Constant.ARG_EMAIL];
  }

  static Future<String> getSharedWithList({required List<dynamic> uids}) async {
    if (uids.isEmpty) return "";
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.EMAIL_TO_UID_COLLECTION)
        .where(Constant.ARG_UID, whereIn: uids)
        .get();

    String returnString = "";

    querySnapshot.docs.forEach((doc) {
      returnString += doc[Constant.ARG_EMAIL];
    });

    return returnString;
  }

  static Future<List<Task>> getSharedWithTasks(
      {required String uid,
      required String sortBy,
      required bool descending}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.TASK_COLLECTION)
        .where(Task.SHARED_WITH, arrayContains: uid)
        .orderBy(sortBy, descending: descending)
        .get();

    List<Task> taskList = [];

    querySnapshot.docs.forEach((doc) {
      taskList
          .add(Task.deserialize(doc.data() as Map<String, dynamic>, doc.id));
    });
    return taskList;
  }
}
