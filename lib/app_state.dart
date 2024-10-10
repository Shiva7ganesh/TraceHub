class AppState {
  static final AppState _instance = AppState._internal();
  bool isAdmin = false;

  factory AppState() {
    return _instance;
  }

  AppState._internal();
}
