/// WorkValue - 設定画面
/// 労働条件、通知設定、アプリ設定の管理を提供
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/worker_provider.dart';
import '../providers/settings_provider.dart';
import '../models/worker.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';

/// 設定画面（各種設定管理）
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(UIStrings.settingsTitle),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(WorkValueSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 労働条件設定
            _buildSectionTitle(theme, '労働条件'),
            _buildWorkerSettings(theme),
            
            const SizedBox(height: WorkValueSpacing.large),
            
            // 通知設定
            _buildSectionTitle(theme, '通知設定'),
            _buildNotificationSettings(theme),
            
            const SizedBox(height: WorkValueSpacing.large),
            
            // アプリ設定
            _buildSectionTitle(theme, 'アプリ設定'),
            _buildAppSettings(theme),
            
            const SizedBox(height: WorkValueSpacing.large),
            
            // データ管理
            _buildSectionTitle(theme, 'データ管理'),
            _buildDataManagement(theme),
            
            const SizedBox(height: WorkValueSpacing.large),
            
            // アプリ情報
            _buildSectionTitle(theme, 'アプリ情報'),
            _buildAppInfo(theme),
          ],
        ),
      ),
    );
  }

  /// セクションタイトル
  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: WorkValueSpacing.small),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  /// 労働条件設定
  Widget _buildWorkerSettings(ThemeData theme) {
    return Consumer<WorkerProvider>(
      builder: (context, provider, child) {
        return Card(
          child: Column(
            children: [
              _buildSettingsTile(
                icon: Icons.attach_money,
                title: '月給設定',
                subtitle: FormatSettings.formatCurrency(provider.worker.monthlySalary),
                onTap: () => _showSalaryDialog(provider.worker),
              ),
              _buildSettingsTile(
                icon: Icons.schedule,
                title: '勤務時間設定',
                subtitle: '${provider.worker.dailyWorkHours}時間/日',
                onTap: () => _showWorkHoursDialog(provider.worker),
              ),
              _buildSettingsTile(
                icon: Icons.trending_up,
                title: '残業代倍率',
                subtitle: '${provider.worker.overtimeMultiplier}倍',
                onTap: () => _showOvertimeMultiplierDialog(provider.worker),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 通知設定
  Widget _buildNotificationSettings(ThemeData theme) {
    return Consumer<SettingsProvider>(
      builder: (context, provider, child) {
        return Card(
          child: Column(
            children: [
              _buildSwitchTile(
                icon: Icons.notifications,
                title: '通知機能',
                subtitle: '全ての通知の有効/無効',
                value: provider.isNotificationEnabled,
                onChanged: provider.setNotificationEnabled,
              ),
              _buildSwitchTile(
                icon: Icons.coffee,
                title: '休憩リマインダー',
                subtitle: '1時間ごとの休憩提案',
                value: provider.isBreakReminderEnabled,
                onChanged: provider.setBreakReminderEnabled,
                enabled: provider.isNotificationEnabled,
              ),
              _buildSwitchTile(
                icon: Icons.lunch_dining,
                title: '昼休み通知',
                subtitle: '午前中の成果をお知らせ',
                value: provider.isLunchNotificationEnabled,
                onChanged: provider.setLunchNotificationEnabled,
                enabled: provider.isNotificationEnabled,
              ),
              _buildSwitchTile(
                icon: Icons.home,
                title: '勤務終了通知',
                subtitle: '1日の成果をお知らせ',
                value: provider.isEndNotificationEnabled,
                onChanged: provider.setEndNotificationEnabled,
                enabled: provider.isNotificationEnabled,
              ),
              _buildSwitchTile(
                icon: Icons.warning,
                title: 'サービス残業警告',
                subtitle: '定時超過時の損失通知',
                value: provider.isOvertimeWarningEnabled,
                onChanged: provider.setOvertimeWarningEnabled,
                enabled: provider.isNotificationEnabled,
              ),
            ],
          ),
        );
      },
    );
  }

  /// アプリ設定
  Widget _buildAppSettings(ThemeData theme) {
    return Consumer<SettingsProvider>(
      builder: (context, provider, child) {
        return Card(
          child: Column(
            children: [
              _buildSwitchTile(
                icon: Icons.dark_mode,
                title: 'ダークモード',
                subtitle: '画面を暗いテーマに変更',
                value: provider.isDarkMode,
                onChanged: provider.setDarkMode,
              ),
            ],
          ),
        );
      },
    );
  }

  /// データ管理
  Widget _buildDataManagement(ThemeData theme) {
    return Card(
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.backup,
            title: 'データバックアップ',
            subtitle: 'データをエクスポート',
            onTap: _exportData,
          ),
          _buildSettingsTile(
            icon: Icons.restore,
            title: 'データ復元',
            subtitle: 'バックアップから復元',
            onTap: _importData,
          ),
          _buildSettingsTile(
            icon: Icons.delete_forever,
            title: 'すべてのデータをリセット',
            subtitle: '注意: 元に戻せません',
            onTap: _showResetConfirmDialog,
            textColor: WorkValueColors.error,
          ),
        ],
      ),
    );
  }

  /// アプリ情報
  Widget _buildAppInfo(ThemeData theme) {
    return Card(
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.info,
            title: 'バージョン',
            subtitle: AppConstants.appVersion,
            onTap: null,
          ),
          _buildSettingsTile(
            icon: Icons.description,
            title: 'プライバシーポリシー',
            subtitle: 'データの取り扱いについて',
            onTap: _openPrivacyPolicy,
          ),
          _buildSettingsTile(
            icon: Icons.gavel,
            title: '利用規約',
            subtitle: 'アプリの利用条件',
            onTap: _openTermsOfService,
          ),
          _buildSettingsTile(
            icon: Icons.mail,
            title: 'サポート',
            subtitle: 'お問い合わせ',
            onTap: _contactSupport,
          ),
        ],
      ),
    );
  }

  /// 設定項目タイル
  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      subtitle: Text(subtitle),
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }

  /// スイッチタイル
  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    bool enabled = true,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: enabled ? null : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: enabled ? null : Colors.grey,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: enabled ? onChanged : null,
      ),
    );
  }

  /// 月給設定ダイアログ
  void _showSalaryDialog(Worker worker) {
    final controller = TextEditingController(
      text: worker.monthlySalary.toInt().toString(),
    );
    
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('月給設定'),
        content: TextFormField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '月給（円）',
            hintText: '例: 300000',
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(UIStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final salary = double.tryParse(controller.text);
              if (salary != null && 
                  salary >= ValidationRules.minMonthlySalary && 
                  salary <= ValidationRules.maxMonthlySalary) {
                final newWorker = worker.copyWith(
                  monthlySalary: salary,
                  hourlySalary: salary / worker.monthlyWorkHours,
                );
                context.read<WorkerProvider>().updateWorker(newWorker);
                Navigator.of(context).pop();
              }
            },
            child: const Text(UIStrings.save),
          ),
        ],
      ),
    );
  }

  /// 勤務時間設定ダイアログ
  void _showWorkHoursDialog(Worker worker) {
    final controller = TextEditingController(
      text: worker.dailyWorkHours.toString(),
    );
    
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('勤務時間設定'),
        content: TextFormField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '1日の勤務時間',
            hintText: '例: 8',
            suffixText: '時間',
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(UIStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final hours = int.tryParse(controller.text);
              if (hours != null && 
                  hours >= ValidationRules.minDailyWorkHours && 
                  hours <= ValidationRules.maxDailyWorkHours) {
                final newWorker = worker.copyWith(dailyWorkHours: hours);
                context.read<WorkerProvider>().updateWorker(newWorker);
                Navigator.of(context).pop();
              }
            },
            child: const Text(UIStrings.save),
          ),
        ],
      ),
    );
  }

  /// 残業倍率設定ダイアログ
  void _showOvertimeMultiplierDialog(Worker worker) {
    final controller = TextEditingController(
      text: worker.overtimeMultiplier.toString(),
    );
    
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('残業代倍率設定'),
        content: TextFormField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '残業代倍率',
            hintText: '例: 1.25',
            suffixText: '倍',
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(UIStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final multiplier = double.tryParse(controller.text);
              if (multiplier != null && 
                  multiplier >= ValidationRules.minOvertimeMultiplier && 
                  multiplier <= ValidationRules.maxOvertimeMultiplier) {
                final newWorker = worker.copyWith(overtimeMultiplier: multiplier);
                context.read<WorkerProvider>().updateWorker(newWorker);
                Navigator.of(context).pop();
              }
            },
            child: const Text(UIStrings.save),
          ),
        ],
      ),
    );
  }

  /// リセット確認ダイアログ
  void _showResetConfirmDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(UIStrings.confirmTitle),
        content: const Text(UIStrings.confirmReset),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(UIStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<WorkerProvider>().resetAllData();
              await context.read<SettingsProvider>().resetAllSettings();
              Navigator.of(context).pop();
              _showSuccessSnackBar(UIStrings.successReset);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: WorkValueColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text(UIStrings.confirmResetButton),
          ),
        ],
      ),
    );
  }

  /// データエクスポート
  void _exportData() {
    // 実装時にファイル書き込み処理を追加
    _showSuccessSnackBar('データをエクスポートしました');
  }

  /// データインポート
  void _importData() {
    // 実装時にファイル読み込み処理を追加
    _showSuccessSnackBar('データをインポートしました');
  }

  /// プライバシーポリシーを開く
  void _openPrivacyPolicy() {
    // 実装時にブラウザまたはWebViewで開く
  }

  /// 利用規約を開く
  void _openTermsOfService() {
    // 実装時にブラウザまたはWebViewで開く
  }

  /// サポートに連絡
  void _contactSupport() {
    // 実装時にメールアプリを開く
  }

  /// 成功スナックバー表示
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: WorkValueColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}