/// WorkValue - 設定データプロバイダー
/// アプリ設定、表示設定、通知設定を管理する状態管理クラス
library;

import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';

/// アプリケーション設定管理プロバイダー
/// ダークモード、通知設定、データ管理などの設定を管理
class SettingsProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _isNotificationEnabled = true;
  bool _isBreakReminderEnabled = true;
  bool _isLunchNotificationEnabled = true;
  bool _isEndNotificationEnabled = true;
  bool _isOvertimeWarningEnabled = true;
  
  /// ダークモード設定
  bool get isDarkMode => _isDarkMode;
  
  /// 通知機能の有効/無効
  bool get isNotificationEnabled => _isNotificationEnabled;
  
  /// 休憩リマインダー通知の有効/無効
  bool get isBreakReminderEnabled => _isBreakReminderEnabled;
  
  /// 昼休み成果通知の有効/無効
  bool get isLunchNotificationEnabled => _isLunchNotificationEnabled;
  
  /// 勤務終了通知の有効/無効
  bool get isEndNotificationEnabled => _isEndNotificationEnabled;
  
  /// サービス残業警告通知の有効/無効
  bool get isOvertimeWarningEnabled => _isOvertimeWarningEnabled;

  /// 設定の初期化
  /// ローカルストレージから設定値を復元
  Future<void> initialize() async {
    try {
      _isDarkMode = await StorageService.getBool('isDarkMode', false);
      _isNotificationEnabled = await StorageService.getBool('isNotificationEnabled', true);
      _isBreakReminderEnabled = await StorageService.getBool('isBreakReminderEnabled', true);
      _isLunchNotificationEnabled = await StorageService.getBool('isLunchNotificationEnabled', true);
      _isEndNotificationEnabled = await StorageService.getBool('isEndNotificationEnabled', true);
      _isOvertimeWarningEnabled = await StorageService.getBool('isOvertimeWarningEnabled', true);
      
      notifyListeners();
      debugPrint('✅ SettingsProvider初期化完了');
    } catch (e) {
      debugPrint('❌ SettingsProvider初期化エラー: $e');
    }
  }

  /// ダークモード切り替え
  Future<void> setDarkMode(bool value) async {
    if (_isDarkMode != value) {
      _isDarkMode = value;
      await StorageService.setBool('isDarkMode', value);
      notifyListeners();
      debugPrint('🌙 ダークモード: ${value ? "ON" : "OFF"}');
    }
  }

  /// 全通知の有効/無効切り替え
  Future<void> setNotificationEnabled(bool value) async {
    if (_isNotificationEnabled != value) {
      _isNotificationEnabled = value;
      await StorageService.setBool('isNotificationEnabled', value);
      notifyListeners();
      debugPrint('🔔 通知機能: ${value ? "ON" : "OFF"}');
    }
  }

  /// 休憩リマインダー通知の有効/無効切り替え
  Future<void> setBreakReminderEnabled(bool value) async {
    if (_isBreakReminderEnabled != value) {
      _isBreakReminderEnabled = value;
      await StorageService.setBool('isBreakReminderEnabled', value);
      notifyListeners();
      debugPrint('⏰ 休憩リマインダー: ${value ? "ON" : "OFF"}');
    }
  }

  /// 昼休み成果通知の有効/無効切り替え
  Future<void> setLunchNotificationEnabled(bool value) async {
    if (_isLunchNotificationEnabled != value) {
      _isLunchNotificationEnabled = value;
      await StorageService.setBool('isLunchNotificationEnabled', value);
      notifyListeners();
      debugPrint('🍽️ 昼休み通知: ${value ? "ON" : "OFF"}');
    }
  }

  /// 勤務終了通知の有効/無効切り替え
  Future<void> setEndNotificationEnabled(bool value) async {
    if (_isEndNotificationEnabled != value) {
      _isEndNotificationEnabled = value;
      await StorageService.setBool('isEndNotificationEnabled', value);
      notifyListeners();
      debugPrint('🏁 終了通知: ${value ? "ON" : "OFF"}');
    }
  }

  /// サービス残業警告通知の有効/無効切り替え
  Future<void> setOvertimeWarningEnabled(bool value) async {
    if (_isOvertimeWarningEnabled != value) {
      _isOvertimeWarningEnabled = value;
      await StorageService.setBool('isOvertimeWarningEnabled', value);
      notifyListeners();
      debugPrint('⚠️ 残業警告: ${value ? "ON" : "OFF"}');
    }
  }

  /// 全設定をデフォルトに戻す
  Future<void> resetAllSettings() async {
    try {
      await Future.wait([
        StorageService.setBool('isDarkMode', false),
        StorageService.setBool('isNotificationEnabled', true),
        StorageService.setBool('isBreakReminderEnabled', true),
        StorageService.setBool('isLunchNotificationEnabled', true),
        StorageService.setBool('isEndNotificationEnabled', true),
        StorageService.setBool('isOvertimeWarningEnabled', true),
      ]);
      
      _isDarkMode = false;
      _isNotificationEnabled = true;
      _isBreakReminderEnabled = true;
      _isLunchNotificationEnabled = true;
      _isEndNotificationEnabled = true;
      _isOvertimeWarningEnabled = true;
      
      notifyListeners();
      debugPrint('🔄 設定をリセットしました');
    } catch (e) {
      debugPrint('❌ 設定リセットエラー: $e');
    }
  }

  /// 設定データをエクスポート（バックアップ用）
  Map<String, dynamic> exportSettings() {
    return {
      'isDarkMode': _isDarkMode,
      'isNotificationEnabled': _isNotificationEnabled,
      'isBreakReminderEnabled': _isBreakReminderEnabled,
      'isLunchNotificationEnabled': _isLunchNotificationEnabled,
      'isEndNotificationEnabled': _isEndNotificationEnabled,
      'isOvertimeWarningEnabled': _isOvertimeWarningEnabled,
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  /// 設定データをインポート（復元用）
  Future<bool> importSettings(Map<String, dynamic> data) async {
    try {
      await Future.wait([
        setDarkMode(data['isDarkMode'] as bool? ?? false),
        setNotificationEnabled(data['isNotificationEnabled'] as bool? ?? true),
        setBreakReminderEnabled(data['isBreakReminderEnabled'] as bool? ?? true),
        setLunchNotificationEnabled(data['isLunchNotificationEnabled'] as bool? ?? true),
        setEndNotificationEnabled(data['isEndNotificationEnabled'] as bool? ?? true),
        setOvertimeWarningEnabled(data['isOvertimeWarningEnabled'] as bool? ?? true),
      ]);
      
      debugPrint('📥 設定をインポートしました');
      return true;
    } catch (e) {
      debugPrint('❌ 設定インポートエラー: $e');
      return false;
    }
  }
}