class FilterOptions{
  DateTime? completionTime;
  DateTime? dueDate;
  String? title;
  String? category;
  bool? shared;
  int? priority;
  int? timeComp;
  int? dueComp;
  static Map<String, bool?> boolOptions = {
    "True"  :  true,
    "False" : false,
    "All"   :  null,
  };

  static Map<String, int?> dueOptions = {
    "Not Filtering" : null,
    "Before"        :   -1,
    "Equal To"      :    0,
    "After"         :    1,
  };

  static Map<String, int?> timeOptions = {
    "Not Filtering" : null,
    "Less Than"     :   -1,
    "Equal To"      :    0,
    "Greater Than"  :    1,
  };

  static Map<String, int?> priorityOptions = {
    "Not Filtering" : null,
    "Low"           :    1,
    "Medium"        :    2,
    "High"          :    3,
  };

  @override
  String toString(){
    return "title: $title,  dueDate: $dueDate, category: $category, completionTime: $completionTime, shared: $shared, priority: $priority";
  }
}