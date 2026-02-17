//
//  EventDetailViewModel.swift
//  Planvas
//
//  Created by 백지은 on 1/26/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class EventDetailViewModel: ActivitySettingsBindable {
    // MARK: - Event Data
    var event: Event?
    var startDate: Date = Date()
    var endDate: Date = Date()
    var daysUntil: Int?
    var targetPeriod: String?

    // MARK: - Activity Settings State
    var showActivitySettings = false
    var selectedActivityType: ActivityType = .growth

    // 성장/휴식 각각의 활동치
    var growthValue: Int = 20
    var restValue: Int = 20

    // 성장/휴식 각각의 현재 달성률
    var currentGrowthAchievement: Int = 0
    var currentRestAchievement: Int = 0

    // 성장/휴식 각각의 목표 달성률
    var targetGrowthAchievement: Int = 60
    var targetRestAchievement: Int = 50

    // 추천 활동치 (API defaultPoint)
    var recommendedPoint: Int = 20

    enum ActivityType {
        case growth
        case rest
    }
    
    // MARK: - Computed Properties
    
    /// 현재 선택된 타입의 활동치
    var currentActivityValue: Int {
        selectedActivityType == .growth ? growthValue : restValue
    }
    
    /// 현재 선택된 타입의 현재 달성률
    var currentAchievement: Int {
        selectedActivityType == .growth ? currentGrowthAchievement : currentRestAchievement
    }
    
    /// 현재 선택된 타입의 목표 달성률
    var targetAchievement: Int {
        selectedActivityType == .growth ? targetGrowthAchievement : targetRestAchievement
    }
    
    /// 진행바에 표시할 퍼센트 값
    var displayProgress: Int {
        min(currentAchievement + currentActivityValue, targetAchievement)
    }
    
    /// 진행바 너비 비율 (0.0 ~ 1.0)
    var progressRatio: CGFloat {
        guard targetAchievement > 0 else { return 0 }
        return min(CGFloat(currentAchievement + currentActivityValue) / CGFloat(targetAchievement), 1.0)
    }

    /// AddActivityView와 동일한 구조의 활동치 UI용 (현재 달성률 라벨)
    var growthLabel: String {
        selectedActivityType == .growth ? "성장" : "휴식"
    }

    /// 추가 활동치 퍼센트 문구 (예: +20%)
    var addedPercentText: String {
        "+\(currentActivityValue)%"
    }

    /// AddActivityView와 동일 프로퍼티명 (현재 달성률)
    var currentAchievementPercent: Int {
        currentAchievement
    }

    /// AddActivityView와 동일 프로퍼티명 (목표 퍼센트)
    var goalPercent: Int {
        targetAchievement
    }

    /// AddActivityView와 동일 프로퍼티명 (활동치 값, 조회 시 currentActivityValue와 동일)
    var activityValue: Int {
        get { currentActivityValue }
        set {
            if selectedActivityType == .growth { growthValue = newValue }
            else { restValue = newValue }
        }
    }

    // MARK: - Initialization
    
    private let calendar = Calendar.current

    func configure(
        event: Event,
        startDate: Date,
        endDate: Date,
        daysUntil: Int?,
        targetPeriod: String?
    ) {
        self.event = event
        self.startDate = calendar.startOfDay(for: event.startDate)
        self.endDate = calendar.startOfDay(for: event.endDate)
        self.daysUntil = daysUntil
        self.targetPeriod = targetPeriod

        let point = event.activityPoint ?? 20
        switch event.category {
        case .growth:
            self.selectedActivityType = .growth
            self.showActivitySettings = true
            self.growthValue = point
        case .rest:
            self.selectedActivityType = .rest
            self.showActivitySettings = true
            self.restValue = point
        case .none:
            self.selectedActivityType = .growth
            self.showActivitySettings = false
        }
    }

    /// 진행기간 문자열 갱신 (startDate ~ endDate)
    func updateTargetPeriodFromDates() {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        formatter.locale = Locale(identifier: "ko_KR")
        if calendar.isDate(startDate, inSameDayAs: endDate) {
            targetPeriod = formatter.string(from: startDate)
        } else {
            targetPeriod = "\(formatter.string(from: startDate)) ~ \(formatter.string(from: endDate))"
        }
    }

    /// 현재 날짜·활동치로 수정된 Event 생성 (저장 시 사용)
    func buildUpdatedEvent() -> Event? {
        guard let event = event else { return nil }
        let point = selectedActivityType == .growth ? growthValue : restValue
        return Event(
            id: event.id,
            title: event.title,
            isFixed: event.isFixed,
            isAllDay: event.isAllDay,
            color: event.color,
            type: event.type,
            startDate: calendar.startOfDay(for: startDate),
            endDate: calendar.startOfDay(for: endDate),
            startTime: event.startTime,
            endTime: event.endTime,
            category: event.category,
            isCompleted: event.isCompleted,
            isRepeating: event.isRepeating,
            repeatOption: event.repeatOption,
            fixedScheduleId: event.fixedScheduleId,
            myActivityId: event.myActivityId,
            repeatWeekdays: event.repeatWeekdays,
            repeatEndDate: event.repeatEndDate,
            activityPoint: point
        )
    }
    
    // MARK: - Activity Value Methods
    
    func incrementActivityValue() {
        if selectedActivityType == .growth {
            // 목표 달성률을 초과하지 않도록 제한
            if currentGrowthAchievement + growthValue + 10 <= targetGrowthAchievement {
                growthValue += 10
            }
        } else {
            // 목표 달성률을 초과하지 않도록 제한
            if currentRestAchievement + restValue + 10 <= targetRestAchievement {
                restValue += 10
            }
        }
    }
    
    func decrementActivityValue() {
        if selectedActivityType == .growth {
            growthValue = max(0, growthValue - 10)
        } else {
            restValue = max(0, restValue - 10)
        }
    }
    
    /// GET /api/goals/current 응답(MyPageDTO.GoalSuccessResponse)으로 현재 달성률·목표 퍼센트 반영 (활동 수정 화면용)
    func applyCurrentGoal(_ goal: GoalSuccessResponse) {
        currentGrowthAchievement = goal.currentGrowthRatio ?? 0
        currentRestAchievement = goal.currentRestRatio ?? 0
        targetGrowthAchievement = goal.growthRatio ?? 40
        targetRestAchievement = goal.restRatio ?? 60
    }

    /// 특정 활동 타입이 선택되었는지 확인
    func isActivityTypeSelected(_ type: ActivityType) -> Bool {
        selectedActivityType == type
    }
    
    // MARK: - Actions
    
    func toggleActivitySettings() {
        showActivitySettings = true
    }
    
    func selectActivityType(_ type: ActivityType) {
        selectedActivityType = type
    }
}
