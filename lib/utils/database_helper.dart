import 'dart:async';
import 'package:list_sqflite/models/note.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {

  static DatabaseHelper _databaseHelper;
  static Database _database;

  String noteTable = "note_table";
  String columnId = "id";
  String columnTitle = "title";
  String columnDescription = "description";
  String columnPriority = "priority";
  String columnDate = "date";

  DatabaseHelper._createInstance();


  factory DatabaseHelper(){
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if(_database == null){
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'notes.db';
    var notesDatabase = openDatabase(path, version: 1, onCreate: _onCreateDb);
    return notesDatabase;
  }

  void _onCreateDb(Database db, int newVersion) async {
    await db.execute('CREATE TABLE $noteTable('
        '$columnId INTEGER PRIMARY KEY AUTOINCREMENT,'
        '$columnTitle TEXT,'
        '$columnDescription TEXT,'
        '$columnPriority INTEGER,'
        '$columnDate TEXT)');
  }

  //GET DATABASE
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database;

    //var result = await db.rawQuery('SELECT * FROM $noteTable ORDER BY $columnPriority ASC');
    var result = await db.query(noteTable, orderBy: '$columnPriority ASC');
    return result;
  }

  //INSERT DATABASE
  Future<int> insertNote(Note note) async {
    Database db = await this.database;
    var result = await db.insert(noteTable, note.toMap());
    return result;
  }

  //UPDATE DATABE
  Future<int> updateNote(Note note) async {
    Database db = await this.database;
    var result = await db.update(noteTable, note.toMap(), where: '$columnId = ?', whereArgs: [note.id]);
    return result;
  }

  //DELETE DATABASE
  Future<int> deleteNote(int id) async {
    Database db = await this.database;
    var result = await db.rawDelete('DELETE FROM $noteTable WHERE $columnId = $id');
    return result;
  }

  //GET COUNT OF NOTE OBJECT IN DATABASE
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> i = await db.rawQuery('SELECT COUNT (*) FROM $noteTable');
    int result = Sqflite.firstIntValue(i);
    return result;
  }

  Future<List<Note>> getNoteList() async{
    var noteMapList = await getNoteMapList();
    int count = noteMapList.length;

    List<Note> noteList = List<Note>();

    for(int i=0; i < count; i++){
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }
    return noteList;
  }
}

