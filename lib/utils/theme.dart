/// WorkValue - テーマ設定ユーティリティ
/// iOS専用Material Design 3テーマシステム
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

      // iOS専用BottomNavigationBar設定
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'NotoSansJP',
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'NotoSansJP',
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),

      // カード設定
      cardTheme: CardTheme(
        elevation: 2,
        shadowColor: colorScheme.shadow.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // ボタン設定
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontFamily: 'NotoSansJP',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // テキストボタン設定
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontFamily: 'NotoSansJP',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // 入力フィールド設定
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        labelStyle: const TextStyle(
          fontFamily: 'NotoSansJP',
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        hintStyle: TextStyle(
          fontFamily: 'NotoSansJP',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface.withOpacity(0.6),
        ),
      ),

      // スイッチ設定
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(colorScheme.primary),
        trackColor: WidgetStateProperty.all(colorScheme.primaryContainer),
      ),

      // スライダー設定
      sliderTheme: SliderThemeData(
        activeTrackColor: colorScheme.primary,
        inactiveTrackColor: colorScheme.primaryContainer,
        thumbColor: colorScheme.primary,
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
      primary: _primaryBlue.withOpacity(0.8),
      secondary: _accentGreen.withOpacity(0.8),
      tertiary: _warningOrange.withOpacity(0.8),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      // NotoSansJP + iOS標準フォント融合
      fontFamily: 'NotoSansJP',

      // iOS専用AppBar設定（ダーク）
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

      // iOS専用BottomNavigationBar設定（ダーク）
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'NotoSansJP',
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'NotoSansJP',
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),

      // カード設定（ダーク）
      cardTheme: CardTheme(
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // ボタン設定（ダーク）
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontFamily: 'NotoSansJP',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // 入力フィールド設定（ダーク）
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        labelStyle: const TextStyle(
          fontFamily: 'NotoSansJP',
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        hintStyle: TextStyle(
          fontFamily: 'NotoSansJP',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }

}

/// 特定用途向けカラーセット
class WorkValueColors {
  /// 収入表示用の緑系グラデーション
  static const LinearGradient incomeGradient = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// 損失表示用の赤系グラデーション
  static const LinearGradient lossGradient = LinearGradient(
    colors: [Color(0xFFE53935), Color(0xFFFF5722)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// 警告表示用のオレンジ系グラデーション
  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// 情報表示用の青系グラデーション
  static const LinearGradient infoGradient = LinearGradient(
    colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// 成功表示用の緑系色
  static const Color success = Color(0xFF4CAF50);
  
  /// 警告表示用のオレンジ系色
  static const Color warning = Color(0xFFFF9800);
  
  /// エラー表示用の赤系色
  static const Color error = Color(0xFFE53935);
  
  /// 情報表示用の青系色
  static const Color info = Color(0xFF2196F3);
}

/// テキストスタイル定義
class WorkValueTextStyles {
  /// 大型デジタル時計用スタイル
  static const TextStyle digitalClock = TextStyle(
    fontFamily: 'NotoSansJP',
    fontSize: 48,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.0,
  );

  /// 収入表示用スタイル
  static const TextStyle incomeDisplay = TextStyle(
    fontFamily: 'NotoSansJP',
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
  );

  /// 統計数値用スタイル
  static const TextStyle statisticNumber = TextStyle(
    fontFamily: 'NotoSansJP',
    fontSize: 24,
    fontWeight: FontWeight.w500,
  );

  /// ラベル用スタイル
  static const TextStyle label = TextStyle(
    fontFamily: 'NotoSansJP',
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  /// 小さなキャプション用スタイル
  static const TextStyle caption = TextStyle(
    fontFamily: 'NotoSansJP',
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );
}

/// アニメーション定数
class WorkValueAnimations {
  /// 標準アニメーション継続時間
  static const Duration standardDuration = Duration(milliseconds: 300);
  
  /// 短いアニメーション継続時間
  static const Duration shortDuration = Duration(milliseconds: 200);
  
  /// 長いアニメーション継続時間
  static const Duration longDuration = Duration(milliseconds: 500);
  
  /// パルスアニメーション継続時間
  static const Duration pulseDuration = Duration(seconds: 2);
}

/// レイアウト定数
class WorkValueSpacing {
  /// 極小スペース
  static const double xs = 4.0;
  
  /// 小スペース
  static const double small = 8.0;
  
  /// 中スペース
  static const double medium = 16.0;
  
  /// 大スペース
  static const double large = 24.0;
  
  /// 極大スペース
  static const double xl = 32.0;
  
  /// ページパディング
  static const double pagePadding = 16.0;
  
  /// カードの角丸
  static const double cardRadius = 12.0;
  
  /// ボタンの角丸
  static const double buttonRadius = 8.0;
}