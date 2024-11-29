import 'package:cloud_firestore/cloud_firestore.dart';

class ArchiveEntry {
  final List<String>? imagesURL;
  final List<VideoEntry>? videosURL; // optional

  ArchiveEntry({
    this.imagesURL,
    this.videosURL,
  });

  // Convert ArchiveEntry to Map
  Map<String, dynamic> toMap() {
    return {
      'imagesURL': imagesURL,
      'videosURL': videosURL?.map((video) => video.toMap()).toList(),
    };
  }

  // Factory method to create ArchiveEntry from Map
  factory ArchiveEntry.fromMap(Map<String, dynamic> map) {
    return ArchiveEntry(
      imagesURL: List<String>.from(map['imagesURL'] ?? []),
      videosURL: (map['videosURL'] is List)
          ? (map['videosURL'] as List)
              .map((videoMap) => VideoEntry.fromMap(
                  Map<String, dynamic>.from(videoMap as Map)))
              .toList()
          : (map['videosURL'] != null)
              ? [
                  VideoEntry.fromMap(
                      Map<String, dynamic>.from(map['videosURL'] as Map))
                ]
              : null,
    );
  }

  // Factory method to create ArchiveEntry from Firestore DocumentSnapshot
  factory ArchiveEntry.fromDocumentSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
    return ArchiveEntry.fromMap(data!);
  }

  // Factory method to create ArchiveEntry from Firestore QueryDocumentSnapshot
  factory ArchiveEntry.fromQueryDocumentSnapshot(QueryDocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
    return ArchiveEntry.fromMap(data!);
  }

  // ToString method for easier debugging and logging
  @override
  String toString() {
    return 'ArchiveEntry(imagesURL: $imagesURL, videosURL: $videosURL)';
  }
}

class VideoEntry {
  final String? _id;
  final String? _url;
  final String? _title;
  final DateTime? _createdAt;

  VideoEntry({
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

  // Convert VideoEntry to Map (for Firebase or other storage)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url,
      'title': title,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  // Factory method to create VideoEntry from Map
  factory VideoEntry.fromMap(Map<String, dynamic> map) {
    return VideoEntry(
      id: map['id'] as String?,
      url: map['url'] as String?,
      title: map['title'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
    );
  }
}
