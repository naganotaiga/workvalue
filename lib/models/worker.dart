/// WorkValue - 労働者データモデル
/// 労働条件、勤務状況、収入計算に関するデータ構造を定義
library;

/// 労働者基本情報データモデル
/// 給与条件、勤務時間、設定値を管理
class Worker {
  /// 月給（基本給）
  final double monthlySalary;
  
  /// 時給（時給計算用）
  final double hourlySalary;
  
  /// 残業代倍率（1.25が標準）
  final double overtimeMultiplier;
  
  /// 月間所定労働時間
  final int monthlyWorkHours;
  
  /// 一日の所定労働時間
  final int dailyWorkHours;
  
  /// 始業時刻（24時間形式、例：9なら9:00）
  final int startHour;
  
  /// 終業時刻（24時間形式、例：18なら18:00）
  final int endHour;

  const Worker({
    required this.monthlySalary,
    required this.hourlySalary,
    required this.overtimeMultiplier,
    required this.monthlyWorkHours,
    required this.dailyWorkHours,
    required this.startHour,
    required this.endHour,
  });

  /// デフォルト労働者データ（一般的な会社員設定）
  factory Worker.defaultWorker() {
    return const Worker(
      monthlySalary: 300000.0,      // 月給30万円
      hourlySalary: 1875.0,         // 時給1,875円（月給÷160時間）
      overtimeMultiplier: 1.25,     // 残業代125%
      monthlyWorkHours: 160,        // 月160時間
      dailyWorkHours: 8,            // 日8時間
      startHour: 9,                 // 9:00始業
      endHour: 18,                  // 18:00終業
    );
  }

  /// JSONからの復元
  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      monthlySalary: (json['monthlySalary'] as num).toDouble(),
      hourlySalary: (json['hourlySalary'] as num).toDouble(),
      overtimeMultiplier: (json['overtimeMultiplier'] as num).toDouble(),
      monthlyWorkHours: json['monthlyWorkHours'] as int,
      dailyWorkHours: json['dailyWorkHours'] as int,
      startHour: json['startHour'] as int,
      endHour: json['endHour'] as int,
    );
  }

  /// JSONへの変換
  Map<String, dynamic> toJson() {
    return {
      'monthlySalary': monthlySalary,
      'hourlySalary': hourlySalary,
      'overtimeMultiplier': overtimeMultiplier,
      'monthlyWorkHours': monthlyWorkHours,
      'dailyWorkHours': dailyWorkHours,
      'startHour': startHour,
      'endHour': endHour,
    };
  }

  /// データコピー（変更用）
  Worker copyWith({
    double? monthlySalary,
    double? hourlySalary,
    double? overtimeMultiplier,
    int? monthlyWorkHours,
    int? dailyWorkHours,
    int? startHour,
    int? endHour,
  }) {
    return Worker(
      monthlySalary: monthlySalary ?? this.monthlySalary,
      hourlySalary: hourlySalary ?? this.hourlySalary,
      overtimeMultiplier: overtimeMultiplier ?? this.overtimeMultiplier,
      monthlyWorkHours: monthlyWorkHours ?? this.monthlyWorkHours,
      dailyWorkHours: dailyWorkHours ?? this.dailyWorkHours,
      startHour: startHour ?? this.startHour,
      endHour: endHour ?? this.endHour,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Worker &&
        other.monthlySalary == monthlySalary &&
        other.hourlySalary == hourlySalary &&
        other.overtimeMultiplier == overtimeMultiplier &&
        other.monthlyWorkHours == monthlyWorkHours &&
        other.dailyWorkHours == dailyWorkHours &&
        other.startHour == startHour &&
        other.endHour == endHour;
  }

  @override
  int get hashCode {
    return Object.hash(
      monthlySalary,
      hourlySalary,
      overtimeMultiplier,
      monthlyWorkHours,
      dailyWorkHours,
      startHour,
      endHour,
    );
  }
}

/// 勤務セッションデータモデル
/// 実際の勤務記録を管理
class WorkSession {
  /// セッションID（ユニーク識別子）
  final String id;
  
  /// 勤務開始時刻
  final DateTime startTime;
  
  /// 勤務終了時刻（null = 勤務中）
  final DateTime? endTime;
  
  /// 通常労働時間（分）
  final int regularMinutes;
  
  /// 残業時間（分）
  final int overtimeMinutes;
  
  /// サービス残業時間（分）
  final int serviceOvertimeMinutes;
  
  /// 通常労働収入
  final double regularIncome;
  
  /// 残業代収入
  final double overtimeIncome;
  
  /// サービス残業損失額
  final double serviceOvertimeLoss;

  const WorkSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.regularMinutes,
    required this.overtimeMinutes,
    required this.serviceOvertimeMinutes,
    required this.regularIncome,
    required this.overtimeIncome,
    required this.serviceOvertimeLoss,
  });

  /// 新規セッション作成
  factory WorkSession.start(String id, DateTime startTime) {
    return WorkSession(
      id: id,
      startTime: startTime,
      endTime: null,
      regularMinutes: 0,
      overtimeMinutes: 0,
      serviceOvertimeMinutes: 0,
      regularIncome: 0.0,
      overtimeIncome: 0.0,
      serviceOvertimeLoss: 0.0,
    );
  }

  /// JSONからの復元
  factory WorkSession.fromJson(Map<String, dynamic> json) {
    return WorkSession(
      id: json['id'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null 
          ? DateTime.parse(json['endTime'] as String) 
          : null,
      regularMinutes: json['regularMinutes'] as int,
      overtimeMinutes: json['overtimeMinutes'] as int,
      serviceOvertimeMinutes: json['serviceOvertimeMinutes'] as int,
      regularIncome: (json['regularIncome'] as num).toDouble(),
      overtimeIncome: (json['overtimeIncome'] as num).toDouble(),
      serviceOvertimeLoss: (json['serviceOvertimeLoss'] as num).toDouble(),
    );
  }

  /// JSONへの変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'regularMinutes': regularMinutes,
      'overtimeMinutes': overtimeMinutes,
      'serviceOvertimeMinutes': serviceOvertimeMinutes,
      'regularIncome': regularIncome,
      'overtimeIncome': overtimeIncome,
      'serviceOvertimeLoss': serviceOvertimeLoss,
    };
  }

  /// 勤務中かどうか
  bool get isActive => endTime == null;

  /// 総勤務時間（分）
  int get totalMinutes => regularMinutes + overtimeMinutes + serviceOvertimeMinutes;

  /// 総収入
  double get totalIncome => regularIncome + overtimeIncome;

  /// 総損失
  double get totalLoss => serviceOvertimeLoss;

  /// データコピー（変更用）
  WorkSession copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    int? regularMinutes,
    int? overtimeMinutes,
    int? serviceOvertimeMinutes,
    double? regularIncome,
    double? overtimeIncome,
    double? serviceOvertimeLoss,
  }) {
    return WorkSession(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      regularMinutes: regularMinutes ?? this.regularMinutes,
      overtimeMinutes: overtimeMinutes ?? this.overtimeMinutes,
      serviceOvertimeMinutes: serviceOvertimeMinutes ?? this.serviceOvertimeMinutes,
      regularIncome: regularIncome ?? this.regularIncome,
      overtimeIncome: overtimeIncome ?? this.overtimeIncome,
      serviceOvertimeLoss: serviceOvertimeLoss ?? this.serviceOvertimeLoss,
    );
  }
}