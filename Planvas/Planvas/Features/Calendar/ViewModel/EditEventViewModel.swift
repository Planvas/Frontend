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
    
    // MARK: - 활동치 설정
    @Published var isActivityEnabled: Bool = false
    @Published var selectedActivityType: ActivityType = .growth
    @Published var growthValue: Int = 20
    @Published var restValue: Int = 20
    @Published var currentGrowthAchievement: Int = 0
    @Published var currentRestAchievement: Int = 0
    @Published var targetGrowthAchievement: Int = 40
    @Published var targetRestAchievement: Int = 40
    
    // MARK: - 목표 기간
    @Published var targetPeriod: String = ""
    
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
    
    // MARK: - UI Display Computed Properties
    
    /// 진행바에 표시할 퍼센트 값
    var displayProgress: Int {
        min(currentAchievement + currentActivityValue, targetAchievement)
    }
    
    /// 진행바 너비 비율 (0.0 ~ 1.0)
    var progressRatio: CGFloat {
        min(CGFloat(currentAchievement + currentActivityValue) / CGFloat(targetAchievement), 1.0)
    }
    
    /// 특정 활동 타입이 선택되었는지 확인
    func isActivityTypeSelected(_ type: ActivityType) -> Bool {
        selectedActivityType == type
    }
    
    // MARK: - Initializer
    init() {}
    
    /// 수정할 이벤트로 초기화
    func configure(with event: Event, startDate: Date, endDate: Date, targetPeriod: String?) {
        self.originalEvent = event
        self.eventName = event.title
        self.startDate = startDate
        self.endDate = endDate
        self.isAllDay = event.isAllDay
        self.selectedColor = event.color
        self.targetPeriod = targetPeriod ?? "11/15 ~ 12/3"
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
        return Event(
            id: originalEvent?.id ?? UUID(),
            title: eventName.isEmpty ? "이름 없음" : eventName,
            time: timeString,
            isFixed: originalEvent?.isFixed ?? false,
            isAllDay: isAllDay,
            color: selectedColor
        )
    }
    
    /// 수정된 이벤트 저장
    func saveEvent() {
        let updatedEvent = createUpdatedEvent()
        // TODO: Repository를 통해 이벤트 저장
        // repository.updateEvent(updatedEvent)
        print("이벤트 저장됨: \(updatedEvent.title)")
    }
}
