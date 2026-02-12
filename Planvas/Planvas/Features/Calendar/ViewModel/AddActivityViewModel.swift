//
//  AddActivityViewModel.swift
//  Planvas
//
//  활동 일정 추가(AddActivityView) 전용 ViewModel.
//

import Foundation

@MainActor
@Observable
final class AddActivityViewModel: ActivitySettingsBindable {
    var title: String = ""
    var subtitle: String?
    var targetPeriod: String = ""
    var startDate: Date = Date()
    var endDate: Date = Date()
    var currentAchievementPercent: Int = 10
    var activityValue: Int = 20
    var recommendationPoint: Int = 30
    var goalPercent: Int = 60
    var growthLabel: String = "성장"

    private let calendar = Calendar.current

    /// 진행률 바: 현재 달성 + 이번 활동치 반영 시 퍼센트
    var displayProgress: Int {
        min(currentAchievementPercent + activityValue, goalPercent)
    }

    /// 진행률 바 채움 비율 (0~1)
    var progressRatio: CGFloat {
        guard goalPercent > 0 else { return 0 }
        return min(CGFloat(displayProgress) / CGFloat(goalPercent), 1)
    }

    /// 추가할 활동치로 인한 퍼센트 표시 (예: +20)
    var addedPercentText: String {
        "+\(activityValue)%"
    }

    func incrementActivityValue() {
        // 목표치(currentAchievementPercent + activityValue)를 초과하지 않도록 제한
        let maxAllowed = max(0, goalPercent - currentAchievementPercent)
        activityValue = min(activityValue + 10, maxAllowed)
    }

    func decrementActivityValue() {
        activityValue = max(0, activityValue - 10)
    }

    /// targetPeriod를 startDate, endDate 기준으로 갱신 (M/d ~ M/d)
    func updateTargetPeriodFromDates() {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        formatter.locale = Locale(identifier: "ko_KR")
        targetPeriod = "\(formatter.string(from: startDate)) ~ \(formatter.string(from: endDate))"
    }
}
