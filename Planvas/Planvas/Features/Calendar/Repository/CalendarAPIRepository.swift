//
//  CalendarAPIRepository.swift
//  Planvas
//
//  Created by 백지은 on 2/5/26.
//
//  Repository: NetworkService(DTO) → 도메인 매핑. ViewModel은 네트워크를 모름.
//

import Foundation

/// API 기반 캘린더 Repository (CalendarNetworkService 사용)
final class CalendarAPIRepository: CalendarRepositoryProtocol {
    private let networkService: CalendarNetworkService
    private let calendar = Calendar.current

    init(networkService: CalendarNetworkService = CalendarNetworkService()) {
        self.networkService = networkService
    }

    /// 특정 날짜의 일정 목록 조회 (GET /api/calendar/day → Event 배열)
    func getEvents(for date: Date) async throws -> [Event] {
        let dateKey = dateKeyString(from: date)
        let dayDTO = try await networkService.getDayCalendar(date: dateKey)
        return dayDTO.items.map { mapToEvent(item: $0, date: dayDTO.date) }
    }

    /// 날짜 범위 내 모든 일정 조회 (구간 내 날짜별 getDay 호출 후 합침)
    func getEvents(from startDate: Date, to endDate: Date) async throws -> [Event] {
        var allEvents: [Event] = []
        var current = calendar.startOfDay(for: startDate)
        let endDay = calendar.startOfDay(for: endDate)
        while current <= endDay {
            let events = try await getEvents(for: current)
            allEvents.append(contentsOf: events)
            guard let next = calendar.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }
        return allEvents
    }

    /// 일정 추가 (현재 API 명세 없음, 추후 연동 시 구현)
    func addEvent(_ event: Event) async throws {
        // 명세에 없음: 로컬/다른 API 연동 시 구현
    }

    /// 일정 수정 (현재 API 명세 없음, 추후 연동 시 구현)
    func updateEvent(_ event: Event) async throws {
        // 명세에 없음
    }

    /// 일정 삭제 (현재 API 명세 없음, 추후 연동 시 구현)
    func deleteEvent(_ event: Event) async throws {
        // 명세에 없음
    }

    /// 구글 캘린더에서 가져올 수 있는 일정 목록 (GET events → ImportableSchedule, 일정 선택 화면용)
    func getImportableSchedules() async throws -> [ImportableSchedule] {
        let events = try await networkService.getGoogleCalendarEvents(timeMin: nil, timeMax: nil)
        return events.map { mapToImportableSchedule($0) }
    }

    /// 선택 일정 서버 동기화 (POST sync 호출, 가져오기 확정 시)
    func importSchedules(_ schedules: [ImportableSchedule]) async throws {
        _ = try await networkService.syncGoogleCalendar()
    }

    /// 구글 캘린더 연동 여부·연동일·마지막 동기화 시각 (GET status → 도메인 모델)
    func getGoogleCalendarStatus() async throws -> GoogleCalendarStatus {
        let dto = try await networkService.getGoogleCalendarStatus()
        return GoogleCalendarStatus(
            connected: dto.connected,
            connectedAt: parseISO8601(dto.connectedAt),
            lastSyncedAt: parseISO8601(dto.lastSyncedAt)
        )
    }

    /// 구글 캘린더 연동 (로그인 후 받은 serverAuthCode로 POST connect 호출)
    func connectGoogleCalendar(code: String) async throws {
        try await networkService.connectGoogleCalendar(code: code)
    }

    // MARK: - DTO → 도메인 매핑

    /// ISO8601 문자열 → Date (연동일·마지막 동기화일 파싱)
    private func parseISO8601(_ string: String?) -> Date? {
        guard let string = string else { return nil }
        let full = ISO8601DateFormatter()
        full.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = full.date(from: string) { return d }
        let fallback = ISO8601DateFormatter()
        fallback.formatOptions = [.withInternetDateTime]
        return fallback.date(from: string)
    }

    /// 구글 일정 DTO → 가져오기 선택용 ImportableSchedule
    private func mapToImportableSchedule(_ dto: GoogleCalendarEventDTO) -> ImportableSchedule {
        let start = parseISO8601Date(dto.startAt) ?? Date()
        let end = parseISO8601Date(dto.endAt) ?? Date()
        let timeDesc = buildTimeDescription(allDay: dto.allDay, start: start, end: end, recurrence: dto.recurrence)
        let id = UUID(uuidString: dto.externalEventId) ?? UUID()
        return ImportableSchedule(
            id: id,
            title: dto.title,
            timeDescription: timeDesc,
            startDate: start,
            endDate: end,
            isSelected: false
        )
    }

    /// 일간 일정 DTO → 캘린더 표시용 Event (날짜+시간 조합)
    private func mapToEvent(item: CalendarItemDTO, date: String) -> Event {
        let (startDate, endDate) = parseDayTime(date: date, startTime: item.startTime, endTime: item.endTime)
        let timeString = item.startTime.isEmpty && item.endTime.isEmpty
            ? "하루종일"
            : "\(item.startTime) - \(item.endTime)"
        let id = UUID(uuidString: item.itemId) ?? UUID()
        return Event(
            id: id,
            title: item.title,
            time: timeString,
            isFixed: item.type == "FIXED_SCHEDULE",
            isAllDay: item.startTime.isEmpty && item.endTime.isEmpty,
            color: .red,
            startDate: startDate,
            endDate: endDate,
            category: .none,
            isCompleted: item.completed,
            isRepeating: false
        )
    }

    /// 종일/시간형·반복 여부에 따라 표시용 시간 문자열 생성 (예: "09:00 - 18:00", "M/d - M/d (반복)")
    private func buildTimeDescription(allDay: Bool, start: Date, end: Date, recurrence: String?) -> String {
        if allDay {
            let f = DateFormatter()
            f.dateFormat = "M/d"
            f.locale = Locale(identifier: "ko_KR")
            if Calendar.current.isDate(start, inSameDayAs: end) {
                return f.string(from: start)
            }
            return "\(f.string(from: start)) - \(f.string(from: end))"
        }
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        let startStr = f.string(from: start)
        let endStr = f.string(from: end)
        if let r = recurrence, !r.isEmpty { return "\(startStr) - \(endStr) (반복)" }
        return "\(startStr) - \(endStr)"
    }

    /// ISO8601 날짜 문자열 파싱 (startAt/endAt 등)
    private func parseISO8601Date(_ string: String) -> Date? {
        let full = ISO8601DateFormatter()
        full.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = full.date(from: string) { return d }
        let fallback = ISO8601DateFormatter()
        fallback.formatOptions = [.withInternetDateTime]
        return fallback.date(from: string)
    }

    /// "yyyy-MM-dd" + "HH:mm" 조합으로 해당 날짜의 시작/종료 Date 생성 (종일이면 00:00~다음날 00:00)
    private func parseDayTime(date: String, startTime: String, endTime: String) -> (Date, Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")

        let day = dateFormatter.date(from: date) ?? Date()
        if startTime.isEmpty && endTime.isEmpty {
            let start = calendar.startOfDay(for: day)
            let end = calendar.date(byAdding: .day, value: 1, to: start) ?? start
            return (start, end)
        }
        let start = combine(date: day, time: startTime, formatter: timeFormatter) ?? day
        let end = combine(date: day, time: endTime, formatter: timeFormatter) ?? day
        return (start, end)
    }

    /// 날짜에 시:분 적용해 하나의 Date 반환
    private func combine(date: Date, time: String, formatter: DateFormatter) -> Date? {
        guard let t = formatter.date(from: time) else { return nil }
        let comps = calendar.dateComponents([.hour, .minute], from: t)
        return calendar.date(bySettingHour: comps.hour ?? 0, minute: comps.minute ?? 0, second: 0, of: date)
    }

    /// Date → "yyyy-MM-dd" (API 쿼리/키용)
    private func dateKeyString(from date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
}
