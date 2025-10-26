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
  String _sortOption = '최신순'; // 🔹 현재 정렬 상태 표시

  @override
  void initState() {
    super.initState();
    _loadMemos();
  }

  Future<void> _loadMemos() async {
    final data = await MemoDatabase.getMemos();
    setState(() {
      memos = _applySort(data); // 🔹 정렬 적용
    });
  }

  List<Memo> _applySort(List<Memo> list) {
    final sorted = List<Memo>.from(list);
    if (_sortOption == '제목순') {
      sorted.sort((a, b) => a.title.compareTo(b.title));
    } else {
      sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // 최신순
    }
    return sorted;
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
        memos = _applySort(results); // 검색 결과도 정렬 유지
      });
    }
  }

  // 🔽 정렬 버튼 눌렀을 때 순차적으로 바꾸기
  void _onSortPressed() {
    setState(() {
      _sortOption = _sortOption == '최신순' ? '제목순' : '최신순';
      memos = _applySort(memos);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('정렬: $_sortOption')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('📒 메모장')),
      body: Column(
        children: [
          // 🔍 (1) 검색창 + 정렬 아이콘
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // 검색창
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '제목 또는 내용 검색',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      _searchMemos(value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // 🔽 정렬 아이콘 버튼
                IconButton(
                  icon: const Icon(Icons.sort),
                  tooltip: '정렬',
                  onPressed: _onSortPressed,
                ),
              ],
            ),
          ),

          // 📋 (2) 기존 리스트 부분
          Expanded(
            child: memos.isEmpty
                ? Center(child: Text('메모가 없습니다'))
                : ListView.builder(
              itemCount: memos.length,
              itemBuilder: (context, index) {
                final memo = memos[index];
                return Card(
                  margin:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: ListTile(
                    title: Text(
                      memo.title.isEmpty ? '제목 없음' : memo.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
                      icon: const Icon(Icons.delete, color: Colors.red),
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
        child: const Icon(Icons.add),
      ),
    );
  }
}