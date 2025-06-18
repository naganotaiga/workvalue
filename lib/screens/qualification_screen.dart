/// WorkValue - 資格投資画面
/// 資格取得計画の管理、ROI計算、投資効率判定を提供
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/worker_provider.dart';
import '../models/qualification.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';

/// 資格投資画面（ROI計算・計画管理）
class QualificationScreen extends StatefulWidget {
  const QualificationScreen({super.key});

  @override
  State<QualificationScreen> createState() => _QualificationScreenState();
}

class _QualificationScreenState extends State<QualificationScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(UIStrings.qualificationTitle),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        actions: [
          IconButton(
            onPressed: _showAddQualificationDialog,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Consumer<WorkerProvider>(
        builder: (context, provider, child) {
          final plans = provider.qualificationPlans;
          
          if (plans.isEmpty) {
            return _buildEmptyState(theme);
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(WorkValueSpacing.medium),
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];
              final roi = QualificationROI.calculate(plan);
              return _buildQualificationCard(theme, plan, roi);
            },
          );
        },
      ),
    );
  }

  /// 空の状態表示
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: WorkValueSpacing.medium),
          Text(
            '資格取得計画がありません',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: WorkValueSpacing.small),
          Text(
            '新しい計画を追加してみましょう',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: WorkValueSpacing.large),
          ElevatedButton.icon(
            onPressed: _showAddQualificationDialog,
            icon: const Icon(Icons.add),
            label: const Text('計画を追加'),
          ),
        ],
      ),
    );
  }

  /// 資格カード
  Widget _buildQualificationCard(
    ThemeData theme,
    QualificationPlan plan,
    QualificationROI roi,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: WorkValueSpacing.medium),
      child: Padding(
        padding: const EdgeInsets.all(WorkValueSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    plan.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _buildStatusChip(theme, plan.status),
              ],
            ),
            const SizedBox(height: WorkValueSpacing.medium),
            
            // ROI情報
            _buildROIInfo(theme, roi),
            
            const SizedBox(height: WorkValueSpacing.medium),
            
            // 基本情報
            _buildBasicInfo(theme, plan),
            
            const SizedBox(height: WorkValueSpacing.medium),
            
            // アクションボタン
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _showEditQualificationDialog(plan),
                  child: const Text(UIStrings.edit),
                ),
                TextButton(
                  onPressed: () => _deleteQualification(plan),
                  style: TextButton.styleFrom(
                    foregroundColor: WorkValueColors.error,
                  ),
                  child: const Text(UIStrings.delete),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// ステータスチップ
  Widget _buildStatusChip(ThemeData theme, QualificationStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: WorkValueSpacing.small,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Color(status.colorValue).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName,
        style: theme.textTheme.bodySmall?.copyWith(
          color: Color(status.colorValue),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// ROI情報
  Widget _buildROIInfo(ThemeData theme, QualificationROI roi) {
    return Container(
      padding: const EdgeInsets.all(WorkValueSpacing.medium),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildROIColumn(
                  theme,
                  '会社規定',
                  roi.companyRating,
                  '${FormatSettings.formatDecimal(roi.companyROI)}年で回収',
                  '学習時給: ${FormatSettings.formatCurrency(roi.companyStudyWage)}',
                ),
              ),
              const SizedBox(width: WorkValueSpacing.medium),
              Expanded(
                child: _buildROIColumn(
                  theme,
                  '転職想定',
                  roi.transferRating,
                  '${FormatSettings.formatDecimal(roi.transferROI)}年で回収',
                  '学習時給: ${FormatSettings.formatCurrency(roi.transferStudyWage)}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ROI列
  Widget _buildROIColumn(
    ThemeData theme,
    String title,
    ROIRating rating,
    String roiText,
    String wageText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(rating.icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text(
              rating.displayName,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Color(rating.colorValue),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          roiText,
          style: theme.textTheme.bodySmall,
        ),
        Text(
          wageText,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  /// 基本情報
  Widget _buildBasicInfo(ThemeData theme, QualificationPlan plan) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                theme,
                '費用',
                FormatSettings.formatCurrency(plan.cost),
              ),
            ),
            Expanded(
              child: _buildInfoItem(
                theme,
                '学習時間',
                '${plan.studyHours}時間',
              ),
            ),
          ],
        ),
        const SizedBox(height: WorkValueSpacing.small),
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                theme,
                '目標日',
                FormatSettings.formatDate(plan.targetDate),
              ),
            ),
            if (plan.acquiredDate != null)
              Expanded(
                child: _buildInfoItem(
                  theme,
                  '取得日',
                  FormatSettings.formatDate(plan.acquiredDate!),
                ),
              ),
          ],
        ),
      ],
    );
  }

  /// 情報アイテム
  Widget _buildInfoItem(ThemeData theme, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// 資格追加ダイアログ
  void _showAddQualificationDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => _QualificationDialog(),
    );
  }

  /// 資格編集ダイアログ
  void _showEditQualificationDialog(QualificationPlan plan) {
    showDialog<void>(
      context: context,
      builder: (context) => _QualificationDialog(existingPlan: plan),
    );
  }

  /// 資格削除
  void _deleteQualification(QualificationPlan plan) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(UIStrings.confirmTitle),
        content: Text('${plan.name}を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(UIStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<WorkerProvider>().removeQualificationPlan(plan.id);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: WorkValueColors.error,
            ),
            child: const Text(UIStrings.delete),
          ),
        ],
      ),
    );
  }
}

/// 資格計画ダイアログ
class _QualificationDialog extends StatefulWidget {
  final QualificationPlan? existingPlan;

  const _QualificationDialog({this.existingPlan});

  @override
  State<_QualificationDialog> createState() => _QualificationDialogState();
}

class _QualificationDialogState extends State<_QualificationDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _costController;
  late TextEditingController _studyHoursController;
  late TextEditingController _companyIncreaseController;
  late TextEditingController _transferIncreaseController;
  late DateTime _targetDate;
  QualificationStatus _status = QualificationStatus.planning;

  @override
  void initState() {
    super.initState();
    
    final plan = widget.existingPlan;
    _nameController = TextEditingController(text: plan?.name ?? '');
    _costController = TextEditingController(
      text: plan?.cost.toInt().toString() ?? '',
    );
    _studyHoursController = TextEditingController(
      text: plan?.studyHours.toString() ?? '',
    );
    _companyIncreaseController = TextEditingController(
      text: plan?.companySalaryIncrease.toInt().toString() ?? '',
    );
    _transferIncreaseController = TextEditingController(
      text: plan?.transferSalaryIncrease.toInt().toString() ?? '',
    );
    _targetDate = plan?.targetDate ?? DateTime.now().add(const Duration(days: 365));
    _status = plan?.status ?? QualificationStatus.planning;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    _studyHoursController.dispose();
    _companyIncreaseController.dispose();
    _transferIncreaseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.existingPlan != null;
    
    return AlertDialog(
      title: Text(isEditing ? '資格計画の編集' : '新しい資格計画'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '資格名',
                  hintText: '例: 応用情報技術者',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '資格名を入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: WorkValueSpacing.medium),
              TextFormField(
                controller: _costController,
                decoration: const InputDecoration(
                  labelText: '取得費用（円）',
                  hintText: '例: 50000',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '費用を入力してください';
                  }
                  if (double.tryParse(value) == null) {
                    return '正しい数値を入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: WorkValueSpacing.medium),
              TextFormField(
                controller: _studyHoursController,
                decoration: const InputDecoration(
                  labelText: '学習時間（時間）',
                  hintText: '例: 200',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '学習時間を入力してください';
                  }
                  if (int.tryParse(value) == null) {
                    return '正しい数値を入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: WorkValueSpacing.medium),
              TextFormField(
                controller: _companyIncreaseController,
                decoration: const InputDecoration(
                  labelText: '会社規定昇給額（月額・円）',
                  hintText: '例: 10000',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '昇給額を入力してください';
                  }
                  if (double.tryParse(value) == null) {
                    return '正しい数値を入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: WorkValueSpacing.medium),
              TextFormField(
                controller: _transferIncreaseController,
                decoration: const InputDecoration(
                  labelText: '転職想定昇給額（月額・円）',
                  hintText: '例: 30000',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '昇給額を入力してください';
                  }
                  if (double.tryParse(value) == null) {
                    return '正しい数値を入力してください';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(UIStrings.cancel),
        ),
        ElevatedButton(
          onPressed: _savePlan,
          child: Text(isEditing ? '更新' : '追加'),
        ),
      ],
    );
  }

  void _savePlan() {
    if (!_formKey.currentState!.validate()) return;

    final plan = QualificationPlan(
      id: widget.existingPlan?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      cost: double.parse(_costController.text),
      studyHours: int.parse(_studyHoursController.text),
      companySalaryIncrease: double.parse(_companyIncreaseController.text),
      transferSalaryIncrease: double.parse(_transferIncreaseController.text),
      createdAt: widget.existingPlan?.createdAt ?? DateTime.now(),
      targetDate: _targetDate,
      acquiredDate: widget.existingPlan?.acquiredDate,
      status: _status,
    );

    final provider = context.read<WorkerProvider>();
    if (widget.existingPlan != null) {
      provider.updateQualificationPlan(plan);
    } else {
      provider.addQualificationPlan(plan);
    }

    Navigator.of(context).pop();
  }
}