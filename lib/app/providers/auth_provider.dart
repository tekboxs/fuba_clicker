import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuba_clicker/app/models/user_data.dart';
import 'package:fuba_clicker/app/models/profile.dart';
import '../services/auth_service.dart';
import '../services/sync_service.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this.ref) : super(AuthState.initial()) {
    _initialize();
  }

  final Ref ref;
  final AuthService _authService = AuthService();

  Future<void> _initialize() async {
    await _authService.init();
    await ref.read(syncServiceProvider.notifier).init();

    final isAuthenticated = await _authService.isAuthenticated();
    if (isAuthenticated) {
      final user = await _authService.getCurrentUser();
      state = AuthState.authenticated(user);
    }
  }

  Future<bool> login(String email, String password) async {
    state = AuthState.loading();

    for (int attempt = 0; attempt < 2; attempt++) {
      try {
        await _authService.login(email, password);
        final user = await _authService.fetchUserData();

        state = AuthState.authenticated(user);
        return true;
      } catch (e) {
        if (attempt == 1) {
          state = AuthState.error(e.toString());
          return false;
        }
      }
    }

    return false;
  }

  Future<bool> register(String email, String username, String password) async {
    try {
      state = AuthState.loading();

      await _authService.register(email, username, password);

      final loginSuccess = await login(email, password);
      return loginSuccess;
    } catch (e) {
      state = AuthState.error(e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = AuthState.initial();
  }

  Future<void> refreshUserData() async {
    if (state.isAuthenticated) {
      try {
        final user = await _authService.fetchUserData();
        state = AuthState.authenticated(user);
      } catch (e) {
        state = AuthState.error(e.toString());
      }
    }
  }

  Future<bool> syncToCloud() async {
    if (!state.isAuthenticated) return false;

    try {
      return await ref
          .read(syncServiceProvider.notifier)
          .syncToCloud();
    } catch (e) {
      return false;
    }
  }

  Future<bool> loadFromCloud() async {
    if (!state.isAuthenticated) return false;

    try {
      return await ref
          .read(syncServiceProvider.notifier)
          .downloadCloudToLocal();
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateProfile(String profilePicture) async {
    if (!state.isAuthenticated || state.user == null) return false;

    try {
      final currentUser = state.user!;
      final updatedProfile = currentUser.profile?.copyWith(
            profilePicture: profilePicture,
          ) ??
          Profile(profilePicture: profilePicture);

      final userJson = currentUser.toJson();
      userJson['profile'] = updatedProfile.toJson();

      await _authService.updateUserData(userJson);

      final updatedUser = currentUser.copyWith(profile: updatedProfile);
      await _authService.saveUserData(updatedUser);
      state = AuthState.authenticated(updatedUser);

      return true;
    } catch (e) {
      return false;
    }
  }
}

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserData? user;
  final String? error;

  AuthState({
    required this.isLoading,
    required this.isAuthenticated,
    this.user,
    this.error,
  });

  factory AuthState.initial() {
    return AuthState(
      isLoading: false,
      isAuthenticated: false,
    );
  }

  factory AuthState.loading() {
    return AuthState(
      isLoading: true,
      isAuthenticated: false,
    );
  }

  factory AuthState.authenticated(UserData? user) {
    return AuthState(
      isLoading: false,
      isAuthenticated: true,
      user: user,
    );
  }

  factory AuthState.error(String error) {
    return AuthState(
      isLoading: false,
      isAuthenticated: false,
      error: error,
    );
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

final authStateProvider = Provider<AuthState>((ref) {
  return ref.watch(authNotifierProvider);
});

final currentUserProvider = Provider<UserData?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.isAuthenticated;
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});
