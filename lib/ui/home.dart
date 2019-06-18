import 'package:flutter/material.dart';
import 'package:todo/ui/todo_screen.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: Text("To Do List"),
        backgroundColor: Colors.redAccent.shade700,
        centerTitle: true,
      ),
      body: new ToDoScreen(),
    );
  }
}