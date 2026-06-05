import 'package:flutter/foundation.dart';
import 'package:papirar/core/sync/app_sync_events.dart';
import 'package:papirar/features/perfil/di/profile_module.dart';
import 'package:papirar/features/perfil/domain/entities/user_profile.dart';
import 'package:papirar/features/perfil/domain/usecases/get_current_profile.dart';
import 'package:papirar/features/perfil/domain/usecases/update_profile.dart';
import 'package:papirar/features/perfil/domain/usecases/upload_profile_avatar.dart';

class ProfileController extends ChangeNotifier {
  final GetCurrentProfile _getCurrentProfile;
  final UpdateProfile _updateProfile;
  final UploadProfileAvatar _uploadProfileAvatar;

  static UserProfile? _lastKnownProfile;

  ProfileController({
    GetCurrentProfile? getCurrentProfile,
    UpdateProfile? updateProfile,
    UploadProfileAvatar? uploadProfileAvatar,
  }) : _getCurrentProfile =
           getCurrentProfile ?? ProfileModule.getCurrentProfile(),
       _updateProfile = updateProfile ?? ProfileModule.updateProfile(),
       _uploadProfileAvatar =
           uploadProfileAvatar ?? ProfileModule.uploadProfileAvatar();

  UserProfile? _profile = _lastKnownProfile;
  bool _isLoading = _lastKnownProfile == null;
  bool _isSaving = false;
  bool _isUploadingAvatar = false;
  String? _errorMessage;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isUploadingAvatar => _isUploadingAvatar;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    final hasCurrentProfile = _profile != null;
    _isLoading = !hasCurrentProfile;
    _errorMessage = null;
    if (!hasCurrentProfile) notifyListeners();

    try {
      _profile = await _getCurrentProfile();
      _lastKnownProfile = _profile;
    } catch (_) {
      _errorMessage = 'Não foi possível carregar seu perfil.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> save({
    required String displayName,
    required String username,
    required String bio,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _updateProfile(
        displayName: displayName.trim(),
        username: _normalizeUsername(username),
        bio: bio.trim(),
      );
      _lastKnownProfile = _profile;
      AppSyncEvents.instance.notifyProfileChanged();
      return true;
    } catch (_) {
      _errorMessage = 'Não foi possível salvar o perfil.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> uploadAvatar({
    required Uint8List bytes,
    required String extension,
  }) async {
    _isUploadingAvatar = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _uploadProfileAvatar(bytes: bytes, extension: extension);
      _lastKnownProfile = _profile;
      AppSyncEvents.instance.notifyProfileChanged();
      return true;
    } catch (_) {
      _errorMessage = 'Não foi possível enviar o avatar.';
      return false;
    } finally {
      _isUploadingAvatar = false;
      notifyListeners();
    }
  }

  String _normalizeUsername(String username) {
    return username.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');
  }
}
