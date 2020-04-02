import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:list_sqflite/models/note.dart';
import 'package:list_sqflite/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class NoteDetail extends StatefulWidget {

  final String appBarTitle;
  final Note note;

  NoteDetail(this.note, this.appBarTitle);

	@override
  State<StatefulWidget> createState() {

    return NoteDetailState(this.note, this.appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {

  String appBarTitle;
  Note note;

  NoteDetailState(this.note, this.appBarTitle);

	static var _priorities = ['High', 'Low'];

	DatabaseHelper helper = DatabaseHelper();

	TextEditingController titleController = TextEditingController();
	TextEditingController descriptionController = TextEditingController();

	@override
  Widget build(BuildContext context) {

		TextStyle textStyle = Theme.of(context).textTheme.title;

		titleController.text = note.title;
		descriptionController.text = note.description;

    return WillPopScope(

      onWillPop: (){moveToLastScreen();},

      child: Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: (){
                moveToLastScreen();
              }),
        ),

        body: Padding(
          padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
          child: ListView(
            children: <Widget>[

              // First element
              ListTile(
                title: DropdownButton(
                    items: _priorities.map((String dropDownStringItem) {
                      return DropdownMenuItem<String> (
                        value: dropDownStringItem,
                        child: Text(dropDownStringItem),
                      );
                    }).toList(),

                    style: textStyle,

                    value: getPriorityAsString(note.priority),

                    onChanged: (valueSelectedByUser) {
                      setState(() {
                        debugPrint('User selected $valueSelectedByUser');
                        updatePriorityAsInt(valueSelectedByUser);
                      });
                    }
                ),
              ),

              // Second Element
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: TextField(
                  controller: titleController,
                  style: textStyle,
                  onChanged: (value) {
                    debugPrint('Something changed in Title Text Field');
                    updateTitle();
                  },
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0)
                    )
                  ),
                ),
              ),

              // Third Element
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: TextField(
                  controller: descriptionController,
                  style: textStyle,
                  onChanged: (value) {
                    debugPrint('Something changed in Description Text Field');
                    updateDescription();
                  },
                  decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: textStyle,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0)
                      )
                  ),
                ),
              ),

              // Fourth Element
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        color: Theme.of(context).primaryColorDark,
                        textColor: Theme.of(context).primaryColorLight,
                        child: Text(
                          'Save',
                          textScaleFactor: 1.5,
                        ),
                        onPressed: () {
                          setState(() {
                            debugPrint("Save button clicked");
                            _save();
                          });
                        },
                      ),
                    ),

                    Container(width: 5.0,),

                    Expanded(
                      child: RaisedButton(
                        color: Theme.of(context).primaryColorDark,
                        textColor: Theme.of(context).primaryColorLight,
                        child: Text(
                          'Delete',
                          textScaleFactor: 1.5,
                        ),
                        onPressed: () {
                          setState(() {
                            debugPrint("Delete button clicked");
                            _delete();
                          });
                        },
                      ),
                    ),

                  ],
                ),
              ),

            ],
          ),
        ),

        ),
    );
  }
  
  void moveToLastScreen(){
    Navigator.pop(context, true);
  }

  void updatePriorityAsInt(String value){
	  switch(value){
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

  String getPriorityAsString(int value){
	  String priority;
	  switch (value){
      case 1:
        priority = _priorities[0];
        break;
      case 2:
        priority = _priorities[1];
        break;
    }
    return priority;
  }

  void updateTitle(){
	  note.title = titleController.text;
  }

  void updateDescription(){
	  note.description = descriptionController.text;
  }

  void _save() async{
	  moveToLastScreen();

	  note.date = DateFormat.yMMMd().format(DateTime.now());
	  int result;

	  if (note.id != null){ //case update operation
      result = await helper.updateNote(note);
    }else{ //case insert operation
      result = await helper.insertNote(note);
    }

	  if (result != 0){ //Success
      _showAlertDialog('Status', 'Note Saved Successfully');
    }else{ //Failure
      _showAlertDialog('Status', 'Problem Saving Note ');
    }
  }

  void _delete() async {
	  moveToLastScreen();

	  if(note.id == null){
	    _showAlertDialog('Status', 'No Note was deleted');
	    return;
    }

	  int result = await helper.deleteNote(note.id);
	  if(result != 0){
	    _showAlertDialog('Satus', 'Note deleted successfully');
    }else{
	    _showAlertDialog('Status', 'Error ocurred while deleting note');
    }
  }

  void _showAlertDialog(String title, String message){
	  AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
	  showDialog(
      context: context,
      builder: (_) => alertDialog,
    );
  }
}
