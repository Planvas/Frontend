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

// MARK: - 구글 캘린더 일정 동기화
struct GoogleScheduleSyncResponse: Decodable {
    let resultType: String
    let error: ErrorDTO?
    let success: GoogleScheduleSyncSuccess?
}

struct GoogleScheduleSyncSuccess: Decodable {
    let synced: Bool
    let syncedCount: Int
}

// MARK: - 구글 캘린더 가져올 일정 목록 조회
struct GoogleScheduleListResponse: Decodable {
    let resultType: String
    let error: ErrorDTO?
    let success: GoogleScheduleListSuccessDTO?
}

struct GoogleScheduleListSuccessDTO: Decodable {
    let events: [GoogleCalendarEventDTO]
}

struct GoogleCalendarEventDTO: Decodable {
    let externalEventId: String
    let title: String
    let startAt: String
    let endAt: String
    let allDay: Bool
    let recurrence: String?
}

// MARK: - 월간 캘린더 조회
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
}

// MARK: - 일간 캘린더 조회
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
    let itemId: String
    let type: String
    let title: String
    let startTime: String
    let endTime: String
    let completed: Bool
}
