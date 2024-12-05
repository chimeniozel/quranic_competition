class AboutUsModel {
  String? _description;
  String? _facebookUrl;
  String? _youtubeUrl;
  String? _whatsappPhoneNumber;
  AboutUsModel({
    String? description,
    String? facebookUrl,
    String? youtubeUrl,
    String? whatsappPhoneNumber,
  })  :
        _description = description,
        _facebookUrl = facebookUrl,
        _youtubeUrl = youtubeUrl,
        _whatsappPhoneNumber = whatsappPhoneNumber;

  // Getters
  String? get description => _description;
  String? get facebookUrl => _facebookUrl;
  String? get youtubeUrl => _youtubeUrl;
  String? get whatsappPhoneNumber => _whatsappPhoneNumber;

  // Setters
  void updateDescription(String? description) {
    _description = description;
  }

  void updateFacebookUrl(String? facebookUrl) {
    _facebookUrl = facebookUrl;
  }

  void updateYoutubeUrl(String? youtubeUrl) {
    _youtubeUrl = youtubeUrl;
  }

  void updateWhatsappPhoneNumber(String? whatsappPhoneNumber) {
    _whatsappPhoneNumber = whatsappPhoneNumber;
  }

  // to Map
  Map<String, dynamic> toMap() {
    return {
      'description': _description,
      'facebookUrl': _facebookUrl,
      'youtubeUrl': _youtubeUrl,
      'whatsappPhoneNumber': _whatsappPhoneNumber,
    };
  }

  // from map
  static AboutUsModel fromMap(Map<String, dynamic> map) {
    return AboutUsModel(
      description: map['description'],
      facebookUrl: map['facebookUrl'],
      youtubeUrl: map['youtubeUrl'],
      whatsappPhoneNumber: map['whatsappPhoneNumber'],
    );
  }
}
