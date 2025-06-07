import 'package:flutter/foundation.dart'; // For ChangeNotifier
import 'package:lucasbeatsfederacao/models/user_model.dart'; // Corrected import

class UserProvider extends ChangeNotifier {
  // CORREÇÃO: Usar UserModel
  UserModel? _user;
  bool _isLoading = true;
  bool _isUserDataLoaded = false;

  // CORREÇÃO: Usar UserModel
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isUserDataLoaded => _isUserDataLoaded;

  // CORREÇÃO: Usar UserModel
  void setUser(UserModel user) {
    _user = user;
    _isUserDataLoaded = true;
    _isLoading = false;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    _isUserDataLoaded = false;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

