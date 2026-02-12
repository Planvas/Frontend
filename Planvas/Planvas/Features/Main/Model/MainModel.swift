//
//  MainModel.swift
//  Planvas
//
//  Created by 정서영 on 1/26/26.
//

import SwiftUI

// MARK: - 목표 설정 상태
enum GoalSetting: String, Decodable {
    case ACTIVE
    case ENDED
    case NONE
}

// MARK: - 캘린더 일정
struct Schedule: Identifiable {
    let id: Int
    let title: String
    let type: ScheduleType
    var dates: [Date]
}

// 일정 색상
enum ScheduleType {
    case yellow
    case blue
    case red
    
    init(serverCategory: TodoCategory) {
        switch serverCategory {
        case .growth:
            self = .yellow
        case .rest:
            self = .blue
        case .manual:
            self = .red
        }
    }
    
    var color: Color {
        switch self {
        case .yellow: return .calYellow
        case .blue: return .calBlue1
        case .red: return .calRed
        }
    }
}

// 일정 extension
extension Schedule {
    // 백그라운드 색상 잇기 위한 일정 시작, 끝 구분
    func position(on date: Date) -> SchedulePosition {
        let calendar = Calendar.current
        
        let sortedDates = dates.sorted()
        
        guard let first = sortedDates.first,
              let last = sortedDates.last else {
            return .single
        }
        
        if sortedDates.count == 1 {
            return .single
        }
        
        if calendar.isDate(date, inSameDayAs: first) {
            return .start
        }
        
        if calendar.isDate(date, inSameDayAs: last) {
            return .end
        }
        return .middle
    }
    
    // 일정 며칠간 이어질 때 하루만 일정 제목이 보이도록 구분
    func shouldShowTitle(on date: Date) -> Bool {
        guard let first = dates.sorted().first else { return false }
        return Calendar.current.isDate(date, inSameDayAs: first)
    }
}

// 백그라운드 색상 일정 구분
enum SchedulePosition {
    case single   // 하루짜리
    case start    // 여러 날 - 시작
    case middle   // 여러 날 - 중간
    case end      // 여러 날 - 끝
}

// MARK: - 할 일
struct ToDo: Identifiable {
    let id = UUID()
    let typeColor: ToDoTypeColor
    let title: String
    let isFixed: Bool
    let todoInfo: String
    let startTime: String
    var isCompleted: Bool
}
// 할 일 타입별 색상 정리
enum ToDoTypeColor: String, Codable {
    case calRed
    case calPurple
    case calBlue
    case calGreen
    
    var color: Color {
        switch self {
        case .calRed:
            return Color("calRed")
        case .calPurple:
            return Color("calPurple")
        case .calBlue:
            return Color("calBlue")
        case .calGreen:
            return Color("calGreen")
        }
    }
}

// MARK: - 오늘의 인기 성장 활동
struct ActivityItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let imageName: String
}
