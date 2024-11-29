import 'package:cloud_firestore/cloud_firestore.dart';

class TajweedPostModel {
  String? _id; // Unique identifier for the post
  String _title; // Title of the Tajweed post
  String _content; // Detailed content of the post
  String _author; // Author or source of the post
  DateTime _createdAt; // Timestamp for when the post was created

  // Constructor
  TajweedPostModel({
    String? id,
    required String title,
    required String content,
    required String author,
    required DateTime createdAt,
  })  : _id = id,
        _title = title,
        _content = content,
        _author = author,
        _createdAt = createdAt;

  // Getters
  String? get id => _id;
  String get title => _title;
  String get content => _content;
  String get author => _author;
  DateTime get createdAt => _createdAt;

  // Setters
  set id(String? id) {
    _id = id;
  }

  set title(String title) {
    if (title.isNotEmpty) {
      _title = title;
    } else {
      throw ArgumentError("Title cannot be empty");
    }
  }

  set content(String content) {
    if (content.isNotEmpty) {
      _content = content;
    } else {
      throw ArgumentError("Content cannot be empty");
    }
  }

  set author(String author) {
    if (author.isNotEmpty) {
      _author = author;
    } else {
      throw ArgumentError("Author cannot be empty");
    }
  }

  set createdAt(DateTime createdAt) {
    _createdAt = createdAt;
  }

  // Factory constructor to create a TajweedPostModel from a Firestore document
  factory TajweedPostModel.fromMap(Map<String, dynamic> data) {
    return TajweedPostModel(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      author: data['author'] ?? 'Unknown',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Method to convert a TajweedPostModel instance to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': _id,
      'title': _title,
      'content': _content,
      'author': _author,
      'createdAt': _createdAt,
    };
  }
}
