import './social_link.dart';

class SignupData {
  final String email;
  final String password;
  final String name;
  final String phoneNo;
  final String about;
  final List<SocialLink> links;

  SignupData({
    required this.email,
    required this.password,
    required this.name,
    required this.phoneNo,
    this.about = '',
    this.links = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'phoneNo': phoneNo,
      'about': about,
      'links': links.map((link) => link.toJson()).toList(),
    };
  }

  // Helper method to print signup data (for debugging)
  void printData() {
    print('SignupData:');
    print('Email: $email');
    print('Name: $name');
    print('Phone: $phoneNo');
    print('About: $about');
    print('Links: ${links.map((l) => l.toJson())}');
  }
}