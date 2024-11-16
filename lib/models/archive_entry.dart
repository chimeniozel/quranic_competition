import 'package:cloud_firestore/cloud_firestore.dart';

class ArchiveEntry {
  final List<String>? imagesURL;
  final List<String>? videosURL; // optional

  ArchiveEntry({
    this.imagesURL,
    this.videosURL,
  });

  // Convert ArchiveEntry to Map (for Firebase or other storage)
  Map<String, dynamic> toMap() {
    return {
      'imagesURL': FieldValue.arrayUnion(imagesURL!),
      'videosURL': FieldValue.arrayUnion(videosURL!),
    };
  }

  // Factory method to create ArchiveEntry from Map
  factory ArchiveEntry.fromMap(Map<String, dynamic> map) {
    return ArchiveEntry(
      imagesURL: List<String>.from(map['imagesURL'] ?? []),
      videosURL:
          map['videosURL'] != null ? List<String>.from(map['videosURL']) : null,
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
