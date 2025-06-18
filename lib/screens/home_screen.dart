/// WorkValue - ホーム画面
/// 勤務管理、収入表示、勤務タイマーのメイン機能を提供
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/worker_provider.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';

/// ホーム画面（勤務管理メイン）
/// 労働時間計測、収入表示、勤務開始/終了ボタンを提供
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  Timer? _clockTimer;
  late AnimationController _pulseController;
  late AnimationController _incomeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _incomeAnimation;

  @override
  void initState() {
    super.initState();
    
    // アニメーションコントローラー初期化
    _pulseController = AnimationController(
      duration: WorkValueAnimations.pulseDuration,
      vsync: this,
    );
    
    _incomeController = AnimationController(
      duration: WorkValueAnimations.standardDuration,
      vsync: this,
    );
    
    // アニメーション設定
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _incomeAnimation = CurvedAnimation(
      parent: _incomeController,
      curve: Curves.easeOut,
    );
    
    // 時計タイマー開始
    _startClockTimer();
    
    // 初期アニメーション
    _incomeController.forward();
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _pulseController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  /// 時計タイマーの開始
  void _startClockTimer() {
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {}); // 時計を更新
    });
  }

  /// 勤務開始処理
  Future<void> _startWork() async {
    try {
      final workerProvider = context.read<WorkerProvider>();
      await workerProvider.startWork();
      
      // パルスアニメーション開始
      _pulseController.repeat(reverse: true);
      
      // ハプティクフィードバック
      HapticFeedback.mediumImpact();
    } catch (e) {
      _showErrorSnackBar('勤務開始に失敗しました: $e');
    }
  }

  /// 勤務終了処理
  Future<void> _endWork() async {
    final workerProvider = context.read<WorkerProvider>();
    
    // 定時チェック
    final isOvertime = _isOvertimeWork(workerProvider);
    
    if (isOvertime) {
      // サービス残業確認ダイアログ
      final isServiceOvertime = await _showOvertimeDialog();
      if (isServiceOvertime == null) return; // キャンセル
      
      await workerProvider.endWork(isServiceOvertime: isServiceOvertime);
    } else {
      await workerProvider.endWork();
    }
    
    // パルスアニメーション停止
    _pulseController.stop();
    _pulseController.reset();
    
    // ハプティクフィードバック
    HapticFeedback.heavyImpact();
  }

  /// 残業かどうかの判定
  bool _isOvertimeWork(WorkerProvider provider) {
    if (provider.currentSession == null) return false;
    
    final workMinutes = provider.currentWorkMinutes;
    final regularWorkMinutes = provider.worker.dailyWorkHours * 60;
    
    return workMinutes > regularWorkMinutes;
  }

  /// サービス残業確認ダイアログ
  Future<bool?> _showOvertimeDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('残業の確認'),
        content: const Text('定時を過ぎていますが、サービス残業ですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(UIStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('残業代あり'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: WorkValueColors.error,
            ),
            child: const Text('サービス残業'),
          ),
        ],
      ),
    );
  }

  /// エラースナックバー表示
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: WorkValueColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Consumer<WorkerProvider>(
        builder: (context, workerProvider, child) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(WorkValueSpacing.pagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ヘッダー部分
                  _buildHeader(theme),
                  
                  const SizedBox(height: WorkValueSpacing.large),
                  
                  // メイン収入表示
                  _buildIncomeDisplay(theme, workerProvider),
                  
                  const SizedBox(height: WorkValueSpacing.large),
                  
                  // デジタル時計
                  _buildDigitalClock(theme),
                  
                  const SizedBox(height: WorkValueSpacing.large),
                  
                  // 勤務開始/終了ボタン
                  _buildWorkButton(theme, workerProvider),
                  
                  const SizedBox(height: WorkValueSpacing.large),
                  
                  // 今日の統計
                  _buildTodayStats(theme, workerProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// ヘッダー部分
  Widget _buildHeader(ThemeData theme) {
    final now = DateTime.now();
    final dateFormat = DateFormat('M月d日（E）', 'ja');
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'おはようございます',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              dateFormat.format(now),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.work_outline,
            color: theme.colorScheme.primary,
            size: 32,
          ),
        ),
      ],
    );
  }

  /// メイン収入表示
  Widget _buildIncomeDisplay(ThemeData theme, WorkerProvider provider) {
    final isWorking = provider.isWorking;
    final currentIncome = isWorking ? provider.currentIncome : provider.todaysIncome;
    final label = isWorking ? '現在の収入' : '今日の収入';
    
    return AnimatedBuilder(
      animation: _incomeAnimation,
      child: Container(
        padding: const EdgeInsets.all(WorkValueSpacing.large),
        decoration: BoxDecoration(
          gradient: WorkValueColors.incomeGradient,
          borderRadius: BorderRadius.circular(WorkValueSpacing.cardRadius),
          boxShadow: [
            BoxShadow(
              color: WorkValueColors.success.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: WorkValueSpacing.small),
            AnimatedBuilder(
              animation: isWorking ? _pulseAnimation : 
                  const AlwaysStoppedAnimation(1.0),
              builder: (context, child) {
                return Transform.scale(
                  scale: isWorking ? _pulseAnimation.value : 1.0,
                  child: Text(
                    FormatSettings.formatCurrency(currentIncome),
                    style: WorkValueTextStyles.incomeDisplay.copyWith(
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      builder: (context, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.5),
            end: Offset.zero,
          ).animate(_incomeAnimation),
          child: FadeTransition(
            opacity: _incomeAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// デジタル時計
  Widget _buildDigitalClock(ThemeData theme) {
    final now = DateTime.now();
    final timeFormat = DateFormat('HH:mm:ss');
    
    return Container(
      padding: const EdgeInsets.all(WorkValueSpacing.medium),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(WorkValueSpacing.cardRadius),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Text(
        timeFormat.format(now),
        style: WorkValueTextStyles.digitalClock.copyWith(
          color: theme.colorScheme.onSurface,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// 勤務開始/終了ボタン
  Widget _buildWorkButton(ThemeData theme, WorkerProvider provider) {
    final isWorking = provider.isWorking;
    final buttonText = isWorking ? UIStrings.endWork : UIStrings.startWork;
    final buttonColor = isWorking ? WorkValueColors.error : WorkValueColors.success;
    final buttonIcon = isWorking ? Icons.stop : Icons.play_arrow;
    
    return SizedBox(
      height: 64,
      child: ElevatedButton.icon(
        onPressed: isWorking ? _endWork : _startWork,
        icon: Icon(buttonIcon, size: 28),
        label: Text(
          buttonText,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(WorkValueSpacing.buttonRadius),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  /// 今日の統計
  Widget _buildTodayStats(ThemeData theme, WorkerProvider provider) {
    final todaysWorkMinutes = provider.todaysWorkMinutes;
    final todaysLoss = provider.todaysServiceOvertimeLoss;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(WorkValueSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '今日の統計',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: WorkValueSpacing.medium),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    theme,
                    '労働時間',
                    FormatSettings.formatDuration(todaysWorkMinutes),
                    Icons.access_time,
                    WorkValueColors.info,
                  ),
                ),
                if (todaysLoss > 0) ...[
                  const SizedBox(width: WorkValueSpacing.medium),
                  Expanded(
                    child: _buildStatItem(
                      theme,
                      'サービス残業損失',
                      FormatSettings.formatCurrency(todaysLoss),
                      Icons.warning,
                      WorkValueColors.error,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 統計アイテム
  Widget _buildStatItem(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(WorkValueSpacing.medium),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}