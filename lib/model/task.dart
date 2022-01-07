import 'package:flutter/material.dart';

class Task {
  static const TITLE = 'title';
  static const DESCRIPTION = 'description';
  static const CATEGORY = 'category';
  static const COMPLETION_TIME = 'timetocomplete';
  static const DUE_DATE = 'duedate';
  static const UID = "uid";
  static const SHARED_WITH = "sharedWith";
  static const COMPLETED = 'completed';
  static const PRIORITY = 'priority';

  String? docId;
  late String title;
  late String description;
  late String category;
  DateTime? completionTime;
  DateTime? dueDate;
  late String uid;
  List<dynamic>? sharedWith; //list of uid
  late bool completed;
  late String priority;

  Task({
    this.docId = "",
    this.title = "",
    this.description = "",
    this.category = "",
    this.completionTime,
    this.dueDate,
    this.uid = "",
    this.sharedWith,
    this.completed = false,
    this.priority = "Low",
  }) {
    sharedWith ??= [];
  }

  Task.clone(Task t) {
    docId = t.docId;
    title = t.title;
    description = t.description;
    category = t.category;
    completionTime = t.completionTime;
    dueDate = t.dueDate;
    uid = t.uid;

    sharedWith = [];
    sharedWith!.addAll(t.sharedWith!);

    completed = t.completed;
    priority = t.priority;
  }

  void assign(Task t) {
    docId = t.docId;
    title = t.title;
    description = t.description;
    category = t.category;
    completionTime = t.completionTime;
    dueDate = t.dueDate;
    uid = t.uid;

    sharedWith = [];
    sharedWith!.addAll(t.sharedWith!);
    completed = t.completed;
    priority = t.priority;
  }

  Map<String, dynamic> toFirestoreDoc() {
    return {
      TITLE: title,
      DESCRIPTION: description,
      CATEGORY: category,
      COMPLETION_TIME: completionTime,
      DUE_DATE: dueDate,
      UID: uid,
      SHARED_WITH: sharedWith,
      COMPLETED: completed,
      PRIORITY: priority,
    };
  }

  static Task deserialize(Map<String, dynamic> doc, String docId) {
    return Task(
      docId: docId,
      title: doc[TITLE],
      description: doc[DESCRIPTION],
      category: doc[CATEGORY],
      uid: doc[UID],
      completionTime: doc[COMPLETION_TIME] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              doc[COMPLETION_TIME].millisecondsSinceEpoch),
      dueDate: doc[DUE_DATE] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              doc[DUE_DATE].millisecondsSinceEpoch),
      sharedWith: doc[SHARED_WITH],
      completed: (doc[COMPLETED] == null) ? false : doc[COMPLETED],
      priority: (doc[PRIORITY] == null) ? "Low" : doc[PRIORITY],
    );
  }

  String? printContents() {
    return "Title: " +
        title +
        ", description: " +
        description +
        ", Category: " +
        category +
        ", Completion Time: " +
        completionTime.toString() +
        ", Due Date: " +
        dueDate.toString() +
        ", Completed: " +
        completed.toString() +
        ", Priority: " +
        priority;
  }
}
