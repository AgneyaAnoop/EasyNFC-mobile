
class SocialLink {
  final String platform;
  final String url;
  final bool isCustom;
  final String? customTitle;

  SocialLink({
    required this.platform,
    required this.url,
    this.isCustom = false,
    this.customTitle,
  });

  Map<String, dynamic> toJson() {
    return {
      'platform': platform,
      'url': url,
      'isCustom': isCustom,
      'customTitle': customTitle,
    };
  }
}