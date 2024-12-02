
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

  // Helper for platform-specific URL formatting
  static String formatUrl(String platform, String value) {
    switch (platform.toLowerCase()) {
      case 'instagram':
        if (!value.startsWith('https://instagram.com/')) {
          return 'https://instagram.com/$value';
        }
        break;
      case 'twitter':
        if (!value.startsWith('https://twitter.com/')) {
          value = value.startsWith('@') ? value.substring(1) : value;
          return 'https://twitter.com/$value';
        }
        break;
      case 'whatsapp':
        if (!value.startsWith('https://wa.me/')) {
          // Remove any non-digit characters
          final number = value.replaceAll(RegExp(r'[^\d]'), '');
          return 'https://wa.me/$number';
        }
        break;
      case 'linkedin':
        if (!value.startsWith('https://linkedin.com/in/')) {
          return 'https://linkedin.com/in/$value';
        }
        break;
      case 'email':
        if (!value.startsWith('mailto:')) {
          return 'mailto:$value';
        }
        break;
    }
    return value;
  }

  Map<String, dynamic> toJson() => {
    'platform': platform,
    'url': url,
    'isCustom': isCustom,
    if (customTitle != null) 'customTitle': customTitle,
  };

  factory SocialLink.fromJson(Map<String, dynamic> json) => SocialLink(
    platform: json['platform'],
    url: json['url'],
    isCustom: json['isCustom'] ?? false,
    customTitle: json['customTitle'],
  );
}

