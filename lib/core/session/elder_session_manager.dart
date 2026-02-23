import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ElderSessionManager {
  ElderSessionManager._();

  /// ✅ Stronger Android secure storage (EncryptedSharedPreferences)
  static const AndroidOptions _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: _androidOptions,
  );

  // Keys (elder app)
  static const String _kElderUserId = "elder_user_id"; // returned as user_id
  static const String _kRoleId = "role_id";
  static const String _kLoggedIn = "elder_logged_in";

  static const String _kFullName = "elder_full_name";
  static const String _kEmail = "elder_email";
  static const String _kPhone = "elder_phone";
  static const String _kAddress = "elder_address";
  static const String _kDob = "elder_date_of_birth";
  static const String _kGender = "elder_gender";

  static const String _kFcmToken = "elder_fcm_token";
  static const String _kAppType = "elder_app_type"; // "elder"
  static const String _kDeviceModel = "elder_device_model";

  // --------------------------
  // Login flag
  // --------------------------
  static Future<void> setLoggedIn(bool value) async {
    await _storage.write(key: _kLoggedIn, value: value ? "true" : "false");
  }

  static Future<bool> isLoggedIn() async {
    final v = await _storage.read(key: _kLoggedIn);
    return v == "true";
  }

  // --------------------------
  // Elder user data
  // --------------------------
  static Future<void> saveElderUserId(int userId) async {
    await _storage.write(key: _kElderUserId, value: userId.toString());
    await setLoggedIn(true);
  }

  static Future<int?> getElderUserId() async {
    final v = await _storage.read(key: _kElderUserId);
    return int.tryParse(v ?? "");
  }

  static Future<void> saveRoleId(int roleId) async {
    await _storage.write(key: _kRoleId, value: roleId.toString());
  }

  static Future<int?> getRoleId() async {
    final v = await _storage.read(key: _kRoleId);
    return int.tryParse(v ?? "");
  }

  static Future<void> saveProfile({
    required String fullName,
    required String email,
    required String phone,
    required String address,
    required String dateOfBirth,
    required String gender,
  }) async {
    await _storage.write(key: _kFullName, value: fullName);
    await _storage.write(key: _kEmail, value: email);
    await _storage.write(key: _kPhone, value: phone);
    await _storage.write(key: _kAddress, value: address);
    await _storage.write(key: _kDob, value: dateOfBirth);
    await _storage.write(key: _kGender, value: gender);
  }

  static Future<String?> getFullName() => _storage.read(key: _kFullName);
  static Future<String?> getEmail() => _storage.read(key: _kEmail);
  static Future<String?> getPhone() => _storage.read(key: _kPhone);
  static Future<String?> getAddress() => _storage.read(key: _kAddress);
  static Future<String?> getDob() => _storage.read(key: _kDob);
  static Future<String?> getGender() => _storage.read(key: _kGender);

  // --------------------------
  // FCM
  // --------------------------
  static Future<void> saveFCMToken(String token) async {
    if (token.trim().isEmpty) return;
    await _storage.write(key: _kFcmToken, value: token.trim());
  }

  static Future<String?> getFCMToken() async {
    return await _storage.read(key: _kFcmToken);
  }

  static Future<void> clearFCMToken() async {
    await _storage.delete(key: _kFcmToken);
  }

  // --------------------------
  // Meta
  // --------------------------
  static Future<void> saveAppType(String appType) async {
    await _storage.write(key: _kAppType, value: appType);
  }

  static Future<String?> getAppType() async {
    return await _storage.read(key: _kAppType);
  }

  static Future<void> saveDeviceModel(String model) async {
    await _storage.write(key: _kDeviceModel, value: model);
  }

  static Future<String?> getDeviceModel() async {
    return await _storage.read(key: _kDeviceModel);
  }

  // --------------------------
  // Logout
  // --------------------------
  static Future<void> logout() async {
    await _storage.deleteAll(aOptions: _androidOptions);
  }

  static Future<Map<String, String>> dumpAll() async {
    return await _storage.readAll(aOptions: _androidOptions);
  }
}