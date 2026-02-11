//
//  CalendarRepository.swift
//  Planvas
//
//  Created by 백지은 on 1/22/26.
//

import Foundation

/// Calendar 관련 데이터를 관리하는 repo
protocol CalendarRepositoryProtocol {
    /// 월간 캘린더 조회 (GET /api/calendar/month) - 해당 월 날짜별 메타·프리뷰만 반환
    func getMonthCalendar(year: Int, month: Int) async throws -> MonthlyCalendarSuccessDTO

    /// 특정 날짜의 일정 목록을 가져옵니다 (GET /api/calendar/day) - 날짜 클릭 시 호출
    func getEvents(for date: Date) async throws -> [Event]
    
    /// 특정 날짜 범위의 이벤트 목록을 가져옵니다 (여러 일간 조회용)
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
    /// API 미연동 메서드 (추가/수정/삭제 등 완성 후 재연결용)
    case notImplemented(message: String)
}

/// TODO : 현재는 샘플 데이터를 사용 (프리뷰용 활동/고정 일정 포함)
final class CalendarRepository: CalendarRepositoryProtocol {
    private static let cal = Calendar.current

    /// 날짜만 (00:00) 또는 날짜+시간. 시간 있는 일정은 startDateTime/endDateTime처럼 시·분 반영.
    private static func date(_ y: Int, _ m: Int, _ d: Int, hour: Int? = nil, minute: Int? = nil) -> Date {
        var comps = DateComponents(year: y, month: m, day: d)
        if let h = hour { comps.hour = h }
        if let mn = minute { comps.minute = mn }
        return cal.date(from: comps) ?? Date()
    }

    /// 프리뷰용: 이벤트를 한 번만 정의한 뒤 날짜 구간에 맞춰 배치 (멀티데이 중복 없음).
    private lazy var sampleEvents: [String: [Event]] = Self.buildPreviewSampleEvents()

    private static func buildPreviewSampleEvents() -> [String: [Event]] {
        let calendar = Calendar.current
        func date(_ y: Int, _ m: Int, _ d: Int, hour: Int? = nil, minute: Int? = nil) -> Date {
            var c = DateComponents(year: y, month: m, day: d)
            if let h = hour { c.hour = h }
            if let mn = minute { c.minute = mn }
            return calendar.date(from: c) ?? Date()
        }

        // 이벤트 한 번만 생성 (멀티데이/반복도 인스턴스 하나)
        let event1 = Event(title: "이벤트", isFixed: true, isAllDay: true, color: .purple1, type: .fixed, startDate: date(2026, 1, 2), endDate: date(2026, 1, 2))
        let cafeAlba = Event(title: "카페 알바", isFixed: true, isAllDay: false, color: .red, type: .fixed, startDate: date(2026, 1, 13), endDate: date(2026, 1, 13), startTime: Time(hour: 18, minute: 0), endTime: Time(hour: 22, minute: 0), isRepeating: true, repeatOption: .weekly, repeatEndDate: date(2026, 2, 28))
        let momBirthday = Event(title: "엄마생신", isFixed: true, isAllDay: true, color: .purple2, type: .fixed, startDate: date(2026, 1, 13), endDate: date(2026, 1, 13))
        let seminar = Event(title: "패스트캠퍼스 AI 세미나", isAllDay: false, color: .purple2, type: .activity, startDate: date(2026, 1, 13), endDate: date(2026, 1, 13), startTime: Time(hour: 14, minute: 0), endTime: Time(hour: 17, minute: 0), category: .growth, activityPoint: 30)
        let vietnam = Event(title: "베트남 여행", isFixed: true, isAllDay: true, color: .blue1, type: .fixed, startDate: date(2026, 1, 15), endDate: date(2026, 1, 16))
        let yoga = Event(title: "요가 클래스", isFixed: true, isAllDay: false, color: .green, type: .fixed, startDate: date(2026, 1, 15), endDate: date(2026, 1, 15), startTime: Time(hour: 10, minute: 0), endTime: Time(hour: 11, minute: 0), category: .rest, activityPoint: 20)
        let club = Event(title: "동아리송별", isFixed: true, isAllDay: true, color: .blue3, type: .fixed, startDate: date(2026, 1, 18), endDate: date(2026, 1, 18))
        let samsung = Event(title: "삼성전자 대학생 프로그래밍 경진대회", isAllDay: false, color: .purple2, type: .activity, startDate: date(2026, 1, 18), endDate: date(2026, 1, 20), startTime: Time(hour: 9, minute: 0), endTime: Time(hour: 18, minute: 0), category: .growth, activityPoint: 30)
        let eventPink = Event(title: "이벤트", isFixed: true, isAllDay: true, color: .pink, type: .fixed, startDate: date(2026, 1, 20), endDate: date(2026, 1, 20))

        let allEvents = [event1, cafeAlba, momBirthday, seminar, vietnam, yoga, club, samsung, eventPink]
        var result: [String: [Event]] = [:]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        for event in allEvents {
            var current = calendar.startOfDay(for: event.startDate)
            let endDay = calendar.startOfDay(for: event.endDate)
            while current <= endDay {
                let key = formatter.string(from: current)
                if result[key] == nil { result[key] = [] }
                result[key]?.append(event)
                guard let next = calendar.date(byAdding: .day, value: 1, to: current) else { break }
                current = next
            }
        }
        // 반복 일정: 매주 수요일(1/13 기준) 1월 내 추가
        for day in [20, 27] {
            let key = String(format: "2026-01-%02d", day)
            if result[key] == nil { result[key] = [] }
            if result[key]?.contains(where: { $0.id == cafeAlba.id }) == false {
                result[key]?.append(cafeAlba)
            }
        }
        return result
    }
    
    private func dateKeyString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    func getMonthCalendar(year: Int, month: Int) async throws -> MonthlyCalendarSuccessDTO {
        let range = Calendar.current.range(of: .day, in: .month, for: Calendar.current.date(from: DateComponents(year: year, month: month)) ?? Date())!
        let days = range.map { day -> CalendarDayDTO in
            let dateStr = String(format: "%04d-%02d-%02d", year, month, day)
            let hasKey = sampleEvents[dateStr] != nil
            let list = sampleEvents[dateStr] ?? []
            return CalendarDayDTO(
                date: dateStr,
                hasItems: hasKey,
                itemCount: list.count,
                schedulesPreview: list.prefix(3).map { CalendarRepository.preview(from: $0, itemId: abs($0.id.hashValue) % 1_000_000) }
            )
        }
        return MonthlyCalendarSuccessDTO(year: year, month: month, days: days)
    }

    private static func preview(from event: Event, itemId: Int) -> SchedulePreviewDTO {
        SchedulePreviewDTO(itemId: itemId, title: event.title, isFixed: event.isFixed, isRepeating: event.isRepeating, type: "MANUAL", color: event.color.serverColor)
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
