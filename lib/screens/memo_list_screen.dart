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
  String _sortOption = '최신순';

  // ⭐ 별 색상 상태만 따로 관리 (id 기준)
  final Set<int> _favoriteIds = {};

  @override
  void initState() {
    super.initState();
    _loadMemos();
  }

  Future<void> _loadMemos() async {
    final data = await MemoDatabase.getMemos();
    setState(() {
      memos = _applySort(data);
    });
  }

  List<Memo> _applySort(List<Memo> list) {
    final sorted = List<Memo>.from(list);

    if (_sortOption == '제목순') {
      sorted.sort((a, b) => a.title.compareTo(b.title));
    } else if (_sortOption == '즐겨찾기순') {
      // ⭐ 즐겨찾기(true)가 먼저 오게
      sorted.sort((a, b) {
        if (a.isFavorite && !b.isFavorite) return -1;
        if (!a.isFavorite && b.isFavorite) return 1;
        return 0;
      });
    } else {
      // 최신순
      sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return sorted;
  }

  Future<void> _deleteMemo(int id) async {
    await MemoDatabase.deleteMemo(id);
    setState(() {
      _favoriteIds.remove(id); // 삭제 시 즐겨찾기 상태도 같이 제거
    });
    _loadMemos();
  }

  Future<void> _searchMemos(String keyword) async {
    if (keyword.isEmpty) {
      _loadMemos();
    } else {
      final results = await MemoDatabase.searchMemos(keyword);
      setState(() {
        memos = _applySort(results);
      });
    }
  }

  void _onSortPressed() {
    setState(() {
      if (_sortOption == '최신순') {
        _sortOption = '제목순';
      } else if (_sortOption == '제목순') {
        _sortOption = '즐겨찾기순';
      } else {
        _sortOption = '최신순';
      }

      memos = _applySort(memos);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('정렬: $_sortOption')),
    );
  }

  // ⭐ 즐겨찾기 토글 (DB 영향 없음)
  void _toggleFavorite(Memo memo) async {
    setState(() {
      memo.isFavorite = !memo.isFavorite; // ✅ 상태 변경
    });
    await MemoDatabase.updateMemo(memo); // ✅ DB 반영
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📒 메모장')),
      body: Column(
        children: [
          // 🔍 검색창 + 정렬 버튼
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
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
                IconButton(
                  icon: const Icon(Icons.sort),
                  tooltip: '정렬',
                  onPressed: _onSortPressed,
                ),
              ],
            ),
          ),

          // 📋 메모 리스트
          Expanded(
            child: memos.isEmpty
                ? const Center(child: Text('메모가 없습니다'))
                : ListView.builder(
              itemCount: memos.length,
              itemBuilder: (context, index) {
                final memo = memos[index];
                final isFav = _favoriteIds.contains(memo.id);

                return Card(
                  margin:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: ListTile(
                    title: Text(
                      memo.title.isEmpty ? '제목 없음' : memo.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(memo.createdAt),
                    // ⭐ 즐겨찾기 UI
                    leading: IconButton(
                      icon: Icon(
                        memo.isFavorite ? Icons.star : Icons.star_border,
                        color: memo.isFavorite ? Colors.amber : Colors.grey,
                      ),
                      onPressed: () => _toggleFavorite(memo),
                    ),
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