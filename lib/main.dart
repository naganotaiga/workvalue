/// WorkValue - iOS専用労働価値可視化アプリ
/// メインエントリーポイント - 最適化されたアーキテクチャ
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/worker_provider.dart';
import 'providers/settings_provider.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'screens/main_screen.dart';
import 'utils/theme.dart';

/// WorkValue メインアプリケーション起動
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
      StorageService.initialize(),
      NotificationService.initialize(),
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
  try {
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

    // iPhone専用縦向き固定設定（エラーハンドリング付き）
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]).timeout(
      const Duration(seconds: 3),
      onTimeout: () {
        debugPrint('⚠️ 画面向き設定タイムアウト（動作に影響なし）');
      },
    );
  } catch (e) {
    debugPrint('⚠️ システムUI設定エラー（動作に影響なし）: $e');
  }
}

/// WorkValue メインアプリケーション
/// 社会人専用・iOS専用設計で最適化されたマルチプロバイダー構成
class WorkValueApp extends StatelessWidget {
  const WorkValueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // 社会人向け状態管理プロバイダー群
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
            supportedLocales: const [
              Locale('ja', 'JP'),
              Locale('en', 'US'), // フォールバック用
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            // メイン画面
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