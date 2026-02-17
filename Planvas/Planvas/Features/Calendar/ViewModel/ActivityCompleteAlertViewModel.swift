//
//  ActivityCompleteAlertViewModel.swift
//  Planvas
//
//  Created by 백지은 on 2/12/26.
//

import Foundation

@MainActor
@Observable
final class ActivityCompleteAlertViewModel {
    var title: String
    var subtitle: String
    var category: String
    var growthValue: Int
    var progressMinPercent: Int
    var goalPercent: Int
    var currentPercent: Int
    var confirmButtonTitle: String
    /// PATCH /api/my-activities/{id}/complete 호출 시 사용
    var myActivityId: Int?
    /// 목표 API 적용 여부 (모달에서 getCurrentGoal 호출 후 true)
    private(set) var isGoalLoaded: Bool = false

    init(
        title: String = "활동 완주, 정말 고생 많았어요!",
        subtitle: String = "목표 달성에 한 걸음 더 가까워졌네요",
        category: String = "성장",
        growthValue: Int = 30,
        progressMinPercent: Int = 10,
        goalPercent: Int = 70,
        currentPercent: Int = 40,
        confirmButtonTitle: String = "확인",
        myActivityId: Int? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.category = category
        self.growthValue = growthValue
        self.progressMinPercent = progressMinPercent
        self.goalPercent = goalPercent
        self.currentPercent = currentPercent
        self.confirmButtonTitle = confirmButtonTitle
        self.myActivityId = myActivityId
    }

    /// 그리기/표시용: 목표를 넘어도 최대 목표치로만 표시
    var displayCurrentPercent: Int {
        min(currentPercent, goalPercent)
    }

    var progressRatio: CGFloat {
        guard goalPercent > progressMinPercent else { return 0 }
        return CGFloat(displayCurrentPercent) / CGFloat(goalPercent)
    }

    /// GET /api/goals/current 응답으로 목표·현재 달성률 반영 (모달 표시 시 API 호출 후 호출)
    func applyGoal(_ goal: GoalSuccessResponse) {
        progressMinPercent = 0
        if category == "휴식" {
            goalPercent = goal.restRatio ?? 60
            currentPercent = goal.currentRestRatio ?? 0
        } else {
            goalPercent = goal.growthRatio ?? 40
            currentPercent = goal.currentGrowthRatio ?? 0
        }
        isGoalLoaded = true
    }
}
