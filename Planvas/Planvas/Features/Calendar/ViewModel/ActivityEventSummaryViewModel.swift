//
//  ActivityEventSummaryViewModel.swift
//  Planvas
//
//  Created by 백지은 on 2/12/26.
//

import Foundation

@MainActor
@Observable
final class ActivityEventSummaryViewModel {
    var title: String
    var daysUntilLabel: String?
    var startDate: Date
    var endDate: Date
    /// 활동 타입 라벨 (예: "성장", "휴식"). 포인트와 함께 표시.
    var activityPointLabel: String?
    /// 활동치 포인트 (성장 또는 휴식)
    var activityPoints: Int?
    /// 완료 알림용: 진행률 하한(%). API 연동 전 기본값
    var progressMinPercent: Int?
    /// 완료 알림용: 목표 퍼센트. API 연동 전 기본값
    var goalPercent: Int?
    /// 완료 알림용: 현재 달성 퍼센트. API 연동 전 기본값
    var currentPercent: Int?
    var completionMessage: String
    var editButtonTitle: String
    var completeButtonTitle: String
    var deleteButtonTitle: String

    init(
        title: String,
        daysUntilLabel: String? = nil,
        startDate: Date,
        endDate: Date,
        activityPointLabel: String? = nil,
        activityPoints: Int? = nil,
        progressMinPercent: Int? = nil,
        goalPercent: Int? = nil,
        currentPercent: Int? = nil,
        completionMessage: String = "완료하면 목표 균형에 반영돼요!",
        editButtonTitle: String = "수정하기",
        completeButtonTitle: String = "활동 완료",
        deleteButtonTitle: String = "활동 삭제하기"
    ) {
        self.title = title
        self.daysUntilLabel = daysUntilLabel
        self.startDate = startDate
        self.endDate = endDate
        self.activityPointLabel = activityPointLabel
        self.activityPoints = activityPoints
        self.progressMinPercent = progressMinPercent
        self.goalPercent = goalPercent
        self.currentPercent = currentPercent
        self.completionMessage = completionMessage
        self.editButtonTitle = editButtonTitle
        self.completeButtonTitle = completeButtonTitle
        self.deleteButtonTitle = deleteButtonTitle
    }

    /// GET /api/goals/current 응답(MyPageDTO.GoalSuccessResponse)으로 완료 모달용 현재/목표 퍼센트 반영.
    func applyCurrentGoal(_ goal: GoalSuccessResponse, category: EventCategory) {
        switch category {
        case .growth:
            progressMinPercent = 0
            goalPercent = goal.growthRatio ?? 40
            currentPercent = goal.currentGrowthRatio ?? 0
        case .rest:
            progressMinPercent = 0
            goalPercent = goal.restRatio ?? 60
            currentPercent = goal.currentRestRatio ?? 0
        case .none:
            goalPercent = goal.growthRatio ?? 40
            currentPercent = goal.currentGrowthRatio ?? 0
        }
    }

    /// Event(활동일정)로부터 ViewModel 생성. 화면 .task에서 applyCurrentGoal 호출로 달성률 연동.
    static func from(event: Event, daysUntil: Int?) -> ActivityEventSummaryViewModel {
        let label: String?
        if let d = daysUntil {
            label = d == 0 ? "D-day" : (d > 0 ? "D-\(d)" : "D+\(-d)")
        } else {
            label = nil
        }
        let activityLabel: String?
        switch event.category {
        case .growth: activityLabel = "성장"
        case .rest: activityLabel = "휴식"
        case .none: activityLabel = nil
        }
        return ActivityEventSummaryViewModel(
            title: event.title,
            daysUntilLabel: label,
            startDate: event.startDate,
            endDate: event.endDate,
            activityPointLabel: activityLabel,
            activityPoints: event.activityPoint,
            progressMinPercent: 10,
            goalPercent: 60,
            currentPercent: 40
        )
    }
}
