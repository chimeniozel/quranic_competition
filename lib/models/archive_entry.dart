class ArchiveEntry {
  final String? title;
  final String? description;
  final List<String>? imageURL;
  final List<String>? videoURL; // optional

  ArchiveEntry({required this.title, required this.description, required this.imageURL, this.videoURL});
}
