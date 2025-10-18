import 'dart:async';
import 'package:flutter/material.dart';
import '../db/memo_database.dart';
import '../models/memo.dart';
import 'package:intl/intl.dart';

class MemoEditScreen extends StatefulWidget {
  final Memo? memo;

  const MemoEditScreen({this.memo, Key? key}) : super(key: key);

  @override
  _MemoEditScreenState createState() => _MemoEditScreenState();
}

class _MemoEditScreenState extends State<MemoEditScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  Memo? _currentMemo; // ✅ 현재 메모 상태
  Timer? _debounce;   // ✅ 자동 저장 타이머
  bool _isSaving = false; // ✅ 저장 중 표시
  String _lastSavedTitle = '';
  String _lastSavedContent = '';

  @override
  void initState() {
    super.initState();
    if (widget.memo != null) {
      _currentMemo = widget.memo;
      _titleController.text = widget.memo!.title;
      _contentController.text = widget.memo!.content;
      _lastSavedTitle = widget.memo!.title;
      _lastSavedContent = widget.memo!.content;
    }

    // 화면 이탈 시 마지막 저장 보장
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ModalRoute.of(context)?.addScopedWillPopCallback(() async {
        await _forceSave();
        return true;
      });
    });
  }

  void _autoSave() {
    // ✅ 2초 안에 여러 번 호출되면 마지막만 실행
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(seconds: 2), () async {
      final title = _titleController.text.trim();
      final content = _contentController.text.trim();

      // 변경이 없으면 저장 스킵
      if (title == _lastSavedTitle && content == _lastSavedContent) return;

      setState(() => _isSaving = true);

      final now = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
      final memo = Memo(
        id: _currentMemo?.id,
        title: title,
        content: content,
        createdAt: now,
      );

      if (_currentMemo == null) {
        final newId = await MemoDatabase.insertMemo(memo);
        _currentMemo = Memo(
          id: newId,
          title: memo.title,
          content: memo.content,
          createdAt: memo.createdAt,
        );
      } else {
        await MemoDatabase.updateMemo(memo);
      }

      setState(() {
        _lastSavedTitle = title;
        _lastSavedContent = content;
        _isSaving = false;
      });

      // ✅ 저장 완료 시 하단 알림 (짧게 표시)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('자동 저장 완료', textAlign: TextAlign.center),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  Future<void> _forceSave() async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    await _persistMemo(); // ✅ 바로 저장 실행 (지연 X)
  }

  Future<void> _persistMemo() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title == _lastSavedTitle && content == _lastSavedContent) return;

    setState(() => _isSaving = true);

    final now = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    final memo = Memo(
      id: _currentMemo?.id,
      title: title,
      content: content,
      createdAt: now,
    );

    if (_currentMemo == null) {
      final newId = await MemoDatabase.insertMemo(memo);
      _currentMemo = Memo(
        id: newId,
        title: memo.title,
        content: memo.content,
        createdAt: memo.createdAt,
      );
    } else {
      await MemoDatabase.updateMemo(memo);
    }

    setState(() {
      _lastSavedTitle = title;
      _lastSavedContent = content;
      _isSaving = false;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('자동 저장 완료', textAlign: TextAlign.center),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.green,
      ),
    );
  }


  @override
  void dispose() {
    _debounce?.cancel();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('메모 작성'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(
                child: SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: '제목을 입력하세요',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _autoSave(),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: '내용을 입력하세요',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => _autoSave(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
