import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ElderSessionManager {
  ElderSessionManager._();

  static const AndroidOptions _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: _androidOptions,
  );

  // Keys
  static const String _kElderUserId = "elder_user_id";
  static const String _kRoleId = "elder_role_id";
  static const String _kLoggedIn = "elder_logged_in";

  static const String _kFullName = "elder_full_name";
  static const String _kEmail = "elder_email";
  static const String _kPhone = "elder_phone";
  static const String _kAddress = "elder_address";
  static const String _kDob = "elder_date_of_birth";
  static const String _kGender = "elder_gender";
  static const String _kCreatedAt = "elder_created_at";

  static const String _kRelationshipId = "elder_relationship_id";
  static const String _kCaregiverId = "elder_caregiver_id";

  static const String _kEmergencyPhone = "elder_emergency_phone";

  static const String _kFcmToken = "elder_fcm_token";
  static const String _kAppType = "elder_app_type";
  static const String _kDeviceModel = "elder_device_model";
  static const String _kTimezone = "elder_timezone";

  // Logged-in flag
  static Future<void> setLoggedIn(bool value) async {
    await _storage.write(key: _kLoggedIn, value: value ? "true" : "false");
  }

  static Future<bool> isLoggedIn() async {
    final v = await _storage.read(key: _kLoggedIn);
    return v == "true";
  }

  // Save meta (app/device/timezone)
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

  static Future<void> saveTimezone(String tz) async {
    await _storage.write(key: _kTimezone, value: tz);
  }

  static Future<String?> getTimezone() async {
    return await _storage.read(key: _kTimezone);
  }

  // Save FCM token
  static Future<void> saveFCMToken(String token) async {
    if (token.trim().isEmpty) return;
    await _storage.write(key: _kFcmToken, value: token.trim());
  }

  static Future<String?> getFCMToken() async {
    return await _storage.read(key: _kFcmToken);
  }

  // Save login response (FULL)
  static Future<void> saveLoginResponse(Map<String, dynamic> data) async {
    await _storage.write(key: _kElderUserId, value: data["user_id"].toString());
    await _storage.write(key: _kRoleId, value: data["role_id"].toString());

    await _storage.write(key: _kFullName, value: (data["full_name"] ?? "").toString());
    await _storage.write(key: _kEmail, value: (data["email"] ?? "").toString());
    await _storage.write(key: _kPhone, value: (data["phone"] ?? "").toString());
    await _storage.write(key: _kAddress, value: (data["address"] ?? "").toString());
    await _storage.write(key: _kDob, value: (data["date_of_birth"] ?? "").toString());
    await _storage.write(key: _kGender, value: (data["gender"] ?? "").toString());
    await _storage.write(key: _kCreatedAt, value: (data["created_at"] ?? "").toString());

    // optional relationship mapping
    if (data["relationshipid"] != null) {
      await _storage.write(key: _kRelationshipId, value: data["relationshipid"].toString());
    }
    if (data["caregiverid"] != null) {
      await _storage.write(key: _kCaregiverId, value: data["caregiverid"].toString());
    }

    //  NEW: emergency phone (can be null)
    if (data["emergency_phone"] != null) {
      await _storage.write(
        key: _kEmergencyPhone,
        value: data["emergency_phone"].toString(),
      );
    } else {
      // optionally clear it if backend returned null
      await _storage.delete(key: _kEmergencyPhone);
    }

    await setLoggedIn(true);
  }

  // Getters (commonly used)
  static Future<int?> getElderUserId() async {
    final v = await _storage.read(key: _kElderUserId);
    return int.tryParse(v ?? "");
  }

  static Future<int?> getRoleId() async {
    final v = await _storage.read(key: _kRoleId);
    return int.tryParse(v ?? "");
  }

  static Future<String?> getFullName() async {
    return await _storage.read(key: _kFullName);
  }

  static Future<String?> getEmail() async {
    return await _storage.read(key: _kEmail);
  }

  static Future<int?> getRelationshipId() async {
    final v = await _storage.read(key: _kRelationshipId);
    return int.tryParse(v ?? "");
  }

  static Future<int?> getCaregiverId() async {
    final v = await _storage.read(key: _kCaregiverId);
    return int.tryParse(v ?? "");
  }

  static Future<String?> getEmergencyPhone() async {
    return await _storage.read(key: _kEmergencyPhone);
  }

  // Debug dump
  static Future<void> debugPrintAll() async {
    final all = await _storage.readAll(aOptions: _androidOptions);
    // ignore: avoid_print
    all.forEach((k, v) {
      // ignore: avoid_print
      print("$k => $v");
    });
    // ignore: avoid_print

  }

  // Logout
  static Future<void> logout() async {
    await _storage.deleteAll(aOptions: _androidOptions);
  }
}