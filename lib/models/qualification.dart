/// WorkValue - 資格データモデル
/// 資格取得計画、ROI計算、投資効率判定に関するデータ構造を定義
library;

/// 資格取得計画データモデル
/// 資格投資のROI計算と効率判定を管理
class QualificationPlan {
  /// 計画ID（ユニーク識別子）
  final String id;
  
  /// 資格名
  final String name;
  
  /// 資格取得費用（円）
  final double cost;
  
  /// 予想学習時間（時間）
  final int studyHours;
  
  /// 会社規定での昇給額（月額・円）
  final double companySalaryIncrease;
  
  /// 転職想定での昇給額（月額・円）
  final double transferSalaryIncrease;
  
  /// 計画作成日
  final DateTime createdAt;
  
  /// 取得予定日（目標）
  final DateTime targetDate;
  
  /// 実際の取得日（null = 未取得）
  final DateTime? acquiredDate;
  
  /// 計画ステータス
  final QualificationStatus status;

  const QualificationPlan({
    required this.id,
    required this.name,
    required this.cost,
    required this.studyHours,
    required this.companySalaryIncrease,
    required this.transferSalaryIncrease,
    required this.createdAt,
    required this.targetDate,
    this.acquiredDate,
    required this.status,
  });

  /// JSONからの復元
  factory QualificationPlan.fromJson(Map<String, dynamic> json) {
    return QualificationPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      cost: (json['cost'] as num).toDouble(),
      studyHours: json['studyHours'] as int,
      companySalaryIncrease: (json['companySalaryIncrease'] as num).toDouble(),
      transferSalaryIncrease: (json['transferSalaryIncrease'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      targetDate: DateTime.parse(json['targetDate'] as String),
      acquiredDate: json['acquiredDate'] != null 
          ? DateTime.parse(json['acquiredDate'] as String) 
          : null,
      status: QualificationStatus.values[json['status'] as int],
    );
  }

  /// JSONへの変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cost': cost,
      'studyHours': studyHours,
      'companySalaryIncrease': companySalaryIncrease,
      'transferSalaryIncrease': transferSalaryIncrease,
      'createdAt': createdAt.toIso8601String(),
      'targetDate': targetDate.toIso8601String(),
      'acquiredDate': acquiredDate?.toIso8601String(),
      'status': status.index,
    };
  }

  /// データコピー（変更用）
  QualificationPlan copyWith({
    String? id,
    String? name,
    double? cost,
    int? studyHours,
    double? companySalaryIncrease,
    double? transferSalaryIncrease,
    DateTime? createdAt,
    DateTime? targetDate,
    DateTime? acquiredDate,
    QualificationStatus? status,
  }) {
    return QualificationPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      cost: cost ?? this.cost,
      studyHours: studyHours ?? this.studyHours,
      companySalaryIncrease: companySalaryIncrease ?? this.companySalaryIncrease,
      transferSalaryIncrease: transferSalaryIncrease ?? this.transferSalaryIncrease,
      createdAt: createdAt ?? this.createdAt,
      targetDate: targetDate ?? this.targetDate,
      acquiredDate: acquiredDate ?? this.acquiredDate,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QualificationPlan &&
        other.id == id &&
        other.name == name &&
        other.cost == cost &&
        other.studyHours == studyHours &&
        other.companySalaryIncrease == companySalaryIncrease &&
        other.transferSalaryIncrease == transferSalaryIncrease &&
        other.createdAt == createdAt &&
        other.targetDate == targetDate &&
        other.acquiredDate == acquiredDate &&
        other.status == status;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      cost,
      studyHours,
      companySalaryIncrease,
      transferSalaryIncrease,
      createdAt,
      targetDate,
      acquiredDate,
      status,
    );
  }
}

/// 資格計画ステータス
enum QualificationStatus {
  /// 計画中
  planning,
  
  /// 学習中
  studying,
  
  /// 取得済み
  acquired,
  
  /// 中断
  paused,
  
  /// 取り止め
  cancelled,
}

/// 資格計画ステータス拡張
extension QualificationStatusExtension on QualificationStatus {
  /// 日本語名
  String get displayName {
    switch (this) {
      case QualificationStatus.planning:
        return '計画中';
      case QualificationStatus.studying:
        return '学習中';
      case QualificationStatus.acquired:
        return '取得済み';
      case QualificationStatus.paused:
        return '中断';
      case QualificationStatus.cancelled:
        return '取り止め';
    }
  }

  /// 色（UI表示用）
  int get colorValue {
    switch (this) {
      case QualificationStatus.planning:
        return 0xFF2196F3; // Blue
      case QualificationStatus.studying:
        return 0xFFFF9800; // Orange
      case QualificationStatus.acquired:
        return 0xFF4CAF50; // Green
      case QualificationStatus.paused:
        return 0xFF9E9E9E; // Grey
      case QualificationStatus.cancelled:
        return 0xFFF44336; // Red
    }
  }
}

/// ROI計算結果データモデル
/// 資格投資の効率性を評価
class QualificationROI {
  /// 対象資格計画
  final QualificationPlan plan;
  
  /// 会社規定での年間増収額
  final double companyAnnualIncrease;
  
  /// 転職想定での年間増収額
  final double transferAnnualIncrease;
  
  /// 会社規定でのROI（投資回収期間・年）
  final double companyROI;
  
  /// 転職想定でのROI（投資回収期間・年）
  final double transferROI;
  
  /// 学習時給（会社規定）
  final double companyStudyWage;
  
  /// 学習時給（転職想定）
  final double transferStudyWage;
  
  /// 会社規定での投資効率評価
  final ROIRating companyRating;
  
  /// 転職想定での投資効率評価
  final ROIRating transferRating;

  const QualificationROI({
    required this.plan,
    required this.companyAnnualIncrease,
    required this.transferAnnualIncrease,
    required this.companyROI,
    required this.transferROI,
    required this.companyStudyWage,
    required this.transferStudyWage,
    required this.companyRating,
    required this.transferRating,
  });

  /// ROI計算実行
  factory QualificationROI.calculate(QualificationPlan plan) {
    // 年間増収額計算
    final companyAnnualIncrease = plan.companySalaryIncrease * 12;
    final transferAnnualIncrease = plan.transferSalaryIncrease * 12;
    
    // ROI計算（投資回収期間）
    final companyROI = companyAnnualIncrease > 0 
        ? plan.cost / companyAnnualIncrease 
        : double.infinity;
    final transferROI = transferAnnualIncrease > 0 
        ? plan.cost / transferAnnualIncrease 
        : double.infinity;
    
    // 学習時給計算
    final companyStudyWage = plan.studyHours > 0 
        ? companyAnnualIncrease / plan.studyHours 
        : 0.0;
    final transferStudyWage = plan.studyHours > 0 
        ? transferAnnualIncrease / plan.studyHours 
        : 0.0;
    
    // 投資効率評価
    final companyRating = _calculateRating(companyROI, companyStudyWage);
    final transferRating = _calculateRating(transferROI, transferStudyWage);

    return QualificationROI(
      plan: plan,
      companyAnnualIncrease: companyAnnualIncrease,
      transferAnnualIncrease: transferAnnualIncrease,
      companyROI: companyROI,
      transferROI: transferROI,
      companyStudyWage: companyStudyWage,
      transferStudyWage: transferStudyWage,
      companyRating: companyRating,
      transferRating: transferRating,
    );
  }

  /// 投資効率評価の算出
  static ROIRating _calculateRating(double roi, double studyWage) {
    // ROI（年）と学習時給で総合評価
    if (roi <= 1.0 && studyWage >= 3000) {
      return ROIRating.excellent; // 超優秀：1年以内回収 & 高時給
    } else if (roi <= 2.0 && studyWage >= 2000) {
      return ROIRating.good; // 優秀：2年以内回収 & 中時給
    } else if (roi <= 3.0 && studyWage >= 1000) {
      return ROIRating.fair; // 良好：3年以内回収 & 基本時給
    } else {
      return ROIRating.poor; // 要検討：長期回収 or 低時給
    }
  }
}

/// ROI評価レベル
enum ROIRating {
  /// 超優秀（1年以内回収 & 高学習時給）
  excellent,
  
  /// 優秀（2年以内回収 & 中学習時給）
  good,
  
  /// 良好（3年以内回収 & 基本学習時給）
  fair,
  
  /// 要検討（長期回収 or 低学習時給）
  poor,
}

/// ROI評価レベル拡張
extension ROIRatingExtension on ROIRating {
  /// 日本語名
  String get displayName {
    switch (this) {
      case ROIRating.excellent:
        return '超優秀';
      case ROIRating.good:
        return '優秀';
      case ROIRating.fair:
        return '良好';
      case ROIRating.poor:
        return '要検討';
    }
  }

  /// 色（UI表示用）
  int get colorValue {
    switch (this) {
      case ROIRating.excellent:
        return 0xFF4CAF50; // Green
      case ROIRating.good:
        return 0xFF2196F3; // Blue
      case ROIRating.fair:
        return 0xFFFF9800; // Orange
      case ROIRating.poor:
        return 0xFFF44336; // Red
    }
  }

  /// アイコン（UI表示用）
  String get icon {
    switch (this) {
      case ROIRating.excellent:
        return '⭐️';
      case ROIRating.good:
        return '👍';
      case ROIRating.fair:
        return '👌';
      case ROIRating.poor:
        return '⚠️';
    }
  }
}