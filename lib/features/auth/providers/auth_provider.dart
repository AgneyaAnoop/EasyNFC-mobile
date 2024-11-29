
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../models/signup_data.dart';

// Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// Provider for AuthState
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

// Auth State class
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final String? token;

  AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.token,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    String? token,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      token: token ?? this.token,
    );
  }
}

// Auth Notifier class
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState()) {
    // Check authentication status when provider is created
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    try {
      state = state.copyWith(isLoading: true);
      final isAuthenticated = await _authService.isAuthenticated();
      
      if (isAuthenticated) {
        final token = await _authService.getStoredToken();
        state = state.copyWith(
          isAuthenticated: true,
          token: token,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }


  Future<void> login(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      print('Attempting login for email: $email'); // Debug log
      
      final token = await _authService.login(email, password);
      print('Login successful, token received'); // Debug log
      
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        token: token,
      );
    } catch (e) {
      print('Login error: $e'); // Debug log
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isAuthenticated: false,
      );
      rethrow;
    }
  }

  Future<void> register(SignupData data) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      print('Attempting registration for email: ${data.email}'); // Debug log
      
      final token = await _authService.register(data);
      print('Registration successful, token received'); // Debug log
      
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        token: token,
      );
    } catch (e) {
      print('Registration error: $e'); // Debug log
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isAuthenticated: false,
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      state = AuthState(); // Reset to initial state
    } catch (e) {
      print('Logout error: $e');
      state = state.copyWith(
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Check if user is authenticated
  Future<void> checkAuth() async {
    try {
      final token = await _authService.getStoredToken();
      if (token != null) {
        state = state.copyWith(
          isAuthenticated: true,
          token: token,
        );
      }
    } catch (e) {
      print('Check auth error: $e');
      await logout();
    }
  }
}