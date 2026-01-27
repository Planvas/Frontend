//
//  AddEventViewModel.swift
//  Planvas
//
//  Created on 1/21/26.
//

import Foundation
import Combine

@MainActor
class AddEventViewModel: ObservableObject, RepeatOptionConfigurable {
    @Published var eventName: String = ""
    @Published var startDate: Date = Date()
    @Published var endDate: Date = Date()
    @Published var isAllDay: Bool = false
    @Published var isRepeatEnabled: Bool = false  // 반복 설정 활성화 여부
    @Published var repeatType: RepeatType = .weekly
    @Published var selectedYearDuration: Int = 2
    @Published var selectedWeekdays: Set<Int> = []  // 기본값 빈 집합
    @Published var selectedColor: EventColorType = .red
    
    let weekdays = ["월", "화", "수", "목", "금", "토", "일"]
    let yearDurations = [1, 2, 3, 4]
    
    var repeatOptionDisplay: String {
        repeatType.rawValue
    }
    
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
    
    func createEvent() -> Event {
        let timeString = isAllDay ? "하루종일" : "\(startDate.timeString()) - \(endDate.timeString())"
        
        return Event(
            title: eventName.isEmpty ? "이름 없음" : eventName,
            time: timeString,
            isFixed: false,
            isAllDay: isAllDay,
            color: selectedColor,
            startDate: startDate,
            endDate: endDate,
            category: .none,  // 새 이벤트는 기본적으로 미분류
            isCompleted: false,
            isRepeating: isRepeatEnabled
        )
    }
    
    // MARK: - Repeat Option Picker Methods
    func handleRepeatTypeChange(to newType: RepeatType) {
        // 매일로 전환 시 모든 요일 선택
        if newType == .daily {
            selectedWeekdays = Set(0..<7)
        }
        repeatType = newType
    }
    
    func handleWeekdayToggle(index: Int, isCurrentlySelected: Bool) {
        if isCurrentlySelected {
            selectedWeekdays.remove(index)
            // 요일 선택 해제 시 매주로 전환
            if repeatType == .daily {
                repeatType = .weekly
            }
        } else {
            selectedWeekdays.insert(index)
            // 모든 요일 선택 시 매일로 전환
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
}
