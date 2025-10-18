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

  Future<void> _searchMemos(String keyword) async {
    if (keyword.isEmpty) {
      _loadMemos();
    } else {
      final results = await MemoDatabase.searchMemos(keyword);
      setState(() {
        memos = results;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('📒 메모장')),
      body: Column(
        children: [
          // 🔍 (1) 검색창 추가된 부분
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: '제목 또는 내용 검색',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                _searchMemos(value); // 검색 입력 시 호출
              },
            ),
          ),
          // 📋 (2) 기존 리스트 부분은 Expanded로 감쌈
          Expanded(
            child: memos.isEmpty
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
                      _loadMemos(); // 돌아오면 다시 목록 로드
                    },
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteMemo(memo.id!),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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
