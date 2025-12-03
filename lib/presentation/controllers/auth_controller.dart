import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/api/network_exceptions.dart';

/// Authentication state
enum AuthState { initial, loading, authenticated, unauthenticated, error }

/// Auth controller using ChangeNotifier
class AuthController extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthController(this._authRepository);

  AuthState _state = AuthState.initial;
  UserEntity? _user;
  String? _error;

  AuthState get state => _state;
  UserEntity? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;

  /// Initialize auth state by checking stored token
  Future<void> init() async {
    _state = AuthState.loading;
    notifyListeners();

    try {
      final isLoggedIn = await _authRepository.isAuthenticated();
      if (isLoggedIn) {
        _user = await _authRepository.getCurrentUser();
        _state = AuthState.authenticated;
      } else {
        _state = AuthState.unauthenticated;
      }
    } catch (e) {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  /// Register a new user
  Future<bool> register({
    required String name,
    required String phone,
    required String password,
    String? imageUrl,
  }) async {
    _state = AuthState.loading;
    _error = null;
    notifyListeners();

    try {
      final result = await _authRepository.register(
        name: name,
        phone: phone,
        password: password,
        imageUrl: imageUrl,
      );
      _user = result.user;
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = NetworkExceptions.getMessage(e);
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  /// Login with phone and password
  Future<bool> login({
    required String phone,
    required String password,
  }) async {
    _state = AuthState.loading;
    _error = null;
    notifyListeners();

    try {
      final result = await _authRepository.login(
        phone: phone,
        password: password,
      );
      _user = result.user;
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = NetworkExceptions.getMessage(e);
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? imageUrl,
  }) async {
    _state = AuthState.loading;
    _error = null;
    notifyListeners();

    try {
      final result = await _authRepository.updateProfile(
        name: name,
        phone: phone,
        imageUrl: imageUrl,
      );
      _user = result.user;
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = NetworkExceptions.getMessage(e);
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  /// Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _error = null;
    notifyListeners();

    try {
      await _authRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return true;
    } catch (e) {
      _error = NetworkExceptions.getMessage(e);
      notifyListeners();
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    await _authRepository.logout();
    _user = null;
    _state = AuthState.unauthenticated;
    _error = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    if (_state == AuthState.error) {
      _state = _user != null ? AuthState.authenticated : AuthState.unauthenticated;
    }
    notifyListeners();
  }
}
