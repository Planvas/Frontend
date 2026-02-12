//
//  Event.swift
//  Planvas
//
//  Created by 백지은 on 1/17/26.
//

import Foundation

// MARK: - Time (시:분, 14:00 형식)
struct Time: Codable, Equatable {
    var hour: Int   // 0...23
    var minute: Int // 0...59

    /// "HH:mm" 또는 "H:mm" 형식 문자열
    var formatted: String {
        String(format: "%02d:%02d", hour, minute)
    }

    static let midnight = Time(hour: 0, minute: 0)
    static let endOfDay = Time(hour: 23, minute: 59)

    init(hour: Int, minute: Int) {
        self.hour = max(0, min(23, hour))
        self.minute = max(0, min(59, minute))
    }

    /// "14:00" 형태 문자열에서 생성. 실패 시 midnight 반환.
    init(from timeString: String) {
        let parts = timeString.split(separator: ":")
        let h = parts.count > 0 ? Int(parts[0].trimmingCharacters(in: .whitespaces)) ?? 0 : 0
        let m = parts.count > 1 ? Int(parts[1].trimmingCharacters(in: .whitespaces)) ?? 0 : 0
        self.hour = max(0, min(23, h))
        self.minute = max(0, min(59, m))
    }

    /// Date에서 시·분만 추출
    init(from date: Date, calendar: Calendar = .current) {
        let comps = calendar.dateComponents([.hour, .minute], from: date)
        self.hour = comps.hour ?? 0
        self.minute = comps.minute ?? 0
    }

    func apply(to date: Date, calendar: Calendar = .current) -> Date {
        calendar.date(bySettingHour: hour, minute: minute, second: 0, of: date) ?? date
    }
}

// MARK: - Event Type (fixed / activity)
enum EventType: String, Codable, CaseIterable {
    case fixed = "FIXED"
    case activity = "ACTIVITY"
}

// MARK: - Event Category
enum EventCategory: String, Codable, CaseIterable {
    case growth = "GROWTH"  // 성장
    case rest = "REST"      // 휴식
    case none = "NONE"      // 미분류 (일반 일정)
}

// MARK: - Event Model
struct Event: Identifiable, Codable {
    let id: UUID
    var title: String
    var isFixed: Bool
    var isAllDay: Bool
    let color: EventColorType
    var type: EventType

    /// 날짜만 (해당일 00:00 기준으로 다룸)
    var startDate: Date
    var endDate: Date
    /// isAllDay면 00:00
    var startTime: Time
    /// isAllDay면 23:59
    var endTime: Time

    var category: EventCategory
    var isCompleted: Bool
    var isRepeating: Bool
    /// 매일, 매주, 격주, 매달, 매년
    var repeatOption: RepeatType?

    /// 서버 고정 일정 ID
    var fixedScheduleId: Int?
    /// 서버 내 활동 ID
    var myActivityId: Int?
    var repeatWeekdays: [Int]?
    var repeatEndDate: Date?
    /// 활동 포인트 (activity 타입 시)
    var activityPoint: Int?

    /// 반복 타입 (repeatOption과 동일, 호환용)
    var repeatType: RepeatType? { get { repeatOption } set { repeatOption = newValue } }

    /// 표시용 시간 문자열 (목록 등): "14:00 - 17:00", "2/15 18:45 - 2/16 19:30", 또는 "하루종일"
    var time: String {
        if isAllDay { return "하루종일" }
        let cal = Calendar.current
        if !cal.isDate(startDate, inSameDayAs: endDate) {
            // 멀티데이: "2/15 18:45 - 2/16 19:30"
            let sm = cal.component(.month, from: startDate)
            let sd = cal.component(.day, from: startDate)
            let em = cal.component(.month, from: endDate)
            let ed = cal.component(.day, from: endDate)
            return "\(sm)/\(sd) \(startTime.formatted) - \(em)/\(ed) \(endTime.formatted)"
        }
        return "\(startTime.formatted) - \(endTime.formatted)"
    }

    /// startDate + startTime 조합 (API/비교용)
    func startDateTime(calendar: Calendar = .current) -> Date {
        let day = calendar.startOfDay(for: startDate)
        return startTime.apply(to: day, calendar: calendar)
    }

    /// endDate + endTime 조합 (API/비교용)
    func endDateTime(calendar: Calendar = .current) -> Date {
        let day = calendar.startOfDay(for: endDate)
        return endTime.apply(to: day, calendar: calendar)
    }

    init(
        id: UUID = UUID(),
        title: String,
        isFixed: Bool = false,
        isAllDay: Bool = false,
        color: EventColorType,
        type: EventType = .activity,
        startDate: Date = Date(),
        endDate: Date = Date(),
        startTime: Time = .midnight,
        endTime: Time = .endOfDay,
        category: EventCategory = .none,
        isCompleted: Bool = false,
        isRepeating: Bool = false,
        repeatOption: RepeatType? = nil,
        fixedScheduleId: Int? = nil,
        myActivityId: Int? = nil,
        repeatWeekdays: [Int]? = nil,
        repeatEndDate: Date? = nil,
        activityPoint: Int? = nil
    ) {
        self.id = id
        self.title = title
        self.isFixed = isFixed
        self.isAllDay = isAllDay
        self.color = color
        self.type = type
        self.startDate = startDate
        self.endDate = endDate
        self.startTime = isAllDay ? .midnight : startTime
        self.endTime = isAllDay ? .endOfDay : endTime
        self.category = category
        self.isCompleted = isCompleted
        self.isRepeating = isRepeating
        self.repeatOption = repeatOption
        self.fixedScheduleId = fixedScheduleId
        self.myActivityId = myActivityId
        self.repeatWeekdays = repeatWeekdays
        self.repeatEndDate = repeatEndDate
        self.activityPoint = activityPoint
    }
}
