class Category {
  String? docId;
  String? name;
  String? color;
  String? icon;
  late String uid;
  static const NAME = 'name';
  static const COLOR = 'color';
  static const ICON = 'icon';
  static const UID = "uid";

  Category({this.docId, this.name, this.color, this.icon, this.uid = ""});

  Category.clone(Category c) {
    docId = c.docId;
    name = c.name;
    color = c.color;
    icon = c.icon;
    uid = c.uid;
  }

  void assign(Category c) {
    docId = c.docId;
    name = c.name;
    color = c.color;
    icon = c.icon;
    uid = c.uid;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      NAME: this.name,
      COLOR: this.color,
      ICON: this.icon,
      UID: this.uid
    };
  }

  // deserialization
  static Category fromMap(Map<String, dynamic> doc, String docId) {
    return Category(
        docId: docId,
        name: doc[NAME],
        color: doc[COLOR],
        icon: doc[ICON],
        uid: doc[UID]);
  }
}
