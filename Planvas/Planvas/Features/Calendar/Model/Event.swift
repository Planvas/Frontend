//
//  Event.swift
//  Planvas
//
//  Created by 백지은 on 1/17/26.
//

import Foundation

// MARK: - Event Category
enum EventCategory: String, Codable, CaseIterable {
    case growth = "GROWTH"  // 성장
    case rest = "REST"      // 휴식
    case none = "NONE"      // 미분류 (일반 일정)
}

// MARK: - Event Model
struct Event: Identifiable, Codable {
    let id: UUID
    let title: String
    let time: String
    var isFixed: Bool
    var isAllDay: Bool
    let color: EventColorType
    
    // 추가된 필드
    var startDate: Date
    var endDate: Date
    var category: EventCategory
    var isCompleted: Bool
    var isRepeating: Bool

    init(
        id: UUID = UUID(),
        title: String,
        time: String,
        isFixed: Bool = false,
        isAllDay: Bool = false,
        color: EventColorType,
        startDate: Date = Date(),
        endDate: Date = Date(),
        category: EventCategory = .none,
        isCompleted: Bool = false,
        isRepeating: Bool = false
    ) {
        self.id = id
        self.title = title
        self.time = time
        self.isFixed = isFixed
        self.isAllDay = isAllDay
        self.color = color
        self.startDate = startDate
        self.endDate = endDate
        self.category = category
        self.isCompleted = isCompleted
        self.isRepeating = isRepeating
    }
}
