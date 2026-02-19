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
    var recommendedPoint: Int = 20
    var goalPercent: Int = 60
    var growthLabel: String = "성장"
    /// API 목표 연동용. 성장/휴식 각각 현재·목표 퍼센트. 값이 없는 경우 임의로 40 60으로 설정. 
    private(set) var currentGrowthPercent: Int = 0
    private(set) var currentRestPercent: Int = 0
    private(set) var goalGrowthPercent: Int = 40
    private(set) var goalRestPercent: Int = 60

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

    /// 목표 초과 제한 없이 활동치 자유롭게 조절
    func incrementActivityValue() {
        activityValue += 10
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

    /// GET /api/goals/current 응답(MyPageDTO.GoalSuccessResponse)으로 현재 달성률·목표 퍼센트 반영.
    func applyCurrentGoal(_ goal: GoalSuccessResponse) {
        currentGrowthPercent = goal.currentGrowthRatio ?? 0
        currentRestPercent = goal.currentRestRatio ?? 0
        goalGrowthPercent = goal.growthRatio ?? 40
        goalRestPercent = goal.restRatio ?? 60
        if growthLabel == "성장" {
            currentAchievementPercent = goal.currentGrowthRatio ?? 0
            goalPercent = goal.growthRatio ?? 40
        } else {
            currentAchievementPercent = goal.currentRestRatio ?? 0
            goalPercent = goal.restRatio ?? 60
        }
    }

    /// 성장/휴식 전환 시 표시 퍼센트 갱신
    func syncDisplayPercentFromCategory() {
        if growthLabel == "성장" {
            currentAchievementPercent = currentGrowthPercent
            goalPercent = goalGrowthPercent
        } else {
            currentAchievementPercent = currentRestPercent
            goalPercent = goalRestPercent
        }
    }
}
