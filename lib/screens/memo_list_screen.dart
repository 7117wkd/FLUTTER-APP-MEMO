import 'package:flutter/material.dart';
import '../db/memo_database.dart';
import '../models/memo.dart';
import 'memo_edit_screen.dart';

class MemoListScreen extends StatefulWidget {
  @override
  _MemoListScreenState createState() => _MemoListScreenState();
}

class _MemoListScreenState extends State<MemoListScreen> {
  List<Memo> memos = [];

  @override
  void initState() {
    super.initState();
    _loadMemos();
  }

  Future<void> _loadMemos() async {
    final data = await MemoDatabase.getMemos();
    setState(() {
      memos = data;
    });
  }

  Future<void> _deleteMemo(int id) async {
    await MemoDatabase.deleteMemo(id);
    _loadMemos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('📒 메모장')),
      body: memos.isEmpty
          ? Center(child: Text('메모가 없습니다'))
          : ListView.builder(
        itemCount: memos.length,
        itemBuilder: (context, index) {
          final memo = memos[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: ListTile(
              title: Text(
                memo.title.isEmpty ? '제목 없음' : memo.title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(memo.createdAt),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MemoEditScreen(memo: memo),
                  ),
                );
                _loadMemos();
              },
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteMemo(memo.id!),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MemoEditScreen()),
          );
          _loadMemos();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
