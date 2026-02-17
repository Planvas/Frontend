//
//  CalendarRepository.swift
//  Planvas
//
//  Created by 백지은 on 1/22/26.
//

import Foundation
import CryptoKit

/// Calendar 관련 데이터를 관리하는 repo
protocol CalendarRepositoryProtocol {
    /// 월간 캘린더 조회 (GET /api/calendar/month) - 해당 월 날짜별 메타·프리뷰만 반환
    func getMonthCalendar(year: Int, month: Int) async throws -> MonthlyCalendarSuccessDTO

    /// 특정 날짜의 일정 목록을 가져옵니다 (GET /api/calendar/day) - 날짜 클릭 시 호출
    func getEvents(for date: Date) async throws -> [Event]

    /// 일정 id로 단건 상세 조회 (GET /api/calendar/event/{id}) - 그리드·상세/수정 시 최신 정보용
    func getEventDetail(id: Int) async throws -> Event

    /// 월간 프리뷰(schedulesPreview) + 해당 날짜로 그리드용 Event 생성. 상세 조회 없이 단일일 표시용.
    func eventFromPreview(_ preview: SchedulePreviewDTO, date: String) -> Event

    /// 특정 날짜 범위의 이벤트 목록을 가져옵니다 (여러 일간 조회용)
    func getEvents(from startDate: Date, to endDate: Date) async throws -> [Event]
    
    /// 이벤트를 추가합니다. 성공 시 생성된 일정 id(서버 itemId) 반환.
    func addEvent(_ event: Event) async throws -> Int
    
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

/// API 미연동 시 사용하는 Mock. 월/일 조회는 빈 데이터 반환.
final class CalendarRepository: CalendarRepositoryProtocol {
    private static let cal = Calendar.current

    func getMonthCalendar(year: Int, month: Int) async throws -> MonthlyCalendarSuccessDTO {
        let range = Calendar.current.range(of: .day, in: .month, for: Calendar.current.date(from: DateComponents(year: year, month: month)) ?? Date())!
        let days = range.map { day -> CalendarDayDTO in
            let dateStr = String(format: "%04d-%02d-%02d", year, month, day)
            return CalendarDayDTO(
                date: dateStr,
                hasItems: false,
                itemCount: 0,
                schedulesPreview: [],
                moreCount: 0
            )
        }
        return MonthlyCalendarSuccessDTO(year: year, month: month, days: days)
    }

    func getEvents(for date: Date) async throws -> [Event] {
        []
    }

    func getEventDetail(id: Int) async throws -> Event {
        throw CalendarRepositoryError.notImplemented(message: "Mock에는 일정 데이터가 없습니다.")
    }

    func eventFromPreview(_ preview: SchedulePreviewDTO, date: String) -> Event {
        let day = Self.dateOnlyFormatter.date(from: date) ?? Self.cal.startOfDay(for: Date())
        let startDay = Self.cal.startOfDay(for: day)
        let color: EventColorType = preview.eventColor.map { EventColorType.from(serverColor: $0) }
            ?? (preview.isFixed ? .purple1 : .purple2)
        let category: EventCategory = {
            switch preview.category?.uppercased() {
            case "GROWTH": return .growth
            case "REST": return .rest
            default: return .none
            }
        }()
        let eventType: EventType = (preview.type == "ACTIVITY") ? .activity : .fixed
        let id = Self.stableUUID(from: "\(preview.type)-\(preview.itemId)-\(date)")
        let serverIdInt = Int(preview.itemId)
        let isRepeating = (preview.recurrenceRule != nil && !(preview.recurrenceRule?.isEmpty ?? true))
        return Event(
            id: id,
            title: preview.title,
            isFixed: preview.isFixed,
            isAllDay: true,
            color: color,
            type: eventType,
            startDate: startDay,
            endDate: startDay,
            startTime: .midnight,
            endTime: .endOfDay,
            category: category,
            isCompleted: false,
            isRepeating: isRepeating,
            repeatOption: nil,
            fixedScheduleId: preview.isFixed ? serverIdInt : nil,
            myActivityId: preview.isFixed ? nil : serverIdInt,
            repeatWeekdays: nil,
            activityPoint: eventType == .activity ? 20 : nil
        )
    }

    private static let dateOnlyFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    private static func stableUUID(from string: String) -> UUID {
        var data = Data()
        data.append(contentsOf: string.utf8)
        let hash = Insecure.SHA1.hash(data: data)
        var bytes = Array(Array(hash).prefix(16))
        bytes[6] = (bytes[6] & 0x0F) | 0x50
        bytes[8] = (bytes[8] & 0x3F) | 0x80
        return UUID(uuid: (bytes[0], bytes[1], bytes[2], bytes[3], bytes[4], bytes[5], bytes[6], bytes[7], bytes[8], bytes[9], bytes[10], bytes[11], bytes[12], bytes[13], bytes[14], bytes[15]))
    }

    func getEvents(from startDate: Date, to endDate: Date) async throws -> [Event] {
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
    
    func addEvent(_ event: Event) async throws -> Int {
        0
    }

    func updateEvent(_ event: Event) async throws {
        // Mock: 무시
    }

    func deleteEvent(_ event: Event) async throws {
        // Mock: 무시
    }
    
    func getImportableSchedules() async throws -> [ImportableSchedule] {
        []
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
