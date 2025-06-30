import 'package:flutter/foundation.dart';
import '../../core/models/user.dart';
import '../../core/services/local_data_services.dart';

class AuthViewModel with ChangeNotifier {
  final LocalDataService _localDataService;

  bool _isLoading = false;
  String? _userRole;
  AppUser? _currentUser;

  AuthViewModel(this._localDataService) {
    _initializeUser();
  }

  bool get isLoading => _isLoading;
  String? get userRole => _userRole;
  AppUser? get currentUser => _currentUser;

  Future<void> _initializeUser() async {
    try {
      _userRole = await _localDataService.getUserRole();
      if (_userRole != null) {
        _currentUser = await _localDataService.getCurrentUser();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing user: $e');
    }
  }

  Future<void> login({required String email, required String password}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _userRole = await _localDataService.signIn(email, password);
      _currentUser = await _localDataService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await _localDataService.signOut();
      _userRole = null;
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }
}
