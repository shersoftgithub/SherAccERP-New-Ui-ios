import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screen_ex/flutter_settings_screen_ex.dart';

// import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class HiveCache extends CacheProvider {
  Box ?_preferences;
  final String keyName = 'sheracc_erp_preferences';

  @override
  Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    if (!kIsWeb) {
      final defaultDirectory = await getApplicationDocumentsDirectory();
      Hive.init(defaultDirectory.path);
    }
    _preferences = await Hive.openBox(keyName);
  }

  Set get keys => getKeys();

  @override
  bool getBool(String key,{bool? defaultValue}) => _preferences!.get(key);
  
  @override
  double getDouble(String key, {double? defaultValue}) => _preferences!.get(key);

  @override
  int getInt(String key,{int? defaultValue}) => _preferences!.get(key);

  @override
  String getString(String key,{String? defaultValue}) => _preferences!.get(key);

  @override
  Future<void> setBool(String key, bool? value) => _preferences!.put(key, value);

  @override
  Future<void> setDouble(String key, double? value) => _preferences!.put(key, value);

  @override
  Future<void> setInt(String key, int? value) => _preferences!.put(key, value);

  @override
  Future<void> setString(String key, String? value) => _preferences!.put(key, value);

  @override
  Future<void> setObject<T>(String key, T? value) => _preferences!.put(key, value);

  @override
  bool containsKey(String key) => _preferences!.containsKey(key);

  @override
  Set getKeys() {
    return _preferences!.keys.toSet();
  }

  @override
  Future<void> remove(String key) async {
    if (containsKey(key)) {
      await _preferences!.delete(key);
    }
  }

  @override
  Future<void> removeAll() async {
    final keys = getKeys();
    await _preferences!.deleteAll(keys);
  }
  
  @override
  T? getValue<T>(String key, {T? defaultValue}) {
    var value = _preferences!.get(key);
    if (value is T) {
      return value;
    }
    return defaultValue;
  }
}
