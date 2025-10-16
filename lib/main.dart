import 'package:flutter/material.dart';
import 'screens/memo_list_screen.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(primarySwatch: Colors.indigo),
    home: MemoListScreen(),
  ));
}
