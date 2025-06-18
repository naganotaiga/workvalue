/// WorkValue - 通知サービス
/// iOS専用ローカル通知機能を提供
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// iOS専用通知管理サービス
/// 勤務開始・終了・休憩・残業警告などの通知を管理
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  static bool _initialized = false;

  /// 通知サービスの初期化
  static Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      // iOS専用初期化設定
      const initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
      );
      
      const initializationSettings = InitializationSettings(
        iOS: initializationSettingsIOS,
      );
      
      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      );
      
      // 通知権限のリクエスト
      await _requestPermissions();
      
      _initialized = true;
      debugPrint('✅ NotificationService初期化完了');
    } catch (e) {
      debugPrint('❌ NotificationService初期化エラー: $e');
    }
  }

  /// 通知権限のリクエスト
  static Future<bool> _requestPermissions() async {
    try {
      final result = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      
      debugPrint('🔔 通知権限: ${result ?? false}');
      return result ?? false;
    } catch (e) {
      debugPrint('❌ 通知権限リクエストエラー: $e');
      return false;
    }
  }

  /// iOS専用通知受信コールバック
  static void _onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    debugPrint('📱 iOS通知受信: $title - $body');
  }

  /// 通知タップ時のコールバック
  static void _onDidReceiveNotificationResponse(
      NotificationResponse response) {
    debugPrint('👆 通知タップ: ${response.payload}');
  }

  /// 勤務開始通知
  static Future<void> showWorkStartNotification() async {
    if (!_initialized) await initialize();
    
    try {
      const notificationDetails = NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'default',
          categoryIdentifier: 'work_start',
        ),
      );
      
      await _notificationsPlugin.show(
        1001,
        '勤務開始',
        '今日も一日頑張りましょう！💪',
        notificationDetails,
        payload: 'work_start',
      );
      
      debugPrint('🚀 勤務開始通知を送信');
    } catch (e) {
      debugPrint('❌ 勤務開始通知エラー: $e');
    }
  }

  /// 勤務終了通知
  static Future<void> showWorkEndNotification(
      double totalIncome, double totalLoss) async {
    if (!_initialized) await initialize();
    
    try {
      String body;
      if (totalLoss > 0) {
        body = 'お疲れ様！今日は${totalIncome.toInt()}円稼ぎました。\nサービス残業損失: ${totalLoss.toInt()}円 ⚠️';
      } else {
        body = 'お疲れ様！今日は${totalIncome.toInt()}円稼ぎました！🎉';
      }
      
      const notificationDetails = NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'default',
          categoryIdentifier: 'work_end',
        ),
      );
      
      await _notificationsPlugin.show(
        1002,
        '勤務終了',
        body,
        notificationDetails,
        payload: 'work_end:$totalIncome:$totalLoss',
      );
      
      debugPrint('🏁 勤務終了通知を送信: ${totalIncome}円');
    } catch (e) {
      debugPrint('❌ 勤務終了通知エラー: $e');
    }
  }

  /// 昼休み成果通知
  static Future<void> showLunchNotification(double morningIncome) async {
    if (!_initialized) await initialize();
    
    try {
      const notificationDetails = NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'default',
          categoryIdentifier: 'lunch',
        ),
      );
      
      await _notificationsPlugin.show(
        1003,
        'お昼休み',
        '午前中で${morningIncome.toInt()}円稼ぎました！🍽️\nランチを楽しんでください♪',
        notificationDetails,
        payload: 'lunch:$morningIncome',
      );
      
      debugPrint('🍽️ 昼休み通知を送信: ${morningIncome}円');
    } catch (e) {
      debugPrint('❌ 昼休み通知エラー: $e');
    }
  }

  /// 休憩リマインダー通知
  static Future<void> showBreakReminderNotification() async {
    if (!_initialized) await initialize();
    
    try {
      const notificationDetails = NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'default',
          categoryIdentifier: 'break_reminder',
        ),
      );
      
      await _notificationsPlugin.show(
        1004,
        '休憩リマインダー',
        '1時間経過しました。少し休憩しませんか？☕',
        notificationDetails,
        payload: 'break_reminder',
      );
      
      debugPrint('☕ 休憩リマインダー通知を送信');
    } catch (e) {
      debugPrint('❌ 休憩リマインダー通知エラー: $e');
    }
  }

  /// サービス残業警告通知
  static Future<void> showOvertimeWarningNotification(double lossAmount) async {
    if (!_initialized) await initialize();
    
    try {
      const notificationDetails = NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'default',
          categoryIdentifier: 'overtime_warning',
        ),
      );
      
      await _notificationsPlugin.show(
        1005,
        'サービス残業警告',
        '定時を過ぎています⚠️\n損失額: ${lossAmount.toInt()}円',
        notificationDetails,
        payload: 'overtime_warning:$lossAmount',
      );
      
      debugPrint('⚠️ サービス残業警告通知を送信: ${lossAmount}円');
    } catch (e) {
      debugPrint('❌ サービス残業警告通知エラー: $e');
    }
  }

  /// 定期通知のスケジュール設定
  static Future<void> scheduleBreakReminders() async {
    if (!_initialized) await initialize();
    
    try {
      // 既存の定期通知をキャンセル
      await _notificationsPlugin.cancelAll();
      
      // 1時間ごとの休憩リマインダーを設定
      const notificationDetails = NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'default',
          categoryIdentifier: 'scheduled_break',
        ),
      );
      
      // 1時間後から4時間まで、1時間ごとに通知（簡易実装）
      for (int i = 1; i <= 4; i++) {
        await _notificationsPlugin.show(
          2000 + i,
          '休憩リマインダー',
          '$i時間経過しました。適度な休憩を取りましょう☕',
          notificationDetails,
          payload: 'scheduled_break:$i',
        );
      }
      
      debugPrint('⏰ 定期休憩リマインダーを設定（4時間分）');
    } catch (e) {
      debugPrint('❌ 定期通知設定エラー: $e');
    }
  }

  /// すべての通知をキャンセル
  static Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
      debugPrint('🔕 すべての通知をキャンセル');
    } catch (e) {
      debugPrint('❌ 通知キャンセルエラー: $e');
    }
  }

  /// 特定の通知をキャンセル
  static Future<void> cancelNotification(int id) async {
    try {
      await _notificationsPlugin.cancel(id);
      debugPrint('🔕 通知をキャンセル: ID $id');
    } catch (e) {
      debugPrint('❌ 通知キャンセルエラー (ID $id): $e');
    }
  }

  /// 通知権限の確認
  static Future<bool> checkPermissions() async {
    try {
      final result = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.checkPermissions();
      
      return result != null;
    } catch (e) {
      debugPrint('❌ 通知権限確認エラー: $e');
      return false;
    }
  }

  /// 通知履歴の取得（iOS 14以降）
  static Future<List<ActiveNotification>> getActiveNotifications() async {
    try {
      final notifications = await _notificationsPlugin.getActiveNotifications();
      debugPrint('📋 アクティブ通知数: ${notifications.length}');
      return notifications;
    } catch (e) {
      debugPrint('❌ アクティブ通知取得エラー: $e');
      return [];
    }
  }

  /// カスタム通知の送信
  static Future<void> showCustomNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String? sound,
  }) async {
    if (!_initialized) await initialize();
    
    try {
      final notificationDetails = NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: sound ?? 'default',
          categoryIdentifier: 'custom',
        ),
      );
      
      await _notificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
      
      debugPrint('📨 カスタム通知を送信: $title');
    } catch (e) {
      debugPrint('❌ カスタム通知エラー: $e');
    }
  }
}