class Profile {
  final String id;
  final String name;
  final String phoneNo;
  final String about;
  final List<dynamic> links;
  final String urlSlug;
  final String profileUrl;

  Profile({
    required this.id,
    required this.name,
    required this.phoneNo,
    required this.about,
    required this.links,
    required this.urlSlug,
    required this.profileUrl,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      name: json['name'],
      phoneNo: json['phoneNo'],
      about: json['about'],
      links: json['links'],
      urlSlug: json['urlSlug'],
      profileUrl: json['profileUrl'],
    );
  }
}