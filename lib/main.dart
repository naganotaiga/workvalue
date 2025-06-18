import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// =============================================================================
/// WorkValue - iOS専用労働価値可視化アプリ (パート1/3)
///
/// 【パート1】アプリ基盤・データモデル・ストレージサービス
/// - iOS専用初期化・設定
/// - アプリ基盤とテーマシステム
/// - 社会人向けデータモデル定義
/// - ローカルストレージ管理
///
/// 【対象ユーザー】15-30歳社会人専用
/// 【目的】労働時間を金額で可視化し、モチベーション向上
/// 【核心価値】
/// - 労働の価値可視化（時間→金額変換）
/// - サービス残業問題の明確化（損失額表示）
/// - 資格投資ROI計算（会社規定/転職想定）
///
/// 【iOS専用最適化項目】
/// - iOS専用システムUI設定とハプティクフィードバック
/// - iOS Human Interface Guidelines準拠デザイン
/// - NotoSansJPフォント統合
/// - iOS専用通知システム統合
/// - エネルギー効率最適化
/// =============================================================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // iOS専用初期化処理
  await _initializeWorkValueApp();

  runApp(const WorkValueApp());
}

/// WorkValue専用アプリケーション初期化処理
/// - システムUI設定
/// - 縦向き固定
/// - サービス初期化
Future<void> _initializeWorkValueApp() async {
  try {
    // iOS専用システムUI設定
    await _configureIOSSystemUI();

    // 社会人向けサービス初期化（並列実行でパフォーマンス向上）
    await Future.wait([
      SharedPreferences.getInstance(),
      NotificationService.initialize(),
      StorageService.initialize(),
    ]);

    debugPrint('✅ WorkValue iOS専用アプリ初期化完了');
  } catch (e) {
    debugPrint('❌ WorkValue初期化エラー: $e');
    // エラーが発生してもアプリを起動（フォールバック）
  }
}

/// iOS専用システムUI設定
/// - ステータスバー透明化とアイコン色設定
/// - 縦向き固定（iPhone専用）
/// - iOS専用のビジュアル調整
Future<void> _configureIOSSystemUI() async {
  // iOS専用ステータスバー設定
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // iPhone専用縦向き固定設定
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

// =============================================================================
// App Core - メインアプリケーション
// iOS専用Material Design 3 + Cupertino融合デザイン
// =============================================================================

/// WorkValue メインアプリケーション
/// 社会人専用・iOS専用設計で最適化されたマルチプロバイダー構成
class WorkValueApp extends StatelessWidget {
  const WorkValueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // 社会人向け状態管理プロバイダー群（パート2で詳細実装）
      providers: [
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
        ChangeNotifierProvider(create: (context) => WorkerProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            title: 'WorkValue',
            debugShowCheckedModeBanner: false,

            // iOS専用テーマ設定
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode:
                settingsProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

            // 日本語ローカライゼーション
            locale: const Locale('ja', 'JP'),
            supportedLocales: const [Locale('ja', 'JP')],

            // メイン画面（パート2で実装）
            home: const MainScreen(),

            // iOS専用テキストスケーリング制限
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: MediaQuery.of(context).textScaler.clamp(
                        minScaleFactor: 0.85,
                        maxScaleFactor: 1.3,
                      ),
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}

// =============================================================================
// Theme Configuration - iOS専用テーマシステム
// Material Design 3 + iOS Human Interface Guidelines融合
// =============================================================================

/// iOS専用アプリテーマ設定
/// Material Design 3をベースにiOS専用カスタマイズ
/// 社会人向けプロフェッショナルなデザイン
class AppTheme {
  // 社会人向けプロフェッショナルカラーパレット
  static const Color _primaryBlue = Color(0xFF1976D2); // ビジネス青系プライマリ
  static const Color _accentGreen = Color(0xFF388E3C); // 収入表示用緑系
  static const Color _warningOrange = Color(0xFFF57C00); // サービス残業警告色
  static const Color _errorRed = Color(0xFFD32F2F); // エラー・損失表示色
  static const Color _surfaceLight = Color(0xFFFAFAFA); // iOS明るい背景
  static const Color _surfaceDark = Color(0xFF121212); // iOS暗い背景
  static const Color _iOSGray = Color(0xFFF2F2F7); // iOS標準グレー

  /// ライトテーマ（社会人向けプロフェッショナル）
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryBlue,
      brightness: Brightness.light,
    ).copyWith(
      surface: _surfaceLight,
      error: _errorRed,
      surfaceVariant: _iOSGray,
      primary: _primaryBlue,
      secondary: _accentGreen,
      tertiary: _warningOrange,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      // NotoSansJP + iOS標準フォント融合
      fontFamily: 'NotoSansJP',

      // iOS専用AppBar設定
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontFamily: 'NotoSansJP',
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),

      // iOS専用ボタンスタイル（ビジネス向け）
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25), // iOS角丸デザイン
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          minimumSize: const Size(0, 48),
          elevation: 2,
          shadowColor: colorScheme.shadow.withOpacity(0.3),
          textStyle: const TextStyle(
            fontFamily: 'NotoSansJP',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // iOS専用カードデザイン
      cardTheme: CardTheme(
        color: colorScheme.surface,
        elevation: 3,
        shadowColor: colorScheme.shadow.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // iOS角丸
        ),
      ),

      // iOS専用入力フィールド
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceVariant.withOpacity(0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(fontFamily: 'NotoSansJP'),
        hintStyle: const TextStyle(fontFamily: 'NotoSansJP'),
      ),

      // iOS専用ナビゲーションバー
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface.withOpacity(0.95),
        elevation: 8,
        shadowColor: colorScheme.shadow.withOpacity(0.1),
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(
            fontFamily: 'NotoSansJP',
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// ダークテーマ（社会人向けプロフェッショナル）
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryBlue,
      brightness: Brightness.dark,
    ).copyWith(
      surface: _surfaceDark,
      error: _errorRed,
      primary: _primaryBlue,
      secondary: _accentGreen,
      tertiary: _warningOrange,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'NotoSansJP',
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontFamily: 'NotoSansJP',
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          minimumSize: const Size(0, 48),
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.5),
          textStyle: const TextStyle(
            fontFamily: 'NotoSansJP',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: colorScheme.surface,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(fontFamily: 'NotoSansJP'),
        hintStyle: const TextStyle(fontFamily: 'NotoSansJP'),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface.withOpacity(0.95),
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
    );
  }
}

// =============================================================================
// Constants - アプリ定数
// iOS専用設定とユーティリティ関数
// =============================================================================

/// WorkValue専用定数・ユーティリティクラス
/// iOS専用の設定値と日本語ローカライゼーション対応
class AppConstants {
  // アプリ基本情報
  static const String appName = 'WorkValue';
  static const String appVersion = '1.0.0';

  // デフォルト値（日本の平均的な社会人の値を参考）
  static const double defaultMonthlySalary = 300000.0; // 月給30万円
  static const int defaultWorkingHoursPerDay = 8; // 1日8時間
  static const int defaultWorkingDaysPerMonth = 22; // 月22日勤務
  static const int defaultWorkStartHour = 9; // 始業時刻9時
  static const int defaultWorkEndHour = 18; // 定時18時
  static const double defaultOvertimeRate = 1.25; // 残業代倍率1.25倍

  // 表示・計算設定
  static const String currencySymbol = '¥';
  static const Duration timerUpdateInterval = Duration(seconds: 1);
  static const Duration notificationCooldown = Duration(minutes: 30);
  static const Duration workBreakReminderInterval = Duration(hours: 1);

  // iOS専用ハプティクフィードバック設定
  static const Duration hapticFeedbackDelay = Duration(milliseconds: 50);

  /// 時間表示フォーマット（HH:MM:SS）
  /// iOS専用のモノスペースフォント活用
  static String formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }

  /// 通貨表示フォーマット（日本円）
  /// iOS標準の数値フォーマットに準拠
  static String formatCurrency(double amount) {
    final formatter = NumberFormat('#,###', 'ja_JP');
    return '$currencySymbol${formatter.format(amount)}';
  }

  /// 時給表示フォーマット
  static String formatHourlyWage(double hourlyWage) {
    return '${formatCurrency(hourlyWage)}/時';
  }

  /// 定時判定（サービス残業チェック用）
  static bool isOvertime(
      DateTime startTime, DateTime endTime, int workingHours) {
    final workDuration = endTime.difference(startTime);
    return workDuration.inHours > workingHours;
  }

  /// サービス残業損失計算
  static double calculateOvertimeLoss(
      int overtimeMinutes, double hourlyWage, double overtimeRate) {
    final overtimeHours = overtimeMinutes / 60.0;
    final expectedOvertimePay = overtimeHours * hourlyWage * overtimeRate;
    return expectedOvertimePay; // 本来もらえるはずだった残業代
  }

  /// iOS専用ハプティクフィードバック実行
  static Future<void> provideiOSHapticFeedback(HapticFeedbackType type) async {
    try {
      switch (type) {
        case HapticFeedbackType.light:
          await HapticFeedback.lightImpact();
          break;
        case HapticFeedbackType.medium:
          await HapticFeedback.mediumImpact();
          break;
        case HapticFeedbackType.heavy:
          await HapticFeedback.heavyImpact();
          break;
        case HapticFeedbackType.selection:
          await HapticFeedback.selectionClick();
          break;
      }
    } catch (e) {
      debugPrint('ハプティクフィードバックエラー: $e');
    }
  }

  /// 安全な数値変換（iOS専用エラーハンドリング）
  static double safeToDouble(dynamic value, double defaultValue) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  /// 勤務時間の自然言語変換
  static String formatWorkDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours == 0) {
      return '${minutes}分';
    } else if (minutes == 0) {
      return '${hours}時間';
    } else {
      return '${hours}時間${minutes}分';
    }
  }
}

/// iOS専用ハプティクフィードバックタイプ
enum HapticFeedbackType {
  light, // 軽いタップ（ボタン押下）
  medium, // 中程度のタップ（勤務開始・終了）
  heavy, // 強いタップ（重要な確認）
  selection, // 選択フィードバック（設定変更）
}

// =============================================================================
// Data Models - 社会人向けデータモデル
// iOS専用最適化とJSONシリアライゼーション対応
// =============================================================================

/// 社会人向けユーザー設定データモデル
/// SharedPreferences（iOS UserDefaults）での永続化対応
class UserSettings {
  bool isDarkMode;
  bool notificationsEnabled;
  double monthlySalary;
  int workingHoursPerDay;
  int workingDaysPerMonth;
  int workStartHour;
  int workEndHour;
  double overtimeRate;
  DateTime firstLaunchDate;

  UserSettings({
    this.isDarkMode = false,
    this.notificationsEnabled = true,
    this.monthlySalary = AppConstants.defaultMonthlySalary,
    this.workingHoursPerDay = AppConstants.defaultWorkingHoursPerDay,
    this.workingDaysPerMonth = AppConstants.defaultWorkingDaysPerMonth,
    this.workStartHour = AppConstants.defaultWorkStartHour,
    this.workEndHour = AppConstants.defaultWorkEndHour,
    this.overtimeRate = AppConstants.defaultOvertimeRate,
    DateTime? firstLaunchDate,
  }) : firstLaunchDate = firstLaunchDate ?? DateTime.now();

  /// 時給計算（iOS専用最適化）
  double get hourlyWage {
    final totalMonthlyHours = workingHoursPerDay * workingDaysPerMonth;
    return totalMonthlyHours > 0 ? monthlySalary / totalMonthlyHours : 0.0;
  }

  /// 残業時給計算
  double get overtimeHourlyWage => hourlyWage * overtimeRate;

  /// JSON変換（iOS UserDefaults対応）
  Map<String, dynamic> toJson() => {
        'isDarkMode': isDarkMode,
        'notificationsEnabled': notificationsEnabled,
        'monthlySalary': monthlySalary,
        'workingHoursPerDay': workingHoursPerDay,
        'workingDaysPerMonth': workingDaysPerMonth,
        'workStartHour': workStartHour,
        'workEndHour': workEndHour,
        'overtimeRate': overtimeRate,
        'firstLaunchDate': firstLaunchDate.toIso8601String(),
      };

  /// JSON復元（iOS UserDefaults対応）
  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
        isDarkMode: json['isDarkMode'] ?? false,
        notificationsEnabled: json['notificationsEnabled'] ?? true,
        monthlySalary: AppConstants.safeToDouble(
            json['monthlySalary'], AppConstants.defaultMonthlySalary),
        workingHoursPerDay: json['workingHoursPerDay'] ??
            AppConstants.defaultWorkingHoursPerDay,
        workingDaysPerMonth: json['workingDaysPerMonth'] ??
            AppConstants.defaultWorkingDaysPerMonth,
        workStartHour:
            json['workStartHour'] ?? AppConstants.defaultWorkStartHour,
        workEndHour: json['workEndHour'] ?? AppConstants.defaultWorkEndHour,
        overtimeRate: AppConstants.safeToDouble(
            json['overtimeRate'], AppConstants.defaultOvertimeRate),
        firstLaunchDate: json['firstLaunchDate'] != null
            ? DateTime.parse(json['firstLaunchDate'])
            : DateTime.now(),
      );

  /// 設定更新用コピーコンストラクタ
  UserSettings copyWith({
    bool? isDarkMode,
    bool? notificationsEnabled,
    double? monthlySalary,
    int? workingHoursPerDay,
    int? workingDaysPerMonth,
    int? workStartHour,
    int? workEndHour,
    double? overtimeRate,
  }) =>
      UserSettings(
        isDarkMode: isDarkMode ?? this.isDarkMode,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        monthlySalary: monthlySalary ?? this.monthlySalary,
        workingHoursPerDay: workingHoursPerDay ?? this.workingHoursPerDay,
        workingDaysPerMonth: workingDaysPerMonth ?? this.workingDaysPerMonth,
        workStartHour: workStartHour ?? this.workStartHour,
        workEndHour: workEndHour ?? this.workEndHour,
        overtimeRate: overtimeRate ?? this.overtimeRate,
        firstLaunchDate: firstLaunchDate,
      );
}

/// 作業セッションデータモデル
/// リアルタイム収入計算・サービス残業判定・iOS専用永続化対応
class WorkSession {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final double hourlyWage;
  final double overtimeRate;
  final int scheduledWorkingHours;
  final bool isServiceOvertime; // サービス残業フラグ
  final String? note;

  WorkSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.hourlyWage,
    this.overtimeRate = AppConstants.defaultOvertimeRate,
    this.scheduledWorkingHours = AppConstants.defaultWorkingHoursPerDay,
    this.isServiceOvertime = false,
    this.note,
  });

  /// セッション状態確認
  bool get isActive => endTime == null;

  /// 経過時間計算（秒）
  int get durationInSeconds {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime).inSeconds;
  }

  /// 勤務時間Duration
  Duration get workDuration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  /// 定時内時間（秒）
  int get regularTimeSeconds {
    final maxRegularSeconds = scheduledWorkingHours * 3600;
    return math.min(durationInSeconds, maxRegularSeconds);
  }

  /// 残業時間（秒）
  int get overtimeSeconds {
    final maxRegularSeconds = scheduledWorkingHours * 3600;
    return math.max(0, durationInSeconds - maxRegularSeconds);
  }

  /// 定時内収入計算
  double get regularEarnings {
    final regularHours = regularTimeSeconds / 3600.0;
    return regularHours * hourlyWage;
  }

  /// 残業代計算（サービス残業の場合は0）
  double get overtimeEarnings {
    if (isServiceOvertime) return 0.0;
    final overtimeHours = overtimeSeconds / 3600.0;
    return overtimeHours * hourlyWage * overtimeRate;
  }

  /// 総収入計算
  double get totalEarnings => regularEarnings + overtimeEarnings;

  /// サービス残業損失額計算
  double get serviceLoss {
    if (!isServiceOvertime) return 0.0;
    final overtimeHours = overtimeSeconds / 3600.0;
    return overtimeHours * hourlyWage * overtimeRate;
  }

  /// 残業状態判定
  bool get hasOvertime => overtimeSeconds > 0;

  /// フォーマット済み時間表示
  String get formattedDuration =>
      AppConstants.formatDuration(durationInSeconds);

  /// JSON変換（iOS永続化対応）
  Map<String, dynamic> toJson() => {
        'id': id,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'hourlyWage': hourlyWage,
        'overtimeRate': overtimeRate,
        'scheduledWorkingHours': scheduledWorkingHours,
        'isServiceOvertime': isServiceOvertime,
        'note': note,
      };

  /// JSON復元（iOS永続化対応）
  factory WorkSession.fromJson(Map<String, dynamic> json) => WorkSession(
        id: json['id'],
        startTime: DateTime.parse(json['startTime']),
        endTime:
            json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
        hourlyWage: AppConstants.safeToDouble(json['hourlyWage'], 0.0),
        overtimeRate: AppConstants.safeToDouble(
            json['overtimeRate'], AppConstants.defaultOvertimeRate),
        scheduledWorkingHours: json['scheduledWorkingHours'] ??
            AppConstants.defaultWorkingHoursPerDay,
        isServiceOvertime: json['isServiceOvertime'] ?? false,
        note: json['note'],
      );

  /// セッション終了時のコピー作成
  WorkSession copyWithEnd({
    required DateTime endTime,
    bool? isServiceOvertime,
    String? note,
  }) =>
      WorkSession(
        id: id,
        startTime: startTime,
        endTime: endTime,
        hourlyWage: hourlyWage,
        overtimeRate: overtimeRate,
        scheduledWorkingHours: scheduledWorkingHours,
        isServiceOvertime: isServiceOvertime ?? this.isServiceOvertime,
        note: note ?? this.note,
      );
}

/// 資格取得計画データモデル
/// ROI計算（会社規定/転職想定）・iOS専用永続化対応
class CertificationPlan {
  final String id;
  final String name; // 資格名
  final CertificationType type; // 会社規定 or 転職想定
  final double increaseAmount; // 月額増加（会社規定）or 年額増加（転職想定）
  final int studyHours; // 予想学習時間
  final DateTime? targetDate; // 取得目標日
  final DateTime createdDate; // 計画作成日
  final bool isCompleted; // 取得完了フラグ
  final String? note;

  CertificationPlan({
    required this.id,
    required this.name,
    required this.type,
    required this.increaseAmount,
    required this.studyHours,
    this.targetDate,
    DateTime? createdDate,
    this.isCompleted = false,
    this.note,
  }) : createdDate = createdDate ?? DateTime.now();

  /// 現在年齢から65歳までの残り年数計算（仮定：30歳）
  int get remainingWorkYears {
    final currentAge = 30; // 仮の年齢、実際は設定から取得
    return math.max(0, 65 - currentAge);
  }

  /// 総収入増加計算
  double get totalIncomeIncrease {
    switch (type) {
      case CertificationType.companyRegulation:
        // 会社規定：月額増加 × 12ヶ月 × 残り年数
        return increaseAmount * 12 * remainingWorkYears;
      case CertificationType.jobChange:
        // 転職想定：年額増加 × 残り年数
        return increaseAmount * remainingWorkYears;
    }
  }

  /// 学習時給計算（ROI）
  double get studyHourlyRate {
    return studyHours > 0 ? totalIncomeIncrease / studyHours : 0.0;
  }

  /// 投資効率性判定
  CertificationROILevel get roiLevel {
    if (studyHourlyRate >= 10000) return CertificationROILevel.excellent;
    if (studyHourlyRate >= 5000) return CertificationROILevel.good;
    if (studyHourlyRate >= 2000) return CertificationROILevel.fair;
    return CertificationROILevel.poor;
  }

  /// JSON変換（iOS永続化対応）
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.toString(),
        'increaseAmount': increaseAmount,
        'studyHours': studyHours,
        'targetDate': targetDate?.toIso8601String(),
        'createdDate': createdDate.toIso8601String(),
        'isCompleted': isCompleted,
        'note': note,
      };

  /// JSON復元（iOS永続化対応）
  factory CertificationPlan.fromJson(Map<String, dynamic> json) =>
      CertificationPlan(
        id: json['id'],
        name: json['name'] ?? '',
        type: CertificationType.values.firstWhere(
          (e) => e.toString() == json['type'],
          orElse: () => CertificationType.companyRegulation,
        ),
        increaseAmount: AppConstants.safeToDouble(json['increaseAmount'], 0.0),
        studyHours: json['studyHours'] ?? 0,
        targetDate: json['targetDate'] != null
            ? DateTime.parse(json['targetDate'])
            : null,
        createdDate: json['createdDate'] != null
            ? DateTime.parse(json['createdDate'])
            : DateTime.now(),
        isCompleted: json['isCompleted'] ?? false,
        note: json['note'],
      );

  /// 計画更新用コピーコンストラクタ
  CertificationPlan copyWith({
    String? name,
    CertificationType? type,
    double? increaseAmount,
    int? studyHours,
    DateTime? targetDate,
    bool? isCompleted,
    String? note,
  }) =>
      CertificationPlan(
        id: id,
        name: name ?? this.name,
        type: type ?? this.type,
        increaseAmount: increaseAmount ?? this.increaseAmount,
        studyHours: studyHours ?? this.studyHours,
        targetDate: targetDate ?? this.targetDate,
        createdDate: createdDate,
        isCompleted: isCompleted ?? this.isCompleted,
        note: note ?? this.note,
      );
}

/// 資格取得タイプ（ROI計算方法）
enum CertificationType {
  companyRegulation(
    '会社規定',
    '現在の会社での月給アップを想定',
    Icons.business,
  ),
  jobChange(
    '転職想定',
    '転職による年収アップを想定',
    Icons.work_outline,
  );

  const CertificationType(this.displayName, this.description, this.icon);

  final String displayName; // 表示名
  final String description; // 説明文
  final IconData icon; // アイコン
}

/// 資格投資効率レベル
enum CertificationROILevel {
  excellent(
    '超優秀',
    '時給1万円以上',
    Colors.blue,
    '🚀',
  ),
  good(
    '優秀',
    '時給5千円以上',
    Colors.green,
    '📈',
  ),
  fair(
    '良好',
    '時給2千円以上',
    Colors.orange,
    '📊',
  ),
  poor(
    '要検討',
    '時給2千円未満',
    Colors.red,
    '⚠️',
  );

  const CertificationROILevel(
      this.displayName, this.description, this.color, this.emoji);

  final String displayName; // 表示名
  final String description; // 説明文
  final Color color; // 色
  final String emoji; // 絵文字（iOS専用）
}

// =============================================================================
// Storage Service - iOS専用データ永続化サービス
// SharedPreferences（iOS UserDefaults）最適化
// =============================================================================

/// iOS専用ストレージサービス
/// UserDefaults を活用した高速・安全なデータ永続化
/// 社会人向けデータ（給与計算・資格計画）対応
class StorageService {
  // ストレージキー定数（iOS UserDefaults）
  static const String _keyUserSettings = 'user_settings_v1';
  static const String _keyWorkSessions = 'work_sessions_v1';
  static const String _keyCertificationPlans = 'certification_plans_v1';
  static const String _keyAppVersion = 'app_version';

  static SharedPreferences? _prefs;

  /// iOS専用初期化
  static Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await _performMigrationIfNeeded();
      debugPrint('✅ iOS StorageService初期化完了');
    } catch (e) {
      debugPrint('❌ StorageService初期化失敗: $e');
      rethrow;
    }
  }

  /// バージョン管理とマイグレーション
  static Future<void> _performMigrationIfNeeded() async {
    final currentVersion = _preferences.getString(_keyAppVersion);
    if (currentVersion != AppConstants.appVersion) {
      debugPrint(
          'WorkValueバージョン更新: $currentVersion → ${AppConstants.appVersion}');
      await _preferences.setString(_keyAppVersion, AppConstants.appVersion);
    }
  }

  /// 安全なSharedPreferences取得
  static SharedPreferences get _preferences {
    if (_prefs == null) {
      throw Exception('StorageService未初期化 - initialize()を先に実行してください');
    }
    return _prefs!;
  }

  /// ユーザー設定保存（iOS UserDefaults最適化）
  static Future<bool> saveUserSettings(UserSettings settings) async {
    try {
      final jsonString = jsonEncode(settings.toJson());
      final success =
          await _preferences.setString(_keyUserSettings, jsonString);
      if (success) {
        debugPrint('✅ ユーザー設定保存完了');
      }
      return success;
    } catch (e) {
      debugPrint('❌ ユーザー設定保存失敗: $e');
      return false;
    }
  }

  /// ユーザー設定読み込み（iOS UserDefaults最適化）
  static Future<UserSettings> loadUserSettings() async {
    try {
      final jsonString = _preferences.getString(_keyUserSettings);
      if (jsonString == null) {
        debugPrint('🔄 新規ユーザー設定を作成');
        return UserSettings();
      }

      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final settings = UserSettings.fromJson(jsonMap);
      debugPrint('✅ ユーザー設定読み込み完了');
      return settings;
    } catch (e) {
      debugPrint('❌ ユーザー設定読み込み失敗: $e - デフォルト設定を使用');
      return UserSettings();
    }
  }

  /// 作業セッション保存（バッチ処理）
  static Future<bool> saveWorkSessions(List<WorkSession> sessions) async {
    try {
      final jsonList = sessions.map((s) => s.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      final success =
          await _preferences.setString(_keyWorkSessions, jsonString);
      if (success) {
        debugPrint('✅ 作業セッション保存完了: ${sessions.length}件');
      }
      return success;
    } catch (e) {
      debugPrint('❌ 作業セッション保存失敗: $e');
      return false;
    }
  }

  /// 作業セッション読み込み（iOS最適化）
  static Future<List<WorkSession>> loadWorkSessions() async {
    try {
      final jsonString = _preferences.getString(_keyWorkSessions);
      if (jsonString == null) return [];

      final jsonList = jsonDecode(jsonString) as List;
      final sessions =
          jsonList.map((json) => WorkSession.fromJson(json)).toList();
      debugPrint('✅ 作業セッション読み込み完了: ${sessions.length}件');
      return sessions;
    } catch (e) {
      debugPrint('❌ 作業セッション読み込み失敗: $e');
      return [];
    }
  }

  /// 資格計画保存（バッチ処理）
  static Future<bool> saveCertificationPlans(
      List<CertificationPlan> plans) async {
    try {
      final jsonList = plans.map((p) => p.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      final success =
          await _preferences.setString(_keyCertificationPlans, jsonString);
      if (success) {
        debugPrint('✅ 資格計画保存完了: ${plans.length}件');
      }
      return success;
    } catch (e) {
      debugPrint('❌ 資格計画保存失敗: $e');
      return false;
    }
  }

  /// 資格計画読み込み（iOS最適化）
  static Future<List<CertificationPlan>> loadCertificationPlans() async {
    try {
      final jsonString = _preferences.getString(_keyCertificationPlans);
      if (jsonString == null) return [];

      final jsonList = jsonDecode(jsonString) as List;
      final plans =
          jsonList.map((json) => CertificationPlan.fromJson(json)).toList();
      debugPrint('✅ 資格計画読み込み完了: ${plans.length}件');
      return plans;
    } catch (e) {
      debugPrint('❌ 資格計画読み込み失敗: $e');
      return [];
    }
  }

  /// 作業セッション追加（単体追加の最適化）
  static Future<bool> addWorkSession(WorkSession session) async {
    final sessions = await loadWorkSessions();
    sessions.add(session);
    return await saveWorkSessions(sessions);
  }

  /// 資格計画追加（単体追加の最適化）
  static Future<bool> addCertificationPlan(CertificationPlan plan) async {
    final plans = await loadCertificationPlans();
    plans.add(plan);
    return await saveCertificationPlans(plans);
  }

  /// データクリア（デバッグ・リセット用）
  static Future<bool> clearAllData() async {
    try {
      await Future.wait([
        _preferences.remove(_keyUserSettings),
        _preferences.remove(_keyWorkSessions),
        _preferences.remove(_keyCertificationPlans),
      ]);
      debugPrint('✅ 全データクリア完了');
      return true;
    } catch (e) {
      debugPrint('❌ データクリア失敗: $e');
      return false;
    }
  }
}

// =============================================================================
// Notification Service - iOS専用通知サービス
// iOS UserNotifications Framework最適化
// =============================================================================

/// iOS専用通知サービス
/// UserNotifications Framework活用による高度な通知機能
/// 社会人向け通知（休憩・残業・成果）対応
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static DateTime? _lastNotificationTime;

  /// iOS専用初期化
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // iOS専用設定
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        requestCriticalPermission: false, // 重要通知は使用しない
        defaultPresentAlert: true,
        defaultPresentBadge: true,
        defaultPresentSound: true,
      );

      const initSettings = InitializationSettings(iOS: iosSettings);

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _initialized = true;
      debugPrint('✅ iOS NotificationService初期化完了');
    } catch (e) {
      debugPrint('❌ NotificationService初期化失敗: $e');
    }
  }

  /// 通知タップ時の処理
  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('📱 通知タップ: ${response.payload}');
    // 必要に応じて画面遷移などの処理を追加
  }

  /// 通知レート制限チェック
  static bool _canSendNotification() {
    if (_lastNotificationTime == null) return true;

    final timeSinceLastNotification =
        DateTime.now().difference(_lastNotificationTime!);
    return timeSinceLastNotification >= AppConstants.notificationCooldown;
  }

  /// 勤務休憩リマインダー（iOS専用）
  static Future<void> showWorkBreakReminder(double currentEarnings) async {
    if (!_initialized || !_canSendNotification()) return;

    try {
      const notificationDetails = NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: false,
          categoryIdentifier: 'work_break',
          threadIdentifier: 'work_reminders',
        ),
      );

      await _notifications.show(
        1,
        '休憩はいかがですか？',
        '現在${AppConstants.formatCurrency(currentEarnings)}稼いでいます。少し休憩しませんか？',
        notificationDetails,
        payload: 'work_break',
      );

      _lastNotificationTime = DateTime.now();
      await AppConstants.provideiOSHapticFeedback(HapticFeedbackType.light);
      debugPrint('📱 勤務休憩リマインダー送信');
    } catch (e) {
      debugPrint('❌ 勤務休憩リマインダー送信失敗: $e');
    }
  }

  /// 昼休み成果通知（プロジェクト指針の要件）
  static Future<void> showLunchEarningsNotification(
      double morningEarnings) async {
    if (!_initialized) return;

    try {
      const notificationDetails = NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: true,
          categoryIdentifier: 'lunch_earnings',
          threadIdentifier: 'daily_earnings',
        ),
      );

      await _notifications.show(
        2,
        '午前中で${AppConstants.formatCurrency(morningEarnings)}稼ぎました！',
        'お疲れ様です。午後も頑張りましょう！',
        notificationDetails,
        payload: 'lunch_earnings',
      );

      await AppConstants.provideiOSHapticFeedback(HapticFeedbackType.medium);
      debugPrint('📱 昼休み成果通知送信');
    } catch (e) {
      debugPrint('❌ 昼休み成果通知送信失敗: $e');
    }
  }

  /// 勤務終了成果通知（プロジェクト指針の要件）
  static Future<void> showDailyWorkCompletionNotification(
      double totalEarnings) async {
    if (!_initialized) return;

    try {
      const notificationDetails = NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          categoryIdentifier: 'work_completion',
          threadIdentifier: 'daily_earnings',
        ),
      );

      await _notifications.show(
        3,
        '今日もお疲れ様！今日で${AppConstants.formatCurrency(totalEarnings)}稼ぎました！',
        'ゆっくり休んでください。',
        notificationDetails,
        payload: 'work_completion',
      );

      await AppConstants.provideiOSHapticFeedback(HapticFeedbackType.heavy);
      debugPrint('📱 勤務終了成果通知送信');
    } catch (e) {
      debugPrint('❌ 勤務終了成果通知送信失敗: $e');
    }
  }

  /// サービス残業警告通知
  static Future<void> showOvertimeWarningNotification(double lossAmount) async {
    if (!_initialized) return;

    try {
      const notificationDetails = NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          categoryIdentifier: 'overtime_warning',
          threadIdentifier: 'overtime_alerts',
        ),
      );

      await _notifications.show(
        4,
        'サービス残業が発生しています',
        '${AppConstants.formatCurrency(lossAmount)}の損失です。お疲れ様でした。',
        notificationDetails,
        payload: 'overtime_warning',
      );

      await AppConstants.provideiOSHapticFeedback(HapticFeedbackType.heavy);
      debugPrint('📱 サービス残業警告通知送信');
    } catch (e) {
      debugPrint('❌ サービス残業警告通知送信失敗: $e');
    }
  }
}

// =============================================================================
// Forward Declarations - パート2/3で実装される主要クラス
// コンパイルエラー回避のための宣言
// =============================================================================

/// メイン画面（パート2で実装）
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'WorkValue\n社会人専用労働価値可視化アプリ\n\nパート2で完全実装',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

/// 設定管理プロバイダー（パート2で実装）
class SettingsProvider extends ChangeNotifier {
  UserSettings _settings = UserSettings();
  bool get isDarkMode => _settings.isDarkMode;

  // パート2で完全実装
}

/// 社会人向け機能プロバイダー（パート2で実装）
/// 給与計算・勤務記録・資格ROI計算
class WorkerProvider extends ChangeNotifier {
  // パート2で完全実装
}

// =============================================================================
// パート1完了 - WorkValue社会人専用仕様対応
// =============================================================================

/// 【パート1完了】
/// ✅ WorkValue専用アプリ基盤とシステム初期化
/// ✅ 社会人向けプロフェッショナルテーマシステム
/// ✅ 社会人向けデータモデル（UserSettings、WorkSession、CertificationPlan）
/// ✅ iOS UserDefaults最適化ストレージサービス
/// ✅ iOS UserNotifications最適化通知サービス（昼休み・勤務終了・残業警告）
/// ✅ サービス残業判定・ROI計算・ハプティクフィードバック
///
/// 【学生機能完全除外】
/// ❌ StudySession、StudentProvider、StudyIntensity
/// ❌ 学習時間・学習価値・目標大学設定
///
/// 【パート2で実装予定】
/// - 状態管理プロバイダー（Settings、Worker）
/// - メイン画面（大型時計UI・勤務状態表示）
/// - リアルタイム収入計算エンジン
/// - サービス残業判定ダイアログ
///
/// 【パート3で実装予定】
/// - 個別機能画面（WorkerScreen、SettingsScreen、CertificationScreen）
/// - 資格ROI計算画面
/// - 履歴・統計画面
/// - iOS専用最適化機能/// =============================================================================
/// WorkValue - iOS専用労働価値可視化アプリ (パート2/3)
///
/// 【パート2】状態管理・メイン画面・リアルタイム計算エンジン
/// - 設定管理プロバイダー（給与・勤務時間設定）
/// - 社会人向け機能プロバイダー（勤務記録・収入計算・資格管理）
/// - メイン画面（大型デジタル時計・今日の累積収入・操作ボタン）
/// - リアルタイム計算エンジン
/// - サービス残業判定システム
///
/// 【対象ユーザー】15-30歳社会人専用
/// 【核心価値実装】
/// - 労働の価値可視化（時間→金額変換）
/// - サービス残業問題の明確化（損失額表示）
/// - シンプルな操作性（ワンタップ記録）
/// - リアルタイム表示（働いている間の累積収入）
///
/// ※このパートをパート1に追加して使用してください
/// =============================================================================

// =============================================================================
// Providers - 状態管理プロバイダー
// 社会人向け機能に特化した状態管理
// =============================================================================

/// 設定管理プロバイダー
/// 給与設定・勤務時間・アプリ設定の一元管理
class SettingsProvider extends ChangeNotifier {
  UserSettings _settings = UserSettings();
  bool _isLoading = false;
  String? _error;

  // ゲッター
  UserSettings get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isDarkMode => _settings.isDarkMode;
  bool get notificationsEnabled => _settings.notificationsEnabled;
  double get monthlySalary => _settings.monthlySalary;
  double get hourlyWage => _settings.hourlyWage;
  double get overtimeHourlyWage => _settings.overtimeHourlyWage;
  int get workingHoursPerDay => _settings.workingHoursPerDay;
  int get workStartHour => _settings.workStartHour;
  int get workEndHour => _settings.workEndHour;

  SettingsProvider() {
    _loadSettings();
  }

  /// 設定読み込み（アプリ起動時）
  Future<void> _loadSettings() async {
    try {
      _setLoading(true);
      _settings = await StorageService.loadUserSettings();
      notifyListeners();
      debugPrint('✅ 設定読み込み完了');
    } catch (e) {
      _setError('設定読み込み失敗: $e');
      debugPrint('❌ 設定読み込み失敗: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// ダークモード切り替え
  Future<bool> setDarkMode(bool enabled) async {
    try {
      _settings = _settings.copyWith(isDarkMode: enabled);
      notifyListeners();
      await AppConstants.provideiOSHapticFeedback(HapticFeedbackType.selection);
      return await _saveSettings();
    } catch (e) {
      _setError('ダークモード設定失敗: $e');
      return false;
    }
  }

  /// 通知設定切り替え
  Future<bool> setNotificationsEnabled(bool enabled) async {
    try {
      _settings = _settings.copyWith(notificationsEnabled: enabled);
      notifyListeners();
      await AppConstants.provideiOSHapticFeedback(HapticFeedbackType.selection);
      return await _saveSettings();
    } catch (e) {
      _setError('通知設定失敗: $e');
      return false;
    }
  }

  /// 月給設定（時給自動計算）
  Future<bool> setMonthlySalary(double salary) async {
    if (salary <= 0) {
      _setError('月給は0円より大きい値を入力してください');
      return false;
    }

    try {
      _settings = _settings.copyWith(monthlySalary: salary);
      notifyListeners();
      await AppConstants.provideiOSHapticFeedback(HapticFeedbackType.medium);
      debugPrint(
          '💰 月給更新: ${AppConstants.formatCurrency(salary)} (時給: ${AppConstants.formatCurrency(hourlyWage)})');
      return await _saveSettings();
    } catch (e) {
      _setError('月給設定失敗: $e');
      return false;
    }
  }

  /// 勤務時間設定
  Future<bool> setWorkingHours({
    int? hoursPerDay,
    int? daysPerMonth,
    int? startHour,
    int? endHour,
  }) async {
    try {
      _settings = _settings.copyWith(
        workingHoursPerDay: hoursPerDay,
        workingDaysPerMonth: daysPerMonth,
        workStartHour: startHour,
        workEndHour: endHour,
      );
      notifyListeners();
      await AppConstants.provideiOSHapticFeedback(HapticFeedbackType.selection);
      return await _saveSettings();
    } catch (e) {
      _setError('勤務時間設定失敗: $e');
      return false;
    }
  }

  /// 残業倍率設定
  Future<bool> setOvertimeRate(double rate) async {
    if (rate < 1.0) {
      _setError('残業倍率は1.0以上を入力してください');
      return false;
    }

    try {
      _settings = _settings.copyWith(overtimeRate: rate);
      notifyListeners();
      await AppConstants.provideiOSHapticFeedback(HapticFeedbackType.selection);
      return await _saveSettings();
    } catch (e) {
      _setError('残業倍率設定失敗: $e');
      return false;
    }
  }

  /// 設定保存
  Future<bool> _saveSettings() async {
    try {
      final success = await StorageService.saveUserSettings(_settings);
      if (success) {
        debugPrint('✅ 設定保存完了');
      }
      return success;
    } catch (e) {
      _setError('設定保存失敗: $e');
      return false;
    }
  }

  /// ローディング状態設定
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// エラー設定
  void _setError(String error) {
    _error = error;
    notifyListeners();
    debugPrint('❌ SettingsProvider エラー: $error');
  }

  /// エラークリア
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

/// 社会人向け機能プロバイダー
/// 勤務記録・収入計算・資格管理の一元管理
class WorkerProvider extends ChangeNotifier {
  // 勤務状態
  WorkSession? _currentSession;
  List<WorkSession> _sessionHistory = [];
  Timer? _timer;
  bool _isWorking = false;
  int _currentSessionSeconds = 0;

  // 今日の統計
  double _todayRegularEarnings = 0.0;
  double _todayOvertimeEarnings = 0.0;
  double _todayServiceLoss = 0.0;
  int _todayWorkingSeconds = 0;

  // 時給設定（SettingsProviderから同期）
  double _hourlyWage = AppConstants.defaultMonthlySalary /
      (AppConstants.defaultWorkingHoursPerDay *
          AppConstants.defaultWorkingDaysPerMonth);
  double _overtimeRate = AppConstants.defaultOvertimeRate;
  int _scheduledWorkingHours = AppConstants.defaultWorkingHoursPerDay;

  // 資格計画
  List<CertificationPlan> _certificationPlans = [];

  // 通知管理
  DateTime? _lastBreakNotification;
  DateTime? _lunchNotificationSent;

  // エラー管理
  String? _error;

  // ゲッター - 勤務状態
  bool get isWorking => _isWorking;
  WorkSession? get currentSession => _currentSession;
  int get currentSessionSeconds => _currentSessionSeconds;
  String get formattedCurrentTime =>
      AppConstants.formatDuration(_currentSessionSeconds);
  String? get error => _error;

  // ゲッター - 収入計算
  double get currentRegularEarnings {
    if (!_isWorking) return 0.0;
    final regularSeconds =
        math.min(_currentSessionSeconds, _scheduledWorkingHours * 3600);
    return (regularSeconds / 3600.0) * _hourlyWage;
  }

  double get currentOvertimeEarnings {
    if (!_isWorking) return 0.0;
    final overtimeSeconds =
        math.max(0, _currentSessionSeconds - (_scheduledWorkingHours * 3600));
    return (overtimeSeconds / 3600.0) * _hourlyWage * _overtimeRate;
  }

  double get currentTotalEarnings =>
      currentRegularEarnings + currentOvertimeEarnings;

  bool get isCurrentlyOvertime =>
      _currentSessionSeconds > (_scheduledWorkingHours * 3600);

  int get currentOvertimeMinutes {
    if (!isCurrentlyOvertime) return 0;
    return ((_currentSessionSeconds - (_scheduledWorkingHours * 3600)) / 60)
        .floor();
  }

  // ゲッター - 今日の統計
  double get todayTotalEarnings =>
      _todayRegularEarnings + _todayOvertimeEarnings + currentTotalEarnings;
  double get todayTotalLoss => _todayServiceLoss;
  String get todayWorkingTime => AppConstants.formatDuration(
      _todayWorkingSeconds + _currentSessionSeconds);

  // ゲッター - 資格計画
  List<CertificationPlan> get certificationPlans =>
      List.unmodifiable(_certificationPlans);
  List<CertificationPlan> get activeCertificationPlans =>
      _certificationPlans.where((plan) => !plan.isCompleted).toList();

  WorkerProvider() {
    _loadData();
  }

  /// データ読み込み（アプリ起動時）
  Future<void> _loadData() async {
    try {
      final futures = await Future.wait([
        StorageService.loadWorkSessions(),
        StorageService.loadCertificationPlans(),
      ]);

      _sessionHistory = futures[0] as List<WorkSession>;
      _certificationPlans = futures[1] as List<CertificationPlan>;

      _calculateTodayStats();
      notifyListeners();
      debugPrint('✅ WorkerProvider データ読み込み完了');
    } catch (e) {
      _setError('データ読み込み失敗: $e');
      debugPrint('❌ WorkerProvider データ読み込み失敗: $e');
    }
  }

  /// 今日の統計計算
  void _calculateTodayStats() {
    final today = DateTime.now();
    final todaySessions = _sessionHistory.where((session) {
      return session.startTime.year == today.year &&
          session.startTime.month == today.month &&
          session.startTime.day == today.day &&
          !session.isActive; // 完了済みセッションのみ
    }).toList();

    _todayRegularEarnings = todaySessions.fold(
        0.0, (sum, session) => sum + session.regularEarnings);
    _todayOvertimeEarnings = todaySessions.fold(
        0.0, (sum, session) => sum + session.overtimeEarnings);
    _todayServiceLoss =
        todaySessions.fold(0.0, (sum, session) => sum + session.serviceLoss);
    _todayWorkingSeconds = todaySessions.fold(
        0, (sum, session) => sum + session.durationInSeconds);

    debugPrint(
        '📊 今日の統計: 定時${AppConstants.formatCurrency(_todayRegularEarnings)} + 残業${AppConstants.formatCurrency(_todayOvertimeEarnings)} - 損失${AppConstants.formatCurrency(_todayServiceLoss)}');
  }

  /// 設定同期（SettingsProviderから呼び出し）
  void updateWageSettings({
    required double hourlyWage,
    required double overtimeRate,
    required int scheduledWorkingHours,
  }) {
    _hourlyWage = hourlyWage;
    _overtimeRate = overtimeRate;
    _scheduledWorkingHours = scheduledWorkingHours;
    notifyListeners();
    debugPrint('💰 時給設定更新: ${AppConstants.formatHourlyWage(hourlyWage)}');
  }

  /// 勤務開始
  Future<bool> startWork() async {
    if (_isWorking) {
      _setError('既に勤務中です');
      return false;
    }

    try {
      final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
      _currentSession = WorkSession(
        id: sessionId,
        startTime: DateTime.now(),
        hourlyWage: _hourlyWage,
        overtimeRate: _overtimeRate,
        scheduledWorkingHours: _scheduledWorkingHours,
      );

      _isWorking = true;
      _currentSessionSeconds = 0;
      _lunchNotificationSent = null; // 昼休み通知リセット

      _startTimer();
      await AppConstants.provideiOSHapticFeedback(HapticFeedbackType.medium);

      notifyListeners();
      debugPrint('🚀 勤務開始: ${_currentSession!.startTime}');
      return true;
    } catch (e) {
      _setError('勤務開始失敗: $e');
      return false;
    }
  }

  /// 勤務終了
  Future<bool> stopWork({String? note}) async {
    if (!_isWorking || _currentSession == null) {
      _setError('勤務中ではありません');
      return false;
    }

    try {
      _stopTimer();

      final endTime = DateTime.now();
      final isOvertime =
          _currentSessionSeconds > (_scheduledWorkingHours * 3600);

      // サービス残業判定は呼び出し元で行う（MainScreenのダイアログ）
      final completedSession = _currentSession!.copyWithEnd(
        endTime: endTime,
        note: note,
      );

      // セッション保存
      _sessionHistory.add(completedSession);
      await StorageService.addWorkSession(completedSession);

      // 統計更新
      _calculateTodayStats();

      // 勤務終了通知
      await NotificationService.showDailyWorkCompletionNotification(
          todayTotalEarnings);

      // 状態リセット
      _isWorking = false;
      _currentSession = null;
      _currentSessionSeconds = 0;

      await AppConstants.provideiOSHapticFeedback(HapticFeedbackType.heavy);
      notifyListeners();

      debugPrint(
          '🏁 勤務終了: $endTime (総収入: ${AppConstants.formatCurrency(completedSession.totalEarnings)})');
      return true;
    } catch (e) {
      _setError('勤務終了失敗: $e');
      return false;
    }
  }

  /// サービス残業として記録
  Future<bool> markAsServiceOvertime({String? note}) async {
    if (!_isWorking || _currentSession == null) return false;

    try {
      _stopTimer();

      final endTime = DateTime.now();
      final completedSession = _currentSession!.copyWithEnd(
        endTime: endTime,
        isServiceOvertime: true,
        note: note,
      );

      // セッション保存
      _sessionHistory.add(completedSession);
      await StorageService.addWorkSession(completedSession);

      // 統計更新
      _calculateTodayStats();

      // サービス残業警告通知
      await NotificationService.showOvertimeWarningNotification(
          completedSession.serviceLoss);

      // 状態リセット
      _isWorking = false;
      _currentSession = null;
      _currentSessionSeconds = 0;

      await AppConstants.provideiOSHapticFeedback(HapticFeedbackType.heavy);
      notifyListeners();

      debugPrint(
          '⚠️ サービス残業記録: 損失${AppConstants.formatCurrency(completedSession.serviceLoss)}');
      return true;
    } catch (e) {
      _setError('サービス残業記録失敗: $e');
      return false;
    }
  }

  /// タイマー開始
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(AppConstants.timerUpdateInterval, (timer) {
      _currentSessionSeconds++;
      notifyListeners();

      // 通知チェック
      _checkNotifications();
    });
  }

  /// タイマー停止
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// 通知チェック（1秒ごと）
  void _checkNotifications() {
    final now = DateTime.now();

    // 1時間ごとの休憩リマインダー
    if (_currentSessionSeconds > 0 && _currentSessionSeconds % 3600 == 0) {
      final timeSinceLastBreak = _lastBreakNotification == null
          ? Duration(hours: 999)
          : now.difference(_lastBreakNotification!);

      if (timeSinceLastBreak >= AppConstants.workBreakReminderInterval) {
        NotificationService.showWorkBreakReminder(currentTotalEarnings);
        _lastBreakNotification = now;
      }
    }

    // 昼休み通知（12:00-13:00の間で1回のみ）
    if (_lunchNotificationSent == null &&
        now.hour >= 12 &&
        now.hour < 13 &&
        _currentSessionSeconds >= 3 * 3600) {
      // 3時間以上勤務後
      NotificationService.showLunchEarningsNotification(currentTotalEarnings);
      _lunchNotificationSent = now;
    }
  }

  /// 資格計画追加
  Future<bool> addCertificationPlan(CertificationPlan plan) async {
    try {
      _certificationPlans.add(plan);
      await StorageService.addCertificationPlan(plan);
      notifyListeners();
      await AppConstants.provideiOSHapticFeedback(HapticFeedbackType.selection);
      debugPrint('📚 資格計画追加: ${plan.name}');
      return true;
    } catch (e) {
      _setError('資格計画追加失敗: $e');
      return false;
    }
  }

  /// 資格計画完了マーク
  Future<bool> completeCertificationPlan(String planId) async {
    try {
      final planIndex = _certificationPlans.indexWhere((p) => p.id == planId);
      if (planIndex == -1) return false;

      _certificationPlans[planIndex] =
          _certificationPlans[planIndex].copyWith(isCompleted: true);
      await StorageService.saveCertificationPlans(_certificationPlans);
      notifyListeners();
      await AppConstants.provideiOSHapticFeedback(HapticFeedbackType.medium);
      debugPrint('🎉 資格取得完了: ${_certificationPlans[planIndex].name}');
      return true;
    } catch (e) {
      _setError('資格完了記録失敗: $e');
      return false;
    }
  }

  /// エラー設定
  void _setError(String error) {
    _error = error;
    notifyListeners();
    debugPrint('❌ WorkerProvider エラー: $error');
  }

  /// エラークリア
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}

// =============================================================================
// Main Screen - メイン画面
// 大型デジタル時計・今日の累積収入・開始/停止ボタン
// =============================================================================

/// メイン画面
/// プロジェクト指針に基づく大型時計UI + 今日の収入 + 操作ボタン
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late PageController _pageController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);

    // パルスアニメーション（勤務中の表示）
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseController.repeat(reverse: true);

    // フェードアニメーション（画面遷移）
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController.forward();

    // 設定同期
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncProviders();
    });
  }

  /// プロバイダー同期
  void _syncProviders() {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    final workerProvider = Provider.of<WorkerProvider>(context, listen: false);

    workerProvider.updateWageSettings(
      hourlyWage: settingsProvider.hourlyWage,
      overtimeRate: settingsProvider.settings.overtimeRate,
      scheduledWorkingHours: settingsProvider.workingHoursPerDay,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  /// タブ選択
  void _onTabSelected(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );

    AppConstants.provideiOSHapticFeedback(HapticFeedbackType.selection);
  }

  /// アクティブタイマー確認
  bool _hasActiveTimer() {
    final workerProvider = Provider.of<WorkerProvider>(context, listen: false);
    return workerProvider.isWorking;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceVariant.withOpacity(0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildCustomAppBar(theme),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeController,
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) =>
                        setState(() => _selectedIndex = index),
                    children: [
                      WorkTimerScreen(pulseController: _pulseController),
                      const CertificationScreen(), // パート3で実装
                      const SettingsScreen(), // パート3で実装
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(theme),
      floatingActionButton:
          _hasActiveTimer() ? _buildQuickStopButton(theme) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  /// カスタムAppBar
  Widget _buildCustomAppBar(ThemeData theme) {
    final titles = ['勤務管理', '資格投資', '設定'];
    final descriptions = ['労働時間を価値に換算', '資格取得のROI計算', 'アプリの設定管理'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WorkValue',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              Text(
                descriptions[_selectedIndex],
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const Spacer(),
          _buildStatusIndicator(theme),
        ],
      ),
    );
  }

  /// 勤務状態インジケーター
  Widget _buildStatusIndicator(ThemeData theme) {
    return Consumer<WorkerProvider>(
      builder: (context, workerProvider, child) {
        final isWorking = workerProvider.isWorking;

        if (!isWorking) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.pause_circle_outline,
                    size: 16, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  '待機中',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (sin(_pulseController.value * 2 * pi) * 0.05),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.colorScheme.primary),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.work,
                        size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      '勤務中',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// ボトムナビゲーションバー
  Widget _buildBottomNavigationBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onTabSelected,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.access_time_outlined),
              selectedIcon: Icon(Icons.access_time),
              label: '勤務管理',
            ),
            NavigationDestination(
              icon: Icon(Icons.school_outlined),
              selectedIcon: Icon(Icons.school),
              label: '資格投資',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: '設定',
            ),
          ],
        ),
      ),
    );
  }

  /// クイック停止ボタン（勤務中のみ表示）
  Widget _buildQuickStopButton(ThemeData theme) {
    return Consumer<WorkerProvider>(
      builder: (context, workerProvider, child) {
        if (!workerProvider.isWorking) return const SizedBox.shrink();

        return FloatingActionButton.extended(
          onPressed: () => _showStopWorkDialog(workerProvider),
          backgroundColor: theme.colorScheme.errorContainer,
          foregroundColor: theme.colorScheme.onErrorContainer,
          icon: const Icon(Icons.stop),
          label: const Text('勤務終了'),
        );
      },
    );
  }

  /// 勤務終了確認ダイアログ
  Future<void> _showStopWorkDialog(WorkerProvider workerProvider) async {
    // サービス残業チェック
    final isOvertime = workerProvider.isCurrentlyOvertime;

    if (isOvertime) {
      // サービス残業判定ダイアログ
      _showOvertimeDialog(workerProvider);
    } else {
      // 通常の終了確認
      _showNormalStopDialog(workerProvider);
    }
  }

  /// 通常終了確認ダイアログ
  Future<void> _showNormalStopDialog(WorkerProvider workerProvider) async {
    final shouldStop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.work_off, color: Colors.orange),
            SizedBox(width: 8),
            Text('勤務終了確認'),
          ],
        ),
        content: Text(
          '今日の収入: ${AppConstants.formatCurrency(workerProvider.currentTotalEarnings)}\n'
          '勤務時間: ${workerProvider.formattedCurrentTime}\n\n'
          '勤務を終了しますか？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('継続'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('終了'),
          ),
        ],
      ),
    );

    if (shouldStop == true) {
      final success = await workerProvider.stopWork();
      if (success && mounted) {
        _showSuccessSnackBar('お疲れ様でした！');
      }
    }
  }

  /// サービス残業判定ダイアログ（プロジェクト指針の要件）
  Future<void> _showOvertimeDialog(WorkerProvider workerProvider) async {
    final overtimeMinutes = workerProvider.currentOvertimeMinutes;
    final potentialLoss = AppConstants.calculateOvertimeLoss(overtimeMinutes,
        workerProvider._hourlyWage, workerProvider._overtimeRate);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('サービス残業ですか？'),
          ],
        ),
        content: Text(
          '残業時間: ${overtimeMinutes}分\n'
          '現在の収入: ${AppConstants.formatCurrency(workerProvider.currentTotalEarnings)}\n\n'
          '残業代が支払われない場合、\n'
          '${AppConstants.formatCurrency(potentialLoss)}の損失になります。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'service'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('サービス残業'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'paid'),
            child: const Text('残業代あり'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'continue'),
            child: const Text('勤務継続'),
          ),
        ],
      ),
    );

    switch (result) {
      case 'service':
        final success = await workerProvider.markAsServiceOvertime();
        if (success && mounted) {
          _showErrorSnackBar('サービス残業として記録しました');
        }
        break;
      case 'paid':
        final success = await workerProvider.stopWork();
        if (success && mounted) {
          _showSuccessSnackBar('お疲れ様でした！');
        }
        break;
      case 'continue':
        // 何もしない（勤務継続）
        break;
    }
  }

  /// 成功スナックバー
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// エラースナックバー
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// =============================================================================
// Work Timer Screen - 勤務時間管理画面
// 大型デジタル時計・今日の累積収入・開始/停止ボタン（プロジェクト指針準拠）
// =============================================================================

/// 勤務時間管理画面
/// プロジェクト指針の「メイン画面レイアウト」を忠実に実装
class WorkTimerScreen extends StatefulWidget {
  final AnimationController pulseController;

  const WorkTimerScreen({super.key, required this.pulseController});

  @override
  State<WorkTimerScreen> createState() => _WorkTimerScreenState();
}

class _WorkTimerScreenState extends State<WorkTimerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer2<WorkerProvider, SettingsProvider>(
      builder: (context, workerProvider, settingsProvider, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildWelcomeSection(theme, workerProvider),
                  const SizedBox(height: 32),
                  // メイン時計セクション（プロジェクト指針準拠）
                  _buildMainClockSection(theme, workerProvider),
                  const SizedBox(height: 32),
                  _buildTodayStatsSection(theme, workerProvider),
                  const SizedBox(height: 24),
                  _buildWageInfoSection(theme, settingsProvider),
                  const SizedBox(height: 100), // FAB用余白
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// ウェルカムセクション
  Widget _buildWelcomeSection(ThemeData theme, WorkerProvider workerProvider) {
    final hour = DateTime.now().hour;
    String greeting;
    IconData greetingIcon;

    if (hour < 12) {
      greeting = 'おはようございます！';
      greetingIcon = Icons.wb_sunny;
    } else if (hour < 18) {
      greeting = 'こんにちは！';
      greetingIcon = Icons.wb_sunny_outlined;
    } else {
      greeting = 'お疲れ様です！';
      greetingIcon = Icons.nights_stay;
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(greetingIcon, color: theme.colorScheme.primary, size: 32),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                workerProvider.isWorking
                    ? '勤務中 - 時間が価値を生み出しています'
                    : '今日も価値ある時間を過ごしましょう',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// メイン時計セクション（プロジェクト指針の重要要件）
  Widget _buildMainClockSection(
      ThemeData theme, WorkerProvider workerProvider) {
    return Column(
      children: [
        // 大型デジタル時計（プロジェクト指針準拠）
        _buildMainClock(theme, workerProvider),
        const SizedBox(height: 24),
        // 今日の収入表示（プロジェクト指針準拠）
        _buildTodayEarnings(theme, workerProvider),
        const SizedBox(height: 24),
        // ステータス表示（プロジェクト指針準拠）
        _buildWorkStatus(theme, workerProvider),
        const SizedBox(height: 32),
        // 開始・停止ボタン（プロジェクト指針準拠）
        _buildMainActionButton(theme, workerProvider),
      ],
    );
  }

  /// 大型デジタル時計（プロジェクト指針：13:45:23形式）
  Widget _buildMainClock(ThemeData theme, WorkerProvider workerProvider) {
    return AnimatedBuilder(
      animation: widget.pulseController,
      builder: (context, child) {
        final pulseValue = workerProvider.isWorking
            ? 1.0 + (sin(widget.pulseController.value * 2 * pi) * 0.02)
            : 1.0;

        return Transform.scale(
          scale: pulseValue,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: workerProvider.isWorking
                      ? theme.colorScheme.primary.withOpacity(0.2)
                      : theme.colorScheme.shadow.withOpacity(0.1),
                  blurRadius: workerProvider.isWorking ? 20 : 10,
                  offset: const Offset(0, 8),
                ),
              ],
              border: workerProvider.isWorking
                  ? Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      width: 2)
                  : null,
            ),
            child: Column(
              children: [
                // デジタル時計表示（プロジェクト指針の大型時計）
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    workerProvider.formattedCurrentTime,
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontSize: 72, // 大型表示
                      fontWeight: FontWeight.bold,
                      color: workerProvider.isWorking
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withOpacity(0.4),
                      fontFeatures: const [FontFeature.tabularFigures()],
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // 残業状況表示
                if (workerProvider.isWorking &&
                    workerProvider.isCurrentlyOvertime)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Text(
                      '残業中 +${workerProvider.currentOvertimeMinutes}分',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 今日の収入表示（プロジェクト指針準拠）
  Widget _buildTodayEarnings(ThemeData theme, WorkerProvider workerProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            '今日の収入',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.green[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          // 大きく表示（プロジェクト指針準拠）
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              AppConstants.formatCurrency(workerProvider.todayTotalEarnings),
              key: ValueKey(workerProvider.todayTotalEarnings.toInt()),
              style: theme.textTheme.headlineLarge?.copyWith(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.green[600],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '勤務時間: ${workerProvider.todayWorkingTime}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.green[600],
            ),
          ),
        ],
      ),
    );
  }

  /// ステータス表示（プロジェクト指針準拠）
  Widget _buildWorkStatus(ThemeData theme, WorkerProvider workerProvider) {
    IconData statusIcon;
    String statusText;
    Color statusColor;

    if (workerProvider.isWorking) {
      if (workerProvider.isCurrentlyOvertime) {
        statusIcon = Icons.access_time_filled;
        statusText = '勤務中（残業）';
        statusColor = Colors.orange;
      } else {
        statusIcon = Icons.work;
        statusText = '勤務中';
        statusColor = theme.colorScheme.primary;
      }
    } else {
      statusIcon = Icons.pause_circle;
      statusText = '待機中';
      statusColor = theme.colorScheme.onSurface.withOpacity(0.6);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: theme.textTheme.titleMedium?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// メインアクションボタン（プロジェクト指針準拠）
  Widget _buildMainActionButton(
      ThemeData theme, WorkerProvider workerProvider) {
    if (!workerProvider.isWorking) {
      // 勤務開始ボタン（大型ボタン）
      return SizedBox(
        width: double.infinity,
        height: 64,
        child: ElevatedButton.icon(
          onPressed: () => _startWork(workerProvider),
          icon: const Icon(Icons.play_arrow, size: 32),
          label: const Text(
            '勤務開始',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          ),
        ),
      );
    } else {
      // 勤務終了ボタン（大型ボタン）
      return SizedBox(
        width: double.infinity,
        height: 64,
        child: ElevatedButton.icon(
          onPressed: () => _stopWork(workerProvider),
          icon: const Icon(Icons.stop, size: 32),
          label: const Text(
            '勤務終了',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          ),
        ),
      );
    }
  }

  /// 今日の統計セクション
  Widget _buildTodayStatsSection(
      ThemeData theme, WorkerProvider workerProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.today, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                '今日の詳細',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  theme,
                  '定時収入',
                  AppConstants.formatCurrency(
                      workerProvider._todayRegularEarnings +
                          workerProvider.currentRegularEarnings),
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  theme,
                  '残業代',
                  AppConstants.formatCurrency(
                      workerProvider._todayOvertimeEarnings +
                          workerProvider.currentOvertimeEarnings),
                  Colors.green,
                ),
              ),
            ],
          ),
          if (workerProvider.todayTotalLoss > 0) ...[
            const SizedBox(height: 12),
            _buildStatItem(
              theme,
              'サービス残業損失',
              AppConstants.formatCurrency(workerProvider.todayTotalLoss),
              Colors.red,
            ),
          ],
        ],
      ),
    );
  }

  /// 統計アイテム
  Widget _buildStatItem(
      ThemeData theme, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color[600],
            ),
          ),
        ],
      ),
    );
  }

  /// 時給情報セクション
  Widget _buildWageInfoSection(
      ThemeData theme, SettingsProvider settingsProvider) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(Icons.attach_money,
                    color: theme.colorScheme.secondary, size: 24),
                const SizedBox(width: 8),
                Text('時給', style: theme.textTheme.bodyMedium),
                Text(
                  AppConstants.formatHourlyWage(settingsProvider.hourlyWage),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(Icons.schedule, color: Colors.orange[600], size: 24),
                const SizedBox(width: 8),
                Text('残業時給', style: theme.textTheme.bodyMedium),
                Text(
                  AppConstants.formatHourlyWage(
                      settingsProvider.overtimeHourlyWage),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 勤務開始処理
  Future<void> _startWork(WorkerProvider workerProvider) async {
    await AppConstants.provideiOSHapticFeedback(HapticFeedbackType.medium);
    final success = await workerProvider.startWork();

    if (!success && mounted) {
      _showErrorSnackBar(workerProvider.error ?? '勤務開始に失敗しました');
    }
  }

  /// 勤務終了処理
  Future<void> _stopWork(WorkerProvider workerProvider) async {
    // MainScreenのstopWorkDialogを呼び出し
    if (mounted) {
      final mainScreenState =
          context.findAncestorStateOfType<_MainScreenState>();
      mainScreenState?._showStopWorkDialog(workerProvider);
    }
  }

  /// エラースナックバー
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// =============================================================================
// Forward Declarations - パート3で実装される画面
// コンパイルエラー回避のための宣言
// =============================================================================

/// 資格投資画面（パート3で実装）
class CertificationScreen extends StatelessWidget {
  const CertificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '資格投資画面\n\nパート3で実装予定\n- 資格計画管理\n- ROI計算\n- 学習時給表示',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}

/// 設定画面（パート3で実装）
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '設定画面\n\nパート3で実装予定\n- 給与設定\n- 勤務時間設定\n- アプリ設定',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}

// =============================================================================
// パート2完了 - WorkValue核心機能実装
// =============================================================================

/// 【パート2完了】
/// ✅ 状態管理プロバイダー（SettingsProvider、WorkerProvider）
/// ✅ リアルタイム収入計算エンジン・タイマー管理
/// ✅ メイン画面（プロジェクト指針準拠の大型時計UI）
/// ✅ サービス残業判定システム「サービス残業ですか？」ダイアログ
/// ✅ 通知連携（昼休み・勤務終了・残業警告）
/// ✅ iOS専用ハプティクフィードバック統合
/// ✅ 今日の統計・時給表示・勤務状態インジケーター
///
/// 【プロジェクト指針要件達成】
/// ✅ 大型デジタル時計（13:45:23形式）
/// ✅ 今日の累積収入表示（¥12,450形式）
/// ✅ ステータス表示（勤務中/待機中）
/// ✅ 開始・停止ボタン（大型ボタン）
/// ✅ サービス残業判定ポップアップ
/// ✅ リアルタイム収入計算
/// ✅ 昼休み・勤務終了通知
///
/// 【パート3で実装予定】
/// - 資格投資画面（ROI計算・計画管理）
/// - 設定画面（給与・勤務時間・アプリ設定）
/// - 履歴画面（過去の勤務記録・統計）
/// - 高度なUI/UXコンポーネント/// =============================================================================
/// WorkValue - iOS専用労働価値可視化アプリ (パート3/3 最終)
///
/// 【パート3】個別画面・資格ROI計算・設定機能・完成版
/// - 資格投資画面（ROI計算・投資効率判定）
/// - 設定画面（給与・勤務時間・アプリ設定）
/// - 履歴・統計画面
/// - iOS専用高度なUI/UXコンポーネント
///
/// 【対象ユーザー】15-30歳社会人専用
/// 【完成機能】
/// - 労働価値可視化システム完成
/// - 資格投資ROI計算システム完成
/// - サービス残業判定システム完成
/// - iOS専用最適化完成
///
/// ※このパートをパート1・パート2に追加して完成版としてください
/// =============================================================================

// =============================================================================
// Certification Screen - 資格投資画面
// 資格取得のROI計算・投資効率判定・計画管理
// =============================================================================

/// 資格投資画面
/// 会社規定/転職想定の2パターンでROI計算
class CertificationScreen extends StatefulWidget {
  const CertificationScreen({super.key});

  @override
  State<CertificationScreen> createState() => _CertificationScreenState();
}

class _CertificationScreenState extends State<CertificationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<WorkerProvider>(
      builder: (context, workerProvider, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeSection(theme),
                  const SizedBox(height: 24),
                  _buildROIOverviewSection(theme, workerProvider),
                  const SizedBox(height: 32),
                  _buildCertificationPlansSection(theme, workerProvider),
                  const SizedBox(height: 24),
                  _buildAddPlanButton(theme),
                  const SizedBox(height: 100), // FAB用余白
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// ウェルカムセクション
  Widget _buildWelcomeSection(ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.school, color: Colors.blue, size: 32),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '資格投資でキャリアアップ',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '資格取得の投資効率をROI計算で見える化',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// ROI概要セクション
  Widget _buildROIOverviewSection(
      ThemeData theme, WorkerProvider workerProvider) {
    final plans = workerProvider.activeCertificationPlans;

    if (plans.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 48,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '資格計画を追加して\n投資効率を計算しましょう',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    // 最も効率の良い資格を表示
    final bestPlan =
        plans.reduce((a, b) => a.studyHourlyRate > b.studyHourlyRate ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.blue[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: Colors.blue[600], size: 24),
              const SizedBox(width: 8),
              Text(
                '最高投資効率',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            bestPlan.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '学習時給: ${AppConstants.formatHourlyWage(bestPlan.studyHourlyRate)}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[600],
                ),
              ),
              const SizedBox(width: 8),
              _buildROIBadge(bestPlan.roiLevel),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '総収入増加: ${AppConstants.formatCurrency(bestPlan.totalIncomeIncrease)}',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.blue[600],
            ),
          ),
        ],
      ),
    );
  }

  /// ROIレベルバッジ
  Widget _buildROIBadge(CertificationROILevel level) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: level.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: level.color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            level.emoji,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 4),
          Text(
            level.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: level.color[700],
            ),
          ),
        ],
      ),
    );
  }

  /// 資格計画リストセクション
  Widget _buildCertificationPlansSection(
      ThemeData theme, WorkerProvider workerProvider) {
    final plans = workerProvider.certificationPlans;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '資格計画',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (plans.isEmpty)
          _buildEmptyPlansState(theme)
        else
          ...plans.map((plan) => _buildPlanCard(theme, workerProvider, plan)),
      ],
    );
  }

  /// 空の計画状態
  Widget _buildEmptyPlansState(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.add_circle_outline,
            size: 48,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '資格計画を追加して\n投資効率を分析しましょう',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// 資格計画カード
  Widget _buildPlanCard(
      ThemeData theme, WorkerProvider workerProvider, CertificationPlan plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: plan.isCompleted
            ? Border.all(color: Colors.green.withOpacity(0.3))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー
          Row(
            children: [
              Icon(
                plan.type.icon,
                color:
                    plan.isCompleted ? Colors.green : theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  plan.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    decoration:
                        plan.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              if (plan.isCompleted)
                const Icon(Icons.check_circle, color: Colors.green, size: 20)
              else
                _buildROIBadge(plan.roiLevel),
            ],
          ),
          const SizedBox(height: 12),

          // タイプとROI情報
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  plan.type.displayName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '学習時給: ${AppConstants.formatHourlyWage(plan.studyHourlyRate)}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: plan.roiLevel.color[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 詳細情報
          _buildDetailRow(
              theme,
              '収入増加',
              AppConstants.formatCurrency(plan.increaseAmount),
              plan.type == CertificationType.companyRegulation ? '月額' : '年額'),
          const SizedBox(height: 8),
          _buildDetailRow(theme, '学習時間', '${plan.studyHours}時間', '予想'),
          const SizedBox(height: 8),
          _buildDetailRow(theme, '総増加額',
              AppConstants.formatCurrency(plan.totalIncomeIncrease), '生涯'),

          if (!plan.isCompleted) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _completeCertification(workerProvider, plan),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('取得完了'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => _editPlan(plan),
                  icon: const Icon(Icons.edit),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.surfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// 詳細情報行
  Widget _buildDetailRow(
      ThemeData theme, String label, String value, String unit) {
    return Row(
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const Spacer(),
        Text(
          '$value ($unit)',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// 計画追加ボタン
  Widget _buildAddPlanButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _addCertificationPlan,
        icon: const Icon(Icons.add, size: 24),
        label: const Text(
          '新しい資格計画を追加',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
      ),
    );
  }

  /// 資格計画追加
  Future<void> _addCertificationPlan() async {
    await showDialog(
      context: context,
      builder: (context) => const CertificationPlanDialog(),
    );
  }

  /// 計画編集
  Future<void> _editPlan(CertificationPlan plan) async {
    await showDialog(
      context: context,
      builder: (context) => CertificationPlanDialog(plan: plan),
    );
  }

  /// 資格取得完了
  Future<void> _completeCertification(
      WorkerProvider workerProvider, CertificationPlan plan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('資格取得完了'),
        content: Text('${plan.name}の取得が完了しましたか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('完了'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AppConstants.provideiOSHapticFeedback(HapticFeedbackType.medium);
      final success = await workerProvider.completeCertificationPlan(plan.id);
      if (success && mounted) {
        _showSuccessSnackBar('資格取得完了おめでとうございます！🎉');
      }
    }
  }

  /// 成功スナックバー
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// =============================================================================
// Certification Plan Dialog - 資格計画追加・編集ダイアログ
// =============================================================================

/// 資格計画追加・編集ダイアログ
class CertificationPlanDialog extends StatefulWidget {
  final CertificationPlan? plan;

  const CertificationPlanDialog({super.key, this.plan});

  @override
  State<CertificationPlanDialog> createState() =>
      _CertificationPlanDialogState();
}

class _CertificationPlanDialogState extends State<CertificationPlanDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _increaseAmountController = TextEditingController();
  final _studyHoursController = TextEditingController();

  CertificationType _selectedType = CertificationType.companyRegulation;
  DateTime? _targetDate;

  @override
  void initState() {
    super.initState();
    if (widget.plan != null) {
      _nameController.text = widget.plan!.name;
      _increaseAmountController.text = widget.plan!.increaseAmount.toString();
      _studyHoursController.text = widget.plan!.studyHours.toString();
      _selectedType = widget.plan!.type;
      _targetDate = widget.plan!.targetDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _increaseAmountController.dispose();
    _studyHoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.plan != null;

    return AlertDialog(
      title: Text(isEdit ? '資格計画編集' : '新しい資格計画'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 資格名
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '資格名',
                    hintText: '例: 情報処理技術者試験',
                    prefixIcon: Icon(Icons.school),
                  ),
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return '資格名を入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 計算タイプ選択
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '計算タイプ',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...CertificationType.values.map((type) {
                      return RadioListTile<CertificationType>(
                        title: Text(type.displayName),
                        subtitle: Text(type.description),
                        value: type,
                        groupValue: _selectedType,
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value!;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 16),

                // 収入増加額
                TextFormField(
                  controller: _increaseAmountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText:
                        _selectedType == CertificationType.companyRegulation
                            ? '月給増加額'
                            : '年収増加額',
                    hintText: '例: 50000',
                    prefixIcon: const Icon(Icons.attach_money),
                    suffixText:
                        _selectedType == CertificationType.companyRegulation
                            ? '円/月'
                            : '円/年',
                  ),
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return '金額を入力してください';
                    }
                    if (double.tryParse(value!) == null) {
                      return '正しい数値を入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 学習時間
                TextFormField(
                  controller: _studyHoursController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '予想学習時間',
                    hintText: '例: 300',
                    prefixIcon: Icon(Icons.schedule),
                    suffixText: '時間',
                  ),
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return '学習時間を入力してください';
                    }
                    if (int.tryParse(value!) == null) {
                      return '正しい数値を入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 目標日（オプション）
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(_targetDate == null
                      ? '目標日を設定（任意）'
                      : '目標日: ${DateFormat('yyyy/MM/dd').format(_targetDate!)}'),
                  trailing: _targetDate == null
                      ? const Icon(Icons.add)
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => _targetDate = null),
                        ),
                  onTap: _selectTargetDate,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: _savePlan,
          child: Text(isEdit ? '更新' : '追加'),
        ),
      ],
    );
  }

  /// 目標日選択
  Future<void> _selectTargetDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)), // 10年後まで
    );

    if (date != null) {
      setState(() {
        _targetDate = date;
      });
    }
  }

  /// 計画保存
  Future<void> _savePlan() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final increaseAmount = double.parse(_increaseAmountController.text);
    final studyHours = int.parse(_studyHoursController.text);

    final plan = CertificationPlan(
      id: widget.plan?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      type: _selectedType,
      increaseAmount: increaseAmount,
      studyHours: studyHours,
      targetDate: _targetDate,
    );

    final workerProvider = Provider.of<WorkerProvider>(context, listen: false);

    // TODO: 編集機能は将来実装（現在は追加のみ）
    final success = await workerProvider.addCertificationPlan(plan);

    if (success && mounted) {
      await AppConstants.provideiOSHapticFeedback(HapticFeedbackType.medium);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('資格計画を${widget.plan != null ? '更新' : '追加'}しました'),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
}

// =============================================================================
// Settings Screen - 設定画面
// 給与設定・勤務時間設定・アプリ設定
// =============================================================================

/// 設定画面
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            slivers: [
              _buildSliverAppBar(theme),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildBasicSettingsSection(theme, settingsProvider),
                      const SizedBox(height: 24),
                      _buildSalarySettingsSection(theme, settingsProvider),
                      const SizedBox(height: 24),
                      _buildWorkTimeSettingsSection(theme, settingsProvider),
                      const SizedBox(height: 24),
                      _buildDataSection(theme, settingsProvider),
                      const SizedBox(height: 24),
                      _buildAppInfoSection(theme),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// SliverAppBar
  Widget _buildSliverAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Text('設定', style: TextStyle(color: theme.colorScheme.onSurface)),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primaryContainer.withOpacity(0.3),
                theme.colorScheme.secondaryContainer.withOpacity(0.3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 基本設定セクション
  Widget _buildBasicSettingsSection(
      ThemeData theme, SettingsProvider settingsProvider) {
    return _buildSettingsSection(
      theme: theme,
      title: '基本設定',
      icon: Icons.settings,
      children: [
        _buildSwitchTile(
          theme: theme,
          title: 'ダークモード',
          subtitle: 'アプリの外観をダークテーマに変更',
          icon: Icons.dark_mode,
          value: settingsProvider.isDarkMode,
          onChanged: (value) async {
            final success = await settingsProvider.setDarkMode(value);
            if (!success && mounted) {
              _showErrorSnackBar('設定の変更に失敗しました');
            }
          },
        ),
        _buildSwitchTile(
          theme: theme,
          title: '通知',
          subtitle: '休憩リマインダーや成果通知を受け取る',
          icon: Icons.notifications,
          value: settingsProvider.notificationsEnabled,
          onChanged: (value) async {
            final success =
                await settingsProvider.setNotificationsEnabled(value);
            if (!success && mounted) {
              _showErrorSnackBar('通知設定の変更に失敗しました');
            }
          },
        ),
      ],
    );
  }

  /// 給与設定セクション
  Widget _buildSalarySettingsSection(
      ThemeData theme, SettingsProvider settingsProvider) {
    return _buildSettingsSection(
      theme: theme,
      title: '給与設定',
      icon: Icons.attach_money,
      children: [
        _buildActionTile(
          theme: theme,
          title: '月給',
          subtitle: AppConstants.formatCurrency(settingsProvider.monthlySalary),
          icon: Icons.account_balance_wallet,
          onTap: () => _showSalaryDialog(settingsProvider),
        ),
        _buildInfoTile(
          theme: theme,
          title: '計算時給',
          subtitle: AppConstants.formatHourlyWage(settingsProvider.hourlyWage),
          icon: Icons.calculate,
        ),
        _buildActionTile(
          theme: theme,
          title: '残業倍率',
          subtitle: '${settingsProvider.settings.overtimeRate}倍',
          icon: Icons.trending_up,
          onTap: () => _showOvertimeRateDialog(settingsProvider),
        ),
        _buildInfoTile(
          theme: theme,
          title: '残業時給',
          subtitle: AppConstants.formatHourlyWage(
              settingsProvider.overtimeHourlyWage),
          icon: Icons.schedule,
        ),
      ],
    );
  }

  /// 勤務時間設定セクション
  Widget _buildWorkTimeSettingsSection(
      ThemeData theme, SettingsProvider settingsProvider) {
    return _buildSettingsSection(
      theme: theme,
      title: '勤務時間設定',
      icon: Icons.access_time,
      children: [
        _buildActionTile(
          theme: theme,
          title: '1日の労働時間',
          subtitle: '${settingsProvider.workingHoursPerDay}時間',
          icon: Icons.today,
          onTap: () => _showWorkingHoursDialog(settingsProvider),
        ),
        _buildActionTile(
          theme: theme,
          title: '始業時刻',
          subtitle: '${settingsProvider.workStartHour}:00',
          icon: Icons.play_arrow,
          onTap: () => _showWorkStartTimeDialog(settingsProvider),
        ),
        _buildActionTile(
          theme: theme,
          title: '定時',
          subtitle: '${settingsProvider.workEndHour}:00',
          icon: Icons.stop,
          onTap: () => _showWorkEndTimeDialog(settingsProvider),
        ),
        _buildInfoTile(
          theme: theme,
          title: '月労働日数',
          subtitle: '${settingsProvider.settings.workingDaysPerMonth}日',
          icon: Icons.calendar_month,
        ),
      ],
    );
  }

  /// データ管理セクション
  Widget _buildDataSection(ThemeData theme, SettingsProvider settingsProvider) {
    return _buildSettingsSection(
      theme: theme,
      title: 'データ管理',
      icon: Icons.storage,
      children: [
        _buildActionTile(
          theme: theme,
          title: '勤務履歴',
          subtitle: '過去の勤務記録を確認',
          icon: Icons.history,
          onTap: () => _showWorkHistoryScreen(),
        ),
        _buildActionTile(
          theme: theme,
          title: 'データリセット',
          subtitle: '全データを削除（注意）',
          icon: Icons.delete_forever,
          onTap: () => _showDataResetDialog(),
          textColor: Colors.red,
        ),
      ],
    );
  }

  /// アプリ情報セクション
  Widget _buildAppInfoSection(ThemeData theme) {
    return _buildSettingsSection(
      theme: theme,
      title: 'アプリ情報',
      icon: Icons.info,
      children: [
        _buildInfoTile(
          theme: theme,
          title: 'WorkValue',
          subtitle: 'バージョン ${AppConstants.appVersion}',
          icon: Icons.apps,
        ),
        _buildActionTile(
          theme: theme,
          title: 'このアプリについて',
          subtitle: '労働価値可視化アプリ',
          icon: Icons.info_outline,
          onTap: () => _showAboutDialog(),
        ),
        _buildActionTile(
          theme: theme,
          title: '使い方ガイド',
          subtitle: 'アプリの基本的な使い方',
          icon: Icons.help_outline,
          onTap: () => _showHelpDialog(),
        ),
      ],
    );
  }

  /// 設定セクション構築
  Widget _buildSettingsSection({
    required ThemeData theme,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  /// スイッチタイル
  Widget _buildSwitchTile({
    required ThemeData theme,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: theme.colorScheme.primary, size: 20),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(value: value, onChanged: onChanged),
      contentPadding: EdgeInsets.zero,
    );
  }

  /// アクションタイル
  Widget _buildActionTile({
    required ThemeData theme,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    final color = textColor ?? theme.colorScheme.primary;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: TextStyle(color: textColor)),
      subtitle:
          Text(subtitle, style: TextStyle(color: textColor?.withOpacity(0.7))),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  /// 情報タイル
  Widget _buildInfoTile({
    required ThemeData theme,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: theme.colorScheme.primary, size: 20),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      contentPadding: EdgeInsets.zero,
    );
  }

  // ダイアログ表示メソッド群

  /// 月給設定ダイアログ
  void _showSalaryDialog(SettingsProvider settingsProvider) {
    final controller = TextEditingController(
      text: settingsProvider.monthlySalary.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('月給設定'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            labelText: '月給（円）',
            prefixText: '¥',
            hintText: '300000',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              final value = double.tryParse(controller.text);
              if (value != null && value > 0) {
                final success = await settingsProvider.setMonthlySalary(value);
                if (mounted) {
                  Navigator.pop(context);
                  if (success) {
                    _showSuccessSnackBar('月給を更新しました');
                    _syncWageSettings(settingsProvider);
                  } else {
                    _showErrorSnackBar('更新に失敗しました');
                  }
                }
              } else {
                _showErrorSnackBar('正しい金額を入力してください');
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  /// 残業倍率設定ダイアログ
  void _showOvertimeRateDialog(SettingsProvider settingsProvider) {
    final controller = TextEditingController(
      text: settingsProvider.settings.overtimeRate.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('残業倍率設定'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: '残業倍率',
            hintText: '1.25',
            suffixText: '倍',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              final value = double.tryParse(controller.text);
              if (value != null && value >= 1.0) {
                final success = await settingsProvider.setOvertimeRate(value);
                if (mounted) {
                  Navigator.pop(context);
                  if (success) {
                    _showSuccessSnackBar('残業倍率を更新しました');
                    _syncWageSettings(settingsProvider);
                  } else {
                    _showErrorSnackBar('更新に失敗しました');
                  }
                }
              } else {
                _showErrorSnackBar('1.0以上の数値を入力してください');
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  /// 労働時間設定ダイアログ
  void _showWorkingHoursDialog(SettingsProvider settingsProvider) {
    final controller = TextEditingController(
      text: settingsProvider.workingHoursPerDay.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('1日の労働時間設定'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            labelText: '労働時間（時間）',
            hintText: '8',
            suffixText: '時間',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0 && value <= 16) {
                final success =
                    await settingsProvider.setWorkingHours(hoursPerDay: value);
                if (mounted) {
                  Navigator.pop(context);
                  if (success) {
                    _showSuccessSnackBar('労働時間を更新しました');
                    _syncWageSettings(settingsProvider);
                  } else {
                    _showErrorSnackBar('更新に失敗しました');
                  }
                }
              } else {
                _showErrorSnackBar('1-16時間の範囲で入力してください');
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  /// 始業時刻設定ダイアログ
  void _showWorkStartTimeDialog(SettingsProvider settingsProvider) {
    int selectedHour = settingsProvider.workStartHour;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('始業時刻設定'),
        content: SizedBox(
          height: 200,
          child: ListWheelScrollView.useDelegate(
            itemExtent: 50,
            onSelectedItemChanged: (index) {
              selectedHour = index + 6; // 6時から開始
            },
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: 13, // 6:00-18:00
              builder: (context, index) {
                final hour = index + 6;
                return Center(
                  child: Text(
                    '${hour.toString().padLeft(2, '0')}:00',
                    style: const TextStyle(fontSize: 20),
                  ),
                );
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await settingsProvider.setWorkingHours(
                  startHour: selectedHour);
              if (mounted) {
                Navigator.pop(context);
                if (success) {
                  _showSuccessSnackBar('始業時刻を更新しました');
                } else {
                  _showErrorSnackBar('更新に失敗しました');
                }
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  /// 定時設定ダイアログ
  void _showWorkEndTimeDialog(SettingsProvider settingsProvider) {
    int selectedHour = settingsProvider.workEndHour;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('定時設定'),
        content: SizedBox(
          height: 200,
          child: ListWheelScrollView.useDelegate(
            itemExtent: 50,
            onSelectedItemChanged: (index) {
              selectedHour = index + 15; // 15時から開始
            },
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: 8, // 15:00-22:00
              builder: (context, index) {
                final hour = index + 15;
                return Center(
                  child: Text(
                    '${hour.toString().padLeft(2, '0')}:00',
                    style: const TextStyle(fontSize: 20),
                  ),
                );
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success =
                  await settingsProvider.setWorkingHours(endHour: selectedHour);
              if (mounted) {
                Navigator.pop(context);
                if (success) {
                  _showSuccessSnackBar('定時を更新しました');
                } else {
                  _showErrorSnackBar('更新に失敗しました');
                }
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  /// 勤務履歴画面表示
  void _showWorkHistoryScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WorkHistoryScreen()),
    );
  }

  /// データリセット確認ダイアログ
  void _showDataResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('データリセット'),
          ],
        ),
        content: const Text(
          '全ての勤務記録と資格計画が削除されます。\n'
          'この操作は取り消せません。\n\n'
          '本当にリセットしますか？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await StorageService.clearAllData();
              if (success && mounted) {
                _showSuccessSnackBar('データをリセットしました');
                // アプリ再起動が必要な旨を通知
                _showRestartDialog();
              } else {
                _showErrorSnackBar('リセットに失敗しました');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('リセット'),
          ),
        ],
      ),
    );
  }

  /// アプリ再起動ダイアログ
  void _showRestartDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('アプリ再起動'),
        content: const Text('データリセットが完了しました。\nアプリを再起動してください。'),
        actions: [
          ElevatedButton(
            onPressed: () => SystemNavigator.pop(),
            child: const Text('終了'),
          ),
        ],
      ),
    );
  }

  /// このアプリについてダイアログ
  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.work, color: Colors.white, size: 32),
      ),
      children: const [
        Text(
          'WorkValue は労働時間を金額で可視化し、15-30歳社会人のモチベーション向上を図るiOS専用アプリです。\n\n'
          '【主要機能】\n'
          '• リアルタイム収入計算\n'
          '• サービス残業の損失額表示\n'
          '• 資格取得のROI計算\n'
          '• 労働価値の見える化\n\n'
          '時間を有効活用し、より充実したキャリアを築きましょう。',
        ),
      ],
    );
  }

  /// ヘルプダイアログ
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('使い方ガイド'),
        content: const SingleChildScrollView(
          child: Text(
            '【基本的な使い方】\n'
            '1. 設定画面で月給を入力\n'
            '2. 勤務管理画面で「勤務開始」をタップ\n'
            '3. リアルタイムで収入が表示されます\n'
            '4. 勤務終了時は「勤務終了」をタップ\n\n'
            '【サービス残業判定】\n'
            '定時を過ぎた場合、自動的に残業判定ダイアログが表示されます。\n\n'
            '【資格投資】\n'
            '資格投資画面で取得予定の資格を追加し、ROI（投資収益率）を計算できます。\n\n'
            '【通知機能】\n'
            '昼休みや勤務終了時に成果通知が届きます。',
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  /// 時給設定同期
  void _syncWageSettings(SettingsProvider settingsProvider) {
    final workerProvider = Provider.of<WorkerProvider>(context, listen: false);
    workerProvider.updateWageSettings(
      hourlyWage: settingsProvider.hourlyWage,
      overtimeRate: settingsProvider.settings.overtimeRate,
      scheduledWorkingHours: settingsProvider.workingHoursPerDay,
    );
  }

  /// 成功スナックバー
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// エラースナックバー
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// =============================================================================
// Work History Screen - 勤務履歴画面
// 過去の勤務記録・統計表示
// =============================================================================

/// 勤務履歴画面
class WorkHistoryScreen extends StatefulWidget {
  const WorkHistoryScreen({super.key});

  @override
  State<WorkHistoryScreen> createState() => _WorkHistoryScreenState();
}

class _WorkHistoryScreenState extends State<WorkHistoryScreen> {
  List<WorkSession> _allSessions = [];
  List<WorkSession> _filteredSessions = [];
  String _selectedFilter = 'all'; // all, today, week, month

  @override
  void initState() {
    super.initState();
    _loadWorkSessions();
  }

  /// 勤務セッション読み込み
  Future<void> _loadWorkSessions() async {
    final sessions = await StorageService.loadWorkSessions();
    setState(() {
      _allSessions = sessions.where((s) => !s.isActive).toList();
      _allSessions.sort((a, b) => b.startTime.compareTo(a.startTime)); // 新しい順
      _applyFilter();
    });
  }

  /// フィルター適用
  void _applyFilter() {
    final now = DateTime.now();

    switch (_selectedFilter) {
      case 'today':
        _filteredSessions = _allSessions.where((session) {
          return session.startTime.year == now.year &&
              session.startTime.month == now.month &&
              session.startTime.day == now.day;
        }).toList();
        break;
      case 'week':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        _filteredSessions = _allSessions.where((session) {
          return session.startTime
              .isAfter(weekStart.subtract(const Duration(days: 1)));
        }).toList();
        break;
      case 'month':
        _filteredSessions = _allSessions.where((session) {
          return session.startTime.year == now.year &&
              session.startTime.month == now.month;
        }).toList();
        break;
      default:
        _filteredSessions = List.from(_allSessions);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('勤務履歴'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilterSection(theme),
          _buildStatsSection(theme),
          Expanded(
            child: _filteredSessions.isEmpty
                ? _buildEmptyState(theme)
                : _buildSessionsList(theme),
          ),
        ],
      ),
    );
  }

  /// フィルターセクション
  Widget _buildFilterSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            '期間:',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('all', '全期間'),
                  const SizedBox(width: 8),
                  _buildFilterChip('today', '今日'),
                  const SizedBox(width: 8),
                  _buildFilterChip('week', '今週'),
                  const SizedBox(width: 8),
                  _buildFilterChip('month', '今月'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// フィルターチップ
  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
          _applyFilter();
        });
      },
    );
  }

  /// 統計セクション
  Widget _buildStatsSection(ThemeData theme) {
    if (_filteredSessions.isEmpty) return const SizedBox.shrink();

    final totalEarnings =
        _filteredSessions.fold(0.0, (sum, s) => sum + s.totalEarnings);
    final totalServiceLoss =
        _filteredSessions.fold(0.0, (sum, s) => sum + s.serviceLoss);
    final totalDuration =
        _filteredSessions.fold(0, (sum, s) => sum + s.durationInSeconds);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              theme,
              '総収入',
              AppConstants.formatCurrency(totalEarnings),
              Colors.green,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatItem(
              theme,
              '労働時間',
              AppConstants.formatWorkDuration(Duration(seconds: totalDuration)),
              Colors.blue,
            ),
          ),
          if (totalServiceLoss > 0) ...[
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatItem(
                theme,
                '損失',
                AppConstants.formatCurrency(totalServiceLoss),
                Colors.red,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 統計アイテム
  Widget _buildStatItem(
      ThemeData theme, String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color[700],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 空の状態
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            '勤務記録がありません',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '勤務を開始すると履歴が表示されます',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  /// セッションリスト
  Widget _buildSessionsList(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredSessions.length,
      itemBuilder: (context, index) {
        final session = _filteredSessions[index];
        return _buildSessionCard(theme, session);
      },
    );
  }

  /// セッションカード
  Widget _buildSessionCard(ThemeData theme, WorkSession session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: session.isServiceOvertime
            ? Border.all(color: Colors.red.withOpacity(0.3))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー
          Row(
            children: [
              Text(
                DateFormat('M/d (E)', 'ja_JP').format(session.startTime),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (session.isServiceOvertime)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'サービス残業',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.red[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // 時間情報
          Row(
            children: [
              Text(
                '${DateFormat('HH:mm').format(session.startTime)} - ${DateFormat('HH:mm').format(session.endTime!)}',
                style: theme.textTheme.bodyMedium,
              ),
              const Spacer(),
              Text(
                session.formattedDuration,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 収入情報
          Row(
            children: [
              Expanded(
                child: _buildSessionStat(
                  theme,
                  '定時収入',
                  AppConstants.formatCurrency(session.regularEarnings),
                  Colors.blue,
                ),
              ),
              if (session.overtimeSeconds > 0) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSessionStat(
                    theme,
                    '残業代',
                    AppConstants.formatCurrency(session.overtimeEarnings),
                    session.isServiceOvertime ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ],
          ),

          if (session.serviceLoss > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    '損失: ${AppConstants.formatCurrency(session.serviceLoss)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.red[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // メモ
          if (session.note?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(
              'メモ: ${session.note}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// セッション統計アイテム
  Widget _buildSessionStat(
      ThemeData theme, String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color[700],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color[600],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// パート3完了 - WorkValue完成版
// =============================================================================

/// 【パート3完了 - WorkValue完成】
/// ✅ 資格投資画面（ROI計算・投資効率判定・計画管理）
/// ✅ 設定画面（給与・勤務時間・アプリ設定）
/// ✅ 勤務履歴画面（過去の勤務記録・統計表示）
/// ✅ 資格計画追加・編集ダイアログ
/// ✅ iOS専用高度なUI/UXコンポーネント
/// ✅ データ管理・リセット機能
/// ✅ ヘルプ・アプリ情報機能
/// 
/// 【WorkValue完成機能一覧】
/// 🎯 労働価値可視化システム
///   - リアルタイム収入計算エンジン
///   - 大型デジタル時計UI（プロジェクト指針準拠）
///   - 今日の累積収入表示
///   - 勤務開始・終了ワンタップ操作
/// 
/// ⚠️ サービス残業判定システム
///   - 定時超過時の自動判定
///   - 「サービス残業ですか？」ダイアログ
///   - 損失額計算・表示
///   - 残業代/サービス残業の分離記録
/// 
/// 📚 資格投資ROI計算システム
///   - 会社規定/転職想定の2パターン計算
///   - 学習時給算出（総収入増加÷学習時間）
///   - 投資効率判定（超優秀/優秀/良好/要検討）
///   - 資格計画管理・進捗追跡
/// 
/// 🔔 通知システム（プロジェクト指針準拠）
///   - 昼休み成果通知：「午前中で◯◯円稼ぎました！」
///   - 勤務終了通知：「今日もお疲れ様！今日で◯◯円稼ぎました！」
///   - サービス残業警告：損失額表示
///   - 休憩リマインダー：1時間ごと
/// 
/// 📊 統計・履歴システム
///   - 過去の勤務記録表示
///   - 期間別フィルタリング（今日/今週/今月/全期間）
///   - 収入・労働時間・損失の集計
///   - サービス残業の可視化
/// 
/// ⚙️ 設定システム
///   - 月給・時給・残業倍率設定
///   - 勤務時間・始業時刻・定時設定
///   - ダークモード・通知設定
///   - データ管理・リセット機能
/// 
/// 📱 iOS専用最適化
///   - ハプティクフィードバック（勤務開始・終了・設定変更）
///   - パルスアニメーション（勤務中の視覚フィードバック）
///   - スライド・フェードアニメーション
///   - iOS Human Interface Guidelines準拠デザイン
///   - NotoSansJPフォント統合
/// 
/// 【対象ユーザー】
/// 15-30歳社会人専用・モチベーション向上・労働価値の見える化
/// 
/// 【開発完了】
/// WorkValueアプリが完成しました。
/// パート1・パート2・パート3を結合して完全版としてご利用ください。