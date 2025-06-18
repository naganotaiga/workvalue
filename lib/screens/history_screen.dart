/// WorkValue - 履歴画面
/// 過去の勤務記録、統計表示、期間フィルタリングを提供
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/worker_provider.dart';
import '../models/worker.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';

/// 履歴画面（勤務記録表示）
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedPeriod = UIStrings.filterAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(UIStrings.historyTitle),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
      ),
      body: Consumer<WorkerProvider>(
        builder: (context, provider, child) {
          final sessions = _getFilteredSessions(provider.workHistory);
          
          return Column(
            children: [
              // 期間フィルター
              _buildPeriodFilter(theme),
              
              // 統計サマリー
              _buildSummary(theme, sessions),
              
              // 履歴リスト
              Expanded(
                child: _buildHistoryList(theme, sessions),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 期間フィルター
  Widget _buildPeriodFilter(ThemeData theme) {
    const periods = [
      UIStrings.filterToday,
      UIStrings.filterThisWeek,
      UIStrings.filterThisMonth,
      UIStrings.filterAll,
    ];
    
    return Container(
      padding: const EdgeInsets.all(WorkValueSpacing.medium),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: periods.map((period) {
            final isSelected = _selectedPeriod == period;
            return Padding(
              padding: const EdgeInsets.only(right: WorkValueSpacing.small),
              child: FilterChip(
                label: Text(period),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedPeriod = period;
                  });
                },
                backgroundColor: theme.colorScheme.surface,
                selectedColor: theme.colorScheme.primaryContainer,
                labelStyle: TextStyle(
                  color: isSelected 
                      ? theme.colorScheme.primary 
                      : theme.colorScheme.onSurface,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 統計サマリー
  Widget _buildSummary(ThemeData theme, List<WorkSession> sessions) {
    final totalIncome = sessions.fold<double>(
      0.0, (sum, session) => sum + session.totalIncome
    );
    final totalLoss = sessions.fold<double>(
      0.0, (sum, session) => sum + session.totalLoss
    );
    final totalMinutes = sessions.fold<int>(
      0, (sum, session) => sum + session.totalMinutes
    );
    
    return Card(
      margin: const EdgeInsets.all(WorkValueSpacing.medium),
      child: Padding(
        padding: const EdgeInsets.all(WorkValueSpacing.medium),
        child: Row(
          children: [
            Expanded(
              child: _buildSummaryItem(
                theme,
                '総収入',
                FormatSettings.formatCurrency(totalIncome),
                WorkValueColors.success,
              ),
            ),
            if (totalLoss > 0) ...[
              Expanded(
                child: _buildSummaryItem(
                  theme,
                  '損失',
                  FormatSettings.formatCurrency(totalLoss),
                  WorkValueColors.error,
                ),
              ),
            ],
            Expanded(
              child: _buildSummaryItem(
                theme,
                '労働時間',
                FormatSettings.formatDuration(totalMinutes),
                WorkValueColors.info,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// サマリーアイテム
  Widget _buildSummaryItem(
    ThemeData theme,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// 履歴リスト
  Widget _buildHistoryList(ThemeData theme, List<WorkSession> sessions) {
    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: WorkValueSpacing.medium),
            Text(
              'まだ勤務記録がありません',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(WorkValueSpacing.medium),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[sessions.length - 1 - index]; // 新しい順
        return _buildSessionCard(theme, session);
      },
    );
  }

  /// セッションカード
  Widget _buildSessionCard(ThemeData theme, WorkSession session) {
    return Card(
      margin: const EdgeInsets.only(bottom: WorkValueSpacing.small),
      child: Padding(
        padding: const EdgeInsets.all(WorkValueSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  FormatSettings.formatDate(session.startTime),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  FormatSettings.formatCurrency(session.totalIncome),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: WorkValueColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: WorkValueSpacing.small),
            Row(
              children: [
                Text(
                  '${FormatSettings.formatTime(session.startTime)} - ',
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  session.endTime != null 
                      ? FormatSettings.formatTime(session.endTime!) 
                      : '勤務中',
                  style: theme.textTheme.bodyMedium,
                ),
                const Spacer(),
                Text(
                  FormatSettings.formatDuration(session.totalMinutes),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: WorkValueColors.info,
                  ),
                ),
              ],
            ),
            if (session.totalLoss > 0) ...[
              const SizedBox(height: WorkValueSpacing.small),
              Row(
                children: [
                  Icon(
                    Icons.warning,
                    size: 16,
                    color: WorkValueColors.error,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'サービス残業損失: ${FormatSettings.formatCurrency(session.totalLoss)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: WorkValueColors.error,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// フィルタリングされたセッション取得
  List<WorkSession> _getFilteredSessions(List<WorkSession> allSessions) {
    final now = DateTime.now();
    
    switch (_selectedPeriod) {
      case UIStrings.filterToday:
        return allSessions.where((session) {
          return session.startTime.year == now.year &&
              session.startTime.month == now.month &&
              session.startTime.day == now.day;
        }).toList();
        
      case UIStrings.filterThisWeek:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return allSessions.where((session) {
          return session.startTime.isAfter(weekStart);
        }).toList();
        
      case UIStrings.filterThisMonth:
        return allSessions.where((session) {
          return session.startTime.year == now.year &&
              session.startTime.month == now.month;
        }).toList();
        
      default:
        return allSessions;
    }
  }
}