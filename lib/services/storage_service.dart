/// WorkValue - ローカルストレージサービス
/// SharedPreferencesを使用したデータ永続化を管理
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ローカルストレージ管理サービス
/// アプリデータの永続化とCRUD操作を提供
class StorageService {
  static SharedPreferences? _prefs;
  
  /// サービスの初期化
  static Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      debugPrint('✅ StorageService初期化完了');
    } catch (e) {
      debugPrint('❌ StorageService初期化エラー: $e');
    }
  }
  
  /// SharedPreferencesインスタンスの取得
  static Future<SharedPreferences> get _preferences async {
    return _prefs ?? await SharedPreferences.getInstance();
  }

  /// 文字列の保存
  static Future<bool> setString(String key, String value) async {
    try {
      final prefs = await _preferences;
      final result = await prefs.setString(key, value);
      debugPrint('💾 文字列保存: $key = $value');
      return result;
    } catch (e) {
      debugPrint('❌ 文字列保存エラー ($key): $e');
      return false;
    }
  }

  /// 文字列の取得
  static Future<String?> getString(String key) async {
    try {
      final prefs = await _preferences;
      final value = prefs.getString(key);
      debugPrint('📖 文字列取得: $key = $value');
      return value;
    } catch (e) {
      debugPrint('❌ 文字列取得エラー ($key): $e');
      return null;
    }
  }

  /// 整数の保存
  static Future<bool> setInt(String key, int value) async {
    try {
      final prefs = await _preferences;
      final result = await prefs.setInt(key, value);
      debugPrint('💾 整数保存: $key = $value');
      return result;
    } catch (e) {
      debugPrint('❌ 整数保存エラー ($key): $e');
      return false;
    }
  }

  /// 整数の取得
  static Future<int> getInt(String key, int defaultValue) async {
    try {
      final prefs = await _preferences;
      final value = prefs.getInt(key) ?? defaultValue;
      debugPrint('📖 整数取得: $key = $value');
      return value;
    } catch (e) {
      debugPrint('❌ 整数取得エラー ($key): $e');
      return defaultValue;
    }
  }

  /// 浮動小数点数の保存
  static Future<bool> setDouble(String key, double value) async {
    try {
      final prefs = await _preferences;
      final result = await prefs.setDouble(key, value);
      debugPrint('💾 浮動小数点数保存: $key = $value');
      return result;
    } catch (e) {
      debugPrint('❌ 浮動小数点数保存エラー ($key): $e');
      return false;
    }
  }

  /// 浮動小数点数の取得
  static Future<double> getDouble(String key, double defaultValue) async {
    try {
      final prefs = await _preferences;
      final value = prefs.getDouble(key) ?? defaultValue;
      debugPrint('📖 浮動小数点数取得: $key = $value');
      return value;
    } catch (e) {
      debugPrint('❌ 浮動小数点数取得エラー ($key): $e');
      return defaultValue;
    }
  }

  /// 真偽値の保存
  static Future<bool> setBool(String key, bool value) async {
    try {
      final prefs = await _preferences;
      final result = await prefs.setBool(key, value);
      debugPrint('💾 真偽値保存: $key = $value');
      return result;
    } catch (e) {
      debugPrint('❌ 真偽値保存エラー ($key): $e');
      return false;
    }
  }

  /// 真偽値の取得
  static Future<bool> getBool(String key, bool defaultValue) async {
    try {
      final prefs = await _preferences;
      final value = prefs.getBool(key) ?? defaultValue;
      debugPrint('📖 真偽値取得: $key = $value');
      return value;
    } catch (e) {
      debugPrint('❌ 真偽値取得エラー ($key): $e');
      return defaultValue;
    }
  }

  /// マップ（JSON）の保存
  static Future<bool> setMap(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = jsonEncode(value);
      final result = await setString(key, jsonString);
      debugPrint('💾 マップ保存: $key');
      return result;
    } catch (e) {
      debugPrint('❌ マップ保存エラー ($key): $e');
      return false;
    }
  }

  /// マップ（JSON）の取得
  static Future<Map<String, dynamic>?> getMap(String key) async {
    try {
      final jsonString = await getString(key);
      if (jsonString == null) return null;
      
      final Map<String, dynamic> map = jsonDecode(jsonString);
      debugPrint('📖 マップ取得: $key');
      return map;
    } catch (e) {
      debugPrint('❌ マップ取得エラー ($key): $e');
      return null;
    }
  }

  /// リスト（JSON）の保存
  static Future<bool> setList(String key, List<dynamic> value) async {
    try {
      final jsonString = jsonEncode(value);
      final result = await setString(key, jsonString);
      debugPrint('💾 リスト保存: $key (${value.length}件)');
      return result;
    } catch (e) {
      debugPrint('❌ リスト保存エラー ($key): $e');
      return false;
    }
  }

  /// リスト（JSON）の取得
  static Future<List<dynamic>?> getList(String key) async {
    try {
      final jsonString = await getString(key);
      if (jsonString == null) return null;
      
      final List<dynamic> list = jsonDecode(jsonString);
      debugPrint('📖 リスト取得: $key (${list.length}件)');
      return list;
    } catch (e) {
      debugPrint('❌ リスト取得エラー ($key): $e');
      return null;
    }
  }

  /// データの削除
  static Future<bool> remove(String key) async {
    try {
      final prefs = await _preferences;
      final result = await prefs.remove(key);
      debugPrint('🗑️ データ削除: $key');
      return result;
    } catch (e) {
      debugPrint('❌ データ削除エラー ($key): $e');
      return false;
    }
  }

  /// すべてのデータをクリア
  static Future<bool> clear() async {
    try {
      final prefs = await _preferences;
      final result = await prefs.clear();
      debugPrint('🧹 全データクリア完了');
      return result;
    } catch (e) {
      debugPrint('❌ 全データクリアエラー: $e');
      return false;
    }
  }

  /// 保存されているキー一覧を取得
  static Future<Set<String>> getAllKeys() async {
    try {
      final prefs = await _preferences;
      final keys = prefs.getKeys();
      debugPrint('🔑 保存キー一覧: $keys');
      return keys;
    } catch (e) {
      debugPrint('❌ キー一覧取得エラー: $e');
      return {};
    }
  }

  /// 指定キーのデータが存在するか確認
  static Future<bool> containsKey(String key) async {
    try {
      final prefs = await _preferences;
      final exists = prefs.containsKey(key);
      debugPrint('🔍 データ存在確認: $key = $exists');
      return exists;
    } catch (e) {
      debugPrint('❌ データ存在確認エラー ($key): $e');
      return false;
    }
  }

  /// ストレージ使用量の概算取得（開発用）
  static Future<int> getStorageSize() async {
    try {
      final prefs = await _preferences;
      final keys = prefs.getKeys();
      int totalSize = 0;
      
      for (final key in keys) {
        final value = prefs.get(key);
        if (value != null) {
          totalSize += key.length + value.toString().length;
        }
      }
      
      debugPrint('📊 ストレージ使用量概算: ${totalSize}文字');
      return totalSize;
    } catch (e) {
      debugPrint('❌ ストレージ使用量取得エラー: $e');
      return 0;
    }
  }

  /// データのバックアップ作成
  static Future<Map<String, dynamic>> createBackup() async {
    try {
      final prefs = await _preferences;
      final keys = prefs.getKeys();
      final Map<String, dynamic> backup = {};
      
      for (final key in keys) {
        backup[key] = prefs.get(key);
      }
      
      backup['backupCreatedAt'] = DateTime.now().toIso8601String();
      debugPrint('💾 バックアップ作成完了: ${keys.length}件');
      return backup;
    } catch (e) {
      debugPrint('❌ バックアップ作成エラー: $e');
      return {};
    }
  }

  /// バックアップからの復元
  static Future<bool> restoreFromBackup(Map<String, dynamic> backup) async {
    try {
      final prefs = await _preferences;
      
      // 既存データをクリア
      await prefs.clear();
      
      // バックアップデータを復元
      for (final entry in backup.entries) {
        if (entry.key == 'backupCreatedAt') continue;
        
        final value = entry.value;
        if (value is String) {
          await prefs.setString(entry.key, value);
        } else if (value is int) {
          await prefs.setInt(entry.key, value);
        } else if (value is double) {
          await prefs.setDouble(entry.key, value);
        } else if (value is bool) {
          await prefs.setBool(entry.key, value);
        }
      }
      
      debugPrint('📥 バックアップ復元完了: ${backup.length - 1}件');
      return true;
    } catch (e) {
      debugPrint('❌ バックアップ復元エラー: $e');
      return false;
    }
  }
}