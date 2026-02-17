//
//  AddTodoViewModel.swift
//  Planvas
//
//  Created by 정서영 on 2/18/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class AddTodoViewModel {
    
    // MARK: - 기본 이벤트 정보
    var eventName: String = ""
    var startDate: Date = Date()
    var endDate: Date = Date()
    var isAllDay: Bool = false
    var selectedColor: EventColorType = .red
    
    // MARK: - 활동치 설정
    var isActivityEnabled: Bool = false
    var selectedActivityType: ActivityType = .growth
    var growthValue: Int = 20
    var restValue: Int = 20
    var currentGrowthAchievement: Int = 0
    var currentRestAchievement: Int = 0
    var targetGrowthAchievement: Int = 40
    var targetRestAchievement: Int = 40
    
    enum ActivityType {
        case growth
        case rest
    }
    
    // MARK: - Color Picker
    let availableColors: [EventColorType] = [
        .purple2, .blue1, .red, .yellow,
        .blue2, .pink, .green, .blue3,
        .ccc, .purple1
    ]
    
    // MARK: - Activity Computed Properties
    
    var currentActivityValue: Int {
        selectedActivityType == .growth ? growthValue : restValue
    }
    
    var currentAchievement: Int {
        selectedActivityType == .growth ? currentGrowthAchievement : currentRestAchievement
    }
    
    var targetAchievement: Int {
        selectedActivityType == .growth ? targetGrowthAchievement : targetRestAchievement
    }
    
    var displayProgress: Int {
        min(currentAchievement + currentActivityValue, targetAchievement)
    }
    
    var progressRatio: CGFloat {
        guard targetAchievement > 0 else { return 0 }
        return min(
            CGFloat(currentAchievement + currentActivityValue) /
            CGFloat(targetAchievement),
            1.0
        )
    }
    
    func isActivityTypeSelected(_ type: ActivityType) -> Bool {
        selectedActivityType == type
    }
    
    // MARK: - 목표 기간 (View에서 사용)
    var targetPeriod: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        
        let calendar = Calendar.current
        if calendar.isDate(startDate, inSameDayAs: endDate) {
            return formatter.string(from: startDate)
        }
        
        return "\(formatter.string(from: startDate)) ~ \(formatter.string(from: endDate))"
    }
    
    // MARK: - Activity Value Control
    
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
            growthValue = max(0, growthValue - 10)
        } else {
            restValue = max(0, restValue - 10)
        }
    }
    
    // MARK: - Event 생성 (추가용)
    
    func createUpdatedEvent() -> Event {
        
        let category: EventCategory
        if isActivityEnabled {
            category = selectedActivityType == .growth ? .growth : .rest
        } else {
            category = .none
        }
        
        let calendar = Calendar.current
        
        let startDay = calendar.startOfDay(for: startDate)
        let endDay = calendar.startOfDay(for: endDate)
        
        let startTime: Time = isAllDay ? .midnight : Time(from: startDate, calendar: calendar)
        let endTime: Time = isAllDay ? .endOfDay : Time(from: endDate, calendar: calendar)
        
        return Event(
            id: UUID(),
            title: eventName.isEmpty ? "이름 없음" : eventName,
            isFixed: false,
            isAllDay: isAllDay,
            color: selectedColor,
            type: isActivityEnabled ? .activity : .fixed,
            startDate: startDay,
            endDate: endDay,
            startTime: startTime,
            endTime: endTime,
            category: category,
            isCompleted: false,
            isRepeating: false,
            repeatOption: nil,
            fixedScheduleId: nil,
            myActivityId: nil,
            repeatWeekdays: nil,
            repeatEndDate: nil,
            activityPoint: isActivityEnabled ? currentActivityValue : 0
        )
    }
    
    func saveEvent() {
        // 실제 저장은 외부에서 처리
    }
}
