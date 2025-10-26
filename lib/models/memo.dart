class Memo {
  int? id;
  String title;
  String content;
  String createdAt;
  bool isFavorite; // ✅ 추가

  Memo({
    this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.isFavorite = false, // ✅ 기본값 false
  });

  // Map → Memo
  factory Memo.fromMap(Map<String, dynamic> map) {
    return Memo(
      id: map['id'],
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      createdAt: map['created_at'] ?? '',
      isFavorite: (map['is_favorite'] ?? 0) == 1, // ✅ DB에서 0/1 → bool
    );
  }

  // Memo → Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'created_at': createdAt,
      'is_favorite': isFavorite ? 1 : 0, // ✅ bool → 0/1 변환
    };
  }
}