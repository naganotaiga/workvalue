/// WorkValue - メイン画面
/// タブベースナビゲーションでホーム、履歴、資格投資、設定画面を管理
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/worker_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'qualification_screen.dart';
import 'settings_screen.dart';

/// メインスクリーン（タブベースナビゲーション）
/// iOS専用デザインでボトムナビゲーションタブを提供
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _animationController;

  /// タブ画面リスト
  static const List<Widget> _screens = [
    HomeScreen(),
    HistoryScreen(),
    QualificationScreen(),
    SettingsScreen(),
  ];

  /// タブ情報
  static const List<_TabInfo> _tabs = [
    _TabInfo(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: UIStrings.homeTitle,
    ),
    _TabInfo(
      icon: Icons.history_outlined,
      activeIcon: Icons.history,
      label: UIStrings.historyTitle,
    ),
    _TabInfo(
      icon: Icons.school_outlined,
      activeIcon: Icons.school,
      label: UIStrings.qualificationTitle,
    ),
    _TabInfo(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: UIStrings.settingsTitle,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: WorkValueAnimations.standardDuration,
      vsync: this,
    );
    
    // プロバイダー初期化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// プロバイダーの初期化
  Future<void> _initializeProviders() async {
    try {
      final workerProvider = context.read<WorkerProvider>();
      final settingsProvider = context.read<SettingsProvider>();
      
      await Future.wait([
        workerProvider.initialize(),
        settingsProvider.initialize(),
      ]);
      
      _animationController.forward();
    } catch (e) {
      debugPrint('❌ プロバイダー初期化エラー: $e');
    }
  }

  /// タブ変更処理
  void _onTabChanged(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
      
      // ページ遷移アニメーション
      _pageController.animateToPage(
        index,
        duration: WorkValueAnimations.standardDuration,
        curve: Curves.easeInOut,
      );
      
      // ハプティクフィードバック
      HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      // iOS専用システムUI設定
      extendBody: true,
      extendBodyBehindAppBar: false,
      
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _animationController,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.easeOut,
                )),
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  children: _screens,
                ),
              ),
            );
          },
        ),
      ),
      
      // iOS専用ボトムナビゲーションバー
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.2),
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              children: _tabs.asMap().entries.map((entry) {
                final index = entry.key;
                final tab = entry.value;
                final isSelected = _currentIndex == index;
                
                return Expanded(
                  child: _buildTabItem(
                    tab: tab,
                    isSelected: isSelected,
                    onTap: () => _onTabChanged(index),
                    theme: theme,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  /// タブアイテムのビルド
  Widget _buildTabItem({
    required _TabInfo tab,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    final color = isSelected 
        ? theme.colorScheme.primary 
        : theme.colorScheme.onSurface.withOpacity(0.6);
    
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: WorkValueAnimations.shortDuration,
        curve: Curves.easeInOut,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // アイコン
            AnimatedSwitcher(
              duration: WorkValueAnimations.shortDuration,
              child: Icon(
                isSelected ? tab.activeIcon : tab.icon,
                key: ValueKey('${tab.label}_$isSelected'),
                color: color,
                size: 24,
              ),
            ),
            
            const SizedBox(height: 4),
            
            // ラベル
            AnimatedDefaultTextStyle(
              duration: WorkValueAnimations.shortDuration,
              style: theme.textTheme.labelSmall!.copyWith(
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 12,
              ),
              child: Text(
                tab.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// タブ情報データクラス
class _TabInfo {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _TabInfo({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// メイン画面用のエラーウィジェット
class MainScreenError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const MainScreenError({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(WorkValueSpacing.large),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              
              const SizedBox(height: WorkValueSpacing.medium),
              
              Text(
                UIStrings.errorGeneral,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: WorkValueSpacing.small),
              
              Text(
                message,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              
              if (onRetry != null) ...[
                const SizedBox(height: WorkValueSpacing.large),
                ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('再試行'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// メイン画面用のローディングウィジェット
class MainScreenLoading extends StatelessWidget {
  const MainScreenLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
            
            const SizedBox(height: WorkValueSpacing.medium),
            
            Text(
              'WorkValue を起動中...',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}