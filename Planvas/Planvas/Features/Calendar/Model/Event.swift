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
    
    var startDate: Date
    var endDate: Date
    var category: EventCategory
    var isCompleted: Bool
    var isRepeating: Bool

    /// 서버 고정 일정 ID (반복 일정, PATCH/DELETE fixed-schedules 시 사용)
    var fixedScheduleId: Int?
    /// 서버 내 활동 ID (일시적 일정, PATCH/DELETE my-activities 시 사용)
    var myActivityId: Int?
    /// 반복 요일 (0=월…6=일). 고정 일정 생성 시 POST fixed-schedules에 사용
    var repeatWeekdays: [Int]?
    /// 반복 종료일 (이 날짜까지 매일/매주/격주/매달/매년 반복). nil이면 비반복 또는 미설정
    var repeatEndDate: Date?
    /// 반복 타입 (매일/매주/격주/매달/매년). 반복 일정 표시 확장 시 사용
    var repeatType: RepeatType?
    /// 내 활동 포인트 (my-activities 생성/수정 시 사용, 기본 10)
    var activityPoint: Int?

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
        isRepeating: Bool = false,
        fixedScheduleId: Int? = nil,
        myActivityId: Int? = nil,
        repeatWeekdays: [Int]? = nil,
        repeatEndDate: Date? = nil,
        repeatType: RepeatType? = nil,
        activityPoint: Int? = nil
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
        self.fixedScheduleId = fixedScheduleId
        self.myActivityId = myActivityId
        self.repeatWeekdays = repeatWeekdays
        self.repeatEndDate = repeatEndDate
        self.repeatType = repeatType
        self.activityPoint = activityPoint
    }
}
