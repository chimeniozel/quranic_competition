class TajweedVideoModel {
  final String? _id;
  final String? _url;
  final String? _title;
  final DateTime? _createdAt;

  TajweedVideoModel({
    String? id,
    String? url,
    String? title,
    DateTime? createdAt,
  })  : _id = id,
        _url = url,
        _title = title,
        _createdAt = createdAt;

  // Getters
  String? get id => _id;
  String? get url => _url;
  String? get title => _title;
  DateTime? get createdAt => _createdAt;

  // Setters
  set id(String? id) {
    id = id;
  }

  set url(String? url) {
    url = url;
  }

  set title(String? title) {
    title = title;
  }

  set createdAt(DateTime? createdAt) {
    createdAt = createdAt;
  }

  // Convert TajweedVideoModel to Map (for Firebase or other storage)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url,
      'title': title,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  // Factory method to create TajweedVideoModel from Map
  factory TajweedVideoModel.fromMap(Map<String, dynamic> map) {
    return TajweedVideoModel(
      id: map['id'] as String?,
      url: map['url'] as String?,
      title: map['title'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
    );
  }
}
