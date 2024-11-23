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
  final String? _url;
  final String? _title;
  VideoEntry({
    String? url,
    String? title,
  })  : _url = url,
        _title = title;

  // Getters
  String? get url => _url;
  String? get title => _title;

  // Setters
  set url(String? value) {
    url = value;
  }

  set title(String? value) {
    title = value;
  }

  // Convert VideoEntry to Map (for Firebase or other storage)
  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'title': title,
    };
  }

  // Factory method to create VideoEntry from Map
  factory VideoEntry.fromMap(Map<String, dynamic> map) {
    return VideoEntry(
      url: map['url'],
      title: map['title'],
    );
  }
}
