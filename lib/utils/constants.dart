/// WorkValue - アプリケーション定数
/// アプリ全体で使用する定数値、設定値、文字列リソースを定義
library;

/// アプリケーション基本情報
class AppConstants {
  /// アプリ名
  static const String appName = 'WorkValue';
  
  /// アプリバージョン
  static const String appVersion = '1.0.0';
  
  /// アプリ説明
  static const String appDescription = '労働時間を金額で可視化するiOS専用モチベーションアプリ';
  
  /// 開発者情報
  static const String developerName = 'WorkValue Team';
  
  /// サポートメール
  static const String supportEmail = 'support@workvalue.app';
  
  /// プライバシーポリシーURL
  static const String privacyPolicyUrl = 'https://workvalue.app/privacy';
  
  /// 利用規約URL
  static const String termsOfServiceUrl = 'https://workvalue.app/terms';
}

/// デフォルト設定値
class DefaultValues {
  /// デフォルト月給（円）
  static const double defaultMonthlySalary = 300000.0;
  
  /// デフォルト月間労働時間
  static const int defaultMonthlyWorkHours = 160;
  
  /// デフォルト日次労働時間
  static const int defaultDailyWorkHours = 8;
  
  /// デフォルト始業時刻（時）
  static const int defaultStartHour = 9;
  
  /// デフォルト終業時刻（時）
  static const int defaultEndHour = 18;
  
  /// デフォルト残業代倍率
  static const double defaultOvertimeMultiplier = 1.25;
  
  /// デフォルト時給（月給÷月間労働時間）
  static double get defaultHourlySalary => defaultMonthlySalary / defaultMonthlyWorkHours;
}

/// ストレージキー定数
class StorageKeys {
  /// 労働者情報
  static const String worker = 'worker';
  
  /// 勤務履歴
  static const String workHistory = 'workHistory';
  
  /// 資格計画
  static const String qualificationPlans = 'qualificationPlans';
  
  /// 現在の勤務セッション
  static const String currentSession = 'currentSession';
  
  /// ダークモード設定
  static const String isDarkMode = 'isDarkMode';
  
  /// 通知設定
  static const String isNotificationEnabled = 'isNotificationEnabled';
  
  /// 休憩リマインダー設定
  static const String isBreakReminderEnabled = 'isBreakReminderEnabled';
  
  /// 昼休み通知設定
  static const String isLunchNotificationEnabled = 'isLunchNotificationEnabled';
  
  /// 終了通知設定
  static const String isEndNotificationEnabled = 'isEndNotificationEnabled';
  
  /// サービス残業警告設定
  static const String isOvertimeWarningEnabled = 'isOvertimeWarningEnabled';
  
  /// 初回起動フラグ
  static const String isFirstLaunch = 'isFirstLaunch';
  
  /// 最後のバックアップ日時
  static const String lastBackupDate = 'lastBackupDate';
}

/// 通知ID定数
class NotificationIds {
  /// 勤務開始通知
  static const int workStart = 1001;
  
  /// 勤務終了通知
  static const int workEnd = 1002;
  
  /// 昼休み通知
  static const int lunch = 1003;
  
  /// 休憩リマインダー通知
  static const int breakReminder = 1004;
  
  /// サービス残業警告通知
  static const int overtimeWarning = 1005;
  
  /// 定期休憩リマインダー通知の開始ID
  static const int scheduledBreakStart = 2000;
}

/// UI表示用文字列リソース
class UIStrings {
  /// 画面タイトル
  static const String homeTitle = 'ホーム';
  static const String historyTitle = '履歴';
  static const String qualificationTitle = '資格投資';
  static const String settingsTitle = '設定';
  
  /// ボタンラベル
  static const String startWork = '勤務開始';
  static const String endWork = '勤務終了';
  static const String save = '保存';
  static const String cancel = 'キャンセル';
  static const String reset = 'リセット';
  static const String backup = 'バックアップ';
  static const String restore = '復元';
  static const String delete = '削除';
  static const String edit = '編集';
  static const String add = '追加';
  
  /// 確認ダイアログ
  static const String confirmTitle = '確認';
  static const String confirmReset = '本当にリセットしますか？\nすべてのデータが削除されます。';
  static const String confirmResetButton = 'リセット実行';
  static const String confirmDelete = '本当に削除しますか？';
  static const String confirmDeleteButton = '削除実行';
  
  /// エラーメッセージ
  static const String errorGeneral = 'エラーが発生しました';
  static const String errorNetworkUnavailable = 'ネットワークに接続できません';
  static const String errorInvalidInput = '入力値が正しくありません';
  static const String errorSaveFailure = 'データの保存に失敗しました';
  static const String errorLoadFailure = 'データの読み込みに失敗しました';
  
  /// 成功メッセージ
  static const String successSave = '保存しました';
  static const String successReset = 'リセットしました';
  static const String successBackup = 'バックアップを作成しました';
  static const String successRestore = 'データを復元しました';
  
  /// 単位表示
  static const String currencySymbol = '円';
  static const String hourUnit = '時間';
  static const String minuteUnit = '分';
  static const String dayUnit = '日';
  static const String monthUnit = '月';
  static const String yearUnit = '年';
  
  /// ステータス表示
  static const String working = '勤務中';
  static const String notWorking = '勤務外';
  static const String overtime = '残業中';
  static const String serviceOvertime = 'サービス残業';
  
  /// 期間フィルター
  static const String filterToday = '今日';
  static const String filterThisWeek = '今週';
  static const String filterThisMonth = '今月';
  static const String filterAll = '全期間';
  
  /// 資格ステータス
  static const String qualificationPlanning = '計画中';
  static const String qualificationStudying = '学習中';
  static const String qualificationAcquired = '取得済み';
  static const String qualificationPaused = '中断';
  static const String qualificationCancelled = '取り止め';
  
  /// ROI評価
  static const String roiExcellent = '超優秀';
  static const String roiGood = '優秀';
  static const String roiFair = '良好';
  static const String roiPoor = '要検討';
}

/// 数値フォーマット設定
class FormatSettings {
  /// 通貨フォーマット（カンマ区切り）
  static String formatCurrency(double amount) {
    return '${amount.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]},',
    )}円';
  }
  
  /// 時間フォーマット（時:分）
  static String formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}時間${mins}分';
  }
  
  /// 日付フォーマット（年/月/日）
  static String formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }
  
  /// 時刻フォーマット（時:分）
  static String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
  
  /// 日時フォーマット（月/日 時:分）
  static String formatDateTime(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day} ${formatTime(dateTime)}';
  }
  
  /// パーセンテージフォーマット
  static String formatPercentage(double value) {
    return '${(value * 100).toInt()}%';
  }
  
  /// 小数点フォーマット（2桁）
  static String formatDecimal(double value) {
    return value.toStringAsFixed(2);
  }
}

/// バリデーション設定
class ValidationRules {
  /// 最小月給
  static const double minMonthlySalary = 100000.0;
  
  /// 最大月給
  static const double maxMonthlySalary = 10000000.0;
  
  /// 最小時給
  static const double minHourlySalary = 500.0;
  
  /// 最大時給
  static const double maxHourlySalary = 50000.0;
  
  /// 最小月間労働時間
  static const int minMonthlyWorkHours = 40;
  
  /// 最大月間労働時間
  static const int maxMonthlyWorkHours = 300;
  
  /// 最小日次労働時間
  static const int minDailyWorkHours = 1;
  
  /// 最大日次労働時間
  static const int maxDailyWorkHours = 16;
  
  /// 最小残業倍率
  static const double minOvertimeMultiplier = 1.0;
  
  /// 最大残業倍率
  static const double maxOvertimeMultiplier = 3.0;
  
  /// 最小資格取得費用
  static const double minQualificationCost = 0.0;
  
  /// 最大資格取得費用
  static const double maxQualificationCost = 10000000.0;
  
  /// 最小学習時間
  static const int minStudyHours = 1;
  
  /// 最大学習時間
  static const int maxStudyHours = 10000;
  
  /// 資格名の最小文字数
  static const int minQualificationNameLength = 1;
  
  /// 資格名の最大文字数
  static const int maxQualificationNameLength = 50;
}

/// パフォーマンス設定
class PerformanceSettings {
  /// データ自動保存間隔（秒）
  static const int autoSaveInterval = 30;
  
  /// 履歴データ最大保持件数
  static const int maxHistoryRecords = 1000;
  
  /// 通知スケジュール最大数
  static const int maxScheduledNotifications = 10;
  
  /// ログ出力の最大レベル（0: なし, 1: エラーのみ, 2: 警告以上, 3: すべて）
  static const int logLevel = 2;
}

/// カラー定数（16進数値）
class ColorConstants {
  /// プライマリブルー
  static const int primaryBlueValue = 0xFF1976D2;
  
  /// アクセントグリーン
  static const int accentGreenValue = 0xFF388E3C;
  
  /// 警告オレンジ
  static const int warningOrangeValue = 0xFFF57C00;
  
  /// エラーレッド
  static const int errorRedValue = 0xFFD32F2F;
  
  /// サーフェースライト
  static const int surfaceLightValue = 0xFFFAFAFA;
  
  /// サーフェースダーク
  static const int surfaceDarkValue = 0xFF121212;
  
  /// iOS標準グレー
  static const int iOSGrayValue = 0xFFF2F2F7;
}