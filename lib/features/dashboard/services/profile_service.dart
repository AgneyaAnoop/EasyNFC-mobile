
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../config/api_config.dart';
import '../models/profile.dart';

class ProfileService {
  final _storage = const FlutterSecureStorage();
  
  Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<List<Profile>> getAllProfiles() async {
    try {
      final token = await _getToken();
      if (token == null) throw APIConfig.tokenError;

      final response = await http.get(
        Uri.parse(APIConfig.allProfilesEndpoint),
        headers: APIConfig.authHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['profiles'] as List)
            .map((profile) => Profile.fromJson(profile))
            .toList();
      } else if (response.statusCode == 401) {
        throw APIConfig.unauthorizedError;
      } else {
        throw json.decode(response.body)['message'] ?? APIConfig.serverError;
      }
    } catch (e) {
      print('Error fetching profiles: $e');
      throw e.toString();
    }
  }

  Future<Profile> getActiveProfile() async {
    try {
      final token = await _getToken();
      if (token == null) throw APIConfig.tokenError;

      final response = await http.get(
        Uri.parse(APIConfig.activeProfileEndpoint),
        headers: APIConfig.authHeaders(token),
      );

      if (response.statusCode == 200) {
        return Profile.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        throw APIConfig.unauthorizedError;
      } else {
        throw json.decode(response.body)['message'] ?? APIConfig.serverError;
      }
    } catch (e) {
      print('Error fetching active profile: $e');
      throw e.toString();
    }
  }

  Future<void> switchProfile(int profileIndex) async {
    try {
      final token = await _getToken();
      if (token == null) throw APIConfig.tokenError;

      final response = await http.post(
        Uri.parse(APIConfig.switchProfileEndpoint),
        headers: APIConfig.authHeaders(token),
        body: json.encode({'profileIndex': profileIndex}),
      );

      if (response.statusCode != 200) {
        if (response.statusCode == 401) {
          throw APIConfig.unauthorizedError;
        }
        throw json.decode(response.body)['message'] ?? APIConfig.serverError;
      }
    } catch (e) {
      print('Error switching profile: $e');
      throw e.toString();
    }
  }

  Future<String> createProfile({
    required String name,
    required String phoneNo,
    required String about,
    required List<Map<String, dynamic>> links,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw APIConfig.tokenError;

      final response = await http.post(
        Uri.parse(APIConfig.createProfileEndpoint),
        headers: APIConfig.authHeaders(token),
        body: json.encode({
          'name': name,
          'phoneNo': phoneNo,
          'about': about,
          'links': links,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['profileUrl'];
      } else if (response.statusCode == 401) {
        throw APIConfig.unauthorizedError;
      } else {
        throw json.decode(response.body)['message'] ?? APIConfig.serverError;
      }
    } catch (e) {
      print('Error creating profile: $e');
      throw e.toString();
    }
  }

  Future<void> updateProfile({
    required String profileId,
    String? name,
    String? phoneNo,
    String? about,
    List<Map<String, dynamic>>? links,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw APIConfig.tokenError;

      final response = await http.put(
        Uri.parse(APIConfig.updateProfileEndpoint(profileId)),
        headers: APIConfig.authHeaders(token),
        body: json.encode({
          if (name != null) 'name': name,
          if (phoneNo != null) 'phoneNo': phoneNo,
          if (about != null) 'about': about,
          if (links != null) 'links': links,
        }),
      );

      if (response.statusCode != 200) {
        if (response.statusCode == 401) {
          throw APIConfig.unauthorizedError;
        }
        throw json.decode(response.body)['message'] ?? APIConfig.serverError;
      }
    } catch (e) {
      print('Error updating profile: $e');
      throw e.toString();
    }
  }

  Future<Profile> getProfileById(String profileId) async {
    try {
      final token = await _getToken();
      if (token == null) throw APIConfig.tokenError;

      final response = await http.get(
        Uri.parse(APIConfig.profileByIdEndpoint(profileId)),
        headers: APIConfig.authHeaders(token),
      );

      if (response.statusCode == 200) {
        return Profile.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        throw APIConfig.unauthorizedError;
      } else {
        throw json.decode(response.body)['message'] ?? APIConfig.serverError;
      }
    } catch (e) {
      print('Error fetching profile: $e');
      throw e.toString();
    }
  }

  Future<Profile> getPublicProfile(String urlSlug) async {
    try {
      final response = await http.get(
        Uri.parse(APIConfig.publicProfileBySlugEndpoint(urlSlug)),
        headers: APIConfig.headers,
      );

      if (response.statusCode == 200) {
        return Profile.fromJson(json.decode(response.body));
      } else {
        throw json.decode(response.body)['message'] ?? APIConfig.serverError;
      }
    } catch (e) {
      print('Error fetching public profile: $e');
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> getPublicProfiles({
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final response = await http.get(
        Uri.parse(APIConfig.publicProfilesEndpoint)
            .replace(queryParameters: queryParams),
        headers: APIConfig.headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw json.decode(response.body)['message'] ?? APIConfig.serverError;
      }
    } catch (e) {
      print('Error fetching public profiles: $e');
      throw e.toString();
    }
  }
}