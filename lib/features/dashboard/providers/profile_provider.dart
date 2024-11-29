import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/profile_service.dart';
import '../models/profile.dart';

final profileServiceProvider = Provider<ProfileService>((ref) => ProfileService());

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final profileService = ref.watch(profileServiceProvider);
  return ProfileNotifier(profileService);
});

class ProfileState {
  final List<Profile> profiles;
  final Profile? activeProfile;
  final bool isLoading;
  final String? error;

  ProfileState({
    this.profiles = const [],
    this.activeProfile,
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    List<Profile>? profiles,
    Profile? activeProfile,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      profiles: profiles ?? this.profiles,
      activeProfile: activeProfile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileService _profileService;

  ProfileNotifier(this._profileService) : super(ProfileState());

  Future<void> loadProfiles() async {
    try {
      state = state.copyWith(isLoading: true);
      final profiles = await _profileService.getAllProfiles();
      state = state.copyWith(
        profiles: profiles,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadActiveProfile() async {
    try {
      state = state.copyWith(isLoading: true);
      final profile = await _profileService.getActiveProfile();
      state = state.copyWith(
        activeProfile: profile,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> switchProfile(int index) async {
    try {
      state = state.copyWith(isLoading: true);
      await _profileService.switchProfile(index);
      await loadActiveProfile();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}