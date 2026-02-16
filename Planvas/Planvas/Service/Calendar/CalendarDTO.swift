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

// MARK: - 월간 캘린더 조회 (GET /api/calendar/month)
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
    let moreCount: Int?
}

/// api.md 기준: itemId는 String, 색상 필드명은 eventColor
struct SchedulePreviewDTO: Decodable {
    let itemId: String
    let title: String
    let isFixed: Bool
    let type: String
    let category: String?
    let eventColor: Int?
    let recurrenceRule: String?

    /// 프리뷰용 수동 생성 init
    init(itemId: String, title: String, isFixed: Bool, type: String, category: String? = nil, eventColor: Int? = nil, recurrenceRule: String? = nil) {
        self.itemId = itemId
        self.title = title
        self.isFixed = isFixed
        self.type = type
        self.category = category
        self.eventColor = eventColor
        self.recurrenceRule = recurrenceRule
    }
}

// MARK: - 일간 캘린더 조회 (GET /api/calendar/day)
struct DailyCalendarResponse: Decodable {
    let resultType: String
    let error: ErrorDTO?
    let success: DailyCalendarSuccessDTO?
}

struct DailyCalendarSuccessDTO: Decodable {
    let date: String
    let todayTodos: [CalendarItemDTO]
}

/// api.md 기준: itemId String, startAt/endAt ISO, isFixed, eventColor, recurrenceRule, category, status
struct CalendarItemDTO: Decodable {
    let itemId: String
    let title: String
    let startAt: String?
    let endAt: String?
    let isFixed: Bool?
    let type: String
    let category: String?
    let eventColor: Int?
    let recurrenceRule: String?
    let status: String?  // "TODO" | "DONE"
}

// MARK: - 일정 추가 (POST /api/calendar/event)
struct CreateEventRequestDTO: Encodable {
    let title: String
    let startAt: String   // ISO 8601 (e.g. "2026-02-12T18:10:00+09:00")
    let endAt: String
    let type: String      // "FIXED" (직접 추가·고정 일정) | "ACTIVITY" (활동 일정)
    let category: String  // "GROWTH" | "REST"
    let eventColor: Int   // 1~10
    let recurrenceRule: String?
    let recurrenceEndAt: String?  // "yyyy-MM-dd", 반복 일정인 경우 필수
}

struct CreateEventResponse: Decodable {
    let resultType: String
    let error: ErrorDTO?
    let success: CreateEventSuccess?
}

struct CreateEventSuccess: Decodable {
    let id: Int
    let title: String
    let startAt: String?
    let endAt: String?
    let type: String?
    let status: String?
}

// MARK: - 일정 수정 (PATCH /api/calendar/event/{id})
struct UpdateEventRequestDTO: Encodable {
    let title: String
    let startAt: String
    let endAt: String
    let type: String
    let category: String
    let eventColor: Int
    let recurrenceRule: String?
}

struct UpdateEventResponse: Decodable {
    let resultType: String
    let error: ErrorDTO?
    let success: UpdateEventSuccess?
}

struct UpdateEventSuccess: Decodable {
    let id: Int?
    let title: String?
    let startAt: String?
    let endAt: String?
    let type: String?
}

// MARK: - 일정 삭제 (DELETE /api/calendar/event/{id})
struct DeleteEventResponse: Decodable {
    let resultType: String
    let error: ErrorDTO?
    let success: DeleteEventSuccess?
}

struct DeleteEventSuccess: Decodable {
    let message: String
}
