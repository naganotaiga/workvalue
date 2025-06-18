/// WorkValue - 労働者データプロバイダー
/// 労働者情報、勤務セッション、収入計算を管理する状態管理クラス
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/worker.dart';
import '../models/qualification.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

/// 労働者データ管理プロバイダー
/// 勤務状況、収入計算、勤務履歴を管理
class WorkerProvider extends ChangeNotifier {
  Worker _worker = Worker.defaultWorker();
  WorkSession? _currentSession;
  List<WorkSession> _workHistory = [];
  List<QualificationPlan> _qualificationPlans = [];
  Timer? _workTimer;
  
  /// 現在の労働者情報
  Worker get worker => _worker;
  
  /// 現在の勤務セッション（null = 勤務外）
  WorkSession? get currentSession => _currentSession;
  
  /// 勤務中かどうか
  bool get isWorking => _currentSession != null;
  
  /// 勤務履歴
  List<WorkSession> get workHistory => List.unmodifiable(_workHistory);
  
  /// 資格計画リスト
  List<QualificationPlan> get qualificationPlans => List.unmodifiable(_qualificationPlans);
  
  /// 今日の勤務セッション
  List<WorkSession> get todaysSessions {
    final today = DateTime.now();
    return _workHistory.where((session) {
      return session.startTime.year == today.year &&
          session.startTime.month == today.month &&
          session.startTime.day == today.day;
    }).toList();
  }
  
  /// 今日の総収入
  double get todaysIncome {
    return todaysSessions.fold(0.0, (sum, session) => sum + session.totalIncome);
  }
  
  /// 今日の総勤務時間（分）
  int get todaysWorkMinutes {
    return todaysSessions.fold(0, (sum, session) => sum + session.totalMinutes);
  }
  
  /// 今日のサービス残業損失
  double get todaysServiceOvertimeLoss {
    return todaysSessions.fold(0.0, (sum, session) => sum + session.totalLoss);
  }

  /// プロバイダーの初期化
  /// ローカルストレージからデータを復元
  Future<void> initialize() async {
    try {
      // 労働者情報の復元
      final workerData = await StorageService.getMap('worker');
      if (workerData != null) {
        _worker = Worker.fromJson(workerData);
      }
      
      // 勤務履歴の復元
      final historyData = await StorageService.getList('workHistory');
      if (historyData != null) {
        _workHistory = historyData
            .map((json) => WorkSession.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      
      // 資格計画の復元
      final qualificationData = await StorageService.getList('qualificationPlans');
      if (qualificationData != null) {
        _qualificationPlans = qualificationData
            .map((json) => QualificationPlan.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      
      // 勤務中セッションの復元
      final currentSessionData = await StorageService.getMap('currentSession');
      if (currentSessionData != null) {
        _currentSession = WorkSession.fromJson(currentSessionData);
        _startWorkTimer();
      }
      
      notifyListeners();
      debugPrint('✅ WorkerProvider初期化完了');
    } catch (e) {
      debugPrint('❌ WorkerProvider初期化エラー: $e');
    }
  }

  /// 労働者情報の更新
  Future<void> updateWorker(Worker newWorker) async {
    if (_worker != newWorker) {
      _worker = newWorker;
      await StorageService.setMap('worker', _worker.toJson());
      notifyListeners();
      debugPrint('👤 労働者情報を更新しました');
    }
  }

  /// 勤務開始
  Future<void> startWork() async {
    if (_currentSession != null) {
      debugPrint('⚠️ 既に勤務中です');
      return;
    }
    
    try {
      final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
      _currentSession = WorkSession.start(sessionId, DateTime.now());
      
      // ハプティクフィードバック
      if (!kIsWeb) {
        HapticFeedback.lightImpact();
      }
      
      // 勤務開始通知
      await NotificationService.showWorkStartNotification();
      
      // 勤務タイマー開始
      _startWorkTimer();
      
      // ローカルストレージに保存
      await StorageService.setMap('currentSession', _currentSession!.toJson());
      
      notifyListeners();
      debugPrint('🚀 勤務開始: ${_currentSession!.startTime}');
    } catch (e) {
      debugPrint('❌ 勤務開始エラー: $e');
    }
  }

  /// 勤務終了
  Future<void> endWork({bool isServiceOvertime = false}) async {
    if (_currentSession == null) {
      debugPrint('⚠️ 勤務セッションがありません');
      return;
    }
    
    try {
      final endTime = DateTime.now();
      final workMinutes = endTime.difference(_currentSession!.startTime).inMinutes;
      
      // 勤務時間の分類と収入計算
      final workCalculation = _calculateWorkIncome(workMinutes, isServiceOvertime);
      
      // セッションの完了
      final completedSession = _currentSession!.copyWith(
        endTime: endTime,
        regularMinutes: workCalculation.regularMinutes,
        overtimeMinutes: workCalculation.overtimeMinutes,
        serviceOvertimeMinutes: workCalculation.serviceOvertimeMinutes,
        regularIncome: workCalculation.regularIncome,
        overtimeIncome: workCalculation.overtimeIncome,
        serviceOvertimeLoss: workCalculation.serviceOvertimeLoss,
      );
      
      // 履歴に追加
      _workHistory.add(completedSession);
      _currentSession = null;
      
      // タイマー停止
      _workTimer?.cancel();
      _workTimer = null;
      
      // ハプティクフィードバック
      if (!kIsWeb) {
        HapticFeedback.mediumImpact();
      }
      
      // 勤務終了通知
      await NotificationService.showWorkEndNotification(
        completedSession.totalIncome,
        completedSession.totalLoss,
      );
      
      // ローカルストレージに保存
      await Future.wait([
        StorageService.setList('workHistory', _workHistory.map((s) => s.toJson()).toList()),
        StorageService.remove('currentSession'),
      ]);
      
      notifyListeners();
      debugPrint('🏁 勤務終了: 収入 ${completedSession.totalIncome}円, 損失 ${completedSession.totalLoss}円');
    } catch (e) {
      debugPrint('❌ 勤務終了エラー: $e');
    }
  }

  /// 勤務時間の計算
  WorkCalculation _calculateWorkIncome(int totalMinutes, bool isServiceOvertime) {
    final regularWorkMinutes = _worker.dailyWorkHours * 60;
    final minuteWage = _worker.hourlySalary / 60;
    
    int regularMinutes = 0;
    int overtimeMinutes = 0;
    int serviceOvertimeMinutes = 0;
    double regularIncome = 0.0;
    double overtimeIncome = 0.0;
    double serviceOvertimeLoss = 0.0;
    
    if (totalMinutes <= regularWorkMinutes) {
      // 定時内勤務
      regularMinutes = totalMinutes;
      regularIncome = regularMinutes * minuteWage;
    } else {
      // 残業あり
      regularMinutes = regularWorkMinutes;
      regularIncome = regularMinutes * minuteWage;
      
      final extraMinutes = totalMinutes - regularWorkMinutes;
      
      if (isServiceOvertime) {
        // サービス残業
        serviceOvertimeMinutes = extraMinutes;
        serviceOvertimeLoss = extraMinutes * minuteWage * _worker.overtimeMultiplier;
      } else {
        // 正規残業
        overtimeMinutes = extraMinutes;
        overtimeIncome = extraMinutes * minuteWage * _worker.overtimeMultiplier;
      }
    }
    
    return WorkCalculation(
      regularMinutes: regularMinutes,
      overtimeMinutes: overtimeMinutes,
      serviceOvertimeMinutes: serviceOvertimeMinutes,
      regularIncome: regularIncome,
      overtimeIncome: overtimeIncome,
      serviceOvertimeLoss: serviceOvertimeLoss,
    );
  }

  /// 勤務タイマーの開始
  void _startWorkTimer() {
    _workTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      notifyListeners(); // UIを更新してリアルタイム表示
    });
  }

  /// 現在の勤務時間（分）
  int get currentWorkMinutes {
    if (_currentSession == null) return 0;
    return DateTime.now().difference(_currentSession!.startTime).inMinutes;
  }

  /// 現在の収入（リアルタイム）
  double get currentIncome {
    if (_currentSession == null) return 0.0;
    final calculation = _calculateWorkIncome(currentWorkMinutes, false);
    return calculation.regularIncome + calculation.overtimeIncome;
  }

  /// 資格計画の追加
  Future<void> addQualificationPlan(QualificationPlan plan) async {
    _qualificationPlans.add(plan);
    await StorageService.setList('qualificationPlans', 
        _qualificationPlans.map((p) => p.toJson()).toList());
    notifyListeners();
    debugPrint('📚 資格計画を追加: ${plan.name}');
  }

  /// 資格計画の更新
  Future<void> updateQualificationPlan(QualificationPlan updatedPlan) async {
    final index = _qualificationPlans.indexWhere((p) => p.id == updatedPlan.id);
    if (index != -1) {
      _qualificationPlans[index] = updatedPlan;
      await StorageService.setList('qualificationPlans', 
          _qualificationPlans.map((p) => p.toJson()).toList());
      notifyListeners();
      debugPrint('📝 資格計画を更新: ${updatedPlan.name}');
    }
  }

  /// 資格計画の削除
  Future<void> removeQualificationPlan(String planId) async {
    _qualificationPlans.removeWhere((p) => p.id == planId);
    await StorageService.setList('qualificationPlans', 
        _qualificationPlans.map((p) => p.toJson()).toList());
    notifyListeners();
    debugPrint('🗑️ 資格計画を削除: $planId');
  }

  /// 全データのリセット
  Future<void> resetAllData() async {
    try {
      // 勤務中の場合は強制終了
      if (_currentSession != null) {
        await endWork();
      }
      
      // データのクリア
      _worker = Worker.defaultWorker();
      _workHistory.clear();
      _qualificationPlans.clear();
      _currentSession = null;
      
      // ストレージのクリア
      await Future.wait([
        StorageService.remove('worker'),
        StorageService.remove('workHistory'),
        StorageService.remove('qualificationPlans'),
        StorageService.remove('currentSession'),
      ]);
      
      notifyListeners();
      debugPrint('🔄 全データをリセットしました');
    } catch (e) {
      debugPrint('❌ データリセットエラー: $e');
    }
  }

  @override
  void dispose() {
    _workTimer?.cancel();
    super.dispose();
  }
}

/// 勤務時間計算結果
class WorkCalculation {
  final int regularMinutes;
  final int overtimeMinutes;
  final int serviceOvertimeMinutes;
  final double regularIncome;
  final double overtimeIncome;
  final double serviceOvertimeLoss;

  const WorkCalculation({
    required this.regularMinutes,
    required this.overtimeMinutes,
    required this.serviceOvertimeMinutes,
    required this.regularIncome,
    required this.overtimeIncome,
    required this.serviceOvertimeLoss,
  });
}