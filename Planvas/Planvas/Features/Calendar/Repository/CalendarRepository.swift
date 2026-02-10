//
//  CalendarRepository.swift
//  Planvas
//
//  Created by 백지은 on 1/22/26.
//

import Foundation

/// Calendar 관련 데이터를 관리하는 repo
protocol CalendarRepositoryProtocol {
    /// 특정 날짜의 이벤트 목록을 가져옵니다
    func getEvents(for date: Date) async throws -> [Event]
    
    /// 특정 날짜 범위의 이벤트 목록을 가져옵니다
    func getEvents(from startDate: Date, to endDate: Date) async throws -> [Event]
    
    /// 이벤트를 추가합니다
    func addEvent(_ event: Event) async throws
    
    /// 이벤트를 업데이트합니다
    func updateEvent(_ event: Event) async throws
    
    /// 이벤트를 삭제합니다
    func deleteEvent(_ event: Event) async throws
    
    /// ImportableSchedule 목록을 가져옵니다 (구글 캘린더 가져올 일정 목록)
    func getImportableSchedules() async throws -> [ImportableSchedule]
    
    /// 선택 일정 동기화 (서버에 반영 후 캘린더에서 조회)
    func importSchedules(_ schedules: [ImportableSchedule]) async throws
    
    /// 구글 캘린더 연동 상태 조회
    func getGoogleCalendarStatus() async throws -> GoogleCalendarStatus
    
    /// 구글 캘린더 연동 (serverAuthCode 전달)
    func connectGoogleCalendar(code: String) async throws
}

enum CalendarRepositoryError: Error {
    case missingServerId(message: String)
}

/// TODO : 현재는 샘플 데이터를 사용
final class CalendarRepository: CalendarRepositoryProtocol {
    // 샘플 데이터 (API 연동 전까지)
    private var sampleEvents: [String: [Event]] = [
        "2026-01-02": [
            Event(title: "이벤트", time: "하루종일", color: .purple1)
        ],
        "2026-01-13": [
            Event(title: "카페 알바", time: "매주 수요일 18:00 - 22:00", isFixed: true, color: .red),
            Event(title: "엄마생신", time: "하루종일", isAllDay: true, color: .purple2)
        ],
        "2026-01-15": [
            Event(title: "베트남 여행", time: "하루종일", color: .blue1)
        ],
        "2026-01-16": [
            Event(title: "베트남 여행", time: "10:00 - 20:00", color: .blue2)
        ],
        "2026-01-18": [
            Event(title: "동아리송별", time: "하루종일", color: .blue3)
        ],
        "2026-01-20": [
            Event(title: "이벤트", time: "하루종일", isFixed: true, color: .pink)
        ]
    ]
    
    private func dateKeyString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    func getEvents(for date: Date) async throws -> [Event] {
        // TODO : API 연동 시 이 부분을 네트워크 호출로 변경
        let dateKey = dateKeyString(from: date)
        return sampleEvents[dateKey] ?? []
    }
    
    func getEvents(from startDate: Date, to endDate: Date) async throws -> [Event] {
        // TODO : API 연동 시 이 부분을 네트워크 호출로 변경
        var allEvents: [Event] = []
        var currentDate = startDate
        let calendar = Calendar.current
        
        while currentDate <= endDate {
            let events = try await getEvents(for: currentDate)
            allEvents.append(contentsOf: events)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDate
        }
        
        return allEvents
    }
    
    func addEvent(_ event: Event) async throws {
        // TODO : API 연동 시 이 부분을 네트워크 호출로 변경
        // 현재는 샘플 데이터에 추가만
    }
    
    func updateEvent(_ event: Event) async throws {
        // TODO : API 연동 시 이 부분을 네트워크 호출로 변경
    }
    
    func deleteEvent(_ event: Event) async throws {
        // TODO : API 연동 시 이 부분을 네트워크 호출로 변경
    }
    
    func getImportableSchedules() async throws -> [ImportableSchedule] {
        // TODO : API 연동 시 이 부분을 네트워크 호출로 변경
        let cal = Calendar.current
        func date(_ y: Int, _ m: Int, _ d: Int, hour: Int? = nil) -> Date {
            var c = DateComponents()
            c.year = y; c.month = m; c.day = d
            if let h = hour { c.hour = h; c.minute = 0 }
            return cal.date(from: c) ?? Date()
        }
        return [
            ImportableSchedule(id: "sample-1", title: "편의점 알바", timeDescription: "매주 수요일 18:00 - 22:00", startDate: date(2026, 2, 4, hour: 18), endDate: date(2026, 2, 4, hour: 22), isSelected: true),
            ImportableSchedule(id: "sample-2", title: "컴퓨터활용능력 학원", timeDescription: "매주 목요일 9:00 - 13:00", startDate: date(2026, 2, 5, hour: 9), endDate: date(2026, 2, 5, hour: 13), isSelected: false),
            ImportableSchedule(id: "sample-3", title: "헬스장 PT", timeDescription: "매주 토요일 17:00 - 18:00", startDate: date(2026, 2, 7, hour: 17), endDate: date(2026, 2, 7, hour: 18), isSelected: false),
            ImportableSchedule(id: "sample-4", title: "아빠 생신", timeDescription: "2026년 2월 7일", startDate: date(2026, 2, 7), endDate: date(2026, 2, 7), isSelected: true),
            ImportableSchedule(id: "sample-5", title: "겨울 국내 여행", timeDescription: "2/15 - 2/18", startDate: date(2026, 2, 15), endDate: date(2026, 2, 18), isSelected: true),
            ImportableSchedule(id: "sample-6", title: "개강 전 친구 모임", timeDescription: "2026년 2월 25일", startDate: date(2026, 2, 25), endDate: date(2026, 2, 25), isSelected: false)
        ]
    }
    
    func importSchedules(_ schedules: [ImportableSchedule]) async throws {
        // 샘플 모드: 로컬 반영 없음 (API 연동 시 CalendarAPIRepository 사용)
    }

    func getGoogleCalendarStatus() async throws -> GoogleCalendarStatus {
        GoogleCalendarStatus(connected: false, connectedAt: nil, lastSyncedAt: nil)
    }

    func connectGoogleCalendar(code: String) async throws {
        // 샘플 모드에서는 무시 (API 연동 시 CalendarAPIRepository 사용)
    }
}
