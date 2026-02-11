//
//  EditEventViewModel.swift
//  Planvas
//
//  Created by 백지은 on 1/24/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class EditEventViewModel: RepeatOptionConfigurable {
    // MARK: - 기본 이벤트 정보
    var eventName: String = ""
    var startDate: Date = Date()
    var endDate: Date = Date()
    var isAllDay: Bool = false
    var selectedColor: EventColorType = .red

    // MARK: - 반복 설정
    var repeatType: RepeatType = .weekly
    /// 반복 종료일 (날짜만)
    var repeatEndDate: Date = Date()
    var selectedYearDuration: Int = 1
    var selectedWeekdays: Set<Int> = []
    var isRepeating: Bool = false

    // MARK: - 활동치 설정
    var isActivityEnabled: Bool = false
    var selectedActivityType: ActivityType = .growth
    var growthValue: Int = 20
    var restValue: Int = 20
    var currentGrowthAchievement: Int = 0
    var currentRestAchievement: Int = 0
    var targetGrowthAchievement: Int = 40
    var targetRestAchievement: Int = 40

    // MARK: - 원본 이벤트 (수정 대상)
    private var originalEvent: Event?
    
    enum ActivityType {
        case growth
        case rest
    }
    
    let weekdays = ["월", "화", "수", "목", "금", "토", "일"]
    let yearDurations = [1, 2, 3, 4]
    
    let availableColors: [EventColorType] = [
        .purple2,
        .blue1,
        .red,
        .yellow,
        .blue2,
        .pink,
        .green,
        .blue3,
        .ccc,
        .purple1
    ]
    
    var firstRowColorIndices: [Int] {
        Array(0..<7)
    }
    
    var secondRowColorIndices: [Int] {
        Array(7..<availableColors.count)
    }
    
    // MARK: - 현재 선택된 활동치 관련 computed properties
    var currentActivityValue: Int {
        selectedActivityType == .growth ? growthValue : restValue
    }
    
    var currentAchievement: Int {
        selectedActivityType == .growth ? currentGrowthAchievement : currentRestAchievement
    }
    
    var targetAchievement: Int {
        selectedActivityType == .growth ? targetGrowthAchievement : targetRestAchievement
    }
    
    var repeatOptionDisplay: String {
        repeatType.rawValue
    }

    private let calendar = Calendar.current

    /// 반복 일정일 때 종료일 선택 가능 범위(시작일 당일 23:59:59)
    var endOfStartDate: Date {
        calendar.date(bySettingHour: 23, minute: 59, second: 59, of: startDate) ?? startDate
    }

    /// 반복 일정일 때 종료일을 시작일과 같은 날로 맞춤(종료 시간 유지)
    func syncEndDateToStartDay() {
        guard isRepeating else { return }
        let startDay = calendar.startOfDay(for: startDate)
        let endTime = calendar.dateComponents([.hour, .minute], from: endDate)
        let newEnd = calendar.date(bySettingHour: endTime.hour ?? 0, minute: endTime.minute ?? 0, second: 0, of: startDay) ?? startDay
        endDate = newEnd
        if endDate < startDate {
            endDate = calendar.date(byAdding: .hour, value: 1, to: startDate) ?? startDate
        }
    }
    
    /// 목표 기간: 진행기간(시작일~종료일)에 따라 항상 동기화
    var targetPeriod: String {
        calculateTargetPeriod(from: startDate, to: endDate)
    }
    
    // MARK: - UI Display Computed Properties
    
    /// 진행바에 표시할 퍼센트 값
    var displayProgress: Int {
        min(currentAchievement + currentActivityValue, targetAchievement)
    }
    
    /// 진행바 너비 비율 (0.0 ~ 1.0)
    var progressRatio: CGFloat {
        guard targetAchievement > 0 else { return 0 }
        return min(CGFloat(currentAchievement + currentActivityValue) / CGFloat(targetAchievement), 1.0)
    }
    
    /// 특정 활동 타입이 선택되었는지 확인
    func isActivityTypeSelected(_ type: ActivityType) -> Bool {
        selectedActivityType == type
    }
    
    // MARK: - Initializer
    init() {}
    
    /// 수정할 이벤트로 초기화
    func configure(with event: Event, startDate: Date, endDate: Date) {
        self.originalEvent = event
        self.eventName = event.title
        self.startDate = startDate
        self.endDate = endDate
        self.isAllDay = event.isAllDay
        self.selectedColor = event.color
        self.isRepeating = event.isRepeating
        self.repeatType = event.repeatType ?? .weekly
        self.selectedWeekdays = Set(event.repeatWeekdays ?? [])
        self.repeatEndDate = event.repeatEndDate ?? Calendar.current.date(byAdding: .month, value: 1, to: startDate) ?? startDate
        if let end = event.repeatEndDate {
            let years = Calendar.current.dateComponents([.year], from: event.startDate, to: end).year ?? 1
            self.selectedYearDuration = min(max(years, 1), 4)
        }
        
        // 이벤트 카테고리에 따라 활동치 설정 초기화
        switch event.category {
        case .growth:
            self.selectedActivityType = .growth
            self.isActivityEnabled = true
        case .rest:
            self.selectedActivityType = .rest
            self.isActivityEnabled = true
        case .none:
            self.selectedActivityType = .growth
            self.isActivityEnabled = false
        }
    }
    
    /// 시작일과 종료일로 목표 기간 문자열 생성 (시작일~종료일)
    private func calculateTargetPeriod(from startDate: Date, to endDate: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        let calendar = Calendar.current
        if calendar.isDate(startDate, inSameDayAs: endDate) {
            return formatter.string(from: startDate)
        }
        return "\(formatter.string(from: startDate)) ~ \(formatter.string(from: endDate))"
    }
    
    // MARK: - Activity Value Methods
    func incrementActivityValue() {
        if selectedActivityType == .growth {
            if currentGrowthAchievement + growthValue + 10 <= targetGrowthAchievement {
                growthValue += 10
            }
        } else {
            if currentRestAchievement + restValue + 10 <= targetRestAchievement {
                restValue += 10
            }
        }
    }
    
    func decrementActivityValue() {
        if selectedActivityType == .growth {
            if growthValue > 0 { growthValue -= 10 }
        } else {
            if restValue > 0 { restValue -= 10 }
        }
    }
    
    // MARK: - Repeat Option Methods
    func handleRepeatTypeChange(to newType: RepeatType) {
        switch newType {
        case .daily:
            selectedWeekdays = Set(0..<7)
        case .weekly, .biweekly:
            let weekdayIndex = (Calendar.current.component(.weekday, from: startDate) - 2 + 7) % 7
            selectedWeekdays = [weekdayIndex]
        case .monthly, .yearly:
            break
        }
        repeatType = newType
    }
    
    func handleWeekdayToggle(index: Int, isCurrentlySelected: Bool) {
        if isCurrentlySelected {
            selectedWeekdays.remove(index)
            if repeatType == .daily {
                repeatType = .weekly
            }
        } else {
            selectedWeekdays.insert(index)
            if selectedWeekdays.count == 7 {
                repeatType = .daily
            }
        }
    }
    
    func indicatorOffset(width: CGFloat) -> CGFloat {
        let index = RepeatType.allCases.firstIndex(of: repeatType) ?? 0
        let segmentWidth = width / CGFloat(RepeatType.allCases.count)
        return segmentWidth * CGFloat(index)
    }
    
    // MARK: - Save Event
    func createUpdatedEvent() -> Event {
        let timeString = isAllDay ? "하루종일" : "\(startDate.timeString()) - \(endDate.timeString())"
        
        // 활동치 설정에 따른 카테고리 결정
        let category: EventCategory
        if isActivityEnabled {
            category = selectedActivityType == .growth ? .growth : .rest
        } else {
            category = .none
        }
        
        // 반복 일정은 시작일 == 종료일만 허용
        let effectiveEndDate: Date = isRepeating && !calendar.isDate(startDate, inSameDayAs: endDate)
            ? calendar.date(bySettingHour: calendar.component(.hour, from: endDate), minute: calendar.component(.minute, from: endDate), second: 0, of: startDate) ?? startDate
            : endDate
        // 반복 종료일 = 반복 종료일 선택값 (날짜만)
        let repeatEnd: Date? = isRepeating ? calendar.startOfDay(for: repeatEndDate) : (originalEvent?.repeatEndDate)
        return Event(
            id: originalEvent?.id ?? UUID(),
            title: eventName.isEmpty ? "이름 없음" : eventName,
            time: timeString,
            isFixed: originalEvent?.isFixed ?? false,
            isAllDay: isAllDay,
            color: selectedColor,
            startDate: startDate,
            endDate: effectiveEndDate,
            category: category,
            isCompleted: originalEvent?.isCompleted ?? false,
            isRepeating: isRepeating,
            fixedScheduleId: originalEvent?.fixedScheduleId,
            myActivityId: originalEvent?.myActivityId,
            repeatWeekdays: isRepeating ? Array(selectedWeekdays).sorted() : nil,
            repeatEndDate: repeatEnd,
            repeatType: isRepeating ? repeatType : nil,
            activityPoint: isActivityEnabled ? currentActivityValue : (originalEvent?.activityPoint ?? 10)
        )
    }
    
    /// 수정된 이벤트 저장 (실제 반영은 onSave 콜백 → CalendarViewModel.updateEvent + Repository)
    func saveEvent() {
        // UI 저장 액션; 낙관적 업데이트는 CalendarView onUpdateEvent → viewModel.updateEvent에서 처리
    }
}
