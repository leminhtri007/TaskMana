import 'package:flutter/material.dart';
import 'package:test0/model/constant.dart';
import 'package:test0/model/filter_options.dart';
import 'package:test0/screen/task_list.dart';

class FilterScreen extends StatefulWidget{
  static const routeName = "/filterScreen";
  @override
  State<StatefulWidget> createState() {
    return FilterState();
  }
}

class FilterState extends State<FilterScreen> {
  late _Controller con;
  FilterOptions? options;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    con = _Controller(this);
    super.initState();
  }

  void render(fn){
    setState(fn);
  }


  @override
  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context)!.settings.arguments as Map;
    options ??= args[Constant.ARG_FILTER_OPTIONS];
    print(options);


    return Scaffold(
      appBar: AppBar(title: Text("Filter")),
      body: WillPopScope(
        onWillPop: () async { return false; },
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //Title
                  Row(
                    children: [
                      Text("Title: "),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          onSaved: con.saveTitle,
                        ),
                      ),
                    ],
                  ),
                  //Due Date
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(flex: 2, child: Text("Due Date ")),
                      Expanded(
                        flex: 3,
                        child: DropdownButton<String>(
                          value: FilterOptions.dueOptions.keys.firstWhere(
                            (element) => FilterOptions.dueOptions[element] == options!.dueComp
                          ),
                          icon: const Icon(Icons.arrow_downward),
                          iconSize: 24,
                          elevation: 16,
                          onChanged: con.changeDueOption,
                          items: FilterOptions.dueOptions.keys.toList()
                          .map<DropdownMenuItem<String>>((String value){
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text((options!.dueDate != null)? 
                            "${options!.dueDate!.toLocal()}".split(' ')[0]
                            :"",
                        ),
                      ),
                    ],
                  ),
                  //Category
                  Row(
                    children: [
                      Expanded(flex: 1, child: Text("Category: ")),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          onSaved: con.saveCategory,
                        ),
                      ),
                    ],
                  ),
                  //Time to Complete
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(flex: 2, child: Text("Completion Time ")),
                      Expanded(
                        flex: 3, 
                        child: DropdownButton<String>(
                          value: FilterOptions.timeOptions.keys.firstWhere(
                            (element) => FilterOptions.timeOptions[element] == options!.timeComp
                          ),
                          icon: const Icon(Icons.arrow_downward),
                          iconSize: 24,
                          elevation: 16,
                          onChanged: con.changeTimeOption,
                          items: FilterOptions.timeOptions.keys.toList()
                          .map<DropdownMenuItem<String>>((String value){
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                      Expanded(
                        flex: 3, 
                        child: Text((options!.completionTime != null)?
                          ((options!.completionTime!.minute == 0)? 
                            ("${options!.completionTime!.hour} hour")
                            : ("${options!.completionTime!.hour} hour, ${options!.completionTime!.minute} min")
                          )
                          : "",
                        ),
                      ),
                    ],
                  ),
                  //Shared
                  Row(
                    children: [
                      Text("Shared: "),
                      DropdownButton<String>(
                        value: FilterOptions.boolOptions.keys.firstWhere(
                          (element) => FilterOptions.boolOptions[element] == options!.shared
                        ),
                        icon: const Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        onChanged: con.changeShared,
                        items: FilterOptions.boolOptions.keys.toList()
                        .map<DropdownMenuItem<String>>((String value){
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  //Priority
                  Row(
                    children: [
                      Text("Priority: "),
                      DropdownButton<String>(
                        hint: const Text('Set Priority'),
                        value: FilterOptions.priorityOptions.keys.firstWhere(
                          (element) => FilterOptions.priorityOptions[element] == options!.priority
                        ),
                        icon: const Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        onChanged: con.changePriority,
                        items: FilterOptions.priorityOptions.keys
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        child: Text("Cancel"),
                        onPressed: con.cancel,
                      ),
                      SizedBox(width: 10,),
                      ElevatedButton(
                        child: Text("Filter"),
                        onPressed: con.filter,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Controller{
  late FilterState state;
  _Controller(this.state);

  void cancel(){
    Navigator.pop(state.context, FilterOptions());
  }

  void filter(){
    state.formKey.currentState!.save();

    Navigator.pop(state.context, state.options);
  }

  void saveTitle(String? value){
    if(value == "") return; //keep null if nothing entered

    state.options!.title = value;
  }

  void saveCategory(String? value){
    if(value == "") return; //keep null if nothing entered

    state.options!.category = value;
  }

  void changeShared(String? value){
    state.options!.shared = FilterOptions.boolOptions[value];
    state.render((){});
  }

  Future<void> selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime(2023),
    );

    if (picked != null) {
      state.options!.dueDate = picked;
      state.render(() {});
    }
  }

  Future<void> changeDueOption(String? value) async{
    if(state.options!.dueComp == null) await selectDueDate(state.context);
    state.options!.dueComp = FilterOptions.dueOptions[value];
    if(state.options!.dueComp == null) state.options!.dueDate = null;
    state.render((){});
  }

  Future<void> selectCompletionTime(BuildContext context) async {
    final TimeOfDay? chooseTime = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 1, minute: 0),
        initialEntryMode: TimePickerEntryMode.input,
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        });

    if (chooseTime != null) {
      DateTime dueDate = DateTime.now();
      state.options!.completionTime = DateTime(dueDate.year, dueDate.month,
          dueDate.day, chooseTime.hour, chooseTime.minute);
      state.render(() {});
    }
  }

  Future<void> changeTimeOption(String? value) async{
    if(state.options!.timeComp == null) await selectCompletionTime(state.context);
    state.options!.timeComp = FilterOptions.timeOptions[value];
    if(state.options!.timeComp == null) state.options!.completionTime = null;
    state.render((){});
  }

  void changePriority(String? value) async{
    state.options!.priority = FilterOptions.priorityOptions[value];
    state.render((){});
  }
}