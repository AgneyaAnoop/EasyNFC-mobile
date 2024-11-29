// lib/config/api_config.dart
class APIConfig {
  // Backend URLs
  static const String baseUrl = 'https://easy-nfc-backend.vercel.app';
  static const String apiPath = '/api';
  static String get apiUrl => '$baseUrl$apiPath';

  // Frontend URL
  static const String frontendUrl = 'https://easy-nfc-frontend.vercel.app';

  // Auth Endpoints
  static String get authUrl => '$apiUrl/auth';
  static String get loginEndpoint => '$authUrl/login';
  static String get registerEndpoint => '$authUrl/register';
  static String get deleteUserEndpoint => '$authUrl/delete';
  static String get deleteUserWithPasswordEndpoint => '$authUrl/delete-with-password';

  // Profile Base URL
  static String get profileUrl => '$apiUrl/profile';

  // Protected Profile Endpoints
  static String get allProfilesEndpoint => '$profileUrl/all';
  static String get activeProfileEndpoint => '$profileUrl/active';
  static String get createProfileEndpoint => '$profileUrl/create';
  static String get switchProfileEndpoint => '$profileUrl/switch';
  
  // Profile endpoints that require ID
  static String profileByIdEndpoint(String profileId) => '$profileUrl/profile/$profileId';
  static String updateProfileEndpoint(String profileId) => '$profileUrl/update/$profileId';

  // Public Profile Endpoints
  static String get publicProfilesEndpoint => '$profileUrl/public';
  static String publicProfileBySlugEndpoint(String urlSlug) => '$profileUrl/public/$urlSlug';

  // Public URL for sharing (Frontend)
  static String getPublicProfileUrl(String urlSlug) => '$frontendUrl/$urlSlug';

  // Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
  };

  static Map<String, String> authHeaders(String token) => {
    ...headers,
    'Authorization': 'Bearer $token',
  };

  // Response Messages
  static const String tokenError = 'No authentication token found';
  static const String networkError = 'Network error occurred. Please check your connection.';
  static const String serverError = 'Server error occurred. Please try again later.';
  static const String unauthorizedError = 'Unauthorized access. Please login again.';
}