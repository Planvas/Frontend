//
//  CalendarDTO.swift
//  Planvas
//
//  Created by 정서영 on 2/2/26.
//

import Foundation

// MARK: - 구글 캘린더 연동
struct GoogleCalendarRequestDTO: Encodable {
    let code: String
}

struct GoogleCalendarResponse: Decodable {
    let resultType: String
    let error: ErrorDTO?
    let success: GoogleCalendarSuccess?
}

struct GoogleCalendarSuccess: Decodable {
    let message: String?
}

// MARK: - 구글 캘린더 연동 상태 조회
struct GoogleCalendarStateResponse: Decodable {
    let resultType: String
    let error: ErrorDTO?
    let success: GoogleCalendarStateSuccess?
}

struct GoogleCalendarStateSuccess: Decodable {
    let connected: Bool
    let connectedAt: String?
    let lastSyncedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case connected = "isConnected"
        case connectedAt
        case lastSyncedAt
    }
}

// MARK: - 구글 캘린더 일정 동기화 (POST /api/integrations/google-calendar/sync, Swagger: success.savedCount)
struct GoogleScheduleSyncResponse: Decodable {
    let resultType: String
    let error: ErrorDTO?
    let success: GoogleScheduleSyncSuccess?
}

struct GoogleScheduleSyncSuccess: Decodable {
    let savedCount: Int
}

// MARK: - 구글 캘린더 가져올 일정 목록 조회 (GET /api/integrations/google-calendar/events, Swagger: success.events[] id/summary/start/end)
struct GoogleScheduleListResponse: Decodable {
    let resultType: String
    let error: ErrorDTO?
    let success: GoogleScheduleListSuccessDTO?
}

struct GoogleScheduleListSuccessDTO: Decodable {
    let events: [GoogleCalendarEventDTO]
}

/// Swagger: events[] 항목은 id, summary, start{}, end{} 또는 id, title. Google API 스타일 start/end는 { dateTime } 또는 { date }.
struct GoogleCalendarEventDTO: Decodable {
    var externalEventId: String { id }
    var title: String { summary ?? titleValue ?? "" }
    var startAt: String { startObj?.dateTime ?? startObj?.date ?? "" }
    var endAt: String { endObj?.dateTime ?? endObj?.date ?? "" }
    var allDay: Bool { startObj?.date != nil }
    var recurrence: String? { recurrenceRule }
    
    let id: String
    let summary: String?
    let titleValue: String?
    let startObj: GoogleCalendarTime?
    let endObj: GoogleCalendarTime?
    let recurrenceRule: String?
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        summary = try c.decodeIfPresent(String.self, forKey: .summary)
        titleValue = try c.decodeIfPresent(String.self, forKey: .titleValue)
        startObj = try c.decodeIfPresent(GoogleCalendarTime.self, forKey: .startObj)
        endObj = try c.decodeIfPresent(GoogleCalendarTime.self, forKey: .endObj)
        recurrenceRule = try c.decodeIfPresent(String.self, forKey: .recurrenceRule)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case summary
        case titleValue = "title"
        case startObj = "start"
        case endObj = "end"
        case recurrenceRule = "recurrence"
    }
}

struct GoogleCalendarTime: Decodable {
    let dateTime: String?
    let date: String?
}

// MARK: - 월간 캘린더 조회 (GET /api/calendar/month) — API 확정 후 필드 수정 예정
struct MonthlyCalendarResponse: Decodable {
    let resultType: String
    let error: ErrorDTO?
    let success: MonthlyCalendarSuccessDTO?
}

struct MonthlyCalendarSuccessDTO: Decodable {
    let year: Int
    let month: Int
    let days: [CalendarDayDTO]
}

struct CalendarDayDTO: Decodable {
    let date: String
    let hasItems: Bool
    let itemCount: Int
    let schedulesPreview: [SchedulePreviewDTO]
}

struct SchedulePreviewDTO: Decodable {
    /// 서버에서 숫자로 내려줌 (월간 API)
    let itemId: Int
    let title: String
    let isFixed: Bool
    /// 반복 일정 여부. 없으면 false
    let isRepeating: Bool
    let type: String
    /// 색상 (1~10). 프론트에서 EventColorType으로 매핑
    let color: Int?

    init(itemId: Int, title: String, isFixed: Bool, isRepeating: Bool = false, type: String, color: Int?) {
        self.itemId = itemId
        self.title = title
        self.isFixed = isFixed
        self.isRepeating = isRepeating
        self.type = type
        self.color = color
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        itemId = try c.decode(Int.self, forKey: .itemId)
        title = try c.decode(String.self, forKey: .title)
        isFixed = try c.decode(Bool.self, forKey: .isFixed)
        isRepeating = try c.decodeIfPresent(Bool.self, forKey: .isRepeating) ?? false
        type = try c.decode(String.self, forKey: .type)
        color = try c.decodeIfPresent(Int.self, forKey: .color)
    }

    private enum CodingKeys: String, CodingKey {
        case itemId, title, isFixed, isRepeating, type, color
    }
}

// MARK: - 일간 캘린더 조회 — API 확정 후 필드 수정 예정
struct DailyCalendarResponse: Decodable {
    let resultType: String
    let error: ErrorDTO?
    let success: DailyCalendarSuccessDTO?
}

struct DailyCalendarSuccessDTO: Decodable {
    let date: String
    let items: [CalendarItemDTO]
}

struct CalendarItemDTO: Decodable {
    /// 서버에서 숫자로 내려줌 (일간 API)
    let itemId: Int
    let type: String
    let title: String
    /// 일간 API: 날짜+시간(ISO8601). 서버 필드명은 startAt/endAt일 수 있음.
    let startDateTime: String?
    let endDateTime: String?
    /// startDateTime/endDateTime 없을 때 사용: 해당 날짜의 시:분 ("HH:mm")
    let startTime: String?
    let endTime: String?
    let completed: Bool?

    enum CodingKeys: String, CodingKey {
        case itemId, type, title, startTime, endTime, completed
        case startDateTime = "startAt"
        case endDateTime = "endAt"
    }
}
