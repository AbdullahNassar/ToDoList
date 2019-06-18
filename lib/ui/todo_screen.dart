import 'package:flutter/material.dart';
import 'package:todo/model/todo_item.dart';
import 'package:todo/util/database_client.dart';
import 'package:todo/util/date_formatter.dart';

class ToDoScreen extends StatefulWidget {
  @override
  _ToDoScreenState createState() => _ToDoScreenState();
}

class _ToDoScreenState extends State<ToDoScreen> {
  final _textEdittingController = new TextEditingController();
  var db = new DatabaseHelper();
  final List<ToDoItem> _itemList = <ToDoItem>[];
  @override
  void initState() {
    super.initState();
    _readToDoList();
  }
  void _handleSubmit(String text) async{
    _textEdittingController.clear();
    ToDoItem toDoItem = new ToDoItem(text, dateFormatted());
    int savedItemId = await db.saveItem(toDoItem);
    ToDoItem addedItem = await db.getItem(savedItemId);

    setState(() {
      _itemList.insert(0, addedItem); 
    });

    //print("Item saved id: $savedItemId");
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Flexible(
            child: ListView.builder(
              padding: EdgeInsets.all(8.0),
              reverse: false,
              itemCount: _itemList.length,
              itemBuilder: (_, int index){
                return Card(
                  color: Colors.white,
                  child: ListTile(
                    title: _itemList[index],
                    onLongPress: () => _updateItem(_itemList[index],index),
                    leading: new Listener(
                      key: Key(_itemList[index].itemName),
                      child: Icon(Icons.remove_circle, color: Colors.redAccent.shade700,),
                      onPointerDown: (pointerEvent) => _deleteToDo(_itemList[index].id,index),
                    ),
                  ),
                );
              },
            ),
          ),
          new Divider(
            height: 1.0,
          )
        ],
      ),
      floatingActionButton: new FloatingActionButton(
        backgroundColor: Colors.redAccent.shade700,
        tooltip: "Add Item",
        child: new ListTile(
          title: Icon(Icons.add),
        ),
        onPressed: _showFromDialog,
      ),
    );
  }

  void _showFromDialog() {
    var alert = new AlertDialog(
      content: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              cursorColor: Colors.redAccent.shade700,
              controller: _textEdittingController,
              autofocus: true,
              decoration: InputDecoration(
                  fillColor: Colors.redAccent.shade700,
                  labelStyle: new TextStyle(color: Colors.redAccent.shade700),
                  labelText: "Add New Item",
                  hintText: "Things to do...",
                  icon: Icon(Icons.note_add, color: Colors.redAccent.shade700,)
              ),
            ),
          )
        ],
      ),
      actions: <Widget>[
        FlatButton(onPressed: () {
            _handleSubmit(_textEdittingController.text);
            _textEdittingController.clear();
            Navigator.pop(context);
          },
          child: Text("Save",style: TextStyle(color: Colors.redAccent.shade700),),
        ),
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel",style: TextStyle(color: Colors.redAccent.shade700)),
        ),
      ],
    );
    showDialog(context: context, builder: (_){
      return alert;
    });
  }

  _readToDoList() async{
    List items = await db.getItems();
    items.forEach((item){
      //ToDoItem toDoItem = ToDoItem.fromMap(item);
      setState(() {
        _itemList.add(ToDoItem.map(item)); 
      });
      //print("DB Items: ${toDoItem.itemName}");
    });
  }

  _deleteToDo(int id, int index) async {
    //debugPrint("Deleted Item");
    await db.deleteItem(id);
    setState(() {
      _itemList.removeAt(index); 
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text("Item Deleted"),
          backgroundColor: Colors.redAccent.shade700,
        )
      );
    });
  }

   _updateItem(ToDoItem item, int index) async {
    var alert = new AlertDialog(
      content: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              cursorColor: Colors.redAccent.shade700,
              controller: _textEdittingController,
              autofocus: true,
              decoration: InputDecoration(
                  fillColor: Colors.redAccent.shade700,
                  labelStyle: new TextStyle(color: Colors.redAccent.shade700),
                  labelText: "Update Item",
                  hintText: "Things to do...",
                  icon: Icon(Icons.note_add, color: Colors.redAccent.shade700,)
              ),
            ),
          )
        ],
      ),
      actions: <Widget>[
        FlatButton(onPressed: () async{
            ToDoItem itemUpdated = ToDoItem.fromMap(
              {
                "itemName": _textEdittingController.text,
                "dateCreated": dateFormatted(),
                "id": item.id
              }
            );
            _handleUpdatedItem(index, item);
            await db.updateItem(itemUpdated);
            setState(() {
              _readToDoList(); 
            });
            _textEdittingController.clear();
            Navigator.pop(context);
          },
          child: Text("Save",style: TextStyle(color: Colors.redAccent.shade700),),
        ),
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel",style: TextStyle(color: Colors.redAccent.shade700)),
        ),
      ],
    );
    showDialog(context: context, builder: (_){
      return alert;
    });
  }

  void _handleUpdatedItem(int index, ToDoItem item){
    setState(() {
      _itemList.removeWhere((element){
        _itemList[index].itemName == item.itemName;
      }); 
    });
  }
}
