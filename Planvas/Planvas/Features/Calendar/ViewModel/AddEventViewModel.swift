//
//  AddEventViewModel.swift
//  Planvas
//
//  Created on 1/21/26.
//

import SwiftUI
import Combine

@MainActor
class AddEventViewModel: ObservableObject {
    @Published var eventName: String = ""
    @Published var startDate: Date = Date()
    @Published var endDate: Date = Date()
    @Published var isAllDay: Bool = false
    @Published var repeatOption: String = "반복하지 않음"
    @Published var repeatType: RepeatType = .weekly
    @Published var selectedYearDuration: Int = 2
    @Published var selectedWeekdays: Set<Int> = [1] // 월요일 기본 선택
    @Published var selectedColor: EventColorType = .red
    
    enum RepeatType: String, CaseIterable {
        case daily = "매일"
        case weekly = "매주"
        case monthly = "매달"
        case yearly = "매년"
    }
    
    let weekdays = ["월", "화", "수", "목", "금", "토", "일"]
    let yearDurations = [1, 2, 3, 4]
    
    var repeatOptionDisplay: String {
        switch repeatType {
        case .daily:
            return "매일"
        case .weekly:
            if selectedWeekdays.isEmpty {
                return "반복하지 않음"
            }
            let weekdayNames = selectedWeekdays.sorted().map { weekdays[$0] }.joined(separator: ", ")
            return "매주 \(weekdayNames)"
        case .monthly:
            return "매달"
        case .yearly:
            return "\(selectedYearDuration)년"
        }
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
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M/d, EEEE"
        return formatter.string(from: date)
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_EN")
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    func eventColor(for colorType: EventColorType) -> Color {
        switch colorType {
        case .red:
            return .calRed
        case .yellow:
            return .calYellow
        case .pink:
            return .calPink
        case .purple1:
            return .calPurple1
        case .purple2:
            return .calPurple2
        case .blue1:
            return .calBlue1
        case .blue2:
            return .calBlue2
        case .blue3:
            return .calBlue3
        case .green:
            return .calGreen
        case .ccc:
            return .ccc
        }
    }
    
    func createEvent() -> Event {
        let timeString = isAllDay ? "하루종일" : "\(formatTime(startDate)) - \(formatTime(endDate))"
        return Event(
            title: eventName.isEmpty ? "이름 없음" : eventName,
            time: timeString,
            isFixed: false,
            isAllDay: isAllDay,
            color: selectedColor
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
