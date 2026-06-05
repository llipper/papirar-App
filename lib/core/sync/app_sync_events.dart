import 'package:flutter/foundation.dart';

class AppSyncEvents extends ChangeNotifier {
  AppSyncEvents._();

  static final AppSyncEvents instance = AppSyncEvents._();

  int _profileVersion = 0;
  int _studyActivityVersion = 0;

  int get profileVersion => _profileVersion;
  int get studyActivityVersion => _studyActivityVersion;

  void notifyProfileChanged() {
    _profileVersion++;
    notifyListeners();
  }

  void notifyStudyActivityChanged() {
    _studyActivityVersion++;
    notifyListeners();
  }
}
