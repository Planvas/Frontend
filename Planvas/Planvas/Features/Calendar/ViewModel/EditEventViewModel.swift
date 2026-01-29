//
//  EditEventViewModel.swift
//  Planvas
//
//  Created on 1/24/26.
//

import Foundation
import Combine

@MainActor
class EditEventViewModel: ObservableObject, RepeatOptionConfigurable {
    // MARK: - 기본 이벤트 정보
    @Published var eventName: String = ""
    @Published var startDate: Date = Date()
    @Published var endDate: Date = Date()
    @Published var isAllDay: Bool = false
    @Published var selectedColor: EventColorType = .red
    
    // MARK: - 반복 설정
    @Published var repeatType: RepeatType = .weekly
    @Published var selectedYearDuration: Int = 1
    @Published var selectedWeekdays: Set<Int> = []
    @Published var isRepeating: Bool = false
    
    // MARK: - 활동치 설정
    @Published var isActivityEnabled: Bool = false
    @Published var selectedActivityType: ActivityType = .growth
    @Published var growthValue: Int = 20
    @Published var restValue: Int = 20
    @Published var currentGrowthAchievement: Int = 0
    @Published var currentRestAchievement: Int = 0
    @Published var targetGrowthAchievement: Int = 40
    @Published var targetRestAchievement: Int = 40
    
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
        if newType == .daily {
            selectedWeekdays = Set(0..<7)
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
        
        return Event(
            id: originalEvent?.id ?? UUID(),
            title: eventName.isEmpty ? "이름 없음" : eventName,
            time: timeString,
            isFixed: originalEvent?.isFixed ?? false,
            isAllDay: isAllDay,
            color: selectedColor,
            startDate: startDate,
            endDate: endDate,
            category: category,
            isCompleted: originalEvent?.isCompleted ?? false,
            isRepeating: isRepeating
        )
    }
    
    /// 수정된 이벤트 저장 (실제 반영은 onSave 콜백 → CalendarViewModel.updateEvent + Repository)
    func saveEvent() {
        // UI 저장 액션; 낙관적 업데이트는 CalendarView onUpdateEvent → viewModel.updateEvent에서 처리
    }
}
